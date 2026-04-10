--- Server-side Locale module tests

local S = TestRunner.suite('Locale (Server)')
local A = TestRunner.assert

TestRunner.test(S, 'Locale flat exports are accessible', function()
    A.isCallable(exports.helix_lib.locale_t, 'locale_t export should be callable')
    A.isCallable(exports.helix_lib.locale_load, 'locale_load export should be callable')
    A.isCallable(exports.helix_lib.locale_set, 'locale_set export should be callable')
end)

TestRunner.test(S, 'locale_loadFile() loads English translations', function()
    local ok = exports.helix_lib:locale_loadFile('en', GetCurrentResourceName())
    A.isTrue(ok, 'loadFile should return true for en locale')
end)

TestRunner.test(S, 'locale_loadFile() loads Dutch translations', function()
    local ok = exports.helix_lib:locale_loadFile('nl', GetCurrentResourceName())
    A.isTrue(ok, 'loadFile should return true for nl locale')
end)

TestRunner.test(S, 'locale_set() + locale_current() work correctly', function()
    exports.helix_lib:locale_set('en')
    A.equals('en', exports.helix_lib:locale_current(), 'current() should return en')
    exports.helix_lib:locale_set('nl')
    A.equals('nl', exports.helix_lib:locale_current(), 'current() should return nl')
end)

TestRunner.test(S, 'locale_t() translates simple keys', function()
    exports.helix_lib:locale_loadFile('en', GetCurrentResourceName())
    exports.helix_lib:locale_set('en')
    A.equals('This is a test.', exports.helix_lib:locale_t('test_simple'), 'Simple translation mismatch')
end)

TestRunner.test(S, 'locale_t() handles string.format arguments', function()
    exports.helix_lib:locale_loadFile('en', GetCurrentResourceName())
    exports.helix_lib:locale_set('en')
    A.equals('Hello, World!', exports.helix_lib:locale_t('test_greeting', 'World'), 'Formatted translation mismatch')
end)

TestRunner.test(S, 'locale_t() handles numeric format arguments', function()
    exports.helix_lib:locale_set('en')
    A.equals('You have 5 items.', exports.helix_lib:locale_t('test_number', 5), 'Numeric format mismatch')
end)

TestRunner.test(S, 'locale_t() handles multiple format arguments', function()
    exports.helix_lib:locale_set('en')
    A.equals('Alice has 10 coins.', exports.helix_lib:locale_t('test_multi', 'Alice', 10), 'Multi-arg format mismatch')
end)

TestRunner.test(S, 'locale_t() falls back to English for missing keys', function()
    exports.helix_lib:locale_loadFile('en', GetCurrentResourceName())
    exports.helix_lib:locale_loadFile('nl', GetCurrentResourceName())
    exports.helix_lib:locale_set('nl')
    -- nl.lua intentionally omits test_number, should fall back to English
    local result = exports.helix_lib:locale_t('test_number', 7)
    A.equals('You have 7 items.', result, 'Should fall back to English for missing nl key')
end)

TestRunner.test(S, 'locale_t() translates Dutch when key exists', function()
    exports.helix_lib:locale_set('nl')
    A.equals('Dit is een test.', exports.helix_lib:locale_t('test_simple'), 'Dutch translation mismatch')
    A.equals(
        'Hallo, Axle!',
        exports.helix_lib:locale_t('test_greeting', 'Axle'),
        'Dutch formatted translation mismatch'
    )
end)

TestRunner.test(S, 'locale_has() checks key existence', function()
    A.isTrue(exports.helix_lib:locale_has('test_simple', 'en'), 'en should have test_simple')
    A.isTrue(exports.helix_lib:locale_has('test_simple', 'nl'), 'nl should have test_simple')
    A.isFalse(exports.helix_lib:locale_has('test_number', 'nl'), 'nl should NOT have test_number')
    A.isTrue(exports.helix_lib:locale_has('test_number', 'en'), 'en should have test_number')
end)
