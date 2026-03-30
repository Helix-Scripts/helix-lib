--- Server-side test entry point
--- Runs all server test suites after a short delay to ensure helix_lib is fully loaded.

Citizen.CreateThread(function()
    -- Wait for helix_lib to finish initializing
    Citizen.Wait(2000)

    print('')
    print('^5[helix_lib_tests] Starting server-side tests...^0')
    print('')

    TestRunner.runAll('SERVER')
end)

-- Register echo callback for client-side callback tests
Citizen.CreateThread(function()
    Citizen.Wait(1000)
    exports.helix_lib:callback_register('helix_lib_tests:echo', function(source, data)
        return { echoed = data, source = source }
    end)
    exports.helix_lib:callback_register('helix_lib_tests:add', function(source, a, b)
        return a + b
    end)
end)
