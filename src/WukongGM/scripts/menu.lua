--[[
  menu.lua - optional in-game overlay, built on ModMenu.

  ModMenu is optional. main.lua only calls into here if the library resolves,
  so the mod still works on a keybind-only install.

  Widget types used are the ones ModMenu actually implements:
  label, separator, dropdown, button, checkbox.
]]

local gm       = require("gm")
local items    = require("items")
local commands = require("commands")

local M = {}

local TAB_ITEMS   = "Items"
local TAB_UNLOCKS = "Unlocks"
local TAB_TOOLS   = "Tools"

local menuRef = nil

local state = {
    itemId = nil,
    amount = "1000",
    probeStart = "1020",
    allowDangerous = false,
}

local AMOUNTS = {
    { label = "1",         value = "1" },
    { label = "100",       value = "100" },
    { label = "1,000",     value = "1000" },
    { label = "10,000",    value = "10000" },
    { label = "100,000",   value = "100000" },
    { label = "1,000,000", value = "1000000" },
}

--- Blocks of ids to probe. Item ids cluster, so stepping in twelves finds
--- the edges of a block quickly.
local PROBE_STARTS = {}
for start = 1000, 1240, 20 do
    table.insert(PROBE_STARTS, { label = tostring(start) .. "-" .. tostring(start + 11), value = tostring(start) })
end

local function Log(msg) gm.Log(msg) end

--- Dropdown options for every verified item id.
local function ItemOptions()
    local opts = {}
    for id, entry in pairs(items.known) do
        table.insert(opts, { label = string.format("%s  (%d)", entry.name, id), value = tostring(id) })
    end
    table.sort(opts, function(a, b) return a.label < b.label end)
    if #opts == 0 then
        return { { label = "(no verified ids yet)", value = "__none__" } }
    end
    return opts
end

---@param command string
local function RunOne(command)
    if commands.IsDangerous(command) and not state.allowDangerous then
        Log("blocked: " .. command .. " - tick 'Allow destructive commands' first")
        return
    end
    local ok, route = gm.Run(command)
    Log(ok and (command .. " -> " .. route) or (command .. " -> FAILED"))
end

---@param list string[]
local function RunMany(list)
    local sent, total = gm.RunAll(list)
    Log(string.format("dispatched %d/%d - verify in game", sent, total))
end

--- Build a row of buttons from { label, command } pairs.
---@param defs table[]
---@return table[]
local function UnlockButtons(defs)
    local out = {}
    for _, d in ipairs(defs) do
        table.insert(out, {
            type = "button",
            id = "unlock_" .. d[2]:gsub("%s+", "_"),
            label = d[1],
            onClick = function() RunOne(d[2]) end,
        })
    end
    return out
end

---@param ModMenu table
function M.Register(ModMenu)
    menuRef = ModMenu

    -- Items -----------------------------------------------------------
    ModMenu.Register({
        id = "WukongGMItems",
        title = "Give items",
        tab = TAB_ITEMS,
        items = {
            { type = "label", label = "Only verified ids are listed. Unverified ids grant the wrong item silently." },
            { type = "separator" },
            {
                -- Deliberately not searchable. ModMenu's search box styles an
                -- EditableTextBox, and this game's build does not expose
                -- EditableTextBoxStyle.TextStyle, which throws while building
                -- the picker. Re-enable if that ever stops being true.
                type = "dropdown",
                id = "item",
                label = "Item",
                allowEmpty = true,
                options = ItemOptions(),
                default = state.itemId,
                onChange = function(v)
                    state.itemId = (v ~= "__none__") and v or nil
                end,
            },
            {
                type = "dropdown",
                id = "amount",
                label = "Amount",
                options = AMOUNTS,
                default = state.amount,
                onChange = function(v) state.amount = v or "1" end,
            },
            {
                type = "button",
                id = "give",
                label = "Give",
                onClick = function()
                    local id = state.itemId or (menuRef and menuRef.Get("WukongGMItems", "item"))
                    local amount = state.amount or "1"
                    if not id or id == "" or id == "__none__" then
                        Log("pick an item first")
                        return
                    end
                    RunOne(string.format("additem %s %s", id, amount))
                end,
            },
        },
    })

    -- Item id discovery ------------------------------------------------
    ModMenu.Register({
        id = "WukongGMProbe",
        title = "Find new item ids",
        tab = TAB_ITEMS,
        collapsible = true,
        collapsed = true,
        items = {
            { type = "label", label = "Adds 500 of each id in a block. Whatever you end up holding 500 of is that id." },
            {
                type = "dropdown",
                id = "probeStart",
                label = "Id block",
                options = PROBE_STARTS,
                default = state.probeStart,
                onChange = function(v) state.probeStart = v or "1020" end,
            },
            {
                type = "button",
                id = "probe",
                label = "Probe block",
                onClick = function()
                    local first = tonumber(state.probeStart) or 1020
                    Log("probing ids " .. first .. "-" .. (first + 11))
                    RunMany(items.ProbeRange(first, first + 11, 500))
                end,
            },
        },
    })

    -- Unlocks -----------------------------------------------------------
    local unlockItems = {
        { type = "label", label = "Each button runs one GM command." },
        { type = "separator" },
    }
    for _, widget in ipairs(UnlockButtons({
        { "All weapons",     "allweapon" },
        { "All equipment",   "allequip" },
        { "All spells",      "allspell" },
        { "All talents",     "alltalent" },
        { "All spirit skills", "allsoulskill" },
        { "All gourds",      "allhulu" },
        { "All materials",   "allitem" },
        { "All quest items", "alltaskitem" },
        { "All recipes",     "allrecipe" },
        { "All seeds",       "allseeds" },
        { "All map pieces",  "allmap" },
        { "All shrines",     "allmedition 1" },
        { "Full bestiary",   "allcard" },
    })) do
        table.insert(unlockItems, widget)
    end
    table.insert(unlockItems, { type = "separator" })
    table.insert(unlockItems, {
        type = "button",
        id = "unlock_everything",
        label = "Unlock everything",
        onClick = function()
            Log("running unlock_all preset")
            RunMany(commands.presets.unlock_all)
        end,
    })

    ModMenu.Register({
        id = "WukongGMUnlocks",
        title = "Bulk unlocks",
        tab = TAB_UNLOCKS,
        items = unlockItems,
    })

    -- Tools -------------------------------------------------------------
    ModMenu.Register({
        id = "WukongGMTools",
        title = "Tools",
        tab = TAB_TOOLS,
        items = {
            { type = "label", label = "Commands must be run while in gameplay, not at the main menu." },
            { type = "separator" },
            {
                type = "button",
                id = "runFile",
                label = "Run commands.txt",
                onClick = function()
                    local list, path = commands.Load()
                    if not path then Log("no command file found"); return end
                    Log(string.format("running %d command(s) from %s", #list, path))
                    RunMany(list)
                end,
            },
            {
                type = "button",
                id = "diagnose",
                label = "Diagnostics",
                onClick = function() gm.Diagnose() end,
            },
            {
                type = "button",
                id = "invalidate",
                label = "Re-resolve game objects",
                onClick = function()
                    gm.InvalidateCache()
                    Log("cache cleared - next command re-resolves")
                end,
            },
            { type = "separator" },
            {
                type = "checkbox",
                id = "allowDangerous",
                label = "Allow destructive commands (clearrolebag etc.)",
                default = state.allowDangerous,
                onChange = function(on)
                    state.allowDangerous = on and true or false
                    Log("destructive commands " .. (state.allowDangerous and "ENABLED" or "blocked"))
                end,
            },
            { type = "label", label = "clearrolebag sets you to level 0 and empties bag, talents and spells. No undo." },
        },
    })
end

M.TABS = { TAB_ITEMS, TAB_UNLOCKS, TAB_TOOLS }

return M
