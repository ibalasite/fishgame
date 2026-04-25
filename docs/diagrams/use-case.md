---
diagram: use-case
uml-type: 使用案例圖
source: PRD.md §3, §4; EDD.md §4.1
generated: 2026-04-25T00:00:00Z
---

# Use Case Diagram — 使用案例圖

> 來源：PRD.md §3.2 User Personas / §4.1 In Scope；EDD.md §4.1 角色權限矩陣

```mermaid
%%{init: {"theme": "dark"}}%%
graph LR
    Player(["👤 玩家\nPlayer"])
    VIPPlayer(["👤 VIP玩家\nVIPPlayer"])
    Admin(["👤 管理員\nAdmin"])
    PaymentSystem(["⚙️ 外部支付系統\nPaymentSystem"])
    System(["⚙️ 系統\nSystem"])

    subgraph AccountUC["帳號系統"]
        UC_Register["註冊帳號\n(US-ACCT-001)"]
        UC_Login["登入帳號\n(US-ACCT-001)"]
        UC_AgeVerify["年齡驗證\n(US-AGE-001)"]
        UC_ViewProfile["查看個人資料"]
        UC_UpdateProfile["更新個人資料"]
    end

    subgraph GameUC["遊戲系統"]
        UC_JoinRoom["進入房間\n(US-ROOM-001)"]
        UC_ShootFish["射擊捕魚\n(US-FISH-001)"]
        UC_SwitchWeapon["切換武器\n(US-WPSK-001)"]
        UC_UseSkill["使用技能\n(US-WPSK-001)"]
        UC_ViewRanking["查看排行榜"]
        UC_Reconnect["斷線重連\n(US-ROOM-001)"]
    end

    subgraph VIPGameUC["VIP 遊戲特權"]
        UC_JoinVIPRoom["進入 VIP 房間"]
        UC_HighMultiplier["使用高倍率砲台"]
    end

    subgraph ShopUC["商城系統"]
        UC_BuyDiamonds["購買鑽石\n(US-SHOP-001)"]
        UC_BuyWeapon["購買武器道具"]
        UC_SubscribeVIP["訂閱 VIP\n(US-VIP-001)"]
        UC_ViewOrders["查看訂單記錄"]
    end

    subgraph AdminUC["管理後台"]
        UC_ConfigRTP["設定 RTP 參數"]
        UC_ViewKPI["查看 KPI 儀表板"]
        UC_ManageUsers["管理玩家帳號"]
        UC_ConfigActivity["設定活動"]
        UC_ViewAuditLog["查看稽核日誌"]
        UC_DisableJackpot["緊急關閉 Jackpot"]
    end

    subgraph SystemUC["系統自動化"]
        UC_BotFill["Bot 補位\n(30秒超時)"]
        UC_JackpotTrigger["Jackpot 觸發\n(Redis Lua 原子)"]
        UC_RTPCalc["RTP 計算\n(Server-Authoritative)"]
        UC_VerifyReceipt["驗證 IAP Receipt"]
        UC_SessionSettle["遊戲結算"]
    end

    Player --> UC_Register
    Player --> UC_Login
    Player --> UC_AgeVerify
    Player --> UC_ViewProfile
    Player --> UC_UpdateProfile
    Player --> UC_JoinRoom
    Player --> UC_ShootFish
    Player --> UC_SwitchWeapon
    Player --> UC_UseSkill
    Player --> UC_ViewRanking
    Player --> UC_Reconnect
    Player --> UC_BuyDiamonds
    Player --> UC_BuyWeapon
    Player --> UC_SubscribeVIP
    Player --> UC_ViewOrders

    VIPPlayer --> UC_JoinVIPRoom
    VIPPlayer --> UC_HighMultiplier
    VIPPlayer -.->|extends| Player

    Admin --> UC_ConfigRTP
    Admin --> UC_ViewKPI
    Admin --> UC_ManageUsers
    Admin --> UC_ConfigActivity
    Admin --> UC_ViewAuditLog
    Admin --> UC_DisableJackpot

    PaymentSystem --> UC_VerifyReceipt

    System --> UC_BotFill
    System --> UC_JackpotTrigger
    System --> UC_RTPCalc
    System --> UC_SessionSettle

    UC_ShootFish --> UC_RTPCalc
    UC_BuyDiamonds --> UC_VerifyReceipt
    UC_SubscribeVIP --> UC_VerifyReceipt
```
