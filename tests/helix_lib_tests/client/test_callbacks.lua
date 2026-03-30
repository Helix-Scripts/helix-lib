--- Client-side Callback module tests

local S = TestRunner.suite('Callbacks (Client)')
local A = TestRunner.assert

TestRunner.test(S, 'Callback module is accessible via export', function()
    local cb = exports.helix_lib:callback()
    A.notNil(cb, 'Callback export should not be nil')
end)

TestRunner.test(S, 'Callback.trigger is a function', function()
    local cb = exports.helix_lib:callback()
    A.isType(cb.trigger, 'function', 'Callback.trigger should be a function')
end)

TestRunner.test(S, 'Callback.await is a function', function()
    local cb = exports.helix_lib:callback()
    A.isType(cb.await, 'function', 'Callback.await should be a function')
end)

TestRunner.test(S, 'Callback.await() echo round-trip', function()
    local cb = exports.helix_lib:callback()
    local result = cb.await('helix_lib_tests:echo', 'ping')
    A.notNil(result, 'Echo callback should return a result')
    A.isType(result, 'table', 'Echo result should be a table')
    A.equals('ping', result.echoed, 'Echoed value should match')
end)

TestRunner.test(S, 'Callback.await() add round-trip', function()
    local cb = exports.helix_lib:callback()
    local result = cb.await('helix_lib_tests:add', 3, 7)
    A.equals(10, result, 'Add callback should return 10')
end)

TestRunner.test(S, 'Callback.trigger() async works', function()
    local cb = exports.helix_lib:callback()
    local done = false
    local echoResult = nil

    cb.trigger('helix_lib_tests:echo', function(result)
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
