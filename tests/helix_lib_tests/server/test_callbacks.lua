--- Server-side Callback module tests

local S = TestRunner.suite('Callbacks (Server)')
local A = TestRunner.assert

TestRunner.test(S, 'Callback module is accessible via export', function()
    local cb = exports.helix_lib:callback()
    A.notNil(cb, 'Callback export should not be nil')
end)

TestRunner.test(S, 'Callback.register is a function', function()
    local cb = exports.helix_lib:callback()
    A.isType(cb.register, 'function', 'Callback.register should be a function')
end)

TestRunner.test(S, 'Callback.register() does not error', function()
    local cb = exports.helix_lib:callback()
    A.noError(function()
        cb.register('helix_lib_tests:echo', function(source, data)
            return data
        end)
    end, 'Registering a callback should not error')
end)

TestRunner.test(S, 'Callback.register() overwrites without error', function()
    local cb = exports.helix_lib:callback()
    A.noError(function()
        cb.register('helix_lib_tests:echo', function(source, data)
            return { echoed = data }
        end)
    end, 'Re-registering a callback should not error')
end)
