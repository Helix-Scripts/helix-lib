---@class HelixLibConfig
return {
    --- Enable debug mode (verbose logging, hot-reload, dev tools)
    debug = false,

    --- Default locale for translations
    locale = 'en',

    --- Framework override (auto-detected if nil)
    --- Options: 'qbox', 'qbcore', 'esx', 'standalone'
    ---@type 'qbox'|'qbcore'|'esx'|'standalone'|nil
    framework = nil,

    --- Version check on startup
    versionCheck = true,

    --- Notification system
    notifications = {
        --- Notification position on screen
        ---@type 'top-right'|'top-left'|'bottom-right'|'bottom-left'|'top-center'|'bottom-center'
        position = 'top-right',

        --- Default notification duration (ms)
        duration = 5000,
    },

    --- Logging
    logging = {
        --- Log level: 'error', 'warn', 'info', 'debug'
        ---@type 'error'|'warn'|'info'|'debug'
        level = 'info',
    },
}
