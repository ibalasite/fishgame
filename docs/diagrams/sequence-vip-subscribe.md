# Sequence Diagram: POST /vip/subscriptions

## Happy Path

```mermaid
sequenceDiagram
    participant Client as Cocos Client
    participant Shop as Shop Service :3002
    participant MySQL as MySQL :3306
    participant EventBus as Redis Pub/Sub
    participant Account as Account Service :3001

    Client->>Shop: POST /v1/vip/subscriptions {plan_id: "vip_monthly"} + Idempotency-Key: UUID
    Note over Shop: JWT 驗證 + Idempotency-Key 格式驗證
    Shop->>MySQL: SELECT subscriptions WHERE idempotency_key = ? (冪等性)
    alt 未重複
        Shop->>MySQL: SELECT diamond_balance FROM users WHERE id = ?
        alt 餘額足夠 (>= 30 diamonds)
            Shop->>MySQL: BEGIN; UPDATE users SET diamond_balance -= 30; INSERT subscriptions; COMMIT
            Shop->>MySQL: UPDATE users SET vip_tier=1, vip_expires_at = NOW()+30d
            Shop->>EventBus: PUBLISH events:account VIPSubscribed { user_id, plan_id, vip_tier: 1 }
            Shop-->>Client: 201 { subscription_id, vip_tier: 1, expires_at, diamonds_deducted: 30 }
        else 餘額不足
            Shop-->>Client: 422 INSUFFICIENT_DIAMONDS
        else VIP 已啟用
            Shop-->>Client: 422 VIP_ALREADY_ACTIVE
        end
    else Idempotency-Key 已使用
        Shop-->>Client: 409 DUPLICATE_SUBSCRIPTION { original_subscription_id }
    end
```
