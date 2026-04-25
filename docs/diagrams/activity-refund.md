---
diagram: activity-refund
uml-type: 活動圖（退款與補償流程）
source: EDD.md §5.5 Transaction Entity; API.md §2.3 Commerce; ARCH.md §5.4
generated: 2026-04-25T00:00:00Z
---

# Activity Diagram — Refund & Compensation Flow（退款與補償流程）

> 來源：EDD.md §5.5 Transaction Entity；API.md §2.3 Commerce；ARCH.md §5.4 資料一致性策略

```mermaid
%%{init: {"theme": "dark"}}%%
flowchart TD
    subgraph Player["👤 Player"]
        P_RequestRefund[提交退款申請\nDELETE /v1/shop/orders/:orderId]
        P_WaitProcessing[等待退款處理]
        P_RefundSuccess[顯示退款成功\n鑽石扣除確認]
        P_RefundDenied[顯示退款拒絕\n原因說明]
    end

    subgraph ShopService["⚙️ ShopService (Node.js :3001)"]
        SS_FindOrder[查詢訂單\nfindById(orderId)]
        SS_ValidateOwner{訂單屬於\n此玩家?}
        SS_CheckEligibility{退款資格\n檢查}
        SS_CheckDiamondsSpent{鑽石已使用\n超過 50%?}
        SS_PartialRefund[計算部分退款\n按未使用比例]
        SS_FullRefund[全額退款]
        SS_CallPlatformRefund[呼叫 IAP 平台退款 API]
        SS_PlatformResult{平台退款\n成功?}
        SS_DeductDiamonds[扣除玩家鑽石\n已發放部分]
        SS_UpdateRefunded[更新訂單 status=REFUNDED]
        SS_LogAudit[寫入 audit_logs\n退款操作記錄]
        SS_NotifyPlayer[推送退款成功通知]
        SS_DenyRefund[拒絕退款\n記錄原因]
    end

    subgraph AdminService["👤 Admin (管理後台)"]
        AS_ManualRefund[管理員手動觸發退款\nPOST /v1/admin/refunds]
        AS_ApproveRefund[管理員審批退款]
    end

    subgraph PaymentGateway["💳 IAP Platform"]
        PG_ProcessRefund[處理退款請求\nApple/Google Refund API]
        PG_ConfirmRefund[確認退款\n到帳時間 3-5 工作日]
    end

    subgraph Database["💾 Database (MySQL)"]
        DB_FindOrder[SELECT orders WHERE\norderId=? AND userId=?]
        DB_CheckStatus[確認 status=COMPLETED\n且未退款]
        DB_UpdateRefunded[UPDATE orders SET status=REFUNDED\n記錄 refunded_at]
        DB_AuditLog[INSERT audit_logs\n{event=REFUND, before, after}]
        DB_DeductBalance[UPDATE users.diamond_balance -= N\n確保 balance >= 0]
    end

    P_RequestRefund --> SS_FindOrder
    SS_FindOrder --> DB_FindOrder --> DB_CheckStatus

    DB_CheckStatus -->|訂單不存在| SS_DenyRefund
    DB_CheckStatus -->|訂單存在| SS_ValidateOwner

    SS_ValidateOwner -->|不是本人| SS_DenyRefund
    SS_ValidateOwner -->|本人| SS_CheckEligibility

    SS_CheckEligibility -->|訂單 status != COMPLETED| SS_DenyRefund
    SS_CheckEligibility -->|在退款期限內 7天| SS_CheckDiamondsSpent

    SS_CheckDiamondsSpent -->|已用 <= 50%| SS_FullRefund
    SS_CheckDiamondsSpent -->|已用 > 50%| SS_PartialRefund

    SS_FullRefund --> SS_CallPlatformRefund
    SS_PartialRefund --> SS_CallPlatformRefund

    SS_CallPlatformRefund --> PG_ProcessRefund
    PG_ProcessRefund --> PG_ConfirmRefund
    PG_ConfirmRefund --> SS_PlatformResult

    SS_PlatformResult -->|失敗| SS_DenyRefund
    SS_PlatformResult -->|成功| SS_DeductDiamonds

    SS_DeductDiamonds --> DB_DeductBalance
    SS_DeductDiamonds --> SS_UpdateRefunded
    SS_UpdateRefunded --> DB_UpdateRefunded
    SS_UpdateRefunded --> SS_LogAudit
    SS_LogAudit --> DB_AuditLog
    SS_LogAudit --> SS_NotifyPlayer

    SS_NotifyPlayer --> P_WaitProcessing --> P_RefundSuccess
    SS_DenyRefund --> P_RefundDenied

    Note1["管理員手動退款路徑"]
    AS_ManualRefund --> AS_ApproveRefund --> SS_DeductDiamonds

    style P_RefundSuccess fill:#1a472a,stroke:#2d8a50,color:#fff
    style P_RefundDenied fill:#4a1a1a,stroke:#8a2d2d,color:#fff
    style Note1 fill:#1a2a4a,stroke:#2d4a8a,color:#fff
```
