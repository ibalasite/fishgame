# 捕魚遊戲 (fishing-arcade-game)

**多人即時捕魚射擊遊戲**

Build Status: ![placeholder] | License: MIT | Version: v0.1.0-alpha

---

## Overview

fishing-arcade-game is a real-time multiplayer competitive fishing arcade platform targeting casual pay-to-play players in Taiwan and Southeast Asia (ages 18–45). Unlike existing fishing games where "multiplayer" is purely cosmetic, this platform implements genuine resource competition: 4–6 players fight over the same fish in shared rooms, armed with differentiated weapons and skill combinations. The platform pairs this competitive core with a precision RTP engine (85–95%), a shared Jackpot pool, a dual-currency economy, and a VIP subscription system designed to achieve DAU 10,000, a 5% pay rate, and USD 10,000/month in revenue.

---

## Key Features

- **Real-Time Multiplayer Competition** — 4–6 players per room with genuine shared-resource competition; WebSocket state sync at P99 ≤ 100ms via Colyseus
- **Fish Type System** — Normal, Elite, and Boss fish with distinct HP, multiplier, and escape behaviors; Boss escape triggers a consolation reward
- **Weapons System** — Four cannon types (Basic / Laser / Scatter / Lock-on), each with distinct cost ranges (10–100 gold coins) and strategic trade-offs
- **Skills System** — Freeze, Full-Screen Bomb, and Auto-Lock skills with server-enforced cooldown timers; skill use requires server-side ownership validation
- **Dual-Currency Economy** — Gold coins (earned in-game) and Diamonds (purchased via IAP); all Diamond transactions are idempotent with UUID order IDs
- **RTP Engine + Jackpot Pool** — Server-authoritative RTP control (85–95%), loss-streak compensation, and a Redis Lua Script atomic Jackpot trigger (probability ≤ 0.1%) with platform-wide broadcast
- **VIP Subscription** — Monthly Diamond-deducted subscription; VIP players unlock exclusive weapons, skills, and in-room visual status effects
- **Age Verification Compliance** — Three-state machine (UNVERIFIED → DEMO_ONLY → VERIFIED); under-18 accounts are locked from all paid features
- **IAP Commerce** — Apple App Store and Google Play server-side receipt verification; Circuit Breaker fallback queues failed verifications for async retry

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Game Client** | Cocos Creator 3.8 (TypeScript / Lua scripts) — separate deployment |
| **API Gateway** | Node.js 20 LTS + Express 4.x — JWT auth, rate limiting, routing |
| **Real-Time Server** | Node.js 20 LTS + Colyseus 0.15 — WebSocket room state sync |
| **Account Service** | Node.js 20 LTS + TypeScript 5.4 — auth, JWT RS256, VIP, age verification |
| **Shop Service** | Node.js 20 LTS + TypeScript 5.4 — IAP, diamond top-up, idempotent orders |
| **ORM** | Prisma 5.x |
| **Primary Database** | PostgreSQL 16 (production target) / MySQL 8.0 (reference) — accounts, orders, history |
| **Cache & Real-Time State** | Redis 7.x (Cluster Mode) — game state, Jackpot pool, session, leaderboard |
| **Message Bus** | NATS — cross-service Domain Events (e.g., VipActivated, JackpotTriggered) |
| **Infrastructure** | Docker + Kubernetes (k3d local / AWS or GCP Southeast Asia region) |
| **Analytics** | Mixpanel / Amplitude — player behavior events, KPI dashboard |

### Architecture Pattern

Modular Monolith (not microservices). Three independently deployable services share a single codebase to minimize operational overhead for a 3–5 person engineering team. Services communicate in-process; cross-module events use Redis Pub/Sub.

```
Cocos Creator Client
    │
    ├── WSS :2567 ──► Game Service    (Colyseus Room, RTP Engine, Jackpot)
    ├── REST :3001 ─► Account Service (Auth, JWT, VIP, Age Verification)
    └── REST :3002 ─► Shop Service    (IAP, Diamond Top-up, Orders)
                          │
              ┌──────────┴──────────┐
         MySQL/PostgreSQL          Redis 7
         (persistent data)    (real-time state)
```

---

## Business Targets

| Metric | Target |
|---|---|
| Daily Active Users (DAU) | 10,000 |
| Pay Rate | 5% |
| Monthly Revenue | USD 10,000 |
| ARPU (paying users) | USD 20/month |
| D1 Retention | ≥ 35% |
| D7 Retention | ≥ 25% |
| Target Market | Taiwan, Southeast Asia (18–45 years old) |
| Investment Requirement | USD 200,000 |
| Time to Launch | 6 months (3 phases) |

---

## Service Level Objectives

| SLO | Target | Window |
|---|---|---|
| API Availability | ≥ 99.5% | 30-day rolling |
| WebSocket P99 Latency | ≤ 100ms | Real-time |
| REST API P99 Latency | ≤ 500ms | Real-time |
| Error Rate | ≤ 0.1% | 5-minute |

RTO ≤ 30 minutes | RPO ≤ 5 minutes

---

## Interactive Prototype

| Link | Description |
|---|---|
| [📱 UI Prototype](docs/pages/prototype/index.html) | 可點擊的前端原型（8 個畫面，含動畫音效）|
| [🔌 API Explorer](docs/pages/prototype/api-explorer/index.html) | 互動式 API 試打介面（19 個 endpoint，JavaScript Mock）|

> GitHub Pages 線上版：[UI Prototype ↗](https://ibalasite.github.io/fishgame/prototype/) · [API Explorer ↗](https://ibalasite.github.io/fishgame/prototype/api-explorer/)

---

## Document Links

| Document | Description | Path |
|---|---|---|
| BRD | Business Requirements — market analysis, ROI, business model | [docs/BRD.md](docs/BRD.md) |
| PRD | Product Requirements — 8 User Stories, 39 Acceptance Criteria | [docs/PRD.md](docs/PRD.md) |
| EDD | Engineering Design — architecture, data model, API contracts, SLO | [docs/EDD.md](docs/EDD.md) |
| PDD | Product Design Document — UX flows, Cocos Creator scene design | [docs/PDD.md](docs/PDD.md) |
| ARCH | Architecture — C4 diagrams, Bounded Context map | [docs/ARCH.md](docs/ARCH.md) |
| API | REST API reference — 20 endpoints | [docs/API.md](docs/API.md) |
| SCHEMA | Database schema — 11 tables | [docs/SCHEMA.md](docs/SCHEMA.md) |
| test-plan | Test plan — unit, integration, E2E, RTP simulation | [docs/test-plan.md](docs/test-plan.md) |
| RTM | Requirements Traceability Matrix (~80 test cases) | [docs/RTM.md](docs/RTM.md) |
| RUNBOOK | Operations runbook — SLO alerts, incident response | [docs/RUNBOOK.md](docs/RUNBOOK.md) |
| LOCAL_DEPLOY | Local development environment setup | [docs/LOCAL_DEPLOY.md](docs/LOCAL_DEPLOY.md) |
| ALIGN_REPORT | Document alignment scan report (43 findings) | [docs/ALIGN_REPORT.md](docs/ALIGN_REPORT.md) |

**BDD Feature Files** (8 files, 78 scenarios): `features/auth/`, `features/game/`, `features/shop/`

---

## Quick Start

> Implementation has not yet begun. The commands below reflect the intended startup flow once `src/` is scaffolded. See [docs/LOCAL_DEPLOY.md](docs/LOCAL_DEPLOY.md) for the full local deployment guide.

**Prerequisites:** Node.js 20 LTS, Docker Desktop, kubectl, k3d

```bash
# Clone the repository
git clone https://github.com/tbd-org/fishing-arcade-game.git
cd fishing-arcade-game

# Install dependencies
npm install

# Start local infrastructure (PostgreSQL + Redis via Docker)
docker compose up -d

# Run database migrations
npx prisma migrate deploy

# Start all services in development mode
npm run dev
# Account Service → http://localhost:3001
# Shop Service    → http://localhost:3002
# Game Service    → ws://localhost:2567

# Run tests
npm test

# Run BDD feature tests
npx cucumber-js features/
```

---

## Compliance

- **Taiwan PDPA**: Player email fields encrypted with AES-256-GCM; `data_access_logs` table for audit trail
- **Age Verification**: Three-state machine enforced server-side; under-18 accounts blocked from all paid features
- **IAP Receipt Verification**: Server-side validation against Apple and Google APIs; no client-trusted purchase flows
- **RTP Compliance**: `base_rtp` configurable within [0.80, 0.99]; modification restricted to Admin role with audit logging
- **Anti-Cheat**: All game logic (hit detection, RTP, Jackpot trigger) is server-authoritative; client renders results only

---

## Known Issues

Per [docs/ALIGN_REPORT.md](docs/ALIGN_REPORT.md), the following inconsistencies are pending resolution:

1. ~~**CRITICAL** — API.md login lock threshold (10 attempts) conflicts with PRD/EDD (5 attempts)~~ **[FIXED D16-ALIGN-F]** API.md updated to 5 attempts
2. ~~**CRITICAL** — API.md JWT access token TTL (1h) conflicts with PRD/EDD (15min)~~ **[FIXED D16-ALIGN-F]** API.md updated to 900s / 7d
3. **HIGH** — BDD feature error codes conflict with EDD §5.3 definitions at 3 locations; pending ADR confirmation
4. **HIGH** — `age_status` design: EDD defines a 3-state ENUM; SCHEMA implements TINYINT(1); schema migration required
5. **HIGH** — VIP subscription payment channel: PRD says IAP; API/EDD use Diamond deduction (30 diamonds/month). See D1-B-4
6. **INFO** — `src/` and `tests/` directories do not yet exist; code implementation has not started

---

## License

MIT

---

*Documentation generated by the [gendoc](https://github.com/tobala/gendoc) documentation framework.*
