---@class HelixLocale
local Locale = {}

local loaded = {}
local currentLocale = 'en'

--- Load a locale table
---@param lang string Language code (e.g. 'en', 'nl', 'de')
---@param translations table<string, string> Key-value translation pairs
function Locale.load(lang, translations)
    if not loaded[lang] then
        loaded[lang] = {}
    end

    for key, value in pairs(translations) do
        loaded[lang][key] = value
    end
end

--- Load locale from a file
---@param lang string Language code
---@param resourceName? string Resource to load from (defaults to current)
function Locale.loadFile(lang, resourceName)
    resourceName = resourceName or GetCurrentResourceName()
    local file = LoadResourceFile(resourceName, ('locales/%s.lua'):format(lang))

    if not file then
        return false
    end

    -- Sandbox: locale files only need to return a table, no globals required
    local fn, err = load(file, ('@%s/locales/%s.lua'):format(resourceName, lang), 't', {})
    if not fn then
        print(('[helix_lib:locale] ^1Failed to parse locale %s: %s^0'):format(lang, err))
        return false
    end

    local ok, translations = pcall(fn)
    if not ok or type(translations) ~= 'table' then
        print(('[helix_lib:locale] ^1Failed to execute locale %s^0'):format(lang))
        return false
    end

    Locale.load(lang, translations)
    return true
end

--- Set the active locale.
--- NOTE: This is intentionally server-wide (or client-wide). All consumers share a single
--- active locale. This is acceptable for a shared lib — individual resources that need
--- per-player locale should manage their own locale state.
---@param lang string
function Locale.set(lang)
    currentLocale = lang
end

--- Get the active locale
---@return string
function Locale.current()
    return currentLocale
end

--- Translate a key with optional string formatting
---@param key string Translation key
---@param ... any Format arguments
---@return string translated
function Locale.t(key, ...)
    local lang = loaded[currentLocale]
    if not lang then
        return key
    end

    local translation = lang[key]
    if not translation then
        -- Fallback to English
        if currentLocale ~= 'en' and loaded['en'] then
            translation = loaded['en'][key]
        end

        if not translation then
            return key
        end
    end

    if select('#', ...) > 0 then
        local ok, result = pcall(string.format, translation, ...)
        if ok then
            return result
        end
    end

    return translation
end

--- Check if a translation key exists
---@param key string
---@param lang? string
---@return boolean
function Locale.has(key, lang)
    lang = lang or currentLocale
    return loaded[lang] ~= nil and loaded[lang][key] ~= nil
end

return Locale
