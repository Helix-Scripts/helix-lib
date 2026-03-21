---@class HelixConstants
local Constants = {}

--- Library version
Constants.VERSION = '0.1.0'

--- Resource name (cached)
Constants.RESOURCE_NAME = GetCurrentResourceName()

--- GitHub repository for version checks
Constants.GITHUB_REPO = 'Helix-Scripts/helix-lib'

--- Supported frameworks
---@enum Framework
Constants.Framework = {
    QBOX = 'qbox',
    QBCORE = 'qbcore',
    ESX = 'esx',
    STANDALONE = 'standalone',
}

--- Log levels
---@enum LogLevel
Constants.LogLevel = {
    ERROR = 1,
    WARN = 2,
    INFO = 3,
    DEBUG = 4,
}

--- Notification types
---@enum NotifyType
Constants.NotifyType = {
    SUCCESS = 'success',
    ERROR = 'error',
    WARNING = 'warning',
    INFO = 'info',
}

return Constants
