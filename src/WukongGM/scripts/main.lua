--[[
  WukongGM — run Black Myth: Wukong's own GM commands from UE4SS.

  https://github.com/<your-handle>/WukongGM

  Works by calling the game's RunScriptGM UFunction directly, so it does not
  need the in-game console, a C# loader, or any version-specific offsets.

  Default keys (rebind in config.txt):
    F7  run every command in commands.txt
    F8  diagnostics — report what resolved
    F9  unlock-all preset
    F10 is left alone; UE4SS's ConsoleEnablerMod uses it
]]

local gm       = require("gm")
local commands = require("commands")
local items    = require("items")

local MOD_NAME    = "WukongGM"
local MOD_VERSION = "1.0.0"
local CONFIG_PATH = "ue4ss/Mods/WukongGM/config.txt"

local Log = gm.Log

--------------------------------------------------------------------------
-- config
--------------------------------------------------------------------------

local config = {
    key_run      = "F7",
    key_diagnose = "F8",
    key_unlock   = "F9",
    allow_dangerous = false,
}

--- Minimal key=value parser. Deliberately not JSON: users edit this by hand
--- in Notepad, and a stray comma should not brick the mod.
local function LoadConfig()
    local file = io.open(CONFIG_PATH, "r")
    if not file then return end
    for line in file:lines() do
        local key, value = line:match("^%s*([%w_]+)%s*=%s*(.-)%s*$")
        if key and value and value ~= "" and line:sub(1, 1) ~= "#" then
            if value == "true" or value == "false" then
                config[key] = (value == "true")
            else
                config[key] = value
            end
        end
    end
    file:close()
end

---@param name string
---@return integer|nil
local function KeyByName(name)
    if type(name) ~= "string" then return nil end
    return Key[name:upper()]
end

--------------------------------------------------------------------------
-- actions
--------------------------------------------------------------------------

local function RunCommandFile()
    local list, path = commands.Load()
    if not path then
        Log("no command file found — expected one of:")
        for _, p in ipairs(commands.SEARCH_PATHS) do Log("    " .. p) end
        return
    end
    if #list == 0 then
        Log("no commands in " .. path .. " (blank lines and # comments are skipped)")
        return
    end

    local filtered = {}
    for _, cmd in ipairs(list) do
        if commands.IsDangerous(cmd) and not config.allow_dangerous then
            Log("SKIPPED destructive command: " .. cmd)
            Log("  set allow_dangerous = true in config.txt if you really mean it")
        else
            table.insert(filtered, cmd)
        end
    end

    Log(string.format("running %d command(s) from %s", #filtered, path))
    local sent, total = gm.RunAll(filtered)
    Log(string.format("dispatched %d/%d — verify in game", sent, total))
end

---@param name string
local function RunPreset(name)
    local preset = commands.presets[name]
    if not preset then Log("unknown preset: " .. tostring(name)); return end
    Log("preset: " .. name)
    local sent, total = gm.RunAll(preset)
    Log(string.format("dispatched %d/%d — verify in game", sent, total))
end

--------------------------------------------------------------------------
-- startup
--------------------------------------------------------------------------

LoadConfig()

local bindings = {
    { key = config.key_run,      fn = RunCommandFile,                    label = "run commands.txt" },
    { key = config.key_diagnose, fn = gm.Diagnose,                       label = "diagnostics" },
    { key = config.key_unlock,   fn = function() RunPreset("unlock_all") end, label = "unlock-all preset" },
}

for _, b in ipairs(bindings) do
    local code = KeyByName(b.key)
    if code then
        RegisterKeyBind(code, b.fn)
        Log(string.format("%-4s %s", b.key, b.label))
    else
        Log("unknown key in config.txt: " .. tostring(b.key))
    end
end

-- A console command too, for anyone whose build does hook the console.
RegisterConsoleCommandHandler("wukonggm", function(_, params, Ar)
    local cmd = table.concat(params, " ")
    if cmd == "" then
        if Ar then Ar:Log("usage: wukonggm <gm command>") end
        return true
    end
    local ok, route = gm.Run(cmd)
    if Ar then Ar:Log(ok and ("sent via " .. route) or "failed") end
    return true
end)

Log(string.format("%s v%s loaded — %d known item id(s)", MOD_NAME, MOD_VERSION,
    (function() local n = 0; for _ in pairs(items.known) do n = n + 1 end; return n end)()))
