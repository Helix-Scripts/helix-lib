--- Client-side Callback module tests

local S = TestRunner.suite('Callbacks (Client)')
local A = TestRunner.assert

TestRunner.test(S, 'callback_trigger export is accessible', function()
    A.isCallable(exports.helix_lib.callback_trigger, 'callback_trigger should be callable')
end)

TestRunner.test(S, 'callback_await export is accessible', function()
    A.isCallable(exports.helix_lib.callback_await, 'callback_await should be callable')
end)

TestRunner.test(S, 'callback_await() echo round-trip', function()
    local result = exports.helix_lib:callback_await('helix_lib_tests:echo', 'ping')
    A.notNil(result, 'Echo callback should return a result')
    A.isType(result, 'table', 'Echo result should be a table')
    A.equals('ping', result.echoed, 'Echoed value should match')
end)

TestRunner.test(S, 'callback_await() add round-trip', function()
    local result = exports.helix_lib:callback_await('helix_lib_tests:add', 3, 7)
    A.equals(10, result, 'Add callback should return 10')
end)

TestRunner.test(S, 'callback_trigger() async works', function()
    local done = false
    local echoResult = nil

    exports.helix_lib:callback_trigger('helix_lib_tests:echo', function(result)
        echoResult = result
        done = true
    end, 'async_test')

    -- Wait up to 2 seconds for response
    local timeout = 2000
    while not done and timeout > 0 do
        Citizen.Wait(50)
        timeout = timeout - 50
    end

    A.isTrue(done, 'Async callback should have completed within 2s')
    A.notNil(echoResult, 'Async result should not be nil')
    A.equals('async_test', echoResult.echoed, 'Async echoed value should match')
end)
