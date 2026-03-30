# helix-lib

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![FiveM](https://img.shields.io/badge/FiveM-Resource-orange.svg)](https://fivem.net)
[![Lua 5.4](https://img.shields.io/badge/Lua-5.4-blueviolet.svg)](https://www.lua.org)
[![React 18](https://img.shields.io/badge/React-18-61DAFB.svg)](https://react.dev)

Shared utility library for FiveM resources by **Helix Scripts**. Provides a unified framework bridge, callback system, NUI components, config management, and locale support.

## Features

- **Framework Bridge** — Unified API across Qbox, QBCore, and ESX with automatic detection
- **Callback System** — RPC-style client/server callbacks with ox_lib fallback
- **NUI Framework** — React 18 + TypeScript + Vite with pre-built hooks for NUI communication
- **Config System** — Hot-reloadable config with deep merging and watcher support
- **Locale System** — Translation management with fallback chain and string formatting
- **Client Utilities** — Closest player, 3D text, asset loading, vehicle helpers
- **Server Utilities** — Identifier lookup, permission checks, logging, JSON helpers
- **Version Checker** — Automatic GitHub release check on startup

## Installation

1. Download or clone this repository into your server's `resources` directory.
2. Add `ensure helix_lib` to your `server.cfg` (before any resources that depend on it).
3. Configure `config.lua` to match your server setup.

### NUI Development

```bash
cd nui
npm install
npm run dev     # Start Vite dev server
npm run build   # Build to ../html/ for production
```

## Usage

### Exports

```lua
-- Bridge — each function is a flat export (no table proxy issues)
local fw = exports.helix_lib:bridge_framework()       -- 'qbox', 'qbcore', 'esx', or 'standalone'
local isQB = exports.helix_lib:bridge_is('qbcore')    -- boolean check

-- Get a player (server-side)
local player = exports.helix_lib:getPlayer(source)
local player2 = exports.helix_lib:bridge_GetPlayer(source) -- equivalent

-- Send a notification
exports.helix_lib:notify('Hello world!', 'success')
exports.helix_lib:bridge_Notify(source, 'Server-side notification', 'info', 5000)

-- Use the config system
local Config = exports.helix_lib:config()
local cfg = Config.get('helix_lib')

-- Use translations — flat exports
local msg = exports.helix_lib:locale_t('welcome_message', playerName)
exports.helix_lib:locale_set('nl')
local lang = exports.helix_lib:locale_current()

-- Use callbacks — flat exports
-- Server: register
exports.helix_lib:callback_register('myCallback', function(source, data)
    return { ok = true }
end)

-- Client: trigger async
exports.helix_lib:callback_trigger('myCallback', function(result)
    print(result.ok)
end, arg1, arg2)

-- Client: trigger sync (blocking)
local result = exports.helix_lib:callback_await('myCallback', arg1, arg2)
```

### NUI Hooks (React)

```tsx
import { useNuiEvent, useNuiCallback, useNuiClose, useKeyPress } from './hooks';

// Listen for messages from Lua
useNuiEvent('showMenu', (data) => {
  setMenuData(data);
});

// Send data to Lua
const { execute } = useNuiCallback('submitForm');
await execute({ name: 'test' });

// Close NUI
const close = useNuiClose();
useKeyPress('Escape', close);
```

## Configuration

Edit `config.lua` in the resource root:

```lua
return {
    debug = false,
    locale = 'en',
    framework = nil,       -- Auto-detect, or set 'qbox', 'qbcore', 'esx'
    versionCheck = true,
    notifications = {
        position = 'top-right',
        duration = 5000,
    },
    logging = {
        level = 'info',
    },
}
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -m 'feat: add my feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
