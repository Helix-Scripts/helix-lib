--- Server-side Utils tests

local S = TestRunner.suite('Utils (Server)')
local A = TestRunner.assert

-- Utils are typically require()'d internally; test via observable behavior

TestRunner.test(S, 'JSON encode/decode round-trip', function()
    local input = { key = 'value', num = 42, nested = { a = true } }
    local encoded = json.encode(input)
    A.isType(encoded, 'string', 'json.encode should return string')

    local decoded = json.decode(encoded)
    A.isType(decoded, 'table', 'json.decode should return table')
    A.equals('value', decoded.key, 'Round-trip key mismatch')
    A.equals(42, decoded.num, 'Round-trip num mismatch')
    A.equals(true, decoded.nested.a, 'Round-trip nested mismatch')
end)

TestRunner.test(S, 'json.decode handles nil/empty gracefully', function()
    A.noError(function()
        local result = json.decode('')
        -- Should return nil or empty table, not crash
    end, 'json.decode on empty string should not error')
end)

TestRunner.test(S, 'GetCurrentResourceName() works in test context', function()
    local name = GetCurrentResourceName()
    A.equals('helix_lib_tests', name, 'Resource name should be helix_lib_tests')
end)

TestRunner.test(S, 'Citizen.Wait is available', function()
    A.isType(Citizen.Wait, 'function', 'Citizen.Wait should be available')
end)

TestRunner.test(S, 'Citizen.CreateThread is available', function()
    A.isType(Citizen.CreateThread, 'function', 'Citizen.CreateThread should be available')
end)
