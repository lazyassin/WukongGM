--[[
  gm.lua - the bridge to Black Myth: Wukong's own GM command system.

  The game exposes its GM executor as a UFunction on a USharp function
  library. We resolve the class default object once and call through it, so
  nothing here depends on hardcoded offsets and it survives game patches.

      /Script/b1-Managed.Default__BGUFunctionLibraryManaged
          :RunScriptGM(GMCommand, WorldContext)

  Two fallbacks exist for builds where the managed library is absent.
]]

local M = {}

local LOG_PREFIX = "[WukongGM] "

--- Object paths, resolved lazily and cached until they go stale.
local MANAGED_CDO = "/Script/b1-Managed.Default__BGUFunctionLibraryManaged"
local CS_CDO      = "/Script/b1-Managed.Default__BGUFunctionLibraryCS"

--- Classes tried in order when looking for a live WorldContext.
local CONTEXT_CLASSES = {
    "BGP_PlayerControllerCS",
    "BGPPlayerController",
    "PlayerController",
}

local cache = { managed = nil, cs = nil, ctx = nil }

---@param msg string
function M.Log(msg)
    print(LOG_PREFIX .. tostring(msg) .. "\n")
end

---@param path string
---@return UObject|nil
local function FindObject(path)
    local ok, obj = pcall(StaticFindObject, path)
    if ok and obj and obj:IsValid() then return obj end
    return nil
end

---@return UObject|nil
function M.GetManagedLibrary()
    if cache.managed and cache.managed:IsValid() then return cache.managed end
    cache.managed = FindObject(MANAGED_CDO)
    return cache.managed
end

---@return UObject|nil
function M.GetCSLibrary()
    if cache.cs and cache.cs:IsValid() then return cache.cs end
    cache.cs = FindObject(CS_CDO)
    return cache.cs
end

--- Any live UObject in the loaded world works as a WorldContext. The player
--- controller is the most reliable one, and it only exists during gameplay -
--- calls made from the main menu will fail here, which is intended.
---@return UObject|nil
function M.GetWorldContext()
    if cache.ctx and cache.ctx:IsValid() then return cache.ctx end
    for _, class in ipairs(CONTEXT_CLASSES) do
        local ok, obj = pcall(FindFirstOf, class)
        if ok and obj and obj:IsValid() then
            cache.ctx = obj
            return obj
        end
    end
    return nil
end

--- Drop cached objects. Call after a level transition if lookups start failing.
function M.InvalidateCache()
    cache.managed, cache.cs, cache.ctx = nil, nil, nil
end

--- Execute one GM command.
---
--- A successful return means the call was *dispatched*, not that the game
--- acted on it - an unimplemented command returns cleanly and does nothing.
--- Always verify in game.
---@param command string
---@return boolean dispatched
---@return string|nil route which mechanism accepted the call
function M.Run(command)
    if type(command) ~= "string" or command == "" then
        return false, nil
    end

    local ctx = M.GetWorldContext()
    if not ctx then
        M.Log("no WorldContext - load into gameplay before running commands")
        return false, nil
    end

    local managed = M.GetManagedLibrary()
    if managed then
        local ok = pcall(function() managed:RunScriptGM(command, ctx) end)
        if ok then return true, "RunScriptGM" end
    end

    local cs = M.GetCSLibrary()
    if cs then
        local ok = pcall(function() cs:RunGMCommand(ctx, command, false) end)
        if ok then return true, "RunGMCommand" end
    end

    local ok = pcall(function() ctx:ConsoleCommandCS(command) end)
    if ok then return true, "ConsoleCommandCS" end

    return false, nil
end

--- Run a list of commands in order. Returns how many dispatched.
---@param commands string[]
---@return integer sent
---@return integer total
function M.RunAll(commands)
    local sent = 0
    for _, cmd in ipairs(commands) do
        local ok, route = M.Run(cmd)
        if ok then
            sent = sent + 1
            M.Log(string.format("  %s -> %s", cmd, route))
        else
            M.Log(string.format("  %s -> FAILED", cmd))
        end
    end
    return sent, #commands
end

--- Report what resolved. Useful when a user files a bug.
function M.Diagnose()
    M.Log("---- diagnostics ----")
    local managed = M.GetManagedLibrary()
    M.Log("managed library : " .. (managed and managed:GetFullName() or "NOT FOUND"))
    local cs = M.GetCSLibrary()
    M.Log("cs library      : " .. (cs and cs:GetFullName() or "NOT FOUND"))
    local ctx = M.GetWorldContext()
    M.Log("world context   : " .. (ctx and ctx:GetFullName() or "NOT FOUND (are you in gameplay?)"))
    M.Log("---------------------")
end

return M
