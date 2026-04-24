# fishing-arcade-game

多人競技捕魚街機遊戲平台後端——支援 4-6 人即時競技房間、RTP 引擎、Jackpot 獎池、IAP 商城、VIP 訂閱，以及年齡驗證合規機制。

> **文件狀態**：設計完整，程式碼實作尚未開始。  
> **文件中心**：[docs/pages/index.html](docs/pages/index.html)

---

## 專案概述

| 欄位 | 說明 |
|------|------|
| **專案名稱** | fishing-arcade-game（捕魚街機遊戲平台）|
| **類型** | 多人即時競技遊戲後端 |
| **目標市場** | 台灣、東南亞 |
| **技術棧** | Node.js 20 LTS + TypeScript 5.4 + Colyseus 0.15 + Express 4.x + Prisma 5.x + MySQL 8.0 + Redis 7.x |
| **客戶端** | Cocos Creator 3.x（獨立部署，不在本 repo）|

---

## 服務架構

```
Cocos Creator Client
    │
    ├── WSS :2567 ──► Game Service   (Colyseus Room, RTP, Jackpot)
    ├── REST :3001 ─► Account Service (Auth, JWT, VIP, Age Verification)
    └── REST :3002 ─► Shop Service    (IAP, Diamond Topup, Orders)
```

**基礎設施**：MySQL 8.0 + Redis 7.x (Cluster Mode) + Docker / Kubernetes

---

## 核心功能

| 功能 | 描述 |
|------|------|
| **多人競技房間** | 4-6 人快速匹配，WebSocket 即時同步，P99 ≤ 100ms |
| **RTP 引擎** | 動態回報率控制（base_rtp=95%±2%），連敗補償機制 |
| **Jackpot 獎池** | Redis Lua Script 原子鎖，觸發概率 ≤ 0.1%，全服廣播 |
| **武器 & 技能系統** | 4 種武器（10-100 金幣），冰凍/全屏炸彈技能，冷卻機制 |
| **IAP 商城** | Apple AppStore / Google Play 收據驗證，冪等訂單 |
| **VIP 訂閱** | 月費訂閱（鑽石扣款），VIP 專屬武器 & 技能解鎖 |
| **年齡驗證** | 三態狀態機（UNVERIFIED → DEMO_ONLY → VERIFIED），未成年付費鎖定 |

---

## SLO 目標

| SLO | 目標 | 窗口 |
|-----|------|------|
| API 可用性 | ≥ 99.5% | 30 天滾動 |
| WebSocket P99 延遲 | ≤ 100ms | 即時 |
| REST API P99 延遲 | ≤ 500ms | 即時 |
| 錯誤率 | ≤ 0.1% | 5 分鐘 |

RTO ≤ 30 分鐘 ｜ RPO ≤ 5 分鐘

---

## 快速開始

> 尚無程式碼實作。詳細本地部署說明請參閱 [docs/LOCAL_DEPLOY.md](docs/LOCAL_DEPLOY.md)。

**環境需求**：Node.js 20 LTS、Docker Desktop、kubectl、k3d

```bash
# 未來實作完成後的啟動流程（依 docs/LOCAL_DEPLOY.md §3）
npm install
npx prisma migrate deploy
npm run dev   # 同時啟動 account / game / shop 三個服務
```

---

## 文件總覽

| 文件 | 說明 | 路徑 |
|------|------|------|
| BRD | 商業需求文件 | [docs/BRD.md](docs/BRD.md) |
| PRD | 產品需求文件（8 個 User Story，39 個 AC）| [docs/PRD.md](docs/PRD.md) |
| EDD | 工程設計文件（技術棧、架構、SLO）| [docs/EDD.md](docs/EDD.md) |
| ARCH | 架構設計（C4 圖、Bounded Context）| [docs/ARCH.md](docs/ARCH.md) |
| API | API 文件（20 個 REST Endpoint）| [docs/API.md](docs/API.md) |
| SCHEMA | 資料庫 Schema（11 張資料表）| [docs/SCHEMA.md](docs/SCHEMA.md) |
| test-plan | 測試計畫 | [docs/test-plan.md](docs/test-plan.md) |
| RTM | 需求追溯矩陣（~80 個 TC）| [docs/RTM.md](docs/RTM.md) |
| RUNBOOK | 維運手冊（SLO 告警、事故響應）| [docs/RUNBOOK.md](docs/RUNBOOK.md) |
| LOCAL_DEPLOY | 本地開發環境部署指南 | [docs/LOCAL_DEPLOY.md](docs/LOCAL_DEPLOY.md) |
| ALIGN_REPORT | 文件對齊掃描報告（43 個 findings）| [docs/ALIGN_REPORT.md](docs/ALIGN_REPORT.md) |

**BDD Feature Files**（8 個，78 個 Scenarios）：`features/auth/`、`features/game/`、`features/shop/`

---

## 已知文件問題

依 [docs/ALIGN_REPORT.md](docs/ALIGN_REPORT.md)，主要待修復項目：

1. **CRITICAL**：API.md 登入鎖定閾值（10 次）與 PRD/EDD（5 次）不一致 → 需更新 API.md
2. **CRITICAL**：API.md JWT Token 有效期（1h）與 PRD/EDD（15min）不一致 → 需更新 API.md
3. **HIGH**：BDD feature 錯誤碼與 EDD §5.3 定義不一致（3 處）→ 需 ADR 確認後修改
4. **HIGH**：age_status 設計：EDD 定義 ENUM 三態，SCHEMA 實作為 TINYINT(1) → 需 Schema Migration
5. **尚未實作**：`src/` 和 `tests/` 目錄不存在，程式碼實作尚未開始

---

## 合規說明

- 台灣個資法（PDPA）：玩家 email 欄位 AES-256-GCM 加密，data_access_logs 稽核
- 年齡驗證：三態狀態機，未成年（< 18 歲）完全限制付費功能
- IAP 收據驗證：Apple/Google 雙平台伺服器端驗證，防偽造充值
- RTP 合規：base_rtp 可調範圍 [0.80, 0.99]，僅 Admin 角色可調整

---

*由 [gendoc](https://github.com/tobala/gendoc) 文件生成框架生成*
