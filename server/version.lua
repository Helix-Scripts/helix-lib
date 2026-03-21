--- Version checker — checks GitHub releases API on resource start
--- Prints an update notice if a newer version is available.

local Constants = require 'shared.constants'

local function checkVersion()
    local currentVersion = Constants.VERSION
    local repo = Constants.GITHUB_REPO

    PerformHttpRequest(
        ('https://api.github.com/repos/%s/releases/latest'):format(repo),
        function(statusCode, responseText, _headers)
            if statusCode ~= 200 then
                print(('[helix_lib] ^3Unable to check for updates (HTTP %s)^0'):format(statusCode))
                return
            end

            local response = json.decode(responseText)
            if not response or not response.tag_name then
                print('[helix_lib] ^3Unable to parse version response^0')
                return
            end

            local latestVersion = response.tag_name:gsub('^v', '')

            if latestVersion == currentVersion then
                print(('[helix_lib] ^2You are running the latest version (v%s)^0'):format(currentVersion))
            else
                print(('[helix_lib] ^3Update available! Current: v%s — Latest: v%s^0'):format(currentVersion, latestVersion))
                print(('[helix_lib] ^3Download: https://github.com/%s/releases/latest^0'):format(repo))
            end
        end,
        'GET',
        '',
        { ['User-Agent'] = 'helix_lib/' .. currentVersion }
    )
end

-- Check version on resource start (if enabled in config)
CreateThread(function()
    Wait(5000) -- Wait for other resources to initialize
    local Config = require 'shared.config'
    local config = Config.get(Constants.RESOURCE_NAME)

    if config and config.versionCheck ~= false then
        checkVersion()
    end
end)
