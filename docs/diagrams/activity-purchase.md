---
diagram: activity-purchase
uml-type: 活動圖（IAP 購買流程）
source: EDD.md §5.5 Order Entity; PRD.md §4.1 US-SHOP-001; API.md §2.3
generated: 2026-04-25T00:00:00Z
---

# Activity Diagram — IAP Purchase Flow（IAP 鑽石購買流程）

> 來源：EDD.md §5.5 Order Entity；PRD.md §4.1 US-SHOP-001；API.md §2.3 Commerce

```mermaid
%%{init: {"theme": "dark"}}%%
flowchart TD
    subgraph Player["👤 Player (Cocos Creator)"]
        P_OpenShop[開啟商城頁面]
        P_SelectProduct[選擇鑽石套餐\n如: 330 鑽石 = USD 4.99]
        P_InitiatePurchase[發起購買\n系統生成 orderId UUID v4]
        P_PlatformPay[跳轉平台支付\nApp Store / Google Play]
        P_WaitConfirm[等待支付確認]
        P_Success[顯示購買成功\n鑽石 +330 動畫]
        P_Retry[顯示重試提示]
        P_Fail[顯示失敗原因]
    end

    subgraph ShopService["⚙️ ShopService (Node.js :3001)"]
        SS_CheckIdempotency{檢查 orderId\n冪等性?}
        SS_CreateOrder[建立訂單記錄\nstatus=PENDING]
        SS_VerifyReceipt[呼叫 IAP Receipt 驗證\nPlatform-specific]
        SS_CircuitBreaker{Circuit Breaker\n狀態?}
        SS_GrantDiamonds[發放鑽石\npublish IAPPurchaseCompleted]
        SS_UpdateOrder[更新訂單 status=COMPLETED]
        SS_PendingRetry[訂單 status=PENDING\n異步重試排程]
        SS_FailOrder[訂單 status=FAILED\n記錄錯誤原因]
    end

    subgraph PaymentGateway["💳 IAP Payment Gateway (External)"]
        PG_VerifyApple[Apple: POST sandbox.itunes.apple.com\n驗證 Receipt]
        PG_VerifyGoogle[Google: POST googleapis.com\n驗證 purchaseToken]
        PG_ReceiptValid{Receipt 有效?}
        PG_DupReceipt{Receipt 重複\n使用?}
    end

    subgraph AccountService["⚙️ AccountService (Node.js :3000)"]
        AS_UpdateBalance[UPDATE users.diamond_balance += 330\n(via IAPPurchaseCompleted event)]
        AS_NotifyPlayer[推送通知\n鑽石到帳確認]
    end

    subgraph Database["💾 Database (MySQL)"]
        DB_CreateOrder[INSERT orders\n{orderId, userId, productId, status=PENDING}]
        DB_CheckReceipt[SELECT orders WHERE\niap_receipt_hash=? 防重複]
        DB_UpdateCompleted[UPDATE orders SET\nstatus=COMPLETED]
        DB_UpdateFailed[UPDATE orders SET\nstatus=FAILED]
    end

    P_OpenShop --> P_SelectProduct --> P_InitiatePurchase
    P_InitiatePurchase --> SS_CheckIdempotency

    SS_CheckIdempotency -->|orderId 存在，已完成| P_Success
    SS_CheckIdempotency -->|新請求| SS_CreateOrder
    SS_CreateOrder --> DB_CreateOrder --> P_PlatformPay

    P_PlatformPay --> P_WaitConfirm
    P_WaitConfirm --> SS_VerifyReceipt

    SS_VerifyReceipt --> SS_CircuitBreaker
    SS_CircuitBreaker -->|CLOSED 正常| PG_VerifyApple
    SS_CircuitBreaker -->|CLOSED 正常| PG_VerifyGoogle
    SS_CircuitBreaker -->|OPEN 熔斷| SS_PendingRetry

    PG_VerifyApple --> PG_ReceiptValid
    PG_VerifyGoogle --> PG_ReceiptValid

    PG_ReceiptValid -->|無效| SS_FailOrder
    PG_ReceiptValid -->|有效| PG_DupReceipt

    PG_DupReceipt -->|重複使用| SS_FailOrder
    PG_DupReceipt -->|首次使用| DB_CheckReceipt

    DB_CheckReceipt -->|重複 hash| SS_FailOrder
    DB_CheckReceipt -->|全新 receipt| SS_GrantDiamonds

    SS_GrantDiamonds --> SS_UpdateOrder --> DB_UpdateCompleted
    SS_GrantDiamonds --> AS_UpdateBalance --> AS_NotifyPlayer --> P_Success

    SS_FailOrder --> DB_UpdateFailed --> P_Fail
    SS_PendingRetry -->|重試最多 3 次| SS_VerifyReceipt
    SS_PendingRetry -->|3 次失敗| P_Retry

    style P_Success fill:#1a472a,stroke:#2d8a50,color:#fff
    style P_Fail fill:#4a1a1a,stroke:#8a2d2d,color:#fff
    style P_Retry fill:#3a3a1a,stroke:#8a8a2d,color:#fff
    style SS_PendingRetry fill:#2a2a4a,stroke:#4a4a8a,color:#fff
```
