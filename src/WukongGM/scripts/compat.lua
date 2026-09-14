--[[
  compat.lua - smooths over differences between UE4SS builds.

  The UE4SS package commonly shipped for Black Myth: Wukong bundles UEHelpers
  version 2, which predates UEHelpers.GetGameInstance(). ModMenu calls it.

  Upgrading the user's UEHelpers to v3 is not an option: v3 uses the
  CreateInvalidObject() Lua global, which this UE4SS build does not expose, so
  it fails to parse at load and takes every mod that requires it down with it.

      UEHelpers.lua:35: attempt to call a nil value (global 'CreateInvalidObject')

  Instead we patch the loaded module table in place, before anything requires
  ModMenu. Lua caches modules in package.loaded, so ModMenu sees the patched
  table. Nothing on disk changes and other mods are unaffected.
]]

local M = {}

--- Add UEHelpers.GetGameInstance if this build's UEHelpers lacks it.
--- Mirrors the v3 implementation, minus the CreateInvalidObject sentinel.
---@return boolean patched
local function PatchUEHelpers()
    local ok, UEHelpers = pcall(require, "UEHelpers.UEHelpers")
    if not ok or type(UEHelpers) ~= "table" then return false end
    if type(UEHelpers.GetGameInstance) == "function" then return false end

    local cache = nil
    UEHelpers.GetGameInstance = function()
        if cache and cache:IsValid() then return cache end
        cache = FindFirstOf("GameInstance")
        return cache
    end
    return true
end

--- Apply every shim this build needs. Safe to call more than once.
---@param log fun(msg: string)
function M.Apply(log)
    if PatchUEHelpers() then
        log("compat: added UEHelpers.GetGameInstance (UEHelpers v2 detected)")
    end
end

return M
