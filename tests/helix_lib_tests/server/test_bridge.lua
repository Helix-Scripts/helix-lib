--- Server-side Bridge module tests

local S = TestRunner.suite('Bridge (Server)')
local A = TestRunner.assert

TestRunner.test(S, 'Bridge module is accessible via export', function()
    local br = exports.helix_lib:bridge()
    A.notNil(br, 'Bridge export should not be nil')
end)

TestRunner.test(S, 'Bridge.framework is a string', function()
    local br = exports.helix_lib:bridge()
    A.isType(br.framework, 'string', 'framework should be a string')
    A.isTrue(#br.framework > 0, 'framework should not be empty')
end)

TestRunner.test(S, 'Bridge.getFramework() matches .framework', function()
    local br = exports.helix_lib:bridge()
    A.equals(br.framework, br.getFramework(), 'getFramework() should match .framework')
end)

TestRunner.test(S, 'Bridge.is() returns boolean', function()
    local br = exports.helix_lib:bridge()
    local result = br.is('standalone')
    A.isType(result, 'boolean', 'Bridge.is() should return boolean')
end)

TestRunner.test(S, 'Bridge.is() returns true for detected framework', function()
    local br = exports.helix_lib:bridge()
    A.isTrue(br.is(br.framework), 'Bridge.is(detected) should be true')
end)

TestRunner.test(S, 'Bridge.is() returns false for wrong framework', function()
    local br = exports.helix_lib:bridge()
    local fake = br.framework == 'standalone' and 'qbox' or 'standalone'
    A.isFalse(br.is(fake), 'Bridge.is(wrong) should be false')
end)

TestRunner.test(S, 'Bridge.GetPlayer() returns nil for invalid source', function()
    local br = exports.helix_lib:bridge()
    local player = br.GetPlayer(-1)
    A.isNil(player, 'GetPlayer(-1) should return nil')
end)

TestRunner.test(S, 'Bridge.Notify() does not error on server with valid args', function()
    local br = exports.helix_lib:bridge()
    A.noError(function()
        -- source -1 won't actually reach anyone but should not throw
        br.Notify(-1, 'Test notification', 'info', 3000)
    end, 'Bridge.Notify should not error')
end)

TestRunner.test(S, 'Bridge API surface is complete', function()
    local br = exports.helix_lib:bridge()
    A.isType(br.GetPlayer, 'function', 'GetPlayer should exist')
    A.isType(br.GetPlayerMoney, 'function', 'GetPlayerMoney should exist')
    A.isType(br.GetPlayerJob, 'function', 'GetPlayerJob should exist')
    A.isType(br.GetPlayerIdentifier, 'function', 'GetPlayerIdentifier should exist')
    A.isType(br.AddMoney, 'function', 'AddMoney should exist')
    A.isType(br.RemoveMoney, 'function', 'RemoveMoney should exist')
    A.isType(br.HasItem, 'function', 'HasItem should exist')
    A.isType(br.Notify, 'function', 'Notify should exist')
end)
