# tac_bridge

Universal FiveM framework bridge — **QBX · QBCore · ESX · ox_core · ND · Mythic**

Auto-detects your framework and addon modules and exposes a single consistent export API so your scripts never need to know which framework is running underneath.

## Supported Frameworks

| Key | Resource | Notes |
|-----|----------|-------|
| `qbx` | `qbx_core` | Qbox Framework |
| `qb` | `qb-core` | QBCore Framework |
| `esx` | `es_extended` | ESX Legacy Framework |
| `ox` | `ox_core` | ox Framework (archived Apr 2025)|
| `nd` | `ND_Core` | ND Framework |
| `mythic` | `mythic-base` | Mythic Framework |

## Supported Addon Modules

| Module | Auto-detected resources (priority order) |
|--------|------------------------------------------|
| Target | `ox_target` → `qb-target` |
| Inventory | `ox_inventory` → `qb-inventory` |
| Vehicle Keys | `qbx_vehiclekeys` → `qb-vehiclekeys` |
| Vehicle Fuel | `ox_fuel` → `LegacyFuel` → `cdn-fuel` → `lc_fuel` → `qb-fuel` |


---

## Installation

1. Drop the `tac_bridge` folder into your `resources` directory.
2. Add the following to `server.cfg` **in this order**:

```
ensure ox_lib
ensure tac_bridge
ensure your_resource
```

> **Pure QB or ESX without ox_lib?** Comment out `'@ox_lib/init.lua'` in `tac_bridge/fxmanifest.lua` and remove `ox_lib` from the `dependencies` block.

---

## Using as a Dependency

In your resource's `fxmanifest.lua`:

```lua
fx_version 'cerulean'
game 'gta5'

dependencies { 'tac_bridge' }

client_scripts { 'client/*.lua' }
server_scripts { 'server/*.lua' }
```

All exports are then available via `exports.tac_bridge:FunctionName()`.

---

## Configuration

Edit `shared/config.lua` to force a specific framework or module, or disable modules entirely:

```lua
Bridge.Config = {
    ForceFramework = nil,  -- 'qbx'|'qb'|'esx'|'ox'|'nd'|'mythic' — nil = auto
    Inventory   = nil,     -- 'ox_inventory'|'qb-inventory'|false   — nil = auto
    VehicleKeys = nil,     -- 'qbx_vehiclekeys'|'qb-vehiclekeys'|false
    VehicleFuel = nil,     -- 'ox_fuel'|'LegacyFuel'|'cdn-fuel'|'lc_fuel'|'qb-fuel'|false
    Target      = nil,     -- 'ox_target'|'qb-target'|false
    NotifyDuration   = 5000,
    ProgressDuration = 5000,
}
```

Set a module to `false` to disable it. Set it to a resource name string to force a specific resource.

---

## Client Exports

### Player

```lua
local pd     = exports.tac_bridge:GetPlayerData()   -- full player data table
local id     = exports.tac_bridge:GetIdentifier()   -- citizenid / license
local name   = exports.tac_bridge:GetName()         -- "Firstname Lastname"
local loaded = exports.tac_bridge:IsPlayerLoaded()  -- bool
```

### Job & Gang

```lua
-- Full job table: { name, label, grade, gradeLabel, onDuty, isBoss }
local job      = exports.tac_bridge:GetJob()
local jobName  = exports.tac_bridge:GetJobName()   -- string
local jobGrade = exports.tac_bridge:GetJobGrade()  -- number
local onDuty   = exports.tac_bridge:IsOnDuty()     -- bool
local isBoss   = exports.tac_bridge:IsBoss()       -- bool

-- Full gang table: { name, label, grade, gradeLabel }
local gang      = exports.tac_bridge:GetGang()
local gangName  = exports.tac_bridge:GetGangName()
local gangGrade = exports.tac_bridge:GetGangGrade()
```

### Money

```lua
-- account: 'cash' | 'bank' | 'black'  (default: 'cash')
local cash = exports.tac_bridge:GetMoney('cash')
local bank = exports.tac_bridge:GetMoney('bank')
```

### Inventory

```lua
local has   = exports.tac_bridge:HasItem('phone')       -- bool
local count = exports.tac_bridge:GetItemCount('lockpick') -- number (uses ox_inventory when available)
```

### Notifications & UI

```lua
-- type: 'success' | 'error' | 'info' | 'warning'
exports.tac_bridge:Notify('Hello!', 'success')
exports.tac_bridge:Notify('Something went wrong', 'error', 3000)

-- Progress bar
-- opts: { label, duration, useWhileDead, canCancel, disableMovement, disableCombat, anim, prop }
exports.tac_bridge:Progress({ label = 'Searching...', duration = 3000 }, function(completed)
    if completed then print('done') end
end)
```

### Callbacks

```lua
-- Trigger a server callback
exports.tac_bridge:TriggerCallback('myresource:getData', function(result)
    print(result)
end, arg1, arg2)

-- Register a client-side callback handler
exports.tac_bridge:RegisterCallback('myresource:clientCb', function(data, cb)
    cb(true)
end)
```

### Fuel Module

```lua
-- Requires one of: ox_fuel | LegacyFuel | cdn-fuel | lc_fuel | qb-fuel
local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

local fuel = exports.tac_bridge:GetFuel(vehicle)     -- 0–100
exports.tac_bridge:SetFuel(vehicle, 75.0)
```

### Vehicle Keys Module

```lua
-- Requires one of: qbx_vehiclekeys | qb-vehiclekeys
local plate = GetVehicleNumberPlateText(vehicle)

local hasKeys = exports.tac_bridge:HasVehicleKeys(plate)  -- bool
```

---

## Server Exports

### Player Lookup

```lua
local player  = exports.tac_bridge:GetPlayer(source)                    -- raw framework player object
local player  = exports.tac_bridge:GetPlayerByCitizenId('ABC12345')     -- by citizenid
local players = exports.tac_bridge:GetAllPlayers()                      -- table of all online source IDs
local coords  = exports.tac_bridge:GetPlayerCoords(source)              -- vector3
```

### Identity

```lua
local id   = exports.tac_bridge:GetIdentifier(source)
local name = exports.tac_bridge:GetName(source)
```

### Job & Gang

```lua
local job      = exports.tac_bridge:GetJob(source)       -- { name, label, grade, gradeLabel, onDuty, isBoss }
local jobName  = exports.tac_bridge:GetJobName(source)
local jobGrade = exports.tac_bridge:GetJobGrade(source)
local gang     = exports.tac_bridge:GetGang(source)

exports.tac_bridge:SetJob(source, 'police', 2)   -- grade defaults to 0
exports.tac_bridge:SetGang(source, 'vagos', 1)
```

### Money

```lua
-- account: 'cash' | 'bank' | 'black'
local cash = exports.tac_bridge:GetMoney(source, 'cash')

exports.tac_bridge:AddMoney(source, 'cash', 500, 'job_payment')   -- reason optional
exports.tac_bridge:RemoveMoney(source, 'cash', 250, 'purchase')
exports.tac_bridge:SetMoney(source, 'bank', 5000)                 -- QB/QBX/ox_core only
```

### Metadata & Save

```lua
exports.tac_bridge:SetMetaData(source, 'hunger', 100)  -- QB/QBX/ND/Mythic
exports.tac_bridge:SavePlayer(source)                  -- QB/QBX/ND
```

### Inventory

```lua
local has      = exports.tac_bridge:HasItem(source, 'phone')
local count    = exports.tac_bridge:GetItemCount(source, 'lockpick')
local canCarry = exports.tac_bridge:CanCarryItem(source, 'water', 3)

exports.tac_bridge:AddItem(source, 'phone', 1)
exports.tac_bridge:RemoveItem(source, 'lockpick', 2)
```

### Vehicle Keys Module

```lua
exports.tac_bridge:GiveVehicleKeys(source, plate)
exports.tac_bridge:RemoveVehicleKeys(source, plate)
```

### Notify & Callbacks

```lua
-- type: 'success' | 'error' | 'info' | 'warning'
exports.tac_bridge:Notify(source, 'You were paid!', 'success')
exports.tac_bridge:Notify(source, 'Insufficient funds', 'error', 4000)

exports.tac_bridge:RegisterCallback('myresource:getData', function(src, cb, arg1)
    cb({ result = 'some data' })
end)
```

---

## Example

### client.lua

```lua
local job = exports.tac_bridge:GetJobName()

exports.tac_bridge:Progress({
    label    = 'Working...',
    duration = 3000,
}, function(completed)
    if not completed then return end
    exports.tac_bridge:TriggerCallback('myresource:doThing', function(result)
        exports.tac_bridge:Notify(result.msg, result.type)
    end)
end)
```

### server.lua

```lua
exports.tac_bridge:RegisterCallback('myresource:doThing', function(src, cb)
    local job   = exports.tac_bridge:GetJobName(src)
    local grade = exports.tac_bridge:GetJobGrade(src)

    if job ~= 'police' or grade < 2 then
        return cb({ msg = 'Access denied', type = 'error' })
    end

    exports.tac_bridge:AddMoney(src, 'cash', 500, 'reward')
    exports.tac_bridge:AddItem(src, 'evidence_bag', 1)
    cb({ msg = 'Done!', type = 'success' })
end)
```

## Mythic Note

`mythic-base` has **no built-in money, job, or inventory system** — those live in separate `mythic-*` component resources. Money/job/inventory functions return stubs (`0` / `false`) by default. Override the relevant functions after tac_bridge loads:

```lua
-- In your resource's server.lua
Bridge.Server.AddMoney = function(src, account, amount, reason)
    local key = Bridge.Config.Accounts[account] and Bridge.Config.Accounts[account].mythic or account
    COMPONENTS.Economy:AddMoney(src, key, amount, reason)
    return true
end
```
