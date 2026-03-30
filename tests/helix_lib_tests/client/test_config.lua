--- Client-side Config module tests

local S = TestRunner.suite('Config (Client)')
local A = TestRunner.assert

TestRunner.test(S, 'Config module is accessible via export', function()
    local cfg = exports.helix_lib:config()
    A.notNil(cfg, 'Config export should not be nil')
end)

TestRunner.test(S, 'Config.load() returns table', function()
    local cfg = exports.helix_lib:config()
    local data = cfg.load(GetCurrentResourceName())
    A.isType(data, 'table', 'Config.load should return a table')
end)

TestRunner.test(S, 'Config.load() reads correct values on client', function()
    local cfg = exports.helix_lib:config()
    local data = cfg.load(GetCurrentResourceName())
    A.equals('hello_helix', data.testString, 'testString mismatch')
    A.equals(42, data.testNumber, 'testNumber mismatch')
    A.equals(true, data.testBool, 'testBool mismatch')
end)

TestRunner.test(S, 'Config.load() handles nested tables on client', function()
    local cfg = exports.helix_lib:config()
    local data = cfg.load(GetCurrentResourceName())
    A.isType(data.nested, 'table', 'nested should be a table')
    A.equals('found_it', data.nested.deep.value, 'nested deep value mismatch')
    A.equals(3, #data.nested.array, 'nested array length mismatch')
end)

TestRunner.test(S, 'Config.get() returns cached config on client', function()
    local cfg = exports.helix_lib:config()
    cfg.load(GetCurrentResourceName())
    local cached = cfg.get(GetCurrentResourceName())
    A.notNil(cached, 'Cached config should not be nil')
    A.equals('hello_helix', cached.testString, 'Cached value mismatch')
end)

TestRunner.test(S, 'Config.merge() works on client', function()
    local cfg = exports.helix_lib:config()
    local result = cfg.merge({ x = 1 }, { x = 2, y = 3 })
    A.equals(2, result.x, 'Override should win')
    A.equals(3, result.y, 'New key should appear')
end)
