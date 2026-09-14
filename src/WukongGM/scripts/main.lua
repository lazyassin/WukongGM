--[[
  WukongGM — run Black Myth: Wukong's own GM commands from UE4SS.

  https://github.com/lazyassin/WukongGM

  Works by calling the game's RunScriptGM UFunction directly, so it does not
  need the in-game console, a C# loader, or any version-specific offsets.

  Default keys (rebind in config.txt):
    F6  open the overlay, if ModMenu is installed
    F7  run every command in commands.txt
    F8  diagnostics — report what resolved
    F9  unlock-all preset
    F10 is left alone; UE4SS's ConsoleEnablerMod uses it
]]

local gm       = require("gm")
local commands = require("commands")
local items    = require("items")

local MOD_NAME    = "WukongGM"
local MOD_VERSION = "1.0.1"
local CONFIG_PATH = "ue4ss/Mods/WukongGM/config.txt"

local Log = gm.Log

--- Set once the overlay initialises, so diagnostics can query it.
local menuHandle = nil

--- Locate ModMenu's root widget by name. ModMenu names it
--- "ModMenu_Root_<tag>_<n>", and there is no public accessor for it.
---@return UObject|nil
local function FindOverlayRoot()
    if type(ForEachUObject) ~= "function" then return nil end
    -- Match the object's own name, not its path. Every descendant's full name
    -- contains its ancestors, so a substring test on the path matches slots
    -- and children seven levels down instead of the shell itself.
    local found = nil
    pcall(function()
        ForEachUObject(function(obj)
            if found then return end
            local ok, name = pcall(function() return obj:GetFullName() end)
            if not ok or not name then return end
            local leaf = name:match("([^%.]+)$")
            if leaf and leaf:find("^ModMenu_Root") then found = obj end
        end)
    end)
    return found
end

--- ModMenu adds its shell at VIEWPORT_Z_BASE = 1000, which this game's HUD
--- draws over. Re-add the same widget at a higher Z so it is actually
--- visible. Harmless if the panel was already on top.
---@param z integer
local function RaiseOverlay(z)
    local root = FindOverlayRoot()
    if not root then
        Log("overlay root widget not found — cannot raise Z")
        return
    end
    Log("overlay root: " .. root:GetFullName())
    local ok = pcall(function()
        root:RemoveFromParent()
        root:AddToViewport(z)
    end)
    Log(ok and ("overlay re-added at z=" .. z) or "overlay Z raise failed")
end

--- Report gm state plus, if the overlay loaded, what ModMenu thinks it is doing.
local function Diagnose()
    gm.Diagnose()
    if not menuHandle then
        Log("overlay: not loaded")
        return
    end
    local ok, open = pcall(menuHandle.IsOpen)
    Log("overlay IsOpen : " .. (ok and tostring(open) or "query failed"))
    local root = FindOverlayRoot()
    Log("overlay root   : " .. (root and root:GetFullName() or "NOT FOUND"))
    local okS, sections = pcall(menuHandle.ListSections)
    if okS and type(sections) == "table" then
        Log("overlay sections: " .. #sections .. " -> " .. table.concat(sections, ", "))
    else
        Log("overlay sections: query failed")
    end
end

--------------------------------------------------------------------------
-- config
--------------------------------------------------------------------------

local config = {
    key_menu     = "F6",
    key_run      = "F7",
    key_diagnose = "F8",
    key_unlock   = "F9",
    key_raise    = "F5",
    allow_dangerous = false,
    menu_enabled     = false,
    menu_font_scale  = "1.6",
    menu_debug       = false,
    menu_dock        = "left",
    menu_cursor_mode = "engine",
    menu_z           = "30000",
    watch_enabled     = false,
    watch_interval_ms = "500",
}

--- Minimal key=value parser. Deliberately not JSON: users edit this by hand
--- in Notepad, and a stray comma should not brick the mod.
local function LoadConfig()
    local file = io.open(CONFIG_PATH, "r")
    if not file then return end
    for line in file:lines() do
        if line:sub(1, 1) ~= "#" then
            local key, value = line:match("^%s*([%w_]+)%s*=%s*(.-)%s*$")
            if key and value and value ~= "" then
                if value == "true" or value == "false" then
                    config[key] = (value == "true")
                else
                    config[key] = value
                end
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
-- optional overlay
--------------------------------------------------------------------------

--- ModMenu ships alongside this mod but is not required. A keybind-only
--- install must keep working, so every failure here is non-fatal.
---@return boolean loaded
local function SetupMenu()
    if not config.menu_enabled then
        Log("overlay disabled in config.txt")
        return false
    end

    -- Must run before ModMenu is required: it calls UEHelpers.GetGameInstance,
    -- which UEHelpers v2 does not have.
    local compatOk, compat = pcall(require, "compat")
    if compatOk then pcall(compat.Apply, Log) end

    local ok, ModMenu = pcall(require, "ModMenu.ModMenu")
    if not ok or type(ModMenu) ~= "table" then
        Log("ModMenu not found — keybinds only")
        Log("  install it to Mods/shared/ModMenu/ModMenu.lua for the overlay")
        return false
    end

    local menuOk, menu = pcall(require, "menu")
    if not menuOk then
        Log("menu.lua failed to load: " .. tostring(menu))
        return false
    end

    -- ModMenu's own tracing. Open() bails silently when Build.Ensure fails,
    -- so this is the only way to see why a panel never appears.
    if config.menu_debug and type(ModMenu.SetDebug) == "function" then
        pcall(ModMenu.SetDebug, true)
        Log("ModMenu debug tracing on")
    end

    local initOk, err = pcall(function()
        ModMenu.Init({
            title      = "WukongGM",
            instanceId = "WukongGM",
            key        = KeyByName(config.key_menu) or Key.F6,
            keyHint    = config.key_menu,
            dock       = config.menu_dock or "left",
            ignoreLook = true,
            cursorMode = config.menu_cursor_mode or "engine",
            fontScale  = tonumber(config.menu_font_scale) or 1.6,
            tabs       = menu.TABS,
        })
        menu.Register(ModMenu)
    end)

    if not initOk then
        Log("overlay failed to initialise: " .. tostring(err))
        Log("  keybinds still work")
        return false
    end

    -- Open() can succeed while nothing appears on screen, so report state
    -- rather than trusting the absence of errors.
    menuHandle = ModMenu
    local raiseZ = tonumber(config.menu_z) or 30000
    pcall(function()
        ModMenu.OnOpen(function()
            Log("overlay OPEN event fired")
            if raiseZ > 0 then RaiseOverlay(raiseZ) end
        end)
    end)

    Log(string.format("%-4s overlay", config.key_menu))
    return true
end

--------------------------------------------------------------------------
-- startup
--------------------------------------------------------------------------

LoadConfig()

local bindings = {
    { key = config.key_run,      fn = RunCommandFile,                        label = "run commands.txt" },
    { key = config.key_diagnose, fn = Diagnose,                              label = "diagnostics" },
    { key = config.key_unlock,   fn = function() RunPreset("unlock_all") end, label = "unlock-all preset" },
    { key = config.key_raise,    fn = function() RaiseOverlay(tonumber(config.menu_z) or 30000) end, label = "raise overlay above game UI" },
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

local menuLoaded = SetupMenu()

-- File watcher: lets tools/console.ps1 drive the mod without a keypress.
local watchRunning = false
if config.watch_enabled then
    local wok, watch = pcall(require, "watch")
    if wok then
        pcall(watch.Start, {
            intervalMs = tonumber(config.watch_interval_ms) or 500,
            allowDangerous = config.allow_dangerous,
        })
        watchRunning = watch.IsRunning()
    else
        Log("watch.lua failed to load: " .. tostring(watch))
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

local knownIds = 0
for _ in pairs(items.known) do knownIds = knownIds + 1 end

Log(string.format("%s v%s loaded — %d known item id(s), overlay %s",
    MOD_NAME, MOD_VERSION, knownIds, menuLoaded and "on" or "off") .. ", watcher " .. (watchRunning and "on" or "off"))
