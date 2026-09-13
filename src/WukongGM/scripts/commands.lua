--[[
  commands.lua — reads the user's command file and exposes named presets.

  The command file is plain text, one command per line. Blank lines and lines
  beginning with # are ignored, so users can keep a commented library of
  commands and enable them by uncommenting.

  Encoding matters: the file must be ASCII or UTF-8 *without* a BOM. Notepad's
  default "UTF-8" writes a BOM, and the three leading bytes end up as part of
  the first command, which then silently does nothing. Clean() strips it
  anyway, but it is worth knowing.
]]

local M = {}

--- Searched in order; first readable file wins.
M.SEARCH_PATHS = {
    "ue4ss/Mods/WukongGM/commands.txt",
    "gm_command.txt",
}

---@param s string
---@return string
local function Clean(s)
    s = s:gsub("^\239\187\191", "")   -- UTF-8 BOM
    s = s:gsub("[^\32-\126]", "")     -- control characters, stray unicode
    s = s:gsub("^%s+", ""):gsub("%s+$", "")
    return s
end

--- Read and parse the command file.
---@return string[] commands
---@return string|nil path the file that was read
function M.Load()
    for _, path in ipairs(M.SEARCH_PATHS) do
        local file = io.open(path, "r")
        if file then
            local commands = {}
            for line in file:lines() do
                local cleaned = Clean(line)
                if cleaned ~= "" and cleaned:sub(1, 1) ~= "#" then
                    table.insert(commands, cleaned)
                end
            end
            file:close()
            return commands, path
        end
    end
    return {}, nil
end

--- Single-key presets. Each is a list so multi-step actions stay atomic.
M.presets = {
    unlock_all = {
        "allitem",
        "alltaskitem",
        "allattritem",
        "allrecipe",
        "allweapon",
        "allequip",
        "allspell",
        "allhulu",
        "allseeds",
    },
    max_progress = {
        "alltalent",
        "allsoulskill",
        "allmap",
        "allmedition 1",
    },
    rich = {
        "additem 1002 1000000",   -- Will
        "addtalentpoint 100",
    },
}

--- Commands that are destructive enough to require an explicit opt-in.
--- clearrolebag sets the character to level 0 and empties bag, talents and
--- spells. It is never bound to a key.
M.dangerous = {
    ["clearrolebag"]  = true,
    ["clearitem"]     = true,
    ["clearcard"]     = true,
    ["gmclearlegacy"] = true,
    ["clearshopdata"] = true,
    ["clearmeditation"] = true,
    ["clearinterfunc"] = true,
}

---@param command string
---@return boolean
function M.IsDangerous(command)
    local verb = command:match("^(%S+)")
    return verb ~= nil and M.dangerous[verb:lower()] == true
end

return M
