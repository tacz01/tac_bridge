# tac_bridge

Universal FiveM framework bridge — **QBX · QBCore · ESX · ox_core · ND · Mythic**

Auto-detects your framework and addon resources (inventory, vehicle keys, fuel) and exposes a single, consistent export API so your scripts never need to care which framework is running.

## Supported Frameworks

| Key | Resource | Org |
|-----|----------|-----|
| `qbx` | `qbx_core` | Qbox-project |
| `qb` | `qb-core` | qbcore-framework |
| `esx` | `es_extended` | esx-framework |
| `ox` | `ox_core` | overextended / esx-framework fork |
| `nd` | `ND_Core` | ND-Framework |
| `mythic` | `mythic-base` | Mythic-Framework |

## Supported Addon Modules

| Module | Auto-detected resources (priority order) |
|--------|------------------------------------------|
| Inventory | `ox_inventory` → `qb-inventory` |
| Vehicle Keys | `qbx_vehiclekeys` → `qb-vehiclekeys` |
| Vehicle Fuel | `ox_fuel` → `LegacyFuel` → `cdn-fuel` → `lc_fuel` → `qb-fuel` |

## Installation

1. Drop the `tac_bridge` folder into your `resources` directory.
2. Add `ensure tac_bridge` to your `server.cfg` **before** any resource that depends on it.

```
ensure tac_bridge
ensure your_resource
```

## Using as a Dependency

In your resource's `fxmanifest.lua`:

```lua
fx_version 'cerulean'
game 'gta5'

dependencies { 'tac_bridge' }

client_scripts { 'client/*.lua' }
server_scripts { 'server/*.lua' }
```

That's it. All exports are then available via `exports.tac_bridge:FunctionName()`.

## Configuration

Open `shared/config.lua` to override detection or disable modules:

```lua
Bridge.Config = {
    ForceFramework = nil,    -- force: 'qbx'|'qb'|'esx'|'ox'|'nd'|'mythic'
    Inventory   = nil,       -- force: 'ox_inventory'|'qb-inventory'|false
    VehicleKeys = nil,       -- force: 'qbx_vehiclekeys'|'qb-vehiclekeys'|false
    VehicleFuel = nil,       -- force: 'ox_fuel'|'LegacyFuel'|'cdn-fuel'|'lc_fuel'|'qb-fuel'|false
    NotifyDuration   = 5000,
    ProgressDuration = 5000,
}
```

---

## Client Exports

### Player

```lua
-- Returns the full player data table (framework-specific shape)
local pd = exports.tac_bridge:GetPlayerData()

-- Returns the player's unique identifier (citizenid / license etc.)
local id = exports.tac_bridge:GetIdentifier()

-- Returns "Firstname Lastname"
local name = exports.tac_bridge:GetName()

-- Returns true once the player has selected/loaded a character
local loaded = exports.tac_bridge:IsPlayerLoaded()
```

### Job & Gang

```lua
-- Returns the full job table: { name, label, grade, gradeLabel, onDuty, isBoss }
local job = exports.tac_bridge:GetJob()

-- Shorthand helpers
local jobName  = exports.tac_bridge:GetJobName()   -- string
local jobGrade = exports.tac_bridge:GetJobGrade()  -- number
local onDuty   = exports.tac_bridge:IsOnDuty()     -- bool
local isBoss   = exports.tac_bridge:IsBoss()       -- bool

-- Returns the full gang table: { name, label, grade, gradeLabel }
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
-- Returns true if the player has at least 1 of the item
local has = exports.tac_bridge:HasItem('phone')

-- Returns the count of an item (uses ox_inventory when available)
local count = exports.tac_bridge:GetItemCount('lockpick')
```

### Notifications & UI

-- Not Really useful you can just use ox_lib if used but if using a standerd framework like qb for notifications this can be used can be easier if your lazy :)

```lua
-- type: 'success' | 'error' | 'info' | 'warning'
exports.tac_bridge:Notify('Hello!', 'success')
exports.tac_bridge:Notify('Something went wrong', 'error', 3000)

-- Progress bar
-- opts: { label, duration, useWhileDead, canCancel, disableMovement, disableCombat, anim, prop }
exports.tac_bridge:Progress({ label = 'Searching...', duration = 3000 }, function(completed)
    if completed then
        print('done')
    end
end)
```

### Callbacks

```lua
-- Trigger a server callback
exports.tac_bridge:TriggerCallback('myresource:getData', function(result)
    print(result)
end, arg1, arg2)

-- Register a client-side callback handler (QB/QBX only)
exports.tac_bridge:RegisterCallback('myresource:clientCb', function(data, cb)
    cb(true)
end)
```

### Fuel Module

```lua
-- Requires one of: ox_fuel | LegacyFuel | cdn-fuel | lc_fuel | qb-fuel

local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

-- Returns fuel level 0–100
local fuel = exports.tac_bridge:GetFuel(vehicle)

-- Sets fuel level 0–100
exports.tac_bridge:SetFuel(vehicle, 75.0)
```

### Vehicle Keys Module

```lua
-- Requires one of: qbx_vehiclekeys | qb-vehiclekeys

local plate = GetVehicleNumberPlateText(vehicle)

-- Returns true if the local player has keys for this plate
local hasKeys = exports.tac_bridge:HasVehicleKeys(plate)
```

---

## Server Exports

### Player Lookup

```lua
-- Returns the raw framework player object
local player = exports.tac_bridge:GetPlayer(source)

-- Look up an online player by their citizenid / identifier
local player = exports.tac_bridge:GetPlayerByCitizenId('ABC12345')

-- Returns a table of all online source IDs
local players = exports.tac_bridge:GetAllPlayers()
for _, src in ipairs(players) do
    print(src)
end

-- Returns a vector3 of the player's current position
local coords = exports.tac_bridge:GetPlayerCoords(source)
```

### Identity

```lua
local id   = exports.tac_bridge:GetIdentifier(source)
local name = exports.tac_bridge:GetName(source)
```

### Job & Gang

```lua
-- Returns { name, label, grade, gradeLabel, onDuty, isBoss }
local job      = exports.tac_bridge:GetJob(source)
local jobName  = exports.tac_bridge:GetJobName(source)
local jobGrade = exports.tac_bridge:GetJobGrade(source)

-- Returns { name, label, grade, gradeLabel }
local gang = exports.tac_bridge:GetGang(source)

-- Set a player's job (grade defaults to 0)
exports.tac_bridge:SetJob(source, 'police', 2)

-- Set a player's gang
exports.tac_bridge:SetGang(source, 'vagos', 1)
```

### Money

```lua
-- account: 'cash' | 'bank' | 'black'  (default: 'cash')
local cash = exports.tac_bridge:GetMoney(source, 'cash')
local bank = exports.tac_bridge:GetMoney(source, 'bank')

-- Add money  (reason is optional, logged by QB/QBX)
exports.tac_bridge:AddMoney(source, 'cash', 500, 'job_payment')
exports.tac_bridge:AddMoney(source, 'bank', 1000)

-- Remove money
exports.tac_bridge:RemoveMoney(source, 'cash', 250, 'shop_purchase')

-- Set money to an exact amount  (QB/QBX/ox_core only)
exports.tac_bridge:SetMoney(source, 'bank', 5000)
```

### Metadata & Save

```lua
-- Set a metadata value on the player  (QB/QBX/ND/Mythic)
exports.tac_bridge:SetMetaData(source, 'hunger', 100)

-- Force-save the player to the database  (QB/QBX/ND)
exports.tac_bridge:SavePlayer(source)
```

### Inventory

```lua
-- Check
local has   = exports.tac_bridge:HasItem(source, 'phone')
local count = exports.tac_bridge:GetItemCount(source, 'lockpick')

-- Can the player carry more?
local canCarry = exports.tac_bridge:CanCarryItem(source, 'water', 3)

-- Give / take
exports.tac_bridge:AddItem(source, 'phone', 1)
exports.tac_bridge:RemoveItem(source, 'lockpick', 2)
```

### Vehicle Keys Module

```lua
-- Requires one of: qbx_vehiclekeys | qb-vehiclekeys

local plate = GetVehicleNumberPlateText(vehicle)

exports.tac_bridge:GiveVehicleKeys(source, plate)
exports.tac_bridge:RemoveVehicleKeys(source, plate)
```

### Notify & Callbacks

-- Not Really useful you can just use ox_lib if used but if using a standerd framework like qb for Notify this can be used can be easier if your lazy :)

```lua
-- Send a notification to a player
-- type: 'success' | 'error' | 'info' | 'warning'
exports.tac_bridge:Notify(source, 'You were paid!', 'success')
exports.tac_bridge:Notify(source, 'Insufficient funds', 'error', 4000)

-- Register a server callback that clients can trigger
exports.tac_bridge:RegisterCallback('myresource:getData', function(src, cb, arg1)
    cb({ result = 'some data' })
end)
```

---

## Full Example

### client.lua

```lua
local function onUseItem()
    if not exports.tac_bridge:IsPlayerLoaded() then return end

    local job  = exports.tac_bridge:GetJobName()
    local cash = exports.tac_bridge:GetMoney('cash')

    if job ~= 'police' then
        exports.tac_bridge:Notify('You are not a cop!', 'error')
        return
    end

    exports.tac_bridge:Progress({
        label           = 'Checking vehicle...',
        duration        = 3000,
        disableMovement = true,
    }, function(completed)
        if not completed then return end

        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        local plate   = GetVehicleNumberPlateText(vehicle)
        local fuel    = exports.tac_bridge:GetFuel(vehicle)
        local hasKeys = exports.tac_bridge:HasVehicleKeys(plate)

        exports.tac_bridge:TriggerCallback('myresource:checkPlate', function(result)
            exports.tac_bridge:Notify(result.message, result.type)
        end, plate)
    end)
end
```

### server.lua

```lua
exports.tac_bridge:RegisterCallback('myresource:checkPlate', function(src, cb, plate)
    local job   = exports.tac_bridge:GetJobName(src)
    local name  = exports.tac_bridge:GetName(src)
    local grade = exports.tac_bridge:GetJobGrade(src)

    if job ~= 'police' or grade < 2 then
        return cb({ message = 'Access denied', type = 'error' })
    end

    -- Give a reward
    exports.tac_bridge:AddMoney(src, 'cash', 100, 'plate_check_fee')
    exports.tac_bridge:AddItem(src, 'evidence_bag', 1)
    exports.tac_bridge:GiveVehicleKeys(src, plate)

    exports.tac_bridge:Notify(src, ('Officer %s checked plate %s'):format(name, plate), 'success')
    cb({ message = ('Plate %s — cleared'):format(plate), type = 'success' })
end)
```

---

## Mythic Note

`mythic-base` has **no built-in money, job, or inventory system** — those live in separate `mythic-*` component resources. The bridge provides the DataStore player access and resolved account keys, but the money/job/inventory functions return stubs (`0` / `false`) by default.

To wire up your Mythic money component, override the relevant functions **after** tac_bridge loads:

```lua
-- In your resource's server.lua
Bridge.Server.AddMoney = function(src, account, amount, reason)
    local key = Bridge.Config.Accounts[account] and Bridge.Config.Accounts[account].mythic or account
    -- call your COMPONENTS.Money or mythic-economy component here
    COMPONENTS.Economy:AddMoney(src, key, amount, reason)
    return true
end
```
