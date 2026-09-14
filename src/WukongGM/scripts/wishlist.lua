--[[
  wishlist.lua - pick items by name instead of by id.

  items.txt lists every known item with a quantity. Set a number next to what
  you want, save, press F7:

      Refined Iron Sand    = 0      ->    Refined Iron Sand    = 50

  Anything left at 0 is skipped. Names are matched case-insensitively and
  ignoring spaces and punctuation, so "gold tree core" and "Gold Tree Core"
  both work.

  This exists because editing "additem 3961 50" means knowing that 3961 is
  Gold Tree Core. The file removes that step.
]]

local items = require("items")

local M = {}

M.PATH = "ue4ss/Mods/WukongGM/items.txt"

--- Normalise a name for matching: lowercase, letters and digits only.
---@param s string
---@return string
local function Key(s)
    return (s:lower():gsub("[^%a%d]", ""))
end

--- name key -> id, built once from the item database.
local lookup = nil
local function Lookup()
    if lookup then return lookup end
    lookup = {}
    for id, entry in pairs(items.known) do
        lookup[Key(entry.name)] = id
    end
    return lookup
end

--- Read items.txt and turn every non-zero line into an additem command.
---@return string[] commands
---@return integer skipped how many named items were not recognised
---@return string[] unknown the unrecognised names
function M.Load()
    local file = io.open(M.PATH, "r")
    if not file then return {}, 0, {} end

    local map = Lookup()
    local out, unknown = {}, {}

    for line in file:lines() do
        local cleaned = line:gsub("^\239\187\191", ""):gsub("[^\32-\126]", "")
        if cleaned:match("^%s*#") == nil and cleaned:match("%S") then
            local name, qty = cleaned:match("^%s*(.-)%s*=%s*(%-?%d+)%s*$")
            if name and qty then
                local n = tonumber(qty)
                if n and n > 0 then
                    local id = map[Key(name)]
                    if id then
                        table.insert(out, string.format("additem %d %d", id, n))
                    else
                        table.insert(unknown, name)
                    end
                end
            end
        end
    end
    file:close()
    return out, #unknown, unknown
end

return M
