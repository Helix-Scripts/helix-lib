--- Client-side test entry point
--- Runs all client test suites after a delay to ensure helix_lib is loaded
--- and server-side callbacks are registered.

Citizen.CreateThread(function()
    -- Wait for helix_lib to initialize + server callbacks to register
    Citizen.Wait(5000)

    print('')
    print('^5[helix_lib_tests] Starting client-side tests...^0')
    print('')

    TestRunner.runAll('CLIENT')
end)
