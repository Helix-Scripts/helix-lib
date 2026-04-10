--- helix_lib module loader
--- Loaded via shared_script — runs on BOTH client and server before all other scripts.
--- Sets up a require() override so that shared modules (shared/*.lua) can be loaded
--- identically on both sides using standard require('shared.constants') syntax.
---
--- Why: FiveM's files({}) only registers modules for client-side require().
--- Server-side Lua ignores files({}) entirely. This loader uses LoadResourceFile
--- (works on both sides) + load() to make require() universal.

local resourceName = GetCurrentResourceName()
local moduleCache = {}

--- Load a module from the resource using LoadResourceFile + load()
---@param modPath string Dot-separated module path (e.g. 'shared.constants')
---@return any module The module's return value
local function loadModule(modPath)
    -- Check cache first
    if moduleCache[modPath] then
        return moduleCache[modPath]
    end

    -- Convert dot path to file path: shared.bridge.qbox -> shared/bridge/qbox.lua
    local filePath = modPath:gsub('%.', '/') .. '.lua'

    local content = LoadResourceFile(resourceName, filePath)
    if not content then
        error(("helix_lib: module '%s' not found (tried %s)"):format(modPath, filePath), 2)
    end

    local fn, err = load(content, ('@%s/%s'):format(resourceName, filePath))
    if not fn then
        error(("helix_lib: failed to compile '%s': %s"):format(modPath, err), 2)
    end

    local ok, result = pcall(fn)
    if not ok then
        error(("helix_lib: failed to execute '%s': %s"):format(modPath, result), 2)
    end

    -- Cache the result (nil returns are stored as true to mark "loaded")
    moduleCache[modPath] = result or true
    return moduleCache[modPath]
end

-- Override require for helix_lib module paths, defer everything else to the original
local _require = require

---@diagnostic disable-next-line: lowercase-global
require = function(modPath)
    if
        type(modPath) == 'string'
        and (modPath:find('^shared%.') or modPath:find('^server%.') or modPath:find('^client%.'))
    then
        return loadModule(modPath)
    end
    return _require(modPath)
end
