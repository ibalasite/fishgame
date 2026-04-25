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
    [*] --> FIRED : player.shoot [coins>=cost] / deductCoins; createBullet; startAnimation

    FIRED --> FLYING : bulletLeavesCannon / broadcast; startCollisionDetection

    FLYING --> HIT : fishCollision [ALIVE && RTP==true] / applyDamage; emitHitConfirmed

    FLYING --> MISSED : fishCollision [RTP==false] / serverRejectHit

    FLYING --> MISSED : timeout [maxFlight=2000ms] / bulletExpire

    HIT --> [*] : hitAnimationComplete / emitFishKilled; broadcastResult

    MISSED --> [*] : missAnimationComplete / broadcastMissToShooter

    note right of FIRED
        費用已在 FIRED 時扣除：
        - player.deductCoins(weapon.cost)
        - create Bullet{id, playerId, damage}
        - start trajectoryAnimation
    end note

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
    [*] --> WAITING : createRoom [maxPlayers=6] / colyseusOnCreate

    WAITING --> WAITING : playerJoins [count<max] / addPlayer; broadcastJoined

    WAITING --> PLAYING : startSession [count>=4 OR timer30s] / addBots; startWaveScheduler; emitSessionStarted

    WAITING --> CLOSED : dispose [noJoin 5min] / colyseusOnDispose

    PLAYING --> PLAYING : normalGameplay / spawnFish; processShots; accumJackpot

    PLAYING --> ENDING : sessionEnd [duration>=600s OR allLeft] / stopSpawner; settleSession

    ENDING --> CLOSED : settlementComplete / distributeRewards; emitSessionEnded; broadcastResults

    CLOSED --> [*] : roomRemoved / redisCleanup; updateSessionStatus

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
    [*] --> IDLE : jwtLoginSuccess / setStatusIDLE

    IDLE --> IN_ROOM : enterRoom [ageVerified] / addPlayer

    IN_ROOM --> DISCONNECTED : wsDropped / disconnect; setReconnectToken30s

    DISCONNECTED --> IN_ROOM : reconnect(token) [within30s] / restoreState

    DISCONNECTED --> IDLE : timeout [noReconnect30s] / addBot; delReconnectToken

    IN_ROOM --> IDLE : voluntaryLeave OR sessionEnd / removePlayer

    IDLE --> [*] : accountDeleted OR banned / setStatusBanned
```
