--- Client-side Utils tests

local S = TestRunner.suite('Utils (Client)')
local A = TestRunner.assert

TestRunner.test(S, 'GetCurrentResourceName() works in client context', function()
    local name = GetCurrentResourceName()
    A.equals('helix_lib_tests', name, 'Resource name should be helix_lib_tests')
end)

TestRunner.test(S, 'Citizen.Wait is available on client', function()
    A.isType(Citizen.Wait, 'function', 'Citizen.Wait should be available')
end)

TestRunner.test(S, 'Citizen.CreateThread is available on client', function()
    A.isType(Citizen.CreateThread, 'function', 'Citizen.CreateThread should be available')
end)

TestRunner.test(S, 'PlayerPedId native is available', function()
    A.isType(PlayerPedId, 'function', 'PlayerPedId should be a function')
    local ped = PlayerPedId()
    A.isType(ped, 'number', 'PlayerPedId() should return a number')
end)

TestRunner.test(S, 'GetEntityCoords native works', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    A.notNil(coords, 'GetEntityCoords should return a value')
end)

TestRunner.test(S, 'JSON encode/decode round-trip on client', function()
    local input = { test = true, val = 123 }
    local encoded = json.encode(input)
    A.isType(encoded, 'string', 'json.encode should return string')
    local decoded = json.decode(encoded)
    A.equals(true, decoded.test, 'Round-trip test mismatch')
    A.equals(123, decoded.val, 'Round-trip val mismatch')
end)
