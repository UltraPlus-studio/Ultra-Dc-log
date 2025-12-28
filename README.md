# Ultra DC-Log - FiveM Discord Logging System

ระบบบันทึกข้อมูลไปยัง Discord สำหรับ FiveM Server

## 📋 คุณสมบัติ

- ✅ บันทึกการเชื่อมต่อ/ตัดการเชื่อมต่อของผู้เล่น
- ✅ บันทึกข้อความแชท
- ✅ บันทึกการตายและการฆ่า
- ✅ บันทึกคำสั่งที่ใช้
- ✅ บันทึกการเริ่ม/หยุด Resource
- ✅ บันทึกการกระทำของ Admin
- ✅ รองรับ Webhook หลายตัวสำหรับแยกประเภท Log
- ✅ ระบบ Embed สวยงามพร้อมสีสัน
- ✅ **รองรับ Exports ทั้ง Server และ Client**
- ✅ **ระบบ Export ที่ครอบคลุมและใช้งานง่าย**

## 🚀 การติดตั้ง

1. ดาวน์โหลดและวางโฟลเดอร์ `Ultra-Dc-log` ในโฟลเดอร์ `resources` ของเซิร์ฟเวอร์
2. เปิดไฟล์ `config.lua` และแก้ไข Webhook URLs
3. เพิ่มใน `server.cfg`:
   ```
   ensure Ultra-Dc-log
   ```

## ⚙️ การตั้งค่า

### 1. สร้าง Discord Webhook

1. ไปที่ Discord Server ของคุณ
2. ไปที่ Server Settings > Integrations > Webhooks
3. คลิก "New Webhook"
4. คัดลอก Webhook URL
5. วางในไฟล์ `config.lua`

### 2. แก้ไข Config

เปิดไฟล์ `config.lua` และแก้ไข:

```lua
Config.Webhooks = {
    Main = "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL",
    Chat = "https://discord.com/api/webhooks/YOUR_CHAT_WEBHOOK_URL", -- Optional
    Connections = "https://discord.com/api/webhooks/YOUR_CONNECTION_WEBHOOK_URL", -- Optional
    -- ... etc
}
```

### 3. เปิด/ปิด Log Types

คุณสามารถเปิด/ปิดประเภท Log ต่างๆ ได้ใน `config.lua`:

```lua
Config.LogTypes = {
    PlayerConnect = true,    -- บันทึกการเชื่อมต่อ
    PlayerDisconnect = true, -- บันทึกการตัดการเชื่อมต่อ
    PlayerChat = true,       -- บันทึกแชท
    -- ... etc
}
```

## 📖 การใช้งาน

### 🖥️ Server-Side Exports

#### 1. LogToDiscord (พื้นฐาน)
```lua
-- ส่ง Log ไปยัง Discord
exports['Ultra-Dc-log']:LogToDiscord(
    webhook,      -- Webhook URL หรือ Webhook Type (optional, จะใช้ Main ถ้าไม่ระบุ)
    "Title",      -- หัวข้อ
    "Description", -- คำอธิบาย
    color,        -- สี (optional)
    fields,       -- ฟิลด์เพิ่มเติม (optional)
    footer        -- Footer (optional)
)

-- ตัวอย่าง
exports['Ultra-Dc-log']:LogToDiscord(
    nil,
    "Admin Action",
    "Admin banned a player",
    16711680,
    {
        {name = "Admin", value = "John", inline = true},
        {name = "Target", value = "Player123", inline = true}
    }
)

-- ใช้ Webhook Type แทน URL
exports['Ultra-Dc-log']:LogToDiscord(
    "Admin",  -- ใช้ Config.Webhooks.Admin
    "Admin Action",
    "Admin performed an action",
    16711680,
    {
        {name = "Action", value = "Ban", inline = true}
    }
)
```

#### 2. LogCommand (บันทึกคำสั่ง)
```lua
exports['Ultra-Dc-log']:LogCommand(
    source,        -- Player source ID
    "giveitem",    -- Command name
    {"weapon_pistol", "1"}  -- Arguments (table)
)
```

#### 3. LogAdminAction (บันทึกการกระทำของ Admin)
```lua
exports['Ultra-Dc-log']:LogAdminAction(
    source,        -- Admin source ID
    "Ban",         -- Action name
    "Player123",   -- Target (optional)
    "Reason: Cheating"  -- Details (optional)
)
```

#### 4. LogCustom (บันทึกแบบกำหนดเองพร้อมข้อมูลผู้เล่น)
```lua
exports['Ultra-Dc-log']:LogCustom(
    source,        -- Player source ID (nil สำหรับ System)
    "Custom Event",
    "Something happened",
    3447003,       -- Color
    {              -- Fields (optional)
        {name = "Event", value = "Custom", inline = true}
    },
    nil,           -- Footer (optional)
    "Admin"        -- Webhook Type (optional)
)
```

#### 5. LogWithIdentifiers (บันทึกพร้อม Identifiers ทั้งหมด)
```lua
exports['Ultra-Dc-log']:LogWithIdentifiers(
    source,        -- Player source ID
    "Player Info",
    "Detailed player information",
    3447003,       -- Color
    {              -- Additional fields (optional)
        {name = "Custom Field", value = "Value", inline = true}
    },
    "Admin"        -- Webhook Type (optional)
)
```

### 💻 Client-Side Exports

#### 1. LogToDiscord (ส่งจาก Client)
```lua
-- ส่ง Log จาก Client ไปยัง Server แล้วส่งไป Discord
exports['Ultra-Dc-log']:LogToDiscord(
    webhook,       -- Webhook URL หรือ Webhook Type (optional)
    "Title",
    "Description",
    color,         -- Color (optional)
    fields,        -- Fields (optional)
    footer         -- Footer (optional)
)

-- ตัวอย่าง
exports['Ultra-Dc-log']:LogToDiscord(
    "Chat",
    "Player Action",
    "Player did something",
    3447003,
    {
        {name = "Action", value = "Used item", inline = true}
    }
)
```

#### 2. LogCustom (บันทึกแบบกำหนดเองพร้อมข้อมูลผู้เล่นอัตโนมัติ)
```lua
exports['Ultra-Dc-log']:LogCustom(
    "Custom Event",
    "Something happened",
    3447003,       -- Color
    {              -- Fields (optional)
        {name = "Event", value = "Custom", inline = true}
    },
    nil,           -- Footer (optional)
    "Admin"        -- Webhook Type (optional)
)
-- ระบบจะเพิ่มข้อมูลผู้เล่น (ชื่อ, ID) อัตโนมัติ
```

#### 3. LogWithContext (บันทึกพร้อมตำแหน่งและข้อมูลผู้เล่น)
```lua
exports['Ultra-Dc-log']:LogWithContext(
    "Location Event",
    "Player is at a specific location",
    3447003,       -- Color
    {              -- Additional fields (optional)
        {name = "Event", value = "Entered area", inline = true}
    },
    "Admin"        -- Webhook Type (optional)
)
-- ระบบจะเพิ่มข้อมูลผู้เล่นและตำแหน่ง (X, Y, Z) อัตโนมัติ
```

### 📝 ตัวอย่างการใช้งานจริง

#### Server-Side Example
```lua
-- ใน server.lua ของ resource อื่น
RegisterCommand('testlog', function(source, args, rawCommand)
    local playerName = GetPlayerName(source)
    
    -- วิธีที่ 1: ใช้ LogToDiscord
    exports['Ultra-Dc-log']:LogToDiscord(
        nil,
        "Test Log",
        playerName .. " used test command",
        3066993,
        {
            {name = "Command", value = "/testlog", inline = true},
            {name = "Args", value = table.concat(args, " "), inline = true}
        }
    )
    
    -- วิธีที่ 2: ใช้ LogCustom
    exports['Ultra-Dc-log']:LogCustom(
        source,
        "Test Log",
        "Custom log with player info",
        3066993,
        {
            {name = "Command", value = "/testlog", inline = true}
        },
        nil,
        "Commands"
    )
end)
```

#### Client-Side Example
```lua
-- ใน client.lua ของ resource อื่น
RegisterCommand('testlog', function()
    -- วิธีที่ 1: ใช้ LogToDiscord
    exports['Ultra-Dc-log']:LogToDiscord(
        "Chat",
        "Client Test",
        "This is a test from client",
        3447003,
        {
            {name = "Test", value = "Client side", inline = true}
        }
    )
    
    -- วิธีที่ 2: ใช้ LogWithContext (มีตำแหน่งอัตโนมัติ)
    exports['Ultra-Dc-log']:LogWithContext(
        "Location Test",
        "Player location logged",
        3447003,
        {
            {name = "Event", value = "Location check", inline = true}
        },
        "Main"
    )
end)
```

### 🔄 Events (Legacy Support)

#### Log Admin Actions (Event)
```lua
TriggerServerEvent('UltraDC:LogAdminAction', "Ban", "Player123", "Reason: Cheating")
```

#### Log Commands (Event)
```lua
TriggerServerEvent('UltraDC:LogCommand', "giveitem", {"weapon_pistol", "1"})
```

## 🎨 สีที่ใช้

- **Connect**: เขียว (3066993)
- **Disconnect**: แดง (15158332)
- **Chat**: น้ำเงิน (3447003)
- **Death**: แดง (15158332)
- **Kill**: ทอง (15844367)
- **Command**: ม่วง (10181046)
- **Admin**: แดงเข้ม (16711680)

## 📝 หมายเหตุ

- ตรวจสอบให้แน่ใจว่า Webhook URLs ถูกต้อง
- คุณสามารถใช้ Webhook เดียวสำหรับทุกอย่าง หรือแยกตามประเภทได้
- ระบบจะทำงานอัตโนมัติเมื่อผู้เล่นเชื่อมต่อ/ตัดการเชื่อมต่อ/แชท/ตาย

## 🔧 Customization

คุณสามารถปรับแต่งเพิ่มเติมได้ในไฟล์ `server.lua` เพื่อเพิ่ม Event หรือ Log Types ใหม่

## 📄 License
ULTRA+ STUDIO (https://discord.gg/M8Btj2xSAd)
Free to use and modify

## 👤 Author

Ultra DC-Log

---

**สนับสนุน**: หากพบปัญหา กรุณาแจ้งใน (https://discord.gg/M8Btj2xSAd) ของคุณ

