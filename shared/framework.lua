--[[
    tac_bridge — shared/framework.lua
    Auto-detects which framework is active and sets Bridge.Framework.

    Supported:
      'qbx'    — Qbox  (qbx_core)
      'qb'     — QBCore (qb-core)
      'esx'    — ESX Legacy (es_extended)
      'ox'     — ox_core
      'nd'     — ND Framework (ND_Core)
      'mythic' — Mythic Framework (mythic-base)

    You can force a framework in shared/config.lua:
        Bridge.Config.ForceFramework = 'qbx'
]]

Bridge = Bridge or {}

local function detectFramework()
    if Bridge.Config.ForceFramework then
        return Bridge.Config.ForceFramework
    end

    -- QBX must come before QBCore — QBX servers expose a qb-core compat shim
    if isStarted('qbx_core')    then return 'qbx'    end
    if isStarted('qb-core')     then return 'qb'     end
    if isStarted('es_extended') then return 'esx'    end
    if isStarted('ox_core')     then return 'ox'     end
    if isStarted('ND_Core')     then return 'nd'     end
    if isStarted('mythic-base') then return 'mythic' end

    print('^1[tac_bridge] WARNING: No supported framework detected.^0')
    return 'unknown'
end

Bridge.Framework = detectFramework()
print(('^2[tac_bridge] Detected framework: %s^0'):format(Bridge.Framework))
