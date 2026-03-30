--- Server-side Bridge module tests

local S = TestRunner.suite('Bridge (Server)')
local A = TestRunner.assert

TestRunner.test(S, 'bridge_framework export returns a string', function()
    local fw = exports.helix_lib:bridge_framework()
    A.notNil(fw, 'bridge_framework should not return nil')
    A.isType(fw, 'string', 'framework should be a string')
    A.isTrue(#fw > 0, 'framework should not be empty')
end)

TestRunner.test(S, 'bridge_getFramework() matches bridge_framework()', function()
    local fw1 = exports.helix_lib:bridge_framework()
    local fw2 = exports.helix_lib:bridge_getFramework()
    A.equals(fw1, fw2, 'getFramework() should match framework()')
end)

TestRunner.test(S, 'bridge_is() returns boolean', function()
    local result = exports.helix_lib:bridge_is('standalone')
    A.isType(result, 'boolean', 'bridge_is() should return boolean')
end)

TestRunner.test(S, 'bridge_is() returns true for detected framework', function()
    local fw = exports.helix_lib:bridge_framework()
    A.isTrue(exports.helix_lib:bridge_is(fw), 'bridge_is(detected) should be true')
end)

TestRunner.test(S, 'bridge_is() returns false for wrong framework', function()
    local fw = exports.helix_lib:bridge_framework()
    local fake = fw == 'standalone' and 'qbox' or 'standalone'
    A.isFalse(exports.helix_lib:bridge_is(fake), 'bridge_is(wrong) should be false')
end)

TestRunner.test(S, 'bridge_GetPlayer() returns nil for invalid source', function()
    local player = exports.helix_lib:bridge_GetPlayer(-1)
    A.isNil(player, 'GetPlayer(-1) should return nil')
end)

TestRunner.test(S, 'bridge_Notify() does not error on server with valid args', function()
    A.noError(function()
        -- source -1 won't actually reach anyone but should not throw
        exports.helix_lib:bridge_Notify(-1, 'Test notification', 'info', 3000)
    end, 'bridge_Notify should not error')
end)

TestRunner.test(S, 'Bridge API surface is complete (flat exports)', function()
    A.isCallable(exports.helix_lib.bridge_GetPlayer, 'bridge_GetPlayer should be callable')
    A.isCallable(exports.helix_lib.bridge_GetPlayerMoney, 'bridge_GetPlayerMoney should be callable')
    A.isCallable(exports.helix_lib.bridge_GetPlayerJob, 'bridge_GetPlayerJob should be callable')
    A.isCallable(exports.helix_lib.bridge_GetPlayerIdentifier, 'bridge_GetPlayerIdentifier should be callable')
    A.isCallable(exports.helix_lib.bridge_AddMoney, 'bridge_AddMoney should be callable')
    A.isCallable(exports.helix_lib.bridge_RemoveMoney, 'bridge_RemoveMoney should be callable')
    A.isCallable(exports.helix_lib.bridge_HasItem, 'bridge_HasItem should be callable')
    A.isCallable(exports.helix_lib.bridge_Notify, 'bridge_Notify should be callable')
end)
