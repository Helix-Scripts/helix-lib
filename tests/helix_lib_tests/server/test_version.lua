--- Server-side Version check tests
--- Version check is async and runs on startup. We only validate the module exists.

local S = TestRunner.suite('Version (Server)')
local A = TestRunner.assert

TestRunner.test(S, 'helix_lib resource is started', function()
    local state = GetResourceState('helix_lib')
    A.equals('started', state, 'helix_lib should be in started state')
end)

TestRunner.test(S, 'helix_lib has correct metadata', function()
    local version = GetResourceMetadata('helix_lib', 'version', 0)
    A.notNil(version, 'helix_lib should have a version in metadata')
    A.isTrue(#version > 0, 'Version string should not be empty')
end)
