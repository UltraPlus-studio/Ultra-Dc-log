-- Ultra DC-Log Server Script
-- Advanced Discord Logging System for FiveM

local function GetPlayerIdentifiers(source)
    local identifiers = {}
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local identifier = GetPlayerIdentifier(source, i)
        if identifier then
            if string.find(identifier, "steam:") then
                identifiers.steam = identifier
            elseif string.find(identifier, "license:") then
                identifiers.license = identifier
            elseif string.find(identifier, "discord:") then
                identifiers.discord = identifier
            elseif string.find(identifier, "fivem:") then
                identifiers.fivem = identifier
            elseif string.find(identifier, "ip:") then
                identifiers.ip = identifier
            end
        end
    end
    return identifiers
end

local function GetPlayerName(source)
    return GetPlayerName(source) or "Unknown"
end

local function GetFormattedTime()
    local date = os.date("*t")
    return string.format("%02d:%02d:%02d", date.hour, date.min, date.sec)
end

local function GetFormattedDate()
    local date = os.date("*t")
    return string.format("%02d/%02d/%04d", date.day, date.month, date.year)
end

local function SendToDiscord(webhook, title, description, color, fields, footer)
    local embed = {
        {
            ["title"] = title,
            ["description"] = description,
            ["type"] = "rich",
            ["color"] = color or Config.Colors.Info,
            ["fields"] = fields or {},
            ["footer"] = {
                ["text"] = footer or Config.ServerName .. " • " .. GetFormattedDate() .. " " .. GetFormattedTime(),
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }
    
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({
        username = Config.ServerName,
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

-- Player Connect
if Config.LogTypes.PlayerConnect then
    AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
        local source = source
        local identifiers = GetPlayerIdentifiers(source)
        
        local fields = {
            {
                ["name"] = "Player Name",
                ["value"] = name,
                ["inline"] = true
            },
            {
                ["name"] = "Server ID",
                ["value"] = tostring(source),
                ["inline"] = true
            }
        }
        
        if identifiers.steam then
            table.insert(fields, {
                ["name"] = "Steam ID",
                ["value"] = identifiers.steam,
                ["inline"] = true
            })
        end
        
        if identifiers.license then
            table.insert(fields, {
                ["name"] = "License",
                ["value"] = identifiers.license,
                ["inline"] = true
            })
        end
        
        if identifiers.discord then
            table.insert(fields, {
                ["name"] = "Discord ID",
                ["value"] = "<@" .. string.gsub(identifiers.discord, "discord:", "") .. ">",
                ["inline"] = true
            })
        end
        
        if identifiers.ip then
            table.insert(fields, {
                ["name"] = "IP Address",
                ["value"] = string.gsub(identifiers.ip, "ip:", ""),
                ["inline"] = true
            })
        end
        
        local webhook = Config.Webhooks.Connections ~= "YOUR_DISCORD_WEBHOOK_URL_HERE" and Config.Webhooks.Connections or Config.Webhooks.Main
        SendToDiscord(webhook, "🔵 Player Connecting", name .. " is connecting to the server", Config.Colors.Connect, fields)
    end)
end

-- Player Disconnect
if Config.LogTypes.PlayerDisconnect then
    AddEventHandler('playerDropped', function(reason)
        local source = source
        local name = GetPlayerName(source)
        local identifiers = GetPlayerIdentifiers(source)
        
        local fields = {
            {
                ["name"] = "Player Name",
                ["value"] = name,
                ["inline"] = true
            },
            {
                ["name"] = "Server ID",
                ["value"] = tostring(source),
                ["inline"] = true
            },
            {
                ["name"] = "Reason",
                ["value"] = reason or "Unknown",
                ["inline"] = false
            }
        }
        
        if identifiers.steam then
            table.insert(fields, {
                ["name"] = "Steam ID",
                ["value"] = identifiers.steam,
                ["inline"] = true
            })
        end
        
        local webhook = Config.Webhooks.Connections ~= "YOUR_DISCORD_WEBHOOK_URL_HERE" and Config.Webhooks.Connections or Config.Webhooks.Main
        SendToDiscord(webhook, "🔴 Player Disconnected", name .. " left the server", Config.Colors.Disconnect, fields)
    end)
end

-- Chat Messages
if Config.LogTypes.PlayerChat then
    AddEventHandler('chatMessage', function(source, name, message)
        local identifiers = GetPlayerIdentifiers(source)
        
        local fields = {
            {
                ["name"] = "Player",
                ["value"] = name .. " (ID: " .. source .. ")",
                ["inline"] = true
            },
            {
                ["name"] = "Message",
                ["value"] = message,
                ["inline"] = false
            }
        }
        
        if identifiers.discord then
            table.insert(fields, {
                ["name"] = "Discord",
                ["value"] = "<@" .. string.gsub(identifiers.discord, "discord:", "") .. ">",
                ["inline"] = true
            })
        end
        
        local webhook = Config.Webhooks.Chat ~= "YOUR_DISCORD_WEBHOOK_URL_HERE" and Config.Webhooks.Chat or Config.Webhooks.Main
        SendToDiscord(webhook, "💬 Chat Message", name .. " said: " .. message, Config.Colors.Chat, fields)
    end)
end

-- Player Death
if Config.LogTypes.PlayerDeath then
    AddEventHandler('baseevents:onPlayerDied', function(killerType, coords)
        local source = source
        local name = GetPlayerName(source)
        
        local fields = {
            {
                ["name"] = "Player",
                ["value"] = name .. " (ID: " .. source .. ")",
                ["inline"] = true
            },
            {
                ["name"] = "Death Type",
                ["value"] = killerType or "Unknown",
                ["inline"] = true
            }
        }
        
        local webhook = Config.Webhooks.Deaths ~= "YOUR_DISCORD_WEBHOOK_URL_HERE" and Config.Webhooks.Deaths or Config.Webhooks.Main
        SendToDiscord(webhook, "💀 Player Died", name .. " has died", Config.Colors.Death, fields)
    end)
end

-- Player Kill
if Config.LogTypes.PlayerKill then
    AddEventHandler('baseevents:onPlayerKilled', function(killerId, deathData)
        local source = source
        local victimName = GetPlayerName(source)
        local killerName = killerId and GetPlayerName(killerId) or "Unknown"
        
        local fields = {
            {
                ["name"] = "Victim",
                ["value"] = victimName .. " (ID: " .. source .. ")",
                ["inline"] = true
            },
            {
                ["name"] = "Killer",
                ["value"] = killerName .. (killerId and " (ID: " .. killerId .. ")" or ""),
                ["inline"] = true
            }
        }
        
        if deathData and deathData.weaponHash then
            table.insert(fields, {
                ["name"] = "Weapon",
                ["value"] = tostring(deathData.weaponHash),
                ["inline"] = true
            })
        end
        
        local webhook = Config.Webhooks.Deaths ~= "YOUR_DISCORD_WEBHOOK_URL_HERE" and Config.Webhooks.Deaths or Config.Webhooks.Main
        SendToDiscord(webhook, "⚔️ Player Killed", victimName .. " was killed by " .. killerName, Config.Colors.Kill, fields)
    end)
end

-- Commands
if Config.LogTypes.PlayerCommand then
    RegisterServerEvent('UltraDC:LogCommand')
    AddEventHandler('UltraDC:LogCommand', function(command, args)
        local source = source
        local name = GetPlayerName(source)
        local identifiers = GetPlayerIdentifiers(source)
        
        local fields = {
            {
                ["name"] = "Player",
                ["value"] = name .. " (ID: " .. source .. ")",
                ["inline"] = true
            },
            {
                ["name"] = "Command",
                ["value"] = "/" .. command,
                ["inline"] = true
            },
            {
                ["name"] = "Arguments",
                ["value"] = args and table.concat(args, " ") or "None",
                ["inline"] = false
            }
        }
        
        if identifiers.discord then
            table.insert(fields, {
                ["name"] = "Discord",
                ["value"] = "<@" .. string.gsub(identifiers.discord, "discord:", "") .. ">",
                ["inline"] = true
            })
        end
        
        local webhook = Config.Webhooks.Commands ~= "YOUR_DISCORD_WEBHOOK_URL_HERE" and Config.Webhooks.Commands or Config.Webhooks.Main
        SendToDiscord(webhook, "⌨️ Command Used", name .. " used command: /" .. command, Config.Colors.Command, fields)
    end)
end

-- Resource Start/Stop
if Config.LogTypes.ResourceStart then
    AddEventHandler('onResourceStart', function(resourceName)
        if resourceName == GetCurrentResourceName() then return end
        
        local fields = {
            {
                ["name"] = "Resource",
                ["value"] = resourceName,
                ["inline"] = true
            }
        }
        
        SendToDiscord(Config.Webhooks.Main, "✅ Resource Started", "Resource **" .. resourceName .. "** has been started", Config.Colors.Info, fields)
    end)
end

if Config.LogTypes.ResourceStop then
    AddEventHandler('onResourceStop', function(resourceName)
        if resourceName == GetCurrentResourceName() then return end
        
        local fields = {
            {
                ["name"] = "Resource",
                ["value"] = resourceName,
                ["inline"] = true
            }
        }
        
        SendToDiscord(Config.Webhooks.Main, "❌ Resource Stopped", "Resource **" .. resourceName .. "** has been stopped", Config.Colors.Info, fields)
    end)
end

-- Admin Actions (Example - you can customize this)
if Config.LogTypes.AdminActions then
    RegisterServerEvent('UltraDC:LogAdminAction')
    AddEventHandler('UltraDC:LogAdminAction', function(action, target, details)
        local source = source
        local name = GetPlayerName(source)
        local identifiers = GetPlayerIdentifiers(source)
        
        local fields = {
            {
                ["name"] = "Admin",
                ["value"] = name .. " (ID: " .. source .. ")",
                ["inline"] = true
            },
            {
                ["name"] = "Action",
                ["value"] = action,
                ["inline"] = true
            }
        }
        
        if target then
            table.insert(fields, {
                ["name"] = "Target",
                ["value"] = target,
                ["inline"] = true
            })
        end
        
        if details then
            table.insert(fields, {
                ["name"] = "Details",
                ["value"] = details,
                ["inline"] = false
            })
        end
        
        if identifiers.discord then
            table.insert(fields, {
                ["name"] = "Discord",
                ["value"] = "<@" .. string.gsub(identifiers.discord, "discord:", "") .. ">",
                ["inline"] = true
            })
        end
        
        local webhook = Config.Webhooks.Admin ~= "YOUR_DISCORD_WEBHOOK_URL_HERE" and Config.Webhooks.Admin or Config.Webhooks.Main
        SendToDiscord(webhook, "🛡️ Admin Action", name .. " performed: " .. action, Config.Colors.Admin, fields)
    end)
end

-- ============================================
-- EXPORT FUNCTIONS (Server Side)
-- ============================================

-- Main export function for logging to Discord
exports('LogToDiscord', function(webhook, title, description, color, fields, footer)
    local targetWebhook = webhook or Config.Webhooks.Main
    SendToDiscord(targetWebhook, title, description, color, fields, footer)
end)

-- Export function for logging commands
exports('LogCommand', function(source, command, args)
    if not Config.LogTypes.PlayerCommand then return end
    
    local name = GetPlayerName(source)
    local identifiers = GetPlayerIdentifiers(source)
    
    local fields = {
        {
            ["name"] = "Player",
            ["value"] = name .. " (ID: " .. source .. ")",
            ["inline"] = true
        },
        {
            ["name"] = "Command",
            ["value"] = "/" .. command,
            ["inline"] = true
        },
        {
            ["name"] = "Arguments",
            ["value"] = args and table.concat(args, " ") or "None",
            ["inline"] = false
        }
    }
    
    if identifiers.discord then
        table.insert(fields, {
            ["name"] = "Discord",
            ["value"] = "<@" .. string.gsub(identifiers.discord, "discord:", "") .. ">",
            ["inline"] = true
        })
    end
    
    local webhook = Config.Webhooks.Commands ~= "YOUR_DISCORD_WEBHOOK_URL_HERE" and Config.Webhooks.Commands or Config.Webhooks.Main
    SendToDiscord(webhook, "⌨️ Command Used", name .. " used command: /" .. command, Config.Colors.Command, fields)
end)

-- Export function for logging admin actions
exports('LogAdminAction', function(source, action, target, details)
    if not Config.LogTypes.AdminActions then return end
    
    local name = GetPlayerName(source)
    local identifiers = GetPlayerIdentifiers(source)
    
    local fields = {
        {
            ["name"] = "Admin",
            ["value"] = name .. " (ID: " .. source .. ")",
            ["inline"] = true
        },
        {
            ["name"] = "Action",
            ["value"] = action,
            ["inline"] = true
        }
    }
    
    if target then
        table.insert(fields, {
            ["name"] = "Target",
            ["value"] = target,
            ["inline"] = true
        })
    end
    
    if details then
        table.insert(fields, {
            ["name"] = "Details",
            ["value"] = details,
            ["inline"] = false
        })
    end
    
    if identifiers.discord then
        table.insert(fields, {
            ["name"] = "Discord",
            ["value"] = "<@" .. string.gsub(identifiers.discord, "discord:", "") .. ">",
            ["inline"] = true
        })
    end
    
    local webhook = Config.Webhooks.Admin ~= "YOUR_DISCORD_WEBHOOK_URL_HERE" and Config.Webhooks.Admin or Config.Webhooks.Main
    SendToDiscord(webhook, "🛡️ Admin Action", name .. " performed: " .. action, Config.Colors.Admin, fields)
end)

-- Export function for custom logging with automatic player info
exports('LogCustom', function(source, title, description, color, fields, footer, webhookType)
    local name = source and GetPlayerName(source) or "System"
    local playerId = source or "N/A"
    
    local logFields = fields or {}
    
    -- Add player info if source is provided
    if source then
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
                ["value"] = name .. " (ID: " .. playerId .. ")",
                ["inline"] = true
            })
        end
    end
    
    -- Determine webhook
    local targetWebhook = Config.Webhooks.Main
    if webhookType and Config.Webhooks[webhookType] and Config.Webhooks[webhookType] ~= "YOUR_DISCORD_WEBHOOK_URL_HERE" then
        targetWebhook = Config.Webhooks[webhookType]
    end
    
    SendToDiscord(targetWebhook, title, description, color, logFields, footer)
end)

-- Export function for logging with player identifiers
exports('LogWithIdentifiers', function(source, title, description, color, additionalFields, webhookType)
    local name = GetPlayerName(source)
    local identifiers = GetPlayerIdentifiers(source)
    
    local fields = {
        {
            ["name"] = "Player",
            ["value"] = name .. " (ID: " .. source .. ")",
            ["inline"] = true
        }
    }
    
    if identifiers.steam then
        table.insert(fields, {
            ["name"] = "Steam ID",
            ["value"] = identifiers.steam,
            ["inline"] = true
        })
    end
    
    if identifiers.license then
        table.insert(fields, {
            ["name"] = "License",
            ["value"] = identifiers.license,
            ["inline"] = true
        })
    end
    
    if identifiers.discord then
        table.insert(fields, {
            ["name"] = "Discord",
            ["value"] = "<@" .. string.gsub(identifiers.discord, "discord:", "") .. ">",
            ["inline"] = true
        })
    end
    
    if identifiers.ip then
        table.insert(fields, {
            ["name"] = "IP Address",
            ["value"] = string.gsub(identifiers.ip, "ip:", ""),
            ["inline"] = true
        })
    end
    
    -- Add additional fields
    if additionalFields then
        for i, field in ipairs(additionalFields) do
            table.insert(fields, field)
        end
    end
    
    local targetWebhook = Config.Webhooks.Main
    if webhookType and Config.Webhooks[webhookType] and Config.Webhooks[webhookType] ~= "YOUR_DISCORD_WEBHOOK_URL_HERE" then
        targetWebhook = Config.Webhooks[webhookType]
    end
    
    SendToDiscord(targetWebhook, title, description, color, fields, nil)
end)

-- ============================================
-- CLIENT EVENT HANDLERS
-- ============================================

-- Handle client-side log requests
RegisterServerEvent('UltraDC:ClientLogToDiscord')
AddEventHandler('UltraDC:ClientLogToDiscord', function(webhook, title, description, color, fields, footer)
    local source = source
    local playerId = source
    local playerName = GetPlayerName(source)
    local identifiers = GetPlayerIdentifiers(source)
    
    -- Determine webhook
    local targetWebhook = Config.Webhooks.Main
    if type(webhook) == "string" and webhook ~= "" then
        -- If webhook is a string URL, use it directly
        if string.find(webhook, "https://discord.com/api/webhooks") or string.find(webhook, "https://discordapp.com/api/webhooks") then
            targetWebhook = webhook
        -- If webhook is a webhook type name (like "Chat", "Admin", etc.)
        elseif Config.Webhooks[webhook] and Config.Webhooks[webhook] ~= "YOUR_DISCORD_WEBHOOK_URL_HERE" then
            targetWebhook = Config.Webhooks[webhook]
        end
    end
    
    -- Add player info if not already in fields
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
    
    -- Add Discord ID if available
    if identifiers.discord then
        local hasDiscord = false
        for i, field in ipairs(logFields) do
            if field.name == "Discord" or field.name == "Discord ID" then
                hasDiscord = true
                break
            end
        end
        
        if not hasDiscord then
            table.insert(logFields, {
                ["name"] = "Discord",
                ["value"] = "<@" .. string.gsub(identifiers.discord, "discord:", "") .. ">",
                ["inline"] = true
            })
        end
    end
    
    SendToDiscord(targetWebhook, title, description, color, logFields, footer)
end)

print("^2[Ultra DC-Log]^7 Discord logging system loaded successfully!")
print("^2[Ultra DC-Log]^7 Server exports: LogToDiscord, LogCommand, LogAdminAction, LogCustom, LogWithIdentifiers")
print("^2[Ultra DC-Log]^7 Client exports: LogToDiscord, LogCustom, LogWithContext")

