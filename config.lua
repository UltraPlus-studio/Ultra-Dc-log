Config = {}

-- Discord Webhook URLs
Config.Webhooks = {
    -- Main webhook for general logs
    Main = "Webhook_dc",  
    -- Separate webhooks for different event types (optional)
    Chat = "Webhook_dc",
    Connections = "Webhook_dc",
    Deaths = "Webhook_dc",
    Commands = "Webhook_dc",
    Admin = "Webhook_dc"
}

-- Enable/Disable specific log types
Config.LogTypes = {
    PlayerConnect = true,
    PlayerDisconnect = true,
    PlayerChat = true,
    PlayerDeath = true,
    PlayerKill = true,
    PlayerCommand = true,
    ResourceStart = true,
    ResourceStop = true,
    AdminActions = true,
    MoneyTransactions = true,
    VehicleSpawn = true,
    WeaponGiven = true
}

-- Server Information
Config.ServerName = "Your Server Name"
Config.ServerLogo = "https://i.imgur.com/your-logo.png"

-- Colors (Decimal format)
Config.Colors = {
    Connect = 3066993,      -- Green
    Disconnect = 15158332,  -- Red
    Chat = 3447003,         -- Blue
    Death = 15158332,       -- Red
    Kill = 15844367,        -- Gold
    Command = 10181046,     -- Purple
    Admin = 16711680,       -- Red
    Info = 3447003          -- Blue
}

-- Timezone (for timestamps)
Config.Timezone = "Asia/Bangkok"

