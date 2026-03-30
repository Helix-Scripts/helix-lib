--- Client-side Bridge module tests

local S = TestRunner.suite('Bridge (Client)')
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

TestRunner.test(S, 'Bridge.getFramework() returns correct value', function()
    local br = exports.helix_lib:bridge()
    A.equals(br.framework, br.getFramework(), 'getFramework() should match .framework')
end)

TestRunner.test(S, 'Bridge.is() works on client', function()
    local br = exports.helix_lib:bridge()
    A.isTrue(br.is(br.framework), 'Bridge.is(detected) should be true')
    local fake = br.framework == 'standalone' and 'qbox' or 'standalone'
    A.isFalse(br.is(fake), 'Bridge.is(wrong) should be false')
end)

TestRunner.test(S, 'Bridge.Notify() does not error on client', function()
    local br = exports.helix_lib:bridge()
    A.noError(function()
        br.Notify(nil, 'Test from client', 'info', 2000)
    end, 'Client Notify should not error')
end)

TestRunner.test(S, 'Bridge client API surface is present', function()
    local br = exports.helix_lib:bridge()
    A.isType(br.Notify, 'function', 'Notify should exist')
    A.isType(br.getFramework, 'function', 'getFramework should exist')
    A.isType(br.is, 'function', 'is should exist')
end)
