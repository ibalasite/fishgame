---
diagram: state-machine-fish
uml-type: 狀態機圖（魚群生命週期）
source: EDD.md §4.5 Domain Events; PRD.md §4.1 US-FISH-001
generated: 2026-04-25T00:00:00Z
---

# State Machine — Fish Lifecycle（魚群生命週期狀態機）

> 來源：EDD.md §4.5 FishKilled Domain Event；PRD.md §4.1 US-FISH-001；EDD §1.3 US-FISH-001 AC-2

```mermaid
%%{init: {"theme": "dark"}}%%
stateDiagram-v2
    [*] --> SPAWNING : FishSpawner.spawnFish(room)<br/>[room.fishCount < maxFish]

    SPAWNING --> ALIVE : spawnAnimation complete<br/>/ fish.hp = fish.maxHp<br/>/ emit FishSpawned event

    ALIVE --> ALIVE : bullet.hitTarget(fish) [hp > 0]<br/>/ fish.hp -= damage<br/>/ emit FishDamaged event<br/>/ update room state delta

    ALIVE --> DEAD : bullet.hitTarget(fish) [hp <= 0]<br/>/ fish.status = DEAD<br/>/ coins = fish.coinValue * multiplier<br/>/ emit FishKilled {killerId, coins, rtpAtKill}<br/>/ trigger Jackpot.contribute(1%)

    ALIVE --> ESCAPED : fish.escape() [swimTimer expired]<br/>[fishType == BOSS]<br/>/ emit BossEscaped<br/>/ consolationPool += consolationRate

    ESCAPED --> [*] : fish removed from room<br/>/ if BossEscaped: distribute consolation awards<br/>/ broadcast BOSS_ESCAPED animation

    DEAD --> [*] : death animation complete (2s)<br/>/ fish removed from room<br/>/ room.fishCount--<br/>/ winner UI notification

    note right of ALIVE
        ALIVE 狀態下觸發：
        - 普通魚：路徑移動，可被任意玩家命中
        - 精英魚：速度更快，需多次命中
        - Boss 魚：高血量，逃跑計時器 60s
        - 魚的 hp/position 每幀廣播 delta sync
    end note

    note right of DEAD
        DEAD 觸發的副效果：
        1. INSERT fish_kills record（MySQL）
        2. INCR jackpot_pool（Redis atomic）
        3. UPDATE player.gold_balance（async event）
        4. 播放爆炸動畫（animationType）
        5. 廣播 FishKilled 事件給所有房間玩家
    end note

    note right of ESCAPED
        ESCAPED 僅限 Boss 魚：
        - consolationRate 設定為 Boss 面值 × 0.1
        - 所有房間玩家均分安慰獎
        - 觸發 BossEscaped Domain Event
        - 管理後台可查看逃跑記錄
    end note
```

## Fish Type 特性對照

```mermaid
%%{init: {"theme": "dark"}}%%
stateDiagram-v2
    direction LR

    state "NORMAL FISH" as NF {
        [*] --> NF_alive : spawn
        NF_alive --> NF_dead : 1 hit (hp=20)
        NF_dead --> [*]
        note right of NF_alive : multiplier=2, speed=2.0\ncoins = 20\nno escape
    }

    state "ELITE FISH" as EF {
        [*] --> EF_alive : spawn
        EF_alive --> EF_alive : partial hits [hp>0]
        EF_alive --> EF_dead : final hit (hp=0)
        EF_dead --> [*]
        note right of EF_alive : multiplier=10, speed=1.5\nmaxHp=100\nno escape
    }

    state "BOSS FISH" as BF {
        [*] --> BF_alive : spawn (rare wave)
        BF_alive --> BF_alive : partial hits [hp>0]
        BF_alive --> BF_dead : final hit [hp<=0]
        BF_alive --> BF_escaped : escapeTimer=60s expires
        BF_dead --> [*]
        BF_escaped --> [*]
        note right of BF_alive : multiplier=50, speed=0.8\nmaxHp=500, escapeTimer=60s\nBoss kill = winner-takes-all
    }
```
