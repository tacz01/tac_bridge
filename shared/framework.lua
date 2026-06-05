--[[
    tac_bridge — shared/framework.lua
    Auto-detects which framework is active and exposes Bridge.Framework.

    Supported frameworks:
      'qbx'    — Qbox  (qbx_core)            github.com/Qbox-project
      'qb'     — QBCore (qb-core)            github.com/qbcore-framework
      'esx'    — ESX Legacy (es_extended)    github.com/esx-framework
      'ox'     — ox_core (ARCHIVED Apr 2025) github.com/overextended / github.com/esx-framework fork
      'nd'     — ND Framework (ND_Core)      github.com/ND-Framework
      'mythic' — Mythic Framework (mythic-base) github.com/Mythic-Framework
                 NOTE: mythic-base has no built-in money/job system.
                 Money and jobs live in separate Mythic component resources.
                 Override Bridge.Server/Client functions where needed.
]]

Bridge = Bridge or {}

local function detectFramework()
    if Bridge.Config.ForceFramework then
        return Bridge.Config.ForceFramework
    end

    -- QBX must come before QBCore — qbx servers also expose a qb-core shim
    if GetResourceState('qbx_core')   == 'started' then return 'qbx'    end
    if GetResourceState('qb-core')    == 'started' then return 'qb'     end
    if GetResourceState('es_extended')== 'started' then return 'esx'    end
    if GetResourceState('ox_core')    == 'started' then return 'ox'     end
    if GetResourceState('ND_Core')    == 'started' then return 'nd'     end
    if GetResourceState('mythic-base')== 'started' then return 'mythic' end

    print('^1[tac_bridge] WARNING: No supported framework detected.^0')
    return 'unknown'
end

Bridge.Framework = detectFramework()
print(string.format('^2[tac_bridge] Detected framework: %s^0', Bridge.Framework))
