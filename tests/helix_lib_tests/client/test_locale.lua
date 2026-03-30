--- Client-side Locale module tests

local S = TestRunner.suite('Locale (Client)')
local A = TestRunner.assert

TestRunner.test(S, 'Locale module is accessible via export', function()
    local loc = exports.helix_lib:locale()
    A.notNil(loc, 'Locale export should not be nil')
    A.isType(loc.t, 'function', 'Locale.t should be a function')
end)

TestRunner.test(S, 'Locale.loadFile() works on client', function()
    local loc = exports.helix_lib:locale()
    local ok = loc.loadFile('en', GetCurrentResourceName())
    A.isTrue(ok, 'loadFile should return true for en')
end)

TestRunner.test(S, 'Locale.t() translates on client', function()
    local loc = exports.helix_lib:locale()
    loc.loadFile('en', GetCurrentResourceName())
    loc.set('en')
    A.equals('This is a test.', loc.t('test_simple'), 'Translation mismatch')
    A.equals('Hello, Client!', loc.t('test_greeting', 'Client'), 'Formatted translation mismatch')
end)

TestRunner.test(S, 'Locale.set() and current() work on client', function()
    local loc = exports.helix_lib:locale()
    loc.set('en')
    A.equals('en', loc.current(), 'Should be en')
end)

TestRunner.test(S, 'Locale.has() works on client', function()
    local loc = exports.helix_lib:locale()
    loc.loadFile('en', GetCurrentResourceName())
    loc.loadFile('nl', GetCurrentResourceName())
    A.isTrue(loc.has('test_simple', 'en'), 'en should have test_simple')
    A.isTrue(loc.has('test_simple', 'nl'), 'nl should have test_simple')
    A.isFalse(loc.has('test_number', 'nl'), 'nl should NOT have test_number')
end)

TestRunner.test(S, 'Locale fallback works on client', function()
    local loc = exports.helix_lib:locale()
    loc.loadFile('en', GetCurrentResourceName())
    loc.loadFile('nl', GetCurrentResourceName())
    loc.set('nl')
    -- test_number is missing in nl, should fall back to en
    A.equals('You have 3 items.', loc.t('test_number', 3), 'Should fall back to English')
end)
