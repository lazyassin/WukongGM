--[[
  watch.lua — executes commands written to a file, without a keypress.

  A companion console (tools/console.ps1) appends a command to live.txt; this
  poll loop picks it up within a tick, runs it, and truncates the file. The
  empty file is the "consumed" signal, so there is no state to keep in sync.

  This exists because the in-game overlay route needs UMG widgets, and this
  game's Slate structs differ enough from the ones ModMenu targets that the
  panel builds but never renders. Polling a file needs none of that — it is
  the same mechanism the keybind path already uses, minus the key.
]]

local gm = require("gm")
local commands = require("commands")

local M = {}

local LIVE_PATH = "ue4ss/Mods/WukongGM/live.txt"

local running = false
local intervalMs = 500
local allowDangerous = false
local tickFn = nil

--- UE4SS stores a weak reference to delayed callbacks. If Lua's GC collects
--- the closure, EngineTick throws "Ref was not function" and tears down the
--- whole tick hook, so keep a hard reference.
local pinned = {}
local function Pin(fn)
    pinned[fn] = true
    return fn
end

local function Log(msg) gm.Log(msg) end

---@return string[]
local function ReadAndClear()
    local file = io.open(LIVE_PATH, "r")
    if not file then return {} end

    local lines = {}
    for line in file:lines() do
        local cleaned = line:gsub("^\239\187\191", ""):gsub("[^\32-\126]", "")
        cleaned = cleaned:gsub("^%s+", ""):gsub("%s+$", "")
        if cleaned ~= "" and cleaned:sub(1, 1) ~= "#" then
            table.insert(lines, cleaned)
        end
    end
    file:close()

    if #lines > 0 then
        -- Truncate so the same command is not run twice.
        local out = io.open(LIVE_PATH, "w")
        if out then out:close() end
    end
    return lines
end

local function Tick()
    if not running then return end

    local queued = ReadAndClear()
    for _, cmd in ipairs(queued) do
        if commands.IsDangerous(cmd) and not allowDangerous then
            Log("live: BLOCKED destructive command: " .. cmd)
        else
            local ok, route = gm.Run(cmd)
            Log(ok and ("live: " .. cmd .. " -> " .. route)
                    or  ("live: " .. cmd .. " -> FAILED (in gameplay?)"))
        end
    end

    ExecuteInGameThreadWithDelay(intervalMs, tickFn)
end

--- Start polling. Creates live.txt if absent so the console has a target.
---@param opts { intervalMs: integer|nil, allowDangerous: boolean|nil }|nil
function M.Start(opts)
    if running then return end
    opts = opts or {}
    intervalMs = tonumber(opts.intervalMs) or 500
    allowDangerous = opts.allowDangerous == true

    local probe = io.open(LIVE_PATH, "a")
    if probe then
        probe:close()
    else
        Log("watch: cannot open " .. LIVE_PATH .. " — is the folder writable?")
        return
    end

    running = true
    tickFn = Pin(Tick)
    ExecuteInGameThreadWithDelay(intervalMs, tickFn)
    Log(string.format("watch: polling %s every %dms", LIVE_PATH, intervalMs))
end

function M.Stop()
    running = false
    Log("watch: stopped")
end

---@return boolean
function M.IsRunning()
    return running
end

M.LIVE_PATH = LIVE_PATH

return M
