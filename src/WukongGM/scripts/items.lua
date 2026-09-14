--[[
  items.lua — known item IDs.

  Ids are grouped in blocks by category, which makes probing for unknown ones
  much cheaper: find one item in a block and its neighbours are the same kind.

      1xxx  currency, formulas        2xxx  medicine, soak ingredients
      3xxx  herbs, curios, materials  6xxx  seeds

  `verified = true` means confirmed in game by this project. Everything else
  is community-reported and unconfirmed here — a wrong id grants the wrong
  item, which is harmless but confusing, so check before trusting one.

  Add an id with:  additem <id> <count>
]]

local M = {}

--- id -> { name, category, verified }
M.known = {}

--- category id -> display label
M.categories = {}

local function add(category, label, entries)
    M.categories[category] = label
    for _, e in ipairs(entries) do
        M.known[e[1]] = { name = e[2], category = category, verified = e[3] == true }
    end
end

add("currency", "Currency", {
    { 1002, "Will", true },
})

add("formulas", "Formulas", {
    { 1113, "Ascension Powder Formula" },
    { 1144, "Evil Repelling Medicament Formula" },
    { 1166, "Enhanced Ginseng Pellets Formula" },
    { 1168, "Enhanced Tiger Subduing Pellets Formula" },
})

add("drink", "Wine and brewing", {
    { 1998, "Awaken Wine Worm" },
    { 1999, "Luojia Fragrant Vine" },
    { 2001, "Coconut Wine" },
    { 2012, "Loong Balm" },
})

add("medicine", "Medicine and pellets", {
    { 2204, "Body-Warming Powder" },
    { 2205, "Antimiasma Powder" },
    { 2206, "Shock-Quelling Powder" },
    { 2211, "Life-Saving Pill" },
    { 2213, "Ascension Powder" },
    { 2221, "Tonifying Enhancing Medicine" },
    { 2224, "Amplification Pellets" },
    { 2227, "Tiger Subduing Pellets" },
    { 2230, "Longevity Enhancing Medicine" },
    { 2234, "Fortifying Medicament" },
    { 2247, "Evil Repelling Medicament" },
    { 2251, "Enhanced Ginseng Pellets" },
    { 2253, "Enhanced Tiger Subduing Pellets" },
    { 2402, "Incense Trail Talisman" },
})

add("soak", "Soak ingredients", {
    { 2305, "Mount Lingtai Seedlings" },
    { 2310, "Laurel Buds" },
    { 2313, "Deathstinger" },
    { 2314, "Purple-Veined Peach Pit" },
    { 2315, "Bee Mountain Stone" },
    { 2319, "Goji Shoots" },
    { 2320, "Fruit of Dao" },
    { 2323, "Gall Gem" },
})

add("herbs", "Herbs and ores", {
    { 3201, "Licorice" },
    { 3202, "Aged Ginseng" },
    { 3203, "Fragrant Jade Flower" },
    { 3204, "Purple Lingzhi" },
    { 3205, "Fire Bellflower" },
    { 3206, "Gentian" },
    { 3207, "Tree Pearl" },
    { 3208, "Celestial Pear" },
    { 3209, "Withered Silkworm" },
    { 3214, "Nine-Capped Lingzhi" },
    { 3215, "Flame Ore" },
    { 3216, "Jade Lotus" },
    { 3217, "Snake-Head Mushroom" },
    { 3219, "Golden Lotus" },
})

add("curios", "Curios and valuables", {
    { 3003, "Mind Core" },
    { 3301, "Tadpole" },
    { 3302, "Gold Ridge Beast" },
    { 3305, "Buddha's Right Hand" },
    { 3306, "Tiny Piece of Gold" },
    { 3307, "Small Piece of Gold" },
    { 3308, "Large Piece of Gold" },
    { 3309, "Blood of the Iron Bull" },
    { 3310, "Knot of Voidness" },
})

add("materials", "Crafting materials", {
    { 3594, "Celestial Ribbon" },
    { 3901, "Jade Fang" },
    { 3902, "Flame Ebongold" },
    { 3906, "Spider Leg" },
    { 3916, "Starlit Cloud-Bidden Antler" },
    { 3921, "Loong Pearl" },
    { 3925, "Sky-Piercing Horn" },
    { 3929, "Venomous Hair" },
    { 3950, "Yarn" },
    { 3951, "Silk" },
    { 3952, "Cold Iron Leaves" },
    { 3953, "Fine Gold Thread" },
    { 3958, "Stone Spirit" },
    { 3959, "Yaoguai Core" },
    { 3960, "Refined Iron Sand" },
    { 3961, "Gold Tree Core" },
    { 3962, "Kun Steel" },
})

add("seeds", "Seeds", {
    { 6002, "Nine-Capped Lingzhi Seed" },
    { 6004, "Fragrant Jade Flower Seed" },
    { 6005, "Fire Bellflower Seed" },
})

---@param id integer
---@return string|nil
function M.NameOf(id)
    local e = M.known[id]
    return e and e.name or nil
end

---@return integer count
function M.Count()
    local n = 0
    for _ in pairs(M.known) do n = n + 1 end
    return n
end

--- Every id in a category, sorted.
---@param category string
---@return integer[]
function M.InCategory(category)
    local out = {}
    for id, e in pairs(M.known) do
        if e.category == category then table.insert(out, id) end
    end
    table.sort(out)
    return out
end

--- Commands to probe an unmapped id range. Whatever you end up holding 500 of
--- is that id.
---@param first integer
---@param last integer
---@param count integer|nil
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
