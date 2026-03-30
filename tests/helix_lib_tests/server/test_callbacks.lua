--- Server-side Callback module tests

local S = TestRunner.suite('Callbacks (Server)')
local A = TestRunner.assert

TestRunner.test(S, 'callback_register export is accessible', function()
    A.isCallable(exports.helix_lib.callback_register, 'callback_register export should be callable')
end)

TestRunner.test(S, 'callback_register() does not error', function()
    A.noError(function()
        exports.helix_lib:callback_register('helix_lib_tests:echo', function(source, data)
            return data
        end)
    end, 'Registering a callback should not error')
end)

TestRunner.test(S, 'callback_register() overwrites without error', function()
    A.noError(function()
        exports.helix_lib:callback_register('helix_lib_tests:echo', function(source, data)
            return { echoed = data }
        end)
    end, 'Re-registering a callback should not error')
end)
