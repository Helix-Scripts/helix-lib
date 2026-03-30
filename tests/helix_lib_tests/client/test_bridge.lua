--- Client-side Bridge module tests

local S = TestRunner.suite('Bridge (Client)')
local A = TestRunner.assert

TestRunner.test(S, 'bridge_framework export returns a string', function()
    local fw = exports.helix_lib:bridge_framework()
    A.notNil(fw, 'bridge_framework should not return nil')
    A.isType(fw, 'string', 'framework should be a string')
    A.isTrue(#fw > 0, 'framework should not be empty')
end)

TestRunner.test(S, 'bridge_getFramework() returns correct value', function()
    local fw1 = exports.helix_lib:bridge_framework()
    local fw2 = exports.helix_lib:bridge_getFramework()
    A.equals(fw1, fw2, 'getFramework() should match framework()')
end)

TestRunner.test(S, 'bridge_is() works on client', function()
    local fw = exports.helix_lib:bridge_framework()
    A.isTrue(exports.helix_lib:bridge_is(fw), 'bridge_is(detected) should be true')
    local fake = fw == 'standalone' and 'qbox' or 'standalone'
    A.isFalse(exports.helix_lib:bridge_is(fake), 'bridge_is(wrong) should be false')
end)

TestRunner.test(S, 'bridge_Notify() does not error on client', function()
    A.noError(function()
        exports.helix_lib:bridge_Notify(nil, 'Test from client', 'info', 2000)
    end, 'Client Notify should not error')
end)

TestRunner.test(S, 'Bridge client API surface is present (flat exports)', function()
    A.isCallable(exports.helix_lib.bridge_Notify, 'bridge_Notify should be callable')
    A.isCallable(exports.helix_lib.bridge_getFramework, 'bridge_getFramework should be callable')
    A.isCallable(exports.helix_lib.bridge_is, 'bridge_is should be callable')
end)
