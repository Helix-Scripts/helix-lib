--- Client-side NUI/UI module tests
--- These tests validate the UI bridge API surface. Actual NUI rendering
--- requires a browser frame, so we test the Lua-side interface only.

local S = TestRunner.suite('NUI / UI (Client)')
local A = TestRunner.assert

TestRunner.test(S, 'notify export is a function', function()
    local notify = exports.helix_lib:notify
    -- notify is exposed as a direct export function
    A.isType(notify, 'function', 'notify export should be a function')
end)

TestRunner.test(S, 'notify() does not error with valid args', function()
    A.noError(function()
        exports.helix_lib:notify('Test message', 'info', 1000)
    end, 'notify should not error')
end)

TestRunner.test(S, 'notify() handles all notification types', function()
    local types = { 'success', 'error', 'warning', 'info' }
    for _, notifType in ipairs(types) do
        A.noError(function()
            exports.helix_lib:notify('Test ' .. notifType, notifType, 500)
        end, 'notify type ' .. notifType .. ' should not error')
    end
end)
