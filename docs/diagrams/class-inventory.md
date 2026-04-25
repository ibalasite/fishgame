---
generated: 2026-04-25T00:00:00Z
source: docs/diagrams/class-*.md
purpose: class-to-test mapping for test-plan RTM
---

# Class Inventory — 類別清單與測試追蹤

> 來源：class-domain.md, class-application.md, class-infra-presentation.md
> 用途：測試計劃 RTM（Requirements Traceability Matrix）的類別覆蓋追蹤

| Class | Stereotype | Layer | src 路徑（推斷） | test 路徑（推斷） | TC-ID 前綴 |
|-------|-----------|-------|----------------|----------------|-----------|
| **Player** | AggregateRoot | Domain | `src/domain/player/Player.ts` | `tests/unit/domain/player/Player.test.ts` | TC-PLAYER |
| **Room** | AggregateRoot | Domain | `src/domain/room/Room.ts` | `tests/unit/domain/room/Room.test.ts` | TC-ROOM |
| **Fish** | Entity | Domain | `src/domain/fish/Fish.ts` | `tests/unit/domain/fish/Fish.test.ts` | TC-FISH |
| **Bullet** | Entity | Domain | `src/domain/bullet/Bullet.ts` | `tests/unit/domain/bullet/Bullet.test.ts` | TC-BULLET |
| **GameSession** | Entity | Domain | `src/domain/session/GameSession.ts` | `tests/unit/domain/session/GameSession.test.ts` | TC-SESSION |
| **Transaction** | Entity | Domain | `src/domain/transaction/Transaction.ts` | `tests/unit/domain/transaction/Transaction.test.ts` | TC-TX |
| **JackpotEvent** | Entity | Domain | `src/domain/jackpot/JackpotEvent.ts` | `tests/unit/domain/jackpot/JackpotEvent.test.ts` | TC-JACKPOT |
| **Weapon** | ValueObject | Domain | `src/domain/weapon/Weapon.ts` | `tests/unit/domain/weapon/Weapon.test.ts` | TC-WEAPON |
| **Skill** | ValueObject | Domain | `src/domain/skill/Skill.ts` | `tests/unit/domain/skill/Skill.test.ts` | TC-SKILL |
| **Money** | ValueObject | Domain | `src/domain/shared/Money.ts` | `tests/unit/domain/shared/Money.test.ts` | TC-MONEY |
| **Position** | ValueObject | Domain | `src/domain/shared/Position.ts` | `tests/unit/domain/shared/Position.test.ts` | TC-POS |
| **RTPEngine** | DomainService | Domain | `src/domain/rtp/RTPEngine.ts` | `tests/unit/domain/rtp/RTPEngine.test.ts` | TC-RTP |
| **JackpotService** | DomainService | Domain | `src/domain/jackpot/JackpotService.ts` | `tests/unit/domain/jackpot/JackpotService.test.ts` | TC-JP-SVC |
| **FishSpawner** | DomainService | Domain | `src/domain/fish/FishSpawner.ts` | `tests/unit/domain/fish/FishSpawner.test.ts` | TC-SPAWNER |
| **PlayerRepository** | Repository (Interface) | Domain | `src/domain/player/PlayerRepository.ts` | `tests/unit/domain/player/PlayerRepository.test.ts` | TC-REPO-PLAYER |
| **RoomRepository** | Repository (Interface) | Domain | `src/domain/room/RoomRepository.ts` | `tests/unit/domain/room/RoomRepository.test.ts` | TC-REPO-ROOM |
| **FishRepository** | Repository (Interface) | Domain | `src/domain/fish/FishRepository.ts` | `tests/unit/domain/fish/FishRepository.test.ts` | TC-REPO-FISH |
| **PlayerStatus** | Enumeration | Domain | `src/domain/player/PlayerStatus.ts` | `tests/unit/domain/player/Player.test.ts` | TC-PLAYER |
| **FishStatus** | Enumeration | Domain | `src/domain/fish/FishStatus.ts` | `tests/unit/domain/fish/Fish.test.ts` | TC-FISH |
| **RoomStatus** | Enumeration | Domain | `src/domain/room/RoomStatus.ts` | `tests/unit/domain/room/Room.test.ts` | TC-ROOM |
| **WeaponType** | Enumeration | Domain | `src/domain/weapon/WeaponType.ts` | `tests/unit/domain/weapon/Weapon.test.ts` | TC-WEAPON |
| **SkillType** | Enumeration | Domain | `src/domain/skill/SkillType.ts` | `tests/unit/domain/skill/Skill.test.ts` | TC-SKILL |
| **TransactionType** | Enumeration | Domain | `src/domain/transaction/TransactionType.ts` | `tests/unit/domain/transaction/Transaction.test.ts` | TC-TX |
| **CurrencyType** | Enumeration | Domain | `src/domain/shared/CurrencyType.ts` | `tests/unit/domain/shared/Money.test.ts` | TC-MONEY |
| **FishType** | Enumeration | Domain | `src/domain/fish/FishType.ts` | `tests/unit/domain/fish/Fish.test.ts` | TC-FISH |
| **OrderStatus** | Enumeration | Domain | `src/domain/transaction/OrderStatus.ts` | `tests/unit/domain/transaction/Transaction.test.ts` | TC-TX |
| **AgeStatus** | Enumeration | Domain | `src/domain/player/AgeStatus.ts` | `tests/unit/domain/player/Player.test.ts` | TC-PLAYER |
| **ShootFishUseCase** | UseCase | Application | `src/application/game/ShootFishUseCase.ts` | `tests/unit/application/game/ShootFishUseCase.test.ts` | TC-UC-SHOOT |
| **EnterRoomUseCase** | UseCase | Application | `src/application/game/EnterRoomUseCase.ts` | `tests/unit/application/game/EnterRoomUseCase.test.ts` | TC-UC-ENTER |
| **PurchaseUseCase** | UseCase | Application | `src/application/shop/PurchaseUseCase.ts` | `tests/unit/application/shop/PurchaseUseCase.test.ts` | TC-UC-PURCHASE |
| **SubscribeVIPUseCase** | UseCase | Application | `src/application/shop/SubscribeVIPUseCase.ts` | `tests/unit/application/shop/SubscribeVIPUseCase.test.ts` | TC-UC-VIP |
| **RefundUseCase** | UseCase | Application | `src/application/shop/RefundUseCase.ts` | `tests/unit/application/shop/RefundUseCase.test.ts` | TC-UC-REFUND |
| **LeaveRoomUseCase** | UseCase | Application | `src/application/game/LeaveRoomUseCase.ts` | `tests/unit/application/game/LeaveRoomUseCase.test.ts` | TC-UC-LEAVE |
| **SessionSettleUseCase** | UseCase | Application | `src/application/game/SessionSettleUseCase.ts` | `tests/unit/application/game/SessionSettleUseCase.test.ts` | TC-UC-SETTLE |
| **GameService** | ApplicationService | Application | `src/application/game/GameService.ts` | `tests/unit/application/game/GameService.test.ts` | TC-SVC-GAME |
| **RTPService** | ApplicationService | Application | `src/application/rtp/RTPService.ts` | `tests/unit/application/rtp/RTPService.test.ts` | TC-SVC-RTP |
| **JackpotApplicationService** | ApplicationService | Application | `src/application/jackpot/JackpotApplicationService.ts` | `tests/unit/application/jackpot/JackpotApplicationService.test.ts` | TC-SVC-JP |
| **AccountService** | ApplicationService | Application | `src/application/account/AccountService.ts` | `tests/unit/application/account/AccountService.test.ts` | TC-SVC-ACCT |
| **ShootCommand** | DTO | Application | `src/application/game/commands/ShootCommand.ts` | `tests/unit/application/game/ShootFishUseCase.test.ts` | TC-UC-SHOOT |
| **EnterRoomCommand** | DTO | Application | `src/application/game/commands/EnterRoomCommand.ts` | `tests/unit/application/game/EnterRoomUseCase.test.ts` | TC-UC-ENTER |
| **PurchaseCommand** | DTO | Application | `src/application/shop/commands/PurchaseCommand.ts` | `tests/unit/application/shop/PurchaseUseCase.test.ts` | TC-UC-PURCHASE |
| **HitResult** | DTO | Application | `src/application/game/dtos/HitResult.ts` | `tests/unit/application/game/ShootFishUseCase.test.ts` | TC-UC-SHOOT |
| **SessionResult** | DTO | Application | `src/application/game/dtos/SessionResult.ts` | `tests/unit/application/game/SessionSettleUseCase.test.ts` | TC-UC-SETTLE |
| **PurchaseResult** | DTO | Application | `src/application/shop/dtos/PurchaseResult.ts` | `tests/unit/application/shop/PurchaseUseCase.test.ts` | TC-UC-PURCHASE |
| **IPaymentPort** | Port (Interface) | Application | `src/application/ports/IPaymentPort.ts` | `tests/unit/application/shop/PurchaseUseCase.test.ts` | TC-UC-PURCHASE |
| **INotificationPort** | Port (Interface) | Application | `src/application/ports/INotificationPort.ts` | `tests/unit/application/shop/SubscribeVIPUseCase.test.ts` | TC-UC-VIP |
| **IDomainEventBus** | Port (Interface) | Application | `src/application/ports/IDomainEventBus.ts` | `tests/unit/application/game/ShootFishUseCase.test.ts` | TC-UC-SHOOT |
| **ICache** | Port (Interface) | Application | `src/application/ports/ICache.ts` | `tests/unit/application/rtp/RTPService.test.ts` | TC-SVC-RTP |
| **IFeatureFlag** | Port (Interface) | Application | `src/application/ports/IFeatureFlag.ts` | `tests/unit/application/rtp/RTPService.test.ts` | TC-SVC-RTP |
| **ITokenService** | Port (Interface) | Application | `src/application/ports/ITokenService.ts` | `tests/unit/application/account/AccountService.test.ts` | TC-SVC-ACCT |
| **GameController** | Controller | Presentation | `src/presentation/game/GameController.ts` | `tests/integration/presentation/game/GameController.test.ts` | TC-CTRL-GAME |
| **ShopController** | Controller | Presentation | `src/presentation/shop/ShopController.ts` | `tests/integration/presentation/shop/ShopController.test.ts` | TC-CTRL-SHOP |
| **AccountController** | Controller | Presentation | `src/presentation/account/AccountController.ts` | `tests/integration/presentation/account/AccountController.test.ts` | TC-CTRL-ACCT |
| **AdminController** | Controller | Presentation | `src/presentation/admin/AdminController.ts` | `tests/integration/presentation/admin/AdminController.test.ts` | TC-CTRL-ADMIN |
| **GameRoomSchema** | RequestDTO (Colyseus) | Presentation | `src/presentation/game/schemas/GameRoomSchema.ts` | `tests/unit/presentation/game/schemas/GameRoomSchema.test.ts` | TC-SCHEMA-ROOM |
| **PlayerStateSchema** | RequestDTO (Colyseus) | Presentation | `src/presentation/game/schemas/PlayerStateSchema.ts` | `tests/unit/presentation/game/schemas/PlayerStateSchema.test.ts` | TC-SCHEMA-PLAYER |
| **FishStateSchema** | RequestDTO (Colyseus) | Presentation | `src/presentation/game/schemas/FishStateSchema.ts` | `tests/unit/presentation/game/schemas/FishStateSchema.test.ts` | TC-SCHEMA-FISH |
| **PlayerRepositoryImpl** | RepositoryImpl | Infrastructure | `src/infrastructure/db/PlayerRepositoryImpl.ts` | `tests/integration/infrastructure/db/PlayerRepositoryImpl.test.ts` | TC-IMPL-PLAYER |
| **RoomRepositoryImpl** | RepositoryImpl | Infrastructure | `src/infrastructure/db/RoomRepositoryImpl.ts` | `tests/integration/infrastructure/db/RoomRepositoryImpl.test.ts` | TC-IMPL-ROOM |
| **FishKillRepositoryImpl** | RepositoryImpl | Infrastructure | `src/infrastructure/db/FishKillRepositoryImpl.ts` | `tests/integration/infrastructure/db/FishKillRepositoryImpl.test.ts` | TC-IMPL-KILL |
| **OrderRepositoryImpl** | RepositoryImpl | Infrastructure | `src/infrastructure/db/OrderRepositoryImpl.ts` | `tests/integration/infrastructure/db/OrderRepositoryImpl.test.ts` | TC-IMPL-ORDER |
| **PaymentAdapter** | Adapter | Infrastructure | `src/infrastructure/iap/PaymentAdapter.ts` | `tests/unit/infrastructure/iap/PaymentAdapter.test.ts` | TC-ADAPTER-PAY |
| **RedisAdapter** | Adapter | Infrastructure | `src/infrastructure/cache/RedisAdapter.ts` | `tests/integration/infrastructure/cache/RedisAdapter.test.ts` | TC-ADAPTER-REDIS |
| **DomainEventBusImpl** | Adapter | Infrastructure | `src/infrastructure/events/DomainEventBusImpl.ts` | `tests/integration/infrastructure/events/DomainEventBusImpl.test.ts` | TC-ADAPTER-BUS |
| **NotificationAdapter** | Adapter | Infrastructure | `src/infrastructure/notification/NotificationAdapter.ts` | `tests/unit/infrastructure/notification/NotificationAdapter.test.ts` | TC-ADAPTER-NOTIF |
| **FeatureFlagAdapter** | Adapter | Infrastructure | `src/infrastructure/feature/FeatureFlagAdapter.ts` | `tests/unit/infrastructure/feature/FeatureFlagAdapter.test.ts` | TC-ADAPTER-FF |
| **AnalyticsAdapter** | Adapter | Infrastructure | `src/infrastructure/analytics/AnalyticsAdapter.ts` | `tests/unit/infrastructure/analytics/AnalyticsAdapter.test.ts` | TC-ADAPTER-ANALYTICS |

---

## Layer 統計

| Layer | Class 數量 | Test 檔案數 |
|-------|-----------|-----------|
| Domain — AggregateRoot | 2 | 2 |
| Domain — Entity | 5 | 5 |
| Domain — ValueObject | 4 | 4 |
| Domain — DomainService | 3 | 3 |
| Domain — Repository (Interface) | 3 | 3 |
| Domain — Enum | 9 | (共用) |
| Application — UseCase | 7 | 7 |
| Application — ApplicationService | 4 | 4 |
| Application — DTO / Command | 7 | (共用) |
| Application — Port (Interface) | 6 | (共用) |
| Presentation — Controller | 4 | 4 |
| Presentation — Schema (Colyseus) | 3 | 3 |
| Infrastructure — RepositoryImpl | 4 | 4 |
| Infrastructure — Adapter | 6 | 6 |
| **Total** | **71** | **~49** |

---

## TC-ID 說明

| TC-ID 前綴 | 含義 | 示例 TC |
|-----------|------|---------|
| TC-RTP-001 | RTP 引擎命中計算單元測試 | `calculateHit returns HIT when RTP below target` |
| TC-UC-SHOOT-001 | ShootFishUseCase 正常流程 | `execute returns HitResult on valid shoot` |
| TC-UC-SHOOT-002 | ShootFishUseCase 魚已死亡 | `execute throws FishAlreadyDeadError` |
| TC-UC-PURCHASE-001 | PurchaseUseCase 冪等重試 | `execute returns existing order on duplicate orderId` |
| TC-JP-SVC-001 | JackpotService 原子觸發 | `checkAndTrigger returns event only once` |
| TC-CTRL-GAME-001 | GameController 射擊 API | `POST /shoot returns 200 with HitResult` |
| TC-IMPL-PLAYER-001 | PlayerRepositoryImpl DB 整合 | `findById returns player from MySQL` |
| TC-ADAPTER-REDIS-001 | RedisAdapter 連線 | `set and get returns correct value` |
