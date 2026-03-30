--- Server-side Config module tests

local S = TestRunner.suite('Config (Server)')
local A = TestRunner.assert

TestRunner.test(S, 'Config.load() returns table from config.lua', function()
    local cfg = exports.helix_lib:config()
    local data = cfg.load(GetCurrentResourceName())
    A.isType(data, 'table', 'Config.load should return a table')
end)

TestRunner.test(S, 'Config.load() reads correct values', function()
    local cfg = exports.helix_lib:config()
    local data = cfg.load(GetCurrentResourceName())
    A.equals('hello_helix', data.testString, 'testString mismatch')
    A.equals(42, data.testNumber, 'testNumber mismatch')
    A.equals(true, data.testBool, 'testBool mismatch')
end)

TestRunner.test(S, 'Config.load() handles nested tables', function()
    local cfg = exports.helix_lib:config()
    local data = cfg.load(GetCurrentResourceName())
    A.isType(data.nested, 'table', 'nested should be a table')
    A.isType(data.nested.deep, 'table', 'nested.deep should be a table')
    A.equals('found_it', data.nested.deep.value, 'nested.deep.value mismatch')
    A.isType(data.nested.array, 'table', 'nested.array should be a table')
    A.equals(3, #data.nested.array, 'nested.array should have 3 elements')
end)

TestRunner.test(S, 'Config.get() returns cached config', function()
    local cfg = exports.helix_lib:config()
    -- load first to populate cache
    cfg.load(GetCurrentResourceName())
    local cached = cfg.get(GetCurrentResourceName())
    A.notNil(cached, 'Config.get should return cached config')
    A.equals('hello_helix', cached.testString, 'Cached value mismatch')
end)

TestRunner.test(S, 'Config.get() returns nil for unknown resource', function()
    local cfg = exports.helix_lib:config()
    local result = cfg.get('nonexistent_resource_xyz')
    A.isNil(result, 'Config.get should return nil for unknown resource')
end)

TestRunner.test(S, 'Config.merge() deep-merges tables', function()
    local cfg = exports.helix_lib:config()
    local base = { a = 1, b = { c = 2, d = 3 } }
    local override = { b = { c = 99 }, e = 'new' }
    local merged = cfg.merge(base, override)
    A.isType(merged, 'table', 'merge should return a table')
    A.equals(1, merged.a, 'base value should persist')
    A.equals(99, merged.b.c, 'override should win')
    A.equals(3, merged.b.d, 'non-overridden nested value should persist')
    A.equals('new', merged.e, 'new key should appear')
end)

TestRunner.test(S, 'Config.reload() triggers onReload callback', function()
    local cfg = exports.helix_lib:config()
    local resName = GetCurrentResourceName()
    local reloaded = false

    cfg.onReload(resName, function(newConfig)
        reloaded = true
    end)

    cfg.reload(resName)
    -- Give a tick for the callback to fire
    Citizen.Wait(0)
    A.isTrue(reloaded, 'onReload callback should have fired')
end)
