--[[
    tac_bridge — server/bridge.lua

    Unified server-side API verified against real framework source code:
      • QBCore  — github.com/qbcore-framework/qb-core  (player.lua confirmed)
      • QBX     — github.com/Qbox-project/qbx_core     (player.lua confirmed)
      • ESX     — github.com/esx-framework/esx_core    (es_extended)
      • ox_core — github.com/overextended/ox_core      (archived Apr 2025; esx-framework fork active)
      • ND      — github.com/ND-Framework/ND_Core      (player.lua confirmed)
      • Mythic  — github.com/Mythic-Framework/mythic-base
                  NOTE: mythic-base has NO built-in money/job API.
                  Player data uses DataStore: player:GetData(key) / player:SetData(key, val).
                  Money and job logic lives in separate mythic-* component resources.
                  Override Bridge.Server.AddMoney / RemoveMoney / SetJob for your server.

    ┌──────────────────────────────────────────────────────────────────────┐
    │  Bridge.Server.GetPlayer(src)              → fw player obj          │
    │  Bridge.Server.GetPlayerByCitizenId(cid)   → fw player obj          │
    │  Bridge.Server.GetIdentifier(src)          → string                 │
    │  Bridge.Server.GetName(src)                → string                 │
    │  Bridge.Server.GetJob(src)                 → { name, label, grade } │
    │  Bridge.Server.GetGang(src)                → { name, label, grade } │
    │  Bridge.Server.GetMoney(src, acct)         → number                 │
    │  Bridge.Server.AddMoney(src, acct, amt, reason)   → bool            │
    │  Bridge.Server.RemoveMoney(src, acct, amt, reason) → bool           │
    │  Bridge.Server.SetMoney(src, acct, amt, reason)   → bool  [QB/QBX] │
    │  Bridge.Server.SetJob(src, job, grade)     → bool                   │
    │  Bridge.Server.SetGang(src, gang, grade)   → bool                   │
    │  Bridge.Server.SetMetaData(src, key, val)  → bool                   │
    │  Bridge.Server.SavePlayer(src)             → bool                   │
    │  Bridge.Server.HasItem(src, item)          → bool                   │
    │  Bridge.Server.GetItemCount(src, item)     → number                 │
    │  Bridge.Server.AddItem(src, item, amt)     → bool                   │
    │  Bridge.Server.RemoveItem(src, item, amt)  → bool                   │
    │  Bridge.Server.RegisterCallback(name, handler)                      │
    │  Bridge.Server.Notify(src, msg, type, dur)                          │
    │  Bridge.Server.GetAllPlayers()             → table of src IDs       │
    │  Bridge.Server.OnPlayerUpdated(src, key, value)  — hookable         │
    │  Bridge.Server.OnMoneyChange(src, acct, amt, action, reason) — hook │
    └──────────────────────────────────────────────────────────────────────┘
]]

Bridge        = Bridge or {}
Bridge.Server = Bridge.Server or {}

local fw  = Bridge.Framework
local cfg = Bridge.Config

-- ─────────────────────────────────────────────
-- Internal: core object (lazy, nil for ND/Mythic which are globals)
-- ─────────────────────────────────────────────
local _core = nil
local function getCore()
    if _core then return _core end
    if fw == 'qbx' then
        -- QBX removed GetCoreObject server-side — it is purely export-based.
        _core = true
    elseif fw == 'qb' then
        _core = exports['qb-core']:GetCoreObject()
    elseif fw == 'esx' then
        _core = exports['es_extended']:getSharedObject()
    elseif fw == 'ox' or fw == 'nd' or fw == 'mythic' then
        _core = true  -- purely export/global-based
    end
    return _core
end

-- ─────────────────────────────────────────────
-- Internal: QB helper — new flat API with .Functions fallback
--   QB's export buildInterface() exposes both player.Method() and player.Functions.Method()
-- ─────────────────────────────────────────────
local function qbCall(player, method, ...)
    if player[method] then
        return player[method](...)
    elseif player.Functions and player.Functions[method] then
        return player.Functions[method](...)
    end
    return nil
end

-- ─────────────────────────────────────────────
-- GetPlayer(src) — raw framework player object
-- ─────────────────────────────────────────────
function Bridge.Server.GetPlayer(src)
    getCore()
    if fw == 'qbx' then
        -- QBX: direct export only (GetCoreObject removed server-side)
        return exports.qbx_core:GetPlayer(src)
    elseif fw == 'qb' then
        -- New flat export; falls back to core object for older QB builds
        local ok, p = pcall(function() return exports['qb-core']:GetPlayer(src) end)
        if ok and p then return p end
        return _core.Functions.GetPlayer(src)
    elseif fw == 'esx' then
        return _core.GetPlayerFromId(src)
    elseif fw == 'ox' then
        return exports.ox_core:GetPlayer(src)
    elseif fw == 'nd' then
        return exports['ND_Core']:getPlayer(src)
    elseif fw == 'mythic' then
        -- mythic-base: players stored in COMPONENTS.Players global table
        return COMPONENTS and COMPONENTS.Players and COMPONENTS.Players[src] or nil
    end
    return nil
end

-- ─────────────────────────────────────────────
-- GetPlayerByCitizenId(cid)
-- ─────────────────────────────────────────────
function Bridge.Server.GetPlayerByCitizenId(cid)
    getCore()
    if fw == 'qbx' then
        return exports.qbx_core:GetPlayerByCitizenId(cid)
    elseif fw == 'qb' then
        local ok, p = pcall(function() return exports['qb-core']:GetPlayerByCitizenId(cid) end)
        if ok and p then return p end
        return _core.Functions.GetPlayerByCitizenId(cid)
    elseif fw == 'esx' then
        for _, s in ipairs(_core.GetPlayers()) do
            local p = _core.GetPlayerFromId(s)
            if p and p.identifier == cid then return p end
        end
    elseif fw == 'ox' then
        return exports.ox_core:GetPlayerFromCharId(cid)
    elseif fw == 'nd' then
        for _, p in pairs(exports['ND_Core']:getPlayers()) do
            if p.identifier == cid then return p end
        end
    elseif fw == 'mythic' then
        if COMPONENTS and COMPONENTS.Players then
            for _, p in pairs(COMPONENTS.Players) do
                if p:GetData('AccountID') == cid then return p end
            end
        end
    end
    return nil
end

-- ─────────────────────────────────────────────
-- GetIdentifier
-- ─────────────────────────────────────────────
function Bridge.Server.GetIdentifier(src)
    local player = Bridge.Server.GetPlayer(src)
    if not player then return nil end
    if fw == 'qbx' or fw == 'qb' then
        return player.PlayerData.citizenid
    elseif fw == 'esx' then
        return player.identifier
    elseif fw == 'ox' then
        -- ox_core: player.stateId (citizenid equiv) or player.identifier (license)
        return player.stateId or player.identifier
    elseif fw == 'nd' then
        return player.identifier
    elseif fw == 'mythic' then
        -- mythic-base: AccountID is the primary identifier (MongoDB _id)
        return player:GetData('AccountID')
    end
    return nil
end

-- ─────────────────────────────────────────────
-- GetName
-- ─────────────────────────────────────────────
function Bridge.Server.GetName(src)
    local player = Bridge.Server.GetPlayer(src)
    if not player then return 'Unknown' end
    if fw == 'qbx' or fw == 'qb' then
        local ci = player.PlayerData.charinfo
        return ci and ((ci.firstname or '') .. ' ' .. (ci.lastname or '')) or 'Unknown'
    elseif fw == 'esx' then
        return player.getName()
    elseif fw == 'ox' then
        -- ox_core stores firstname/lastname on the player object
        return ((player.firstname or '') .. ' ' .. (player.lastname or '')):gsub('^%s+$', 'Unknown')
    elseif fw == 'nd' then
        return player.fullname or ((player.firstname or '') .. ' ' .. (player.lastname or ''))
    elseif fw == 'mythic' then
        -- mythic-base: character data in DataStore
        local char = player:GetData('Character')
        if char then
            return ((char:GetData('First') or '') .. ' ' .. (char:GetData('Last') or ''))
        end
        return player:GetData('Name') or 'Unknown'
    end
    return 'Unknown'
end

-- ─────────────────────────────────────────────
-- GetJob → { name, label, grade, gradeLabel, onDuty, isBoss }
-- Mythic: no built-in jobs in mythic-base — returns stub; implement via mythic-jobs
-- ox_core: uses groups system; type='job' group is the job
-- ─────────────────────────────────────────────
function Bridge.Server.GetJob(src)
    local player = Bridge.Server.GetPlayer(src)
    if not player then return {} end
    if fw == 'qbx' or fw == 'qb' then
        local j = player.PlayerData.job or {}
        return { name = j.name, label = j.label, grade = j.grade and j.grade.level, gradeLabel = j.grade and j.grade.name, onDuty = j.onduty, isBoss = j.isboss }
    elseif fw == 'esx' then
        local j = player.getJob()
        return { name = j.name, label = j.label, grade = j.grade, gradeLabel = j.grade_label, onDuty = true }
    elseif fw == 'ox' then
        -- ox_core groups: getGroupByType('job') returns name, grade
        local name, grade = player:getGroupByType('job')
        if name then
            return { name = name, label = name, grade = grade, gradeLabel = tostring(grade), onDuty = true }
        end
        return { name = 'unemployed', label = 'Unemployed', grade = 0, gradeLabel = '0', onDuty = false }
    elseif fw == 'nd' then
        local j = player.jobInfo or {}
        local jobName, jobGroup = player.getJob()
        j = jobGroup or j
        return { name = jobName or player.job, label = j.label or player.job, grade = j.rank, gradeLabel = j.rankName, onDuty = true, isBoss = j.isBoss }
    elseif fw == 'mythic' then
        -- mythic-base has no job system; implement via mythic-jobs COMPONENTS
        -- Stub: override this function in your resource
        return { name = 'unknown', label = 'Unknown', grade = 0, gradeLabel = '0', onDuty = false }
    end
    return {}
end

-- ─────────────────────────────────────────────
-- GetGang → { name, label, grade, gradeLabel }
-- ox_core: type='gang' group; ND: first non-job group; Mythic: stub
-- ─────────────────────────────────────────────
function Bridge.Server.GetGang(src)
    local player = Bridge.Server.GetPlayer(src)
    if not player then return {} end
    if fw == 'qbx' or fw == 'qb' then
        local g = player.PlayerData.gang or {}
        return { name = g.name, label = g.label, grade = g.grade and g.grade.level, gradeLabel = g.grade and g.grade.name }
    elseif fw == 'esx' then
        return { name = 'none', label = 'None', grade = 0, gradeLabel = 'None' }
    elseif fw == 'ox' then
        local name, grade = player:getGroupByType('gang')
        if name then return { name = name, label = name, grade = grade, gradeLabel = tostring(grade) } end
        return { name = 'none', label = 'None', grade = 0, gradeLabel = 'None' }
    elseif fw == 'nd' then
        if player.groups then
            for _, g in pairs(player.groups) do
                if not g.isJob then return { name = g.name, label = g.label, grade = g.rank, gradeLabel = g.rankName } end
            end
        end
        return { name = 'none', label = 'None', grade = 0, gradeLabel = 'None' }
    elseif fw == 'mythic' then
        return { name = 'none', label = 'None', grade = 0, gradeLabel = 'None' }
    end
    return {}
end

-- ─────────────────────────────────────────────
-- SetJob(src, jobName, grade)
-- ─────────────────────────────────────────────
function Bridge.Server.SetJob(src, jobName, grade)
    grade = grade or 0
    local player = Bridge.Server.GetPlayer(src)
    if not player then return false end
    if fw == 'qbx' or fw == 'qb' then
        return qbCall(player, 'SetJob', jobName, grade)
    elseif fw == 'esx' then
        player.setJob(jobName, grade); return true
    elseif fw == 'ox' then
        -- ox_core: setGroup(name, grade) — groups replace jobs
        return exports.ox_core:SetGroup(src, jobName, grade)
    elseif fw == 'nd' then
        return player.setJob(jobName, grade) ~= nil
    elseif fw == 'mythic' then
        -- Override this for your mythic-jobs implementation
        return false
    end
    return false
end

-- ─────────────────────────────────────────────
-- SetGang(src, gangName, grade)
-- ─────────────────────────────────────────────
function Bridge.Server.SetGang(src, gangName, grade)
    grade = grade or 0
    local player = Bridge.Server.GetPlayer(src)
    if not player then return false end
    if fw == 'qbx' or fw == 'qb' then
        return qbCall(player, 'SetGang', gangName, grade)
    elseif fw == 'esx' then
        return false
    elseif fw == 'ox' then
        return exports.ox_core:SetGroup(src, gangName, grade)
    elseif fw == 'nd' then
        return player.addGroup(gangName, grade) ~= nil
    elseif fw == 'mythic' then
        return false
    end
    return false
end

-- ─────────────────────────────────────────────
-- GetMoney(src, account)  account: 'cash'|'bank'|'black'
-- Mythic: no base money — stub returning 0; override per your server
-- ox_core: uses AddAccountBalance/RemoveAccountBalance exports
-- ─────────────────────────────────────────────
function Bridge.Server.GetMoney(src, account)
    account = account or 'cash'
    local player = Bridge.Server.GetPlayer(src)
    if not player then return 0 end

    if fw == 'qbx' or fw == 'qb' then
        local key = cfg.Accounts[account] and cfg.Accounts[account].qb or account
        return qbCall(player, 'GetMoney', key) or 0
    elseif fw == 'esx' then
        local key = cfg.Accounts[account] and cfg.Accounts[account].esx or account
        if account == 'cash' then return player.getMoney() or 0 end
        local acc = player.getAccount(key)
        return acc and acc.money or 0
    elseif fw == 'ox' then
        local key = cfg.Accounts[account] and cfg.Accounts[account].ox or account
        local bal = exports.ox_core:GetAccountBalance(src, key)
        return bal or 0
    elseif fw == 'nd' then
        local key = cfg.Accounts[account] and cfg.Accounts[account].nd or account
        return player[key] or 0
    elseif fw == 'mythic' then
        -- mythic-base has no built-in money. Key resolved for your override:
        local key = cfg.Accounts[account] and cfg.Accounts[account].mythic or account
        -- Override Bridge.Server.GetMoney and use player:GetData(key) via your mythic-* money component.
        return 0
    end
    return 0
end

-- ─────────────────────────────────────────────
-- AddMoney(src, account, amount, reason)
-- ─────────────────────────────────────────────
function Bridge.Server.AddMoney(src, account, amount, reason)
    account = account or 'cash'
    reason  = reason  or 'tac_bridge'
    local player = Bridge.Server.GetPlayer(src)
    if not player then return false end

    if fw == 'qbx' or fw == 'qb' then
        local key = cfg.Accounts[account] and cfg.Accounts[account].qb or account
        return qbCall(player, 'AddMoney', key, amount, reason)
    elseif fw == 'esx' then
        local key = cfg.Accounts[account] and cfg.Accounts[account].esx or account
        if account == 'cash' then player.addMoney(amount) else player.addAccountMoney(key, amount) end
        return true
    elseif fw == 'ox' then
        local key = cfg.Accounts[account] and cfg.Accounts[account].ox or account
        return exports.ox_core:AddAccountBalance(src, key, amount)
    elseif fw == 'nd' then
        local key = cfg.Accounts[account] and cfg.Accounts[account].nd or account
        return player.addMoney(key, amount, reason) == true
    elseif fw == 'mythic' then
        local key = cfg.Accounts[account] and cfg.Accounts[account].mythic or account
        -- Override Bridge.Server.AddMoney and call your mythic-* money component with key/amount/reason.
        return false
    end
    return false
end

-- ─────────────────────────────────────────────
-- RemoveMoney(src, account, amount, reason)
-- ─────────────────────────────────────────────
function Bridge.Server.RemoveMoney(src, account, amount, reason)
    account = account or 'cash'
    reason  = reason  or 'tac_bridge'
    local player = Bridge.Server.GetPlayer(src)
    if not player then return false end

    if fw == 'qbx' or fw == 'qb' then
        local key = cfg.Accounts[account] and cfg.Accounts[account].qb or account
        return qbCall(player, 'RemoveMoney', key, amount, reason)
    elseif fw == 'esx' then
        local key = cfg.Accounts[account] and cfg.Accounts[account].esx or account
        if account == 'cash' then player.removeMoney(amount) else player.removeAccountMoney(key, amount) end
        return true
    elseif fw == 'ox' then
        local key = cfg.Accounts[account] and cfg.Accounts[account].ox or account
        return exports.ox_core:RemoveAccountBalance(src, key, amount)
    elseif fw == 'nd' then
        local key = cfg.Accounts[account] and cfg.Accounts[account].nd or account
        return player.deductMoney(key, amount, reason) == true
    elseif fw == 'mythic' then
        local key = cfg.Accounts[account] and cfg.Accounts[account].mythic or account
        -- Override Bridge.Server.RemoveMoney and call your mythic-* money component with key/amount/reason.
        return false
    end
    return false
end

-- ─────────────────────────────────────────────
-- SetMoney(src, account, amount, reason)  [QB/QBX confirmed in source]
-- ─────────────────────────────────────────────
function Bridge.Server.SetMoney(src, account, amount, reason)
    account = account or 'cash'
    reason  = reason  or 'tac_bridge'
    local player = Bridge.Server.GetPlayer(src)
    if not player then return false end

    if fw == 'qbx' or fw == 'qb' then
        local key = cfg.Accounts[account] and cfg.Accounts[account].qb or account
        return qbCall(player, 'SetMoney', key, amount, reason)
    elseif fw == 'ox' then
        local key = cfg.Accounts[account] and cfg.Accounts[account].ox or account
        local current = exports.ox_core:GetAccountBalance(src, key) or 0
        if amount > current then
            return exports.ox_core:AddAccountBalance(src, key, amount - current)
        elseif amount < current then
            return exports.ox_core:RemoveAccountBalance(src, key, current - amount)
        end
        return true
    elseif fw == 'mythic' then
        local key = cfg.Accounts[account] and cfg.Accounts[account].mythic or account
        -- Override Bridge.Server.SetMoney and call your mythic-* money component with key/amount/reason.
        return false
    end
    return false
end

-- ─────────────────────────────────────────────
-- SetMetaData(src, key, value)
-- ─────────────────────────────────────────────
function Bridge.Server.SetMetaData(src, key, value)
    local player = Bridge.Server.GetPlayer(src)
    if not player then return false end
    if fw == 'qbx' or fw == 'qb' then
        return qbCall(player, 'SetMetaData', key, value)
    elseif fw == 'nd' then
        player.setMetadata(key, value); return true
    elseif fw == 'mythic' then
        local char = player:GetData('Character')
        if char then char:SetData(key, value); return true end
        return false
    end
    return false
end

-- ─────────────────────────────────────────────
-- SavePlayer(src)
-- ─────────────────────────────────────────────
function Bridge.Server.SavePlayer(src)
    local player = Bridge.Server.GetPlayer(src)
    if not player then return false end
    if fw == 'qbx' or fw == 'qb' then
        return qbCall(player, 'Save')
    elseif fw == 'nd' then
        return player.save()
    end
    return false
end

-- ─────────────────────────────────────────────
-- HasItem / GetItemCount / AddItem / RemoveItem
-- ox_inventory is the standard for QBX, ox_core, ND and many ESX servers.
-- ─────────────────────────────────────────────
function Bridge.Server.HasItem(src, item)
    return Bridge.Server.GetItemCount(src, item) > 0
end

function Bridge.Server.GetItemCount(src, item)
    local player = Bridge.Server.GetPlayer(src)
    if not player then return 0 end

    if GetResourceState('ox_inventory') == 'started' then
        return exports.ox_inventory:GetItemCount(src, item) or 0
    end
    if fw == 'qbx' or fw == 'qb' then
        local it = qbCall(player, 'GetItemByName', item)
        return it and it.amount or 0
    elseif fw == 'esx' then
        local it = player.getInventoryItem(item)
        return it and it.count or 0
    end
    return 0
end

function Bridge.Server.AddItem(src, item, amount)
    amount = amount or 1
    if GetResourceState('ox_inventory') == 'started' then
        return exports.ox_inventory:AddItem(src, item, amount)
    end
    local player = Bridge.Server.GetPlayer(src)
    if not player then return false end
    if fw == 'qbx' or fw == 'qb' then
        return qbCall(player, 'AddItem', item, amount)
    elseif fw == 'esx' then
        player.addInventoryItem(item, amount); return true
    end
    return false
end

function Bridge.Server.RemoveItem(src, item, amount)
    amount = amount or 1
    if GetResourceState('ox_inventory') == 'started' then
        return exports.ox_inventory:RemoveItem(src, item, amount)
    end
    local player = Bridge.Server.GetPlayer(src)
    if not player then return false end
    if fw == 'qbx' or fw == 'qb' then
        return qbCall(player, 'RemoveItem', item, amount)
    elseif fw == 'esx' then
        player.removeInventoryItem(item, amount); return true
    end
    return false
end

-- ─────────────────────────────────────────────
-- RegisterCallback(name, handler)
--   handler(src, cb, ...) — call cb(result) to respond
--   Mythic: COMPONENTS.Callbacks:RegisterServerCallback(event, cb)
--           where cb receives (source, data, respond)
-- ─────────────────────────────────────────────
function Bridge.Server.RegisterCallback(name, handler)
    if fw == 'qbx' or fw == 'nd' or fw == 'ox' then
        -- ox_lib callbacks (lib is the ox_lib global, loaded via @ox_lib/init.lua)
        if lib and lib.callback then
            lib.callback.register(name, handler)
        else
            -- Fallback: raw net event (no return value — client must fire-and-forget or use a different pattern)
            print('^3[tac_bridge] WARNING: ox_lib not available for RegisterCallback. Add @ox_lib/init.lua to your fxmanifest or ensure ox_lib is started before tac_bridge.^0')
            RegisterNetEvent('__tac_cb:' .. name)
            AddEventHandler('__tac_cb:' .. name, function(cbId, ...)
                local src = source
                handler(src, function(result)
                    TriggerClientEvent('__tac_cbr:' .. name, src, cbId, result)
                end, ...)
            end)
        end
    elseif fw == 'qb' then
        getCore().Functions.CreateCallback(name, handler)
    elseif fw == 'esx' then
        getCore().RegisterServerCallback(name, handler)
    elseif fw == 'mythic' then
        if COMPONENTS and COMPONENTS.Callbacks then
            COMPONENTS.Callbacks:RegisterServerCallback(name, function(source, data, respond)
                handler(source, respond, data)
            end)
        end
    end
end

-- ─────────────────────────────────────────────
-- Notify(src, message, type, duration)
-- ─────────────────────────────────────────────
function Bridge.Server.Notify(src, message, notifyType, duration)
    notifyType = notifyType or 'info'
    duration   = duration   or cfg.NotifyDuration

    if GetResourceState('ox_lib') == 'started' then
        TriggerClientEvent('ox_lib:notify', src, { title = message, type = notifyType, duration = duration })
        return
    end

    if fw == 'qbx' or fw == 'qb' then
        local qbType = notifyType == 'info' and 'primary' or notifyType
        TriggerClientEvent('QBCore:Notify', src, message, qbType, duration)
    elseif fw == 'esx' then
        TriggerClientEvent('esx:showNotification', src, message, notifyType, duration)
    elseif fw == 'mythic' then
        -- Mythic uses its own notification system via COMPONENTS
        -- Trigger directly on the client
        TriggerClientEvent('Core:Client:Notify', src, { message = message, type = notifyType, duration = duration })
    end
end

-- ─────────────────────────────────────────────
-- GetAllPlayers() → table of src IDs
-- ─────────────────────────────────────────────
function Bridge.Server.GetAllPlayers()
    local result = {}
    getCore()
    if fw == 'qbx' then
        -- QBX doesn't export GetPlayers — use FiveM native which always works
        for _, s in ipairs(GetPlayers()) do result[#result+1] = tonumber(s) end
    elseif fw == 'qb' then
        local ok, list = pcall(function() return exports['qb-core']:GetPlayers() end)
        for _, s in ipairs((ok and list) or _core.Functions.GetPlayers()) do result[#result+1] = s end
    elseif fw == 'esx' then
        for _, s in ipairs(_core.GetPlayers()) do result[#result+1] = s end
    elseif fw == 'ox' then
        local players = exports.ox_core:GetPlayers()
        for i = 1, #players do result[#result+1] = players[i].source end
    elseif fw == 'nd' then
        for s in pairs(exports['ND_Core']:getPlayers()) do result[#result+1] = s end
    elseif fw == 'mythic' then
        if COMPONENTS and COMPONENTS.Players then
            for s in pairs(COMPONENTS.Players) do result[#result+1] = s end
        end
    else
        for _, s in ipairs(GetPlayers()) do result[#result+1] = tonumber(s) end
    end
    return result
end

-- ─────────────────────────────────────────────
-- OnPlayerUpdated hook
--
--   Override in your resource:
--     Bridge.Server.OnPlayerUpdated = function(src, key, value) ... end
--
--   QB/QBX keys: 'job' | 'gang' | 'money' | 'metadata' | 'all'
--   ND keys:     'job' | 'groups' | 'metadata' | 'cash' | 'bank'
--   Mythic:      fired manually from DataStore SetData events
-- ─────────────────────────────────────────────
Bridge.Server.OnPlayerUpdated = Bridge.Server.OnPlayerUpdated or function(src, key, value) end

if fw == 'qb' or fw == 'qbx' then
    AddEventHandler('QBCore:Server:OnPlayerUpdated', function(src, key, value)
        Bridge.Server.OnPlayerUpdated(src, key, value)
    end)
end

if fw == 'nd' then
    AddEventHandler('ND:updateCharacter', function(player, key)
        if not player or not player.source then return end
        Bridge.Server.OnPlayerUpdated(player.source, key or 'all', player)
    end)
end

-- ─────────────────────────────────────────────
-- OnMoneyChange hook (QB/QBX confirmed in source: QBCore:Server:OnMoneyChange)
--
--   Override in your resource:
--     Bridge.Server.OnMoneyChange = function(src, account, amount, action, reason) ... end
--
--   action: 'add' | 'remove' | 'set'
-- ─────────────────────────────────────────────
Bridge.Server.OnMoneyChange = Bridge.Server.OnMoneyChange or function(src, account, amount, action, reason) end

if fw == 'qb' or fw == 'qbx' then
    AddEventHandler('QBCore:Server:OnMoneyChange', function(src, account, amount, action, reason)
        Bridge.Server.OnMoneyChange(src, account, amount, action, reason)
    end)
end

if fw == 'nd' then
    AddEventHandler('ND:moneyChange', function(src, account, amount, action, reason)
        Bridge.Server.OnMoneyChange(src, account, amount, action, reason)
    end)
end
