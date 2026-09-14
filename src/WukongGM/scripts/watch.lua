--[[
  watch.lua - runs commands written to live.txt, with no keypress.

  A companion console (tools/console.ps1) appends a command to live.txt; this
  picks it up, runs it, and truncates the file. The empty file is the
  "consumed" signal, so there is no state to keep in sync.

  Polling is driven by RegisterHook rather than a timer. This game's UE4SS
  build never invokes the callback passed to ExecuteInGameThreadWithDelay, so
  the original timer version never ticked once. RegisterHook installs a native
  hook and does work here - CheatManagerEnablerMod registers one successfully
  on the same build.

  A hooked function fires every frame, so file I/O is throttled: the hook only
  checks live.txt once every `throttle` invocations.
]]

local gm = require("gm")
local commands = require("commands")

local M = {}

local LIVE_PATH = "ue4ss/Mods/WukongGM/live.txt"

--- Tried in order; the first that registers wins. PlayerTick is per-frame and
--- always present on a player controller; the others are fallbacks.
local HOOK_CANDIDATES = {
    "/Script/Engine.PlayerController:PlayerTick",
    "/Script/Engine.Actor:ReceiveTick",
    "/Script/Engine.PlayerController:ServerUpdateCamera",
    "/Script/Engine.PlayerController:ClientRestart",
}

local running = false
local throttle = 60
local allowDangerous = false
local ticks = 0
local hookedTo = nil

--- UE4SS keeps a weak reference to callbacks; keep a hard one so Lua's GC
--- cannot collect them out from under the hook.
local pinned = {}
local function Pin(fn) pinned[fn] = true; return fn end

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
        local out = io.open(LIVE_PATH, "w")
        if out then out:close() end
    end
    return lines
end

--- Called from inside the hook. Must never throw: an error here would
--- propagate into a game function.
local function Poll()
    if not running then return end

    ticks = ticks + 1
    if ticks % throttle ~= 0 then return end

    local ok, err = pcall(function()
        local queued = ReadAndClear()
        for _, cmd in ipairs(queued) do
            if commands.IsDangerous(cmd) and not allowDangerous then
                Log("live: BLOCKED destructive command: " .. cmd)
            else
                local sent, route = gm.Run(cmd)
                Log(sent and ("live: " .. cmd .. " -> " .. route)
                         or  ("live: " .. cmd .. " -> FAILED"))
            end
        end
    end)
    if not ok then Log("watch: poll error: " .. tostring(err)) end
end

--- Collect the full names of every UFunction once, so we can check a hook
--- target exists before registering it.
---
--- This matters: RegisterHook on a name the game does not have raises an
--- error that pcall cannot contain - it tears down the whole Lua script, so
--- main.lua never finishes and the keybinds never register either.
---@return table<string, boolean>
local function FunctionNameSet()
    local set = {}
    if type(ForEachUObject) ~= "function" then return set end
    pcall(function()
        ForEachUObject(function(obj)
            local ok, name = pcall(function() return obj:GetFullName() end)
            if ok and name and name:sub(1, 9) == "Function " then
                set[name:sub(10)] = true
            end
        end)
    end)
    return set
end

--- Log some plausible per-frame hook targets the game does have, so a failure
--- here is actionable rather than a dead end.
---@param set table<string, boolean>
local function ReportTickCandidates(set)
    local found = {}
    for name in pairs(set) do
        if name:find("Tick") or name:find("DrawHUD") or name:find("UpdateCamera") then
            table.insert(found, name)
        end
    end
    table.sort(found)
    Log("watch: tick-like functions this build does have:")
    for i = 1, math.min(#found, 15) do Log("    " .. found[i]) end
    if #found > 15 then Log("    ... and " .. (#found - 15) .. " more") end
    if #found == 0 then Log("    none") end
end

--- Start watching. Returns false if no hook could be installed.
---@param opts { throttle: integer|nil, allowDangerous: boolean|nil }|nil
---@return boolean
function M.Start(opts)
    if running then return true end
    opts = opts or {}
    throttle = tonumber(opts.throttle) or 60
    if throttle < 1 then throttle = 1 end
    allowDangerous = opts.allowDangerous == true

    local probe = io.open(LIVE_PATH, "a")
    if probe then
        probe:close()
    else
        Log("watch: cannot open " .. LIVE_PATH)
        return false
    end

    local existing = FunctionNameSet()
    local callback = Pin(function() Poll() end)

    for _, target in ipairs(HOOK_CANDIDATES) do
        if existing[target] then
            local ok, err = pcall(function() RegisterHook(target, callback) end)
            if ok then
                hookedTo = target
                running = true
                Log(string.format("watch: hooked %s, checking every %d calls", target, throttle))
                return true
            end
            Log("watch: " .. target .. " exists but hook failed: " .. tostring(err))
        end
    end

    Log("watch: none of the candidate hook targets exist on this build")
    ReportTickCandidates(existing)
    return false
end

function M.Stop()
    running = false
    Log("watch: stopped")
end

---@return boolean
function M.IsRunning() return running end

---@return string|nil
function M.HookedTo() return hookedTo end

M.LIVE_PATH = LIVE_PATH

return M
