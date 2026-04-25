---
diagram: sequence-shoot-fish-error
uml-type: 序列圖（射擊捕魚異常流程）
source: EDD.md §8.5 Graceful Degradation; ARCH.md §17.2 Circuit Breaker
generated: 2026-04-25T00:00:00Z
---

# Sequence Diagram — Shoot Fish Error Flows（射擊捕魚異常流程）

> 來源：EDD.md §8.5 Graceful Degradation；ARCH.md §17.2 Circuit Breaker 狀態機

## Error Flow 1：RTP 服務降級（Redis 故障）

```mermaid
%%{init: {"theme": "dark"}}%%
sequenceDiagram
    autonumber
    participant CC as CocosCreator Client
    participant CR as GameController
    participant SUC as ShootFishUseCase
    participant RTP as RTPService
    participant CB as CircuitBreaker
    participant Redis as Redis:6379
    participant MySQL as MySQL:3306
    participant Alert as AlertSystem

    CC->>+CR: WSS SHOOT {fishId, weaponType}
    CR->>+SUC: execute(ShootCommand)
    SUC->>+RTP: calculateHit(playerId, fish, weapon)
    RTP->>+CB: callWithBreaker(() => redis.get(rtp_state))
    CB->>+Redis: GET rtp_state:{playerId}
    Redis--xCB: CONNECTION TIMEOUT (>50ms)
    CB->>CB: recordFailure(): failureCount 3→4→5
    CB->>CB: errorRate > 50% → OPEN circuit

    Note over CB,RTP: Circuit Breaker 開路 → 降級模式
    CB-->>-RTP: CircuitBreakerOpenError
    RTP->>RTP: isRTPDegraded==true; fallback fixedHitRate=0.80
    RTP->>RTP: rollDice(0.80) → isHit=true (degraded)
    RTP-->>-SUC: HitResult{isHit: true, degraded: true, coinsAwarded: 300}
    SUC->>+MySQL: INSERT fish_kills {degraded: true}
    MySQL-->>-SUC: OK
    SUC-->>-CR: HitResult (degraded)
    CR-->>CC: STATE_UPDATE (normal, player unaware)

    Note over CR,Alert: 後台告警觸發
    CR->>+Alert: emit RTPServiceDegraded metric
    Alert-->>-Alert: PagerDuty P1 alert to on-call
```

## Error Flow 2：魚已被其他玩家擊殺（Race Condition）

```mermaid
%%{init: {"theme": "dark"}}%%
sequenceDiagram
    autonumber
    participant CC_A as ClientA (Alice)
    participant CC_B as ClientB (Bob)
    participant CR as GameController
    participant SUC as ShootFishUseCase
    participant Redis as Redis:6379

    Note over CC_A,CC_B: Alice 和 Bob 同時射擊 fish_boss_001
    par Alice shoots
        CC_A->>CR: WSS SHOOT {fishId: fish_boss_001}
    and Bob shoots
        CC_B->>CR: WSS SHOOT {fishId: fish_boss_001}
    end

    Note over CR,Redis: Colyseus 序列化處理（單執行緒）
    CR->>+SUC: execute(Alice ShootCommand)
    SUC->>+Redis: SETNX fish_lock:{fishId} {killerId: Alice} EX 5
    Redis-->>-SUC: 1 (Alice acquired lock)
    SUC->>SUC: fish.applyDamage() → hp=0 → killed!
    SUC->>SUC: fish.status = DEAD
    SUC-->>-CR: HitResult{isHit: true, fishKilled: true, winner: Alice}
    CR-->>CC_A: FISH_KILLED {winner: Alice, coins: 5000}
    CR-->>CC_B: FISH_KILLED {winner: Alice, coins: 0}

    CR->>+SUC: execute(Bob ShootCommand)
    SUC->>+Redis: SETNX fish_lock:{fishId} {killerId: Bob} EX 5
    Redis-->>-SUC: 0 (lock already held by Alice)
    SUC->>SUC: fish.status == DEAD → skip hit
    SUC-->>-CR: HitResult{isHit: false, reason: FISH_ALREADY_DEAD}
    CR-->>CC_B: MISS {reason: "Fish already caught"}
```

## Error Flow 3：玩家金幣不足射擊被拒

```mermaid
%%{init: {"theme": "dark"}}%%
sequenceDiagram
    autonumber
    participant CC as CocosCreator Client
    participant CR as GameController
    participant SUC as ShootFishUseCase

    CC->>+CR: WSS SHOOT {fishId, weaponType: LOCK}
    Note over CR: LOCK 武器費用 100 coins，玩家餘額 50 coins
    CR->>+SUC: execute(ShootCommand{weaponType: LOCK})
    SUC->>SUC: canUseWeapon(LOCK): coins(50) < cost(100) → false
    SUC-->>-CR: ValidationError{code: INSUFFICIENT_COINS}
    CR-->>-CC: WSS ERROR {code: INSUFFICIENT_COINS, message: "金幣不足"}
    CC->>CC: showInsufficientCoinsDialog + promptPurchaseFlow
```

## Error Flow 4：玩家斷線重連

```mermaid
%%{init: {"theme": "dark"}}%%
sequenceDiagram
    autonumber
    participant CC as CocosCreator Client
    participant CR as GameController
    participant Redis as Redis:6379

    Note over CC,CR: 網路中斷
    CC--xCR: Connection dropped
    CR->>CR: onLeave(client, consented=false)
    CR->>CR: player.status = DISCONNECTED
    CR->>+Redis: SETEX reconnect_token:{playerId} 30s {roomId, sessionId}
    Redis-->>-CR: OK

    Note over CC,Redis: 玩家在 30 秒內嘗試重連
    CC->>+CR: WSS reconnect {reconnectToken}
    CR->>+Redis: GET reconnect_token:{playerId}
    Redis-->>-CR: {roomId: room_001, sessionId: session_101}
    CR->>CR: restorePlayerState(playerId, roomId)
    CR->>CR: player.status = IN_ROOM
    CR-->>-CC: STATE_PATCH (full room state sync)
    CC->>CC: resumeGameplay()

    Note over CR,Redis: 逾時未重連 → Bot 取代
    CR->>CR: 30s timer expires → addBot(player.position)
    CR->>+Redis: DEL reconnect_token:{playerId}
    Redis-->>-CR: OK
    CR->>CR: broadcast PLAYER_REPLACED_BY_BOT
```
