-- Ultra DC-Log Client Script
-- Advanced Discord Logging System for FiveM (Client Side)

-- Export function for client-side logging
exports('LogToDiscord', function(webhook, title, description, color, fields, footer)
    TriggerServerEvent('UltraDC:ClientLogToDiscord', webhook, title, description, color, fields, footer)
end)

-- Export function for custom client-side logging with player info
exports('LogCustom', function(title, description, color, fields, footer, webhookType)
    local playerId = GetPlayerServerId(PlayerId())
    local playerName = GetPlayerName(PlayerId())
    
    -- Add player info to fields if not already present
    local logFields = fields or {}
    local hasPlayerInfo = false
    
    for i, field in ipairs(logFields) do
        if field.name == "Player" or field.name == "Player Name" then
            hasPlayerInfo = true
            break
        end
    end
    
    if not hasPlayerInfo then
        table.insert(logFields, {
            ["name"] = "Player",
            ["value"] = playerName .. " (ID: " .. playerId .. ")",
            ["inline"] = true
        })
    end
    
    TriggerServerEvent('UltraDC:ClientLogToDiscord', webhookType, title, description, color, logFields, footer)
end)

-- Export function for logging with automatic player context
exports('LogWithContext', function(title, description, color, additionalFields, webhookType)
    local playerId = GetPlayerServerId(PlayerId())
    local playerName = GetPlayerName(PlayerId())
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    
    local fields = {
        {
            ["name"] = "Player",
            ["value"] = playerName .. " (ID: " .. playerId .. ")",
            ["inline"] = true
        },
        {
            ["name"] = "Location",
            ["value"] = string.format("X: %.2f, Y: %.2f, Z: %.2f", coords.x, coords.y, coords.z),
            ["inline"] = true
        }
    }
    
    -- Add additional fields if provided
    if additionalFields then
        for i, field in ipairs(additionalFields) do
            table.insert(fields, field)
        end
    end
    
    TriggerServerEvent('UltraDC:ClientLogToDiscord', webhookType, title, description, color, fields, nil)
end)

print("^2[Ultra DC-Log Client]^7 Client-side logging system loaded successfully!")

