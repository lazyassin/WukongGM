--[[
  items.lua — known item IDs.

  Verified in game by adding a known quantity and watching the inventory.
  Unverified guesses are deliberately not listed; a wrong ID silently adds
  the wrong item, which is worse than no entry at all.

  To identify more, queue a block and see what you end up holding 500 of:

      additem 1020 500
      additem 1021 500
]]

local M = {}

--- id -> { name, note }
M.known = {
    [1002] = { name = "Will", note = "levelling and crafting currency" },
}

--- Ids confirmed to exist in the 1001-1012 block but not yet individually
--- mapped. Celestial Pill is somewhere in here.
M.unmapped_block = { 1001, 1003, 1004, 1005, 1006, 1007, 1008, 1009, 1010, 1011, 1012 }

---@param id integer
---@return string|nil
function M.NameOf(id)
    local entry = M.known[id]
    return entry and entry.name or nil
end

--- Build the commands needed to probe a range of ids.
---@param first integer
---@param last integer
---@param count integer|nil quantity per id, default 500
---@return string[]
function M.ProbeRange(first, last, count)
    count = count or 500
    local out = {}
    for id = first, last do
        table.insert(out, string.format("additem %d %d", id, count))
    end
    return out
end

return M
