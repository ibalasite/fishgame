---
diagram: object-snapshot
uml-type: 物件圖（執行時快照）
source: EDD.md §5.5; class-domain.md
generated: 2026-04-25T00:00:00Z
---

# Object Diagram — Runtime Snapshot（執行時快照）

> 來源：EDD.md §5.5 資料模型；class-domain.md 領域類別

## Snapshot 1：房間進行中狀態（PLAYING）

> 2 名玩家、3 條魚，其中 1 名玩家 VIP 狀態，1 條 Boss 魚血量受損

```mermaid
%%{init: {"theme": "dark"}}%%
classDiagram
    direction LR

    class room_001 {
        id = "room_001"
        roomType = "competitive"
        status = PLAYING
        tableId = "table_A"
        jackpotPool = 15000
        maxPlayers = 6
    }

    class session_101 {
        id = "session_101"
        roomId = "room_001"
        startedAt = 2026-04-25T10_00_00Z
        endedAt = null
        rtpCurrent = 0.88
        playerCount = 2
        status = PLAYING
    }

    class player_vip {
        id = "usr_AliceCUID"
        nickname = "Alice_VIP"
        level = 25
        coins = 85000
        diamonds = 500
        vipLevel = 2
        vipExpiresAt = 2026-07-25T00_00_00Z
        status = IN_ROOM
        ageStatus = VERIFIED
        role = "player"
    }

    class weapon_laser {
        type = LASER
        level = 3
        damage = 120
        cost = 50
        cooldownMs = 800
        isUnlocked = true
    }

    class player_normal {
        id = "usr_BobCUID"
        nickname = "Bob_Challenger"
        level = 8
        coins = 12000
        diamonds = 0
        vipLevel = 0
        vipExpiresAt = null
        status = IN_ROOM
        ageStatus = VERIFIED
        role = "player"
    }

    class weapon_normal {
        type = NORMAL
        level = 1
        damage = 30
        cost = 10
        cooldownMs = 200
        isUnlocked = true
    }

    class fish_boss_001 {
        id = "fish_boss_001"
        fishType = BOSS
        hp = 300
        maxHp = 500
        speed = 0.8
        multiplier = 50
        status = ALIVE
        coinValue = 5000
        spawnedAt = 2026-04-25T10_02_30Z
    }

    class pos_boss {
        x = 320.5
        y = 240.0
    }

    class fish_elite_002 {
        id = "fish_elite_002"
        fishType = ELITE
        hp = 100
        maxHp = 100
        speed = 1.5
        multiplier = 10
        status = ALIVE
        coinValue = 500
        spawnedAt = 2026-04-25T10_03_10Z
    }

    class pos_elite {
        x = 150.0
        y = 380.0
    }

    class fish_normal_003 {
        id = "fish_normal_003"
        fishType = NORMAL
        hp = 20
        maxHp = 20
        speed = 2.0
        multiplier = 2
        status = ALIVE
        coinValue = 20
        spawnedAt = 2026-04-25T10_03_45Z
    }

    class pos_normal {
        x = 500.0
        y = 100.0
    }

    room_001 "1" *-- "1" session_101 : currentSession
    room_001 "1" *-- "2" player_vip : players
    room_001 "1" *-- "2" player_normal : players
    room_001 "1" *-- "3" fish_boss_001 : fishes
    room_001 "1" *-- "3" fish_elite_002 : fishes
    room_001 "1" *-- "3" fish_normal_003 : fishes
    player_vip "1" *-- "1" weapon_laser : equips
    player_normal "1" *-- "1" weapon_normal : equips
    fish_boss_001 "1" *-- "1" pos_boss : at
    fish_elite_002 "1" *-- "1" pos_elite : at
    fish_normal_003 "1" *-- "1" pos_normal : at
```

## Snapshot 2：VIP 高餘額玩家 Profile 快照

> 玩家 VIP2 狀態，持有多種技能，鑽石餘額高

```mermaid
%%{init: {"theme": "dark"}}%%
classDiagram
    direction LR

    class player_vip_boss {
        id = "usr_VIPBossCUID"
        nickname = "GoldKing88"
        level = 50
        coins = 2500000
        diamonds = 3200
        vipLevel = 3
        vipExpiresAt = 2026-10-25T00_00_00Z
        status = IDLE
        ageStatus = VERIFIED
        role = "player"
        failedLoginCount = 0
        lastLoginAt = 2026-04-25T09_30_00Z
    }

    class weapon_lock {
        type = LOCK
        level = 5
        damage = 200
        cost = 100
        cooldownMs = 1500
        isUnlocked = true
    }

    class weapon_scatter {
        type = SCATTER
        level = 3
        damage = 80
        cost = 40
        cooldownMs = 600
        isUnlocked = true
    }

    class skill_freeze {
        type = FREEZE
        level = 3
        durationMs = 5000
        cooldownMs = 30000
        cost = 200
    }

    class skill_bomb {
        type = BOMB
        level = 2
        durationMs = 0
        cooldownMs = 60000
        cost = 500
    }

    class skill_lock {
        type = LOCK
        level = 4
        durationMs = 8000
        cooldownMs = 20000
        cost = 150
    }

    class tx_recent_purchase {
        id = "tx_001"
        playerId = "usr_VIPBossCUID"
        amount = 3200
        currency = DIAMOND
        type = PURCHASE
        status = COMPLETED
        orderId = "ord_UUID_001"
        createdAt = 2026-04-24T20_00_00Z
    }

    player_vip_boss "1" *-- "1" weapon_lock : equips
    player_vip_boss "1" *-- "1" weapon_scatter : owns
    player_vip_boss "1" *-- "1" skill_freeze : owns
    player_vip_boss "1" *-- "1" skill_bomb : owns
    player_vip_boss "1" *-- "1" skill_lock : owns
    player_vip_boss "1" ..> "1" tx_recent_purchase : last transaction
```
