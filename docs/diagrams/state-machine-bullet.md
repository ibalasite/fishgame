---
diagram: state-machine-bullet
uml-type: 狀態機圖（子彈與房間生命週期）
source: EDD.md §4.5; ARCH.md §17.2 Circuit Breaker; PRD.md §4.1 US-WPSK-001
generated: 2026-04-25T00:00:00Z
---

# State Machine — Bullet & Room Lifecycle（子彈與房間生命週期）

> 來源：EDD.md §4.5 Domain Events；PRD.md §4.1 US-WPSK-001；ARCH.md §17.2 Circuit Breaker

## Bullet State Machine（子彈生命週期）

```mermaid
%%{init: {"theme": "dark"}}%%
stateDiagram-v2
    [*] --> FIRED : player.shoot(weapon, fish)<br/>[player.coins >= weapon.cost]<br/>/ player.deductCoins(weapon.cost)<br/>/ create Bullet{id, playerId, damage}<br/>/ start trajectoryAnimation

    FIRED --> FLYING : bullet leaves cannon<br/>/ broadcast to room clients<br/>/ server starts collision detection

    FLYING --> HIT : fishCollision [fish.status == ALIVE]<br/>/ RTPEngine.calculateHit() == true<br/>/ fish.applyDamage(bullet.damage)<br/>/ emit HitConfirmed

    FLYING --> MISSED : fishCollision [RTP roll == false]<br/>/ server rejects hit<br/>/ no coins deducted (already deducted on fire)

    FLYING --> MISSED : timeout [maxFlightMs=2000ms]<br/>/ bullet expires, no target reached

    HIT --> [*] : hitAnimation complete<br/>/ if fish.hp <= 0: emit FishKilled<br/>/ broadcast HIT result to all players

    MISSED --> [*] : missAnimation complete<br/>/ broadcast MISS to shooter only<br/>/ no state change for fish

    note right of FLYING
        Server-Authoritative:
        - 客戶端顯示彈道動畫（視覺）
        - 伺服器端計算真實命中結果
        - 結果廣播後客戶端更新顯示
        - 客戶端無法偽造命中結果
    end note

    note right of HIT
        HIT 後續處理：
        - 費用已在 FIRED 時扣除
        - coins 在 FishKilled 後結算
        - Lock 武器：優先攻擊鎖定魚
        - Scatter 武器：同時產生 3 顆子彈
    end note
```

## Room State Machine（房間生命週期）

```mermaid
%%{init: {"theme": "dark"}}%%
stateDiagram-v2
    [*] --> WAITING : RoomRepository.createRoom()<br/>[roomType, maxPlayers=6]<br/>/ Colyseus onCreate() called

    WAITING --> WAITING : player joins [playerCount < maxPlayers]<br/>/ room.addPlayer(player)<br/>/ broadcast PLAYER_JOINED

    WAITING --> PLAYING : room.startSession() [playerCount >= minPlayers=4]<br/>OR [waitTimer=30s expires AND playerCount>=1]<br/>/ addBots() if needed<br/>/ FishSpawner.startWaveScheduler()<br/>/ emit GameSessionStarted

    WAITING --> CLOSED : room.dispose() [no players join in 5min]<br/>/ Colyseus onDispose() called

    PLAYING --> PLAYING : normal gameplay<br/>/ fish spawning waves<br/>/ player shoot/hit/miss<br/>/ jackpot contributions

    PLAYING --> ENDING : sessionDuration >= maxSessionMs=600000<br/>OR allPlayersLeft<br/>/ stopFishSpawner()<br/>/ SessionSettleUseCase.execute()

    ENDING --> CLOSED : settlement complete<br/>/ distribute rewards (coins/mvp bonus)<br/>/ emit GameSessionEnded<br/>/ broadcast RESULTS to all players<br/>/ Colyseus onDispose() scheduled

    CLOSED --> [*] : room removed from registry<br/>/ Redis cleanup: DEL room_state:{roomId}<br/>/ MySQL: UPDATE game_sessions.status=ENDED

    note right of WAITING
        WAITING 超時補位：
        - 30 秒無人加入 → Bot 自動填補
        - Bot 數量 = maxPlayers - realPlayers
        - Bot 行為由 FishSpawner 策略控制
    end note

    note right of PLAYING
        PLAYING 期間的關鍵限制：
        - 新玩家無法中途加入（防作弊）
        - 斷線 30s 內可重連
        - 斷線 >30s → Bot 取代位置
        - Jackpot 池持續累積
    end note

    note right of ENDING
        ENDING 結算流程：
        1. 停止魚群生成
        2. 計算 MVP（最高金幣）
        3. 分配 MVP 加成獎勵
        4. 發布 GameSessionEnded 事件
        5. Commerce BC 更新餘額（async）
    end note
```

## Player Connection State Machine（玩家連線狀態）

```mermaid
%%{init: {"theme": "dark"}}%%
stateDiagram-v2
    [*] --> IDLE : JWT login successful<br/>/ player.status = IDLE

    IDLE --> IN_ROOM : EnterRoomUseCase.execute()<br/>[ageStatus == VERIFIED]<br/>/ room.addPlayer(player)

    IN_ROOM --> DISCONNECTED : WebSocket dropped<br/>/ player.disconnect()<br/>/ Redis SETEX reconnect_token 30s

    DISCONNECTED --> IN_ROOM : client.reconnect(token) [within 30s]<br/>/ restorePlayerState()

    DISCONNECTED --> IDLE : 30s timeout [no reconnect]<br/>/ addBot(player.position)<br/>/ Redis DEL reconnect_token

    IN_ROOM --> IDLE : player voluntarily leaves<br/>OR session ends<br/>/ room.removePlayer()

    IDLE --> [*] : account deleted / banned<br/>/ player.status = banned
```
