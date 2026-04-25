---
diagram: er-diagram
uml-type: ER 圖（實體關係圖）
source: SCHEMA.md §3 資料表定義; EDD.md §5.5 Entity 清單
generated: 2026-04-25T00:00:00Z
---

# ER Diagram — Entity Relationship Diagram（實體關係圖）

> 來源：SCHEMA.md §3 資料表定義（11 張表）；EDD.md §5.5 Entity 清單與關聯

```mermaid
%%{init: {"theme": "dark"}}%%
erDiagram
    users {
        CHAR_26 id PK "CUID2, prefix usr_"
        VARCHAR_254 email UK "PII — AES-256-GCM encrypted"
        VARCHAR_255 password_hash NOT_NULL "bcrypt cost=12"
        VARCHAR_30 display_name NOT_NULL
        VARCHAR_512 avatar_url NULL
        ENUM role NOT_NULL "player|operator|superadmin"
        TINYINT_1 age_verified NOT_NULL "0=未驗證, 1=已驗證"
        ENUM status NOT_NULL "active|suspended|banned"
        VARCHAR_512 suspend_reason NULL
        TINYINT_UNSIGNED vip_tier NOT_NULL "0=無VIP, 1-3=月/季/年"
        DATETIME_3 vip_expires_at NULL
        BIGINT_UNSIGNED gold_balance NOT_NULL "金幣餘額 >= 0"
        INT_UNSIGNED diamond_balance NOT_NULL "鑽石餘額 >= 0"
        TINYINT_UNSIGNED failed_login_count NOT_NULL
        DATETIME_3 locked_at NULL
        DATETIME_3 last_login_at NULL
        DATETIME_3 created_at NOT_NULL
        DATETIME_3 updated_at NOT_NULL
        DATETIME_3 deleted_at NULL "軟刪除"
    }

    game_sessions {
        BIGINT_UNSIGNED id PK "AUTO_INCREMENT"
        VARCHAR_100 room_id NOT_NULL "Colyseus Room ID"
        ENUM status NOT_NULL "waiting|in_progress|ended"
        TINYINT_UNSIGNED player_count NOT_NULL "4-6"
        DATETIME_3 started_at NOT_NULL
        DATETIME_3 ended_at NULL
        DECIMAL_5_2 rtp_snapshot NULL "對局結束 RTP"
        INT jackpot_contributed NULL "本局貢獻 Jackpot"
    }

    session_players {
        BIGINT_UNSIGNED id PK "AUTO_INCREMENT"
        BIGINT_UNSIGNED session_id FK "→ game_sessions.id"
        CHAR_26 user_id FK "→ users.id"
        BIGINT_UNSIGNED final_gold NOT_NULL "最終金幣"
        TINYINT_1 is_mvp NOT_NULL "MVP 獎勵標記"
        INT kill_count NOT_NULL "本局擊殺魚數"
        DATETIME_3 joined_at NOT_NULL
    }

    fish_kills {
        BIGINT_UNSIGNED id PK "AUTO_INCREMENT (月分區)"
        BIGINT_UNSIGNED session_id FK "→ game_sessions.id"
        CHAR_26 killer_id FK "→ users.id"
        VARCHAR_50 fish_type NOT_NULL "normal|elite|boss"
        BIGINT_UNSIGNED coins_awarded NOT_NULL "金幣獎勵"
        DECIMAL_5_2 rtp_snapshot NOT_NULL "命中時 RTP"
        VARCHAR_50 weapon_type NOT_NULL "武器類型"
        TINYINT_1 is_jackpot_shot NOT_NULL "是否觸發 Jackpot"
        DATETIME_3 killed_at NOT_NULL "分區鍵"
    }

    jackpot_events {
        CHAR_36 id PK "UUID v4"
        BIGINT_UNSIGNED session_id FK "→ game_sessions.id"
        CHAR_26 winner_id FK "→ users.id"
        BIGINT_UNSIGNED amount NOT_NULL "Jackpot 金額"
        BIGINT_UNSIGNED pool_at_trigger NOT_NULL "觸發時獎池"
        DATETIME_3 triggered_at NOT_NULL
    }

    orders {
        CHAR_36 order_id PK "UUID v4 — 冪等 ID"
        CHAR_26 user_id FK "→ users.id"
        VARCHAR_50 product_id NOT_NULL "→ products.id"
        ENUM order_type NOT_NULL "iap_diamond|vip_subscribe|item_purchase"
        DECIMAL_10_2 amount_usd NULL "USD 金額"
        ENUM status NOT_NULL "pending|completed|failed|refunded"
        VARCHAR_64 iap_receipt_hash NULL "SHA256 防重用"
        VARCHAR_20 platform NULL "apple|google"
        INT diamonds_granted NULL "發放鑽石數"
        DATETIME_3 completed_at NULL
        DATETIME_3 refunded_at NULL
        DATETIME_3 created_at NOT_NULL
    }

    vip_subscriptions {
        CHAR_36 id PK "UUID v4"
        CHAR_26 user_id FK "→ users.id (UNIQUE)"
        TINYINT_UNSIGNED vip_tier NOT_NULL "1-3"
        DATETIME_3 activated_at NOT_NULL
        DATETIME_3 expires_at NOT_NULL
        ENUM status NOT_NULL "active|expired|cancelled"
        CHAR_36 order_id FK "→ orders.order_id"
    }

    products {
        VARCHAR_50 id PK "業務 ID: diamonds_330"
        VARCHAR_100 name NOT_NULL "商品名稱"
        ENUM product_type NOT_NULL "diamond_pack|vip_subscription|item"
        DECIMAL_10_2 price_usd NOT_NULL
        INT diamonds_amount NULL "鑽石數量"
        TINYINT_UNSIGNED vip_tier NULL "VIP 等級"
        TINYINT_1 is_active NOT_NULL "上下架"
        JSON metadata NULL "附加設定"
        DATETIME_3 created_at NOT_NULL
    }

    game_configs {
        TINYINT_UNSIGNED id PK "固定=1 (單行表)"
        DECIMAL_4_2 rtp_target_min NOT_NULL "最低 RTP: 85"
        DECIMAL_4_2 rtp_target_max NOT_NULL "最高 RTP: 95"
        DECIMAL_6_2 jackpot_trigger_probability NOT_NULL "觸發概率: 0.01%"
        BIGINT_UNSIGNED jackpot_min_threshold NOT_NULL "最低觸發金額"
        DECIMAL_4_2 jackpot_contribution_rate NOT_NULL "貢獻率: 1%"
        TINYINT_1 jackpot_enabled NOT_NULL
        INT max_players_per_room NOT_NULL "最大玩家數: 6"
        INT min_players_to_start NOT_NULL "最少開局人數: 4"
        INT bot_fill_wait_seconds NOT_NULL "Bot 補位等待: 30"
        DATETIME_3 updated_at NOT_NULL
        CHAR_26 updated_by FK "→ users.id"
    }

    audit_logs {
        BIGINT_UNSIGNED id PK "AUTO_INCREMENT (Append-only)"
        VARCHAR_100 event_type NOT_NULL "REFUND|BAN_USER|RTP_OVERRIDE..."
        CHAR_26 actor_user_id FK "→ users.id (操作者)"
        VARCHAR_50 resource_type NOT_NULL "user|order|game_config"
        VARCHAR_100 resource_id NOT_NULL "資源 ID"
        JSON before_json NULL "變更前快照"
        JSON after_json NULL "變更後快照"
        ENUM outcome NOT_NULL "success|failed"
        VARCHAR_64 ip_hash NULL "SHA256(ip)"
        VARCHAR_100 trace_id NULL "分散式追蹤 ID"
        DATETIME_3 created_at NOT_NULL
    }

    data_access_logs {
        BIGINT_UNSIGNED id PK "AUTO_INCREMENT"
        CHAR_26 accessor_id FK "→ users.id (存取者)"
        CHAR_26 subject_id FK "→ users.id (被存取者)"
        VARCHAR_50 field_accessed NOT_NULL "email|birthdate|phone"
        VARCHAR_50 access_reason NOT_NULL "age_verify|support|audit"
        DATETIME_3 accessed_at NOT_NULL
    }

    %% ===== RELATIONSHIPS =====

    users ||--o{ session_players : "參與 (1:N)"
    game_sessions ||--o{ session_players : "包含 (1:N)"
    game_sessions ||--o{ fish_kills : "記錄 (1:N)"
    users ||--o{ fish_kills : "擊殺 (1:N)"
    game_sessions ||--o| jackpot_events : "觸發 (1:0..1)"
    users ||--o| jackpot_events : "贏得 (1:0..1)"
    users ||--o{ orders : "產生 (1:N)"
    products ||--o{ orders : "對應 (1:N)"
    users ||--o| vip_subscriptions : "擁有 (1:0..1)"
    orders ||--o| vip_subscriptions : "啟動 (1:0..1)"
    users ||--o{ audit_logs : "觸發 (1:N)"
    users ||--o{ data_access_logs : "被存取 (1:N)"
    users ||--o{ data_access_logs : "存取 (1:N)"
    users ||--o| game_configs : "更新 (1:0..1)"
```
