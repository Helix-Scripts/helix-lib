--- Client-side Locale module tests

local S = TestRunner.suite('Locale (Client)')
local A = TestRunner.assert

TestRunner.test(S, 'Locale flat exports are accessible', function()
    A.isCallable(exports.helix_lib.locale_t, 'locale_t should be callable')
end)

TestRunner.test(S, 'locale_loadFile() works on client', function()
    local ok = exports.helix_lib:locale_loadFile('en', GetCurrentResourceName())
    A.isTrue(ok, 'loadFile should return true for en')
end)

TestRunner.test(S, 'locale_t() translates on client', function()
    exports.helix_lib:locale_loadFile('en', GetCurrentResourceName())
    exports.helix_lib:locale_set('en')
    A.equals('This is a test.', exports.helix_lib:locale_t('test_simple'), 'Translation mismatch')
    A.equals('Hello, Client!', exports.helix_lib:locale_t('test_greeting', 'Client'), 'Formatted translation mismatch')
end)

TestRunner.test(S, 'locale_set() and locale_current() work on client', function()
    exports.helix_lib:locale_set('en')
    A.equals('en', exports.helix_lib:locale_current(), 'Should be en')
end)

TestRunner.test(S, 'locale_has() works on client', function()
    exports.helix_lib:locale_loadFile('en', GetCurrentResourceName())
    exports.helix_lib:locale_loadFile('nl', GetCurrentResourceName())
    A.isTrue(exports.helix_lib:locale_has('test_simple', 'en'), 'en should have test_simple')
    A.isTrue(exports.helix_lib:locale_has('test_simple', 'nl'), 'nl should have test_simple')
    A.isFalse(exports.helix_lib:locale_has('test_number', 'nl'), 'nl should NOT have test_number')
end)

TestRunner.test(S, 'Locale fallback works on client', function()
    exports.helix_lib:locale_loadFile('en', GetCurrentResourceName())
    exports.helix_lib:locale_loadFile('nl', GetCurrentResourceName())
    exports.helix_lib:locale_set('nl')
    -- test_number is missing in nl, should fall back to en
    A.equals('You have 3 items.', exports.helix_lib:locale_t('test_number', 3), 'Should fall back to English')
end)
