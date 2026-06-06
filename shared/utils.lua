--[[
    tac_bridge — shared/utils.lua
    Utility helpers used across all bridge files.
    Pattern borrowed from jim_bridge / bl_bridge.
]]

--- Returns true if a resource is currently running.
---@param resource string
---@return boolean
function isStarted(resource)
    if not resource or resource == '' then return false end
    local state = GetResourceState(resource)
    return state == 'started' or state == 'starting'
end

--- Returns the current resource name (the invoking script).
---@return string
function getScript()
    return GetCurrentResourceName()
end

--- Safe pcall-based export existence check.
---@param resource string
---@param exportName string
---@return boolean
function checkExportExists(resource, exportName)
    if not isStarted(resource) then return false end
    local ok = pcall(function()
        return exports[resource][exportName]
    end)
    return ok
end
