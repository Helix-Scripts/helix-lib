--- Minimal test runner for FiveM
--- Collects assertions, prints coloured results to console.

---@class TestRunner
TestRunner = {}

local suites = {}
local currentSuite = nil

--- Register a new test suite
---@param name string Suite name (e.g. 'Config')
---@return table suite
function TestRunner.suite(name)
    local suite = {
        name = name,
        tests = {},
        passed = 0,
        failed = 0,
        skipped = 0,
        errors = {},
    }
    suites[#suites + 1] = suite
    return suite
end

--- Add a test to a suite
---@param suite table
---@param name string
---@param fn fun()
function TestRunner.test(suite, name, fn)
    suite.tests[#suite.tests + 1] = { name = name, fn = fn }
end

--- Skip a test (marks as skipped in output)
---@param suite table
---@param name string
function TestRunner.skip(suite, name)
    suite.tests[#suite.tests + 1] = { name = name, fn = nil, skip = true }
end

--- Assert helpers
local Assert = {}

function Assert.isTrue(value, msg)
    if not value then
        error(msg or ('Expected truthy, got: %s'):format(tostring(value)), 2)
    end
end

function Assert.isFalse(value, msg)
    if value then
        error(msg or ('Expected falsy, got: %s'):format(tostring(value)), 2)
    end
end

function Assert.equals(expected, actual, msg)
    if expected ~= actual then
        error(msg or ('Expected %s, got %s'):format(tostring(expected), tostring(actual)), 2)
    end
end

function Assert.notNil(value, msg)
    if value == nil then
        error(msg or 'Expected non-nil value', 2)
    end
end

function Assert.isNil(value, msg)
    if value ~= nil then
        error(msg or ('Expected nil, got: %s'):format(tostring(value)), 2)
    end
end

function Assert.isType(value, expectedType, msg)
    local actualType = type(value)
    if actualType ~= expectedType then
        error(msg or ('Expected type %s, got %s'):format(expectedType, actualType), 2)
    end
end

function Assert.tableHasKey(tbl, key, msg)
    if type(tbl) ~= 'table' then
        error(msg or ('Expected table, got %s'):format(type(tbl)), 2)
    end
    if tbl[key] == nil then
        error(msg or ('Table missing key: %s'):format(tostring(key)), 2)
    end
end

function Assert.isCallable(value, msg)
    local t = type(value)
    if t == 'function' then return end
    if t == 'table' then
        local mt = getmetatable(value)
        if mt and type(mt.__call) == 'function' then return end
    end
    error(msg or ('Expected callable, got %s'):format(t), 2)
end

function Assert.noError(fn, msg)
    local ok, err = pcall(fn)
    if not ok then
        error(msg or ('Unexpected error: %s'):format(tostring(err)), 2)
    end
end

TestRunner.assert = Assert

--- Run all registered suites and print results
---@param side string 'SERVER' or 'CLIENT'
function TestRunner.runAll(side)
    local totalPassed = 0
    local totalFailed = 0
    local totalSkipped = 0

    print('')
    print('^5╔═══════════════════════════════════════════════════════════╗^0')
    print('^5║       HELIX_LIB TEST HARNESS — ' .. side .. string.rep(' ', 25 - #side) .. '║^0')
    print('^5╚═══════════════════════════════════════════════════════════╝^0')
    print('')

    for _, suite in ipairs(suites) do
        print('^5━━━ Suite: ' .. suite.name .. ' ━━━^0')

        for _, test in ipairs(suite.tests) do
            if test.skip then
                suite.skipped = suite.skipped + 1
                print(('  ^3⊘ SKIP^0  %s'):format(test.name))
            else
                local ok, err = pcall(test.fn)
                if ok then
                    suite.passed = suite.passed + 1
                    print(('  ^2✓ PASS^0  %s'):format(test.name))
                else
                    suite.failed = suite.failed + 1
                    suite.errors[#suite.errors + 1] = { test = test.name, error = err }
                    print(('  ^1✗ FAIL^0  %s'):format(test.name))
                    print(('         ^1→ %s^0'):format(tostring(err)))
                end
            end
        end

        totalPassed = totalPassed + suite.passed
        totalFailed = totalFailed + suite.failed
        totalSkipped = totalSkipped + suite.skipped
        print('')
    end

    -- Summary
    print('^5═══════════════════════════════════════════════════════════^0')
    local statusColor = totalFailed > 0 and '^1' or '^2'
    print(('%s  %d passed, %d failed, %d skipped  (total: %d)^0'):format(
        statusColor, totalPassed, totalFailed, totalSkipped,
        totalPassed + totalFailed + totalSkipped
    ))

    if totalFailed > 0 then
        print('')
        print('^1  FAILURES:^0')
        for _, suite in ipairs(suites) do
            for _, e in ipairs(suite.errors) do
                print(('  ^1[%s] %s^0'):format(suite.name, e.test))
                print(('    → %s'):format(e.error))
            end
        end
    end

    print('^5═══════════════════════════════════════════════════════════^0')
    print('')

    -- Fire event so external tools can capture results
    if side == 'SERVER' then
        TriggerEvent('helix_lib_tests:serverDone', totalPassed, totalFailed, totalSkipped)
    else
        TriggerEvent('helix_lib_tests:clientDone', totalPassed, totalFailed, totalSkipped)
    end

    -- Reset for potential re-runs
    suites = {}
end
