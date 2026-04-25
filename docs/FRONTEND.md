# FRONTEND — 前端技術設計文件 (fishing-arcade-game)

<!-- 上游文件：PRD.md · EDD.md · ARCH.md · API.md · SCHEMA.md · PDD.md · VDD.md -->

---

## Document Control

| 欄位 | 內容 |
|------|------|
| **DOC-ID** | FRONTEND-FISHGAME-20260425 |
| **專案名稱** | fishing-arcade-game（捕魚街機遊戲平台）|
| **文件版本** | v1.0 |
| **狀態** | APPROVED |
| **作者** | Frontend Architect |
| **日期** | 2026-04-25 |
| **上游 EDD** | [EDD.md](EDD.md)（EDD-FISHGAME-20260424）|
| **上游 ARCH** | [ARCH.md](ARCH.md)（ARCH-FISHGAME-20260424）|
| **上游 API** | [API.md](API.md)（API-FISHGAME-20260424）|
| **上游 VDD** | [VDD.md](VDD.md)（VDD-FISHGAME-20260425）|
| **上游 PDD** | [PDD.md](PDD.md)（PDD-FISHGAME-20260425）|
| **審閱者** | Engineering Lead, Art Director, Game Designer Lead |
| **核准者** | CTO / Engineering Lead |

---

## Change Log

| 版本 | 日期 | 作者 | 變更摘要 |
|------|------|------|---------|
| v1.0 | 2026-04-25 | Frontend Architect | 初稿，涵蓋全部章節 |

---

## 目錄

1. 概述與技術選型
2. 專案架構
3. 狀態管理
4. 網路層設計
5. 遊戲核心模組
6. UI/UX 實作
7. 資源管理
8. 效能最佳化
9. 多平台支援
10. 安全性
11. 測試策略
12. 關鍵技術決策（ADR）

Appendix A: API Response 型別定義
Appendix B: Colyseus Schema 型別

---

## 1. 概述與技術選型

### 1.1 前端框架選型

**核心技術棧：Cocos Creator 3.8 + TypeScript**

本專案客戶端採用 **Cocos Creator 3.8**（對應 EDD §3.3 技術棧表格，BRD 硬性約束），使用 **TypeScript** 作為主要開發語言（取代 Lua，提供更強的型別安全與 IDE 整合）。Cocos Creator 3.8 基於 GFX 抽象層支援 WebGL 2.0 / WebGPU，在移動端與 H5 WebGL 均有成熟的效能表現。

| 技術 | 版本 | 選型理由 |
|------|------|---------|
| Cocos Creator | 3.8 | BRD 硬性約束；跨平台（iOS/Android/H5）；WebGL 渲染效能優秀 |
| TypeScript | 5.4 | 型別安全；Colyseus SDK 官方支援；與伺服器端共享型別定義 |
| Colyseus Client SDK | 0.15 | 對應伺服器端 Colyseus 0.15；Delta State Sync；Room 管理 |
| colyseus.js | 0.15.x | 瀏覽器/Node 相容；MIT 授權 |

**技術選型對比**

| 考量 | Cocos Creator 3.8 | Unity（排除）| Egret（排除）|
|------|-------------------|-------------|------------|
| 跨平台 H5 | 原生支援，WebGL 渲染 | 需額外插件，體積大 | 支援但生態萎縮 |
| TypeScript 整合 | 官方支援 | C# 主語言 | 有限支援 |
| 亞洲市場滲透率 | 高（台灣/東南亞主流）| 中（主要歐美）| 低 |
| 社群與工具鏈 | 完善（3.x 版本活躍）| 成熟但授權費高 | 社群萎縮 |
| Bundle 大小（H5）| 可控（< 5 MB 核心）| 過大（> 20 MB）| 中等 |

### 1.2 開發環境與工具鏈

**本地開發環境需求**

| 工具 | 版本 | 用途 |
|------|------|------|
| Cocos Creator IDE | 3.8.x | 場景編輯、資源管理、預覽 |
| Node.js | 20 LTS | 構建工具、腳本執行 |
| TypeScript | 5.4 | 程式碼編譯 |
| VSCode | latest | 程式碼編輯（官方 Cocos 插件）|
| Git LFS | 3.x | 二進位資源版本控制（紋理、音效）|

**構建流程**

```
TypeScript 原始碼
    ↓ tsc（型別檢查）
Cocos Creator 構建系統
    ↓ esbuild（JS 打包）
    ↓ 資源壓縮（紋理：ASTC/ETC2；音效：MP3/OGG）
目標平台產物：
    ├── web-mobile/     (H5 WebGL)
    ├── ios/            (Xcode 專案)
    └── android/        (Gradle 專案)
```

**開發指令（package.json scripts）**

```json
{
  "scripts": {
    "dev": "cocos build --platform web-mobile --debug",
    "build:h5": "cocos build --platform web-mobile --release",
    "build:ios": "cocos build --platform ios --release",
    "build:android": "cocos build --platform android --release",
    "type-check": "tsc --noEmit",
    "lint": "eslint 'assets/scripts/**/*.ts'",
    "test": "jest --config jest.config.ts",
    "test:coverage": "jest --coverage"
  }
}
```

---

## 2. 專案架構

### 2.1 目錄結構

```
assets/
├── scripts/
│   ├── game/                       # 核心遊戲邏輯
│   │   ├── systems/
│   │   │   ├── ShootingSystem.ts   # 射擊指令發送、命中反饋
│   │   │   ├── FishSystem.ts       # 魚群狀態更新、死亡處理
│   │   │   ├── WeaponSystem.ts     # 武器切換、升級邏輯
│   │   │   ├── SkillSystem.ts      # 技能冷卻、觸發邏輯
│   │   │   └── RankSystem.ts       # 即時排名計算（本地快取）
│   │   ├── managers/
│   │   │   ├── FishPoolManager.ts  # 魚節點物件池（100 節點）
│   │   │   ├── BulletPoolManager.ts# 子彈節點物件池（200 節點）
│   │   │   ├── EffectPoolManager.ts# 特效物件池（HitEffect×50, CoinEffect×100）
│   │   │   └── AudioManager.ts     # BGM/SFX 管理
│   │   └── controllers/
│   │       ├── GameController.ts   # 遊戲主邏輯協調器
│   │       └── UIController.ts     # UI 顯示/隱藏協調器
│   ├── network/
│   │   ├── ColyseusClient.ts       # Colyseus Room 連線封裝
│   │   ├── HttpClient.ts           # REST API 封裝（axios-like）
│   │   ├── NetworkManager.ts       # 連線狀態管理、重連邏輯
│   │   └── MessageQueue.ts         # 離線訊息佇列
│   ├── ui/
│   │   ├── hud/
│   │   │   ├── HUDComponent.ts     # 主 HUD（分數、貨幣、排名）
│   │   │   ├── JackpotBar.ts       # Jackpot 進度條
│   │   │   ├── BossHPBar.ts        # Boss 血條
│   │   │   └── WeaponCooldown.ts   # 武器冷卻圓圈
│   │   ├── dialogs/
│   │   │   ├── ShopDialog.ts       # 商城彈窗
│   │   │   ├── SettingsDialog.ts   # 設定彈窗
│   │   │   └── ConfirmDialog.ts    # 通用確認彈窗
│   │   ├── lobby/
│   │   │   ├── LobbyUI.ts          # 大廳主 UI
│   │   │   ├── RoomListItem.ts     # 房間列表項
│   │   │   └── MatchmakingUI.ts    # 配對等待 UI
│   │   └── common/
│   │       ├── ToastComponent.ts   # Toast 通知
│   │       ├── LoadingComponent.ts # 全屏 Loading
│   │       └── VIPBadge.ts         # VIP 徽章元件
│   ├── data/
│   │   ├── types/
│   │   │   ├── api.types.ts        # REST API 回應型別
│   │   │   ├── colyseus.types.ts   # Colyseus Schema 型別
│   │   │   ├── game.types.ts       # 遊戲領域型別
│   │   │   └── ui.types.ts         # UI 狀態型別
│   │   ├── constants/
│   │   │   ├── game.constants.ts   # 遊戲常數（FISH_TYPES, WEAPON_TYPES）
│   │   │   ├── api.constants.ts    # API 端點常數
│   │   │   └── ui.constants.ts     # UI 動畫常數、Z-index
│   │   └── schemas/
│   │       └── GameRoomSchema.ts   # Colyseus Room Schema 客戶端鏡像
│   └── utils/
│       ├── MathUtils.ts            # 彈道計算、向量運算
│       ├── AnimationUtils.ts       # Tween 輔助、緩動函數
│       ├── StorageUtils.ts         # 本地儲存（玩家偏好）
│       └── LogUtils.ts             # 開發環境日誌
├── scenes/
│   ├── LoadingScene.scene          # 啟動載入場景
│   ├── LoginScene.scene            # 登入/註冊場景
│   ├── OnboardingScene.scene       # 新手引導場景
│   ├── LobbyScene.scene            # 大廳場景
│   ├── CannonSelectScene.scene     # 砲台選擇場景
│   ├── MatchmakingScene.scene      # 配對等待場景
│   ├── GameScene.scene             # 主遊戲場景
│   └── SettlementScene.scene       # 結算場景
├── prefabs/
│   ├── fish/
│   │   ├── NormalFish.prefab       # 普通魚（64×48 px）
│   │   ├── EliteFish.prefab        # 精英魚（128×96 px）
│   │   └── BossFish.prefab         # Boss 魚（320×240 px）
│   ├── bullets/
│   │   ├── NormalBullet.prefab
│   │   ├── LaserBullet.prefab
│   │   └── ScatterBullet.prefab
│   ├── effects/
│   │   ├── HitEffect.prefab        # 普通命中特效
│   │   ├── KillEffect.prefab       # 擊殺爆炸特效
│   │   ├── CoinEffect.prefab       # 金幣飛出特效
│   │   └── JackpotEffect.prefab    # Jackpot 全屏特效
│   └── ui/
│       ├── DamageNumber.prefab     # 傷害數字顯示
│       └── MultiplierPopup.prefab  # 倍率爆字彈出
├── textures/
│   ├── fish/                       # 魚類 Sprite Atlas
│   ├── ui/                         # UI 元素紋理
│   ├── effects/                    # 特效紋理
│   └── background/                 # 背景紋理、Shader 圖
├── audio/
│   ├── bgm/                        # 背景音樂（MP3）
│   └── sfx/                        # 音效（OGG/MP3）
├── bundles/
│   ├── core/                       # 核心 Bundle（登入+大廳）
│   ├── game/                       # 遊戲 Bundle（主遊戲資源）
│   ├── shop/                       # 商城 Bundle（商城資源）
│   └── vip/                        # VIP Bundle（VIP 相關資源）
└── resources/                      # 動態載入資源（runtime loadDir）
    ├── fish-configs/               # 魚類設定 JSON
    └── weapon-configs/             # 武器設定 JSON
```

### 2.2 模組分層架構

```
┌──────────────────────────────────────────────────────────┐
│  Presentation Layer（Cocos Creator Node Components）      │
│  Scene Components / UI Components / HUD Components        │
│  → 只處理渲染和用戶輸入；不含業務邏輯                      │
│  → 透過 GameController / UIController 協調                │
├──────────────────────────────────────────────────────────┤
│  Application Layer（Game Systems / Controllers）          │
│  ShootingSystem / FishSystem / WeaponSystem / SkillSystem │
│  → 協調業務流程；處理 Colyseus 事件到視覺反饋的映射        │
│  → 不直接操作網路層（透過 NetworkManager）                 │
├──────────────────────────────────────────────────────────┤
│  Domain Layer（Game Logic / Data Types）                  │
│  游戲規則常數 / 型別定義 / Schema 鏡像                    │
│  → 純資料結構；零 Cocos 依賴；可獨立單元測試              │
├──────────────────────────────────────────────────────────┤
│  Infrastructure Layer（Network / Storage / Audio）        │
│  ColyseusClient / HttpClient / StorageUtils / AudioManager│
│  → 封裝外部依賴；對上層提供穩定的 Interface               │
└──────────────────────────────────────────────────────────┘

依賴方向：Presentation → Application → Domain ← Infrastructure
禁止：Infrastructure 直接呼叫 Presentation
禁止：Domain Layer import Cocos 模組
```

### 2.3 Scene 架構 (Cocos Creator)

**Scene 生命週期與切換策略**

```typescript
// Scene 切換統一透過 SceneManager 處理
enum GameScene {
  LOADING = 'LoadingScene',
  LOGIN = 'LoginScene',
  ONBOARDING = 'OnboardingScene',
  LOBBY = 'LobbyScene',
  CANNON_SELECT = 'CannonSelectScene',
  MATCHMAKING = 'MatchmakingScene',
  GAME = 'GameScene',
  SETTLEMENT = 'SettlementScene',
}

class SceneManager {
  static async loadScene(scene: GameScene, additive = false): Promise<void>
  static async preloadScene(scene: GameScene): Promise<void>
  static unloadScene(scene: GameScene): void
}
```

**Scene 轉換圖**

```
LoadingScene
    ↓ (資源預載完成)
LoginScene ←→ OnboardingScene（首次登入）
    ↓ (登入成功)
LobbyScene
    ↓ (選擇房間)
CannonSelectScene
    ↓ (確認武器)
MatchmakingScene
    ↓ (配對成功)
GameScene
    ↓ (局結束)
SettlementScene
    ↓ (確認結算)
LobbyScene
```

**常駐 Canvas 節點（跨 Scene 持久化）**

```
PersistentCanvas/
├── NetworkManager（全局網路狀態）
├── AudioManager（BGM 跨場景持續播放）
├── ToastLayer（全局 Toast 通知）
└── LoadingLayer（全局 Loading 遮罩）
```

---

## 3. 狀態管理

### 3.1 狀態分層

遊戲前端狀態按照生命週期與職責分為四層：

| 層次 | 類型 | 管理者 | 說明 |
|------|------|--------|------|
| **Server State** | Colyseus Room Schema | ColyseusClient | 權威狀態；伺服器推送；唯讀 |
| **Local Game State** | GameController 內部狀態 | GameController | 本地預測；等待伺服器確認 |
| **UI State** | 各 UI Component 內部 | UIController | 面板開關、動畫狀態 |
| **Persistent State** | LocalStorage | StorageUtils | 玩家偏好（音效、語言） |

**狀態更新原則（Server-Authoritative，對應 EDD §3.2 ADR-003）**

```typescript
// 正確模式：本地 UI 樂觀更新 → 等待伺服器確認 → 如不一致則回滾
class ShootingSystem {
  shoot(targetFishId?: string): void {
    // 1. 立即播放本地射擊動畫（樂觀更新）
    this.playLocalShootAnimation();
    // 2. 發送至伺服器（Server-Authoritative 命中判定）
    this.networkManager.send('shoot', { targetFishId });
    // 3. 等待 fish_died / fish_hit 伺服器事件確認
    // 4. 伺服器回應後觸發金幣獎勵動畫
  }
}
```

### 3.2 Colyseus 狀態同步

Colyseus Delta State Sync 機制確保只傳輸變更部分，節省 40-60% 帶寬（EDD ADR-001）。

**Client-side Schema 鏡像**

```typescript
import { Schema, MapSchema, ArraySchema, type } from '@colyseus/schema';

class PlayerState extends Schema {
  @type('string')  id: string;
  @type('string')  nickname: string;
  @type('uint32')  level: number;
  @type('int64')   coins: number;
  @type('int64')   diamonds: number;
  @type('uint8')   weaponLevel: number;
  @type('uint8')   weaponType: number;
  @type('uint8')   vipTier: number;
  @type('int32')   score: number;       // 本局得分（排名依據）
  @type('boolean') isConnected: boolean;
}

class FishState extends Schema {
  @type('string')  id: string;
  @type('uint8')   fishType: number;    // 0=普通, 1=精英, 2=Boss
  @type('float32') x: number;
  @type('float32') y: number;
  @type('uint32')  hp: number;
  @type('uint32')  maxHp: number;
  @type('uint8')   status: number;      // 0=active, 1=dying, 2=dead
  @type('float32') speed: number;
  @type('uint16')  multiplier: number;  // 基礎倍率
}

class BulletState extends Schema {
  @type('string')  id: string;
  @type('string')  ownerId: string;
  @type('float32') x: number;
  @type('float32') y: number;
  @type('uint8')   weaponType: number;
}

class GameRoomState extends Schema {
  @type({ map: PlayerState })   players  = new MapSchema<PlayerState>();
  @type({ array: FishState })   fishes   = new ArraySchema<FishState>();
  @type({ array: BulletState }) bullets  = new ArraySchema<BulletState>();
  @type('string')               roomStatus: string;   // 'waiting'|'playing'|'ending'
  @type('int64')                jackpotPool: number;
  @type('uint32')               timeRemaining: number; // 秒數
  @type('string')               currentMvpId: string;
}
```

**狀態變更監聽模式**

```typescript
class FishSystem {
  setupStateListeners(room: Room<GameRoomState>): void {
    // 魚新增（新魚出現）
    room.state.fishes.onAdd = (fish: FishState, key: string) => {
      const node = this.fishPoolManager.acquire(fish.fishType);
      node.setWorldPosition(fish.x, fish.y, 0);
      this.fishNodeMap.set(fish.id, node);
      this.playFishSpawnAnimation(node, fish.fishType);
    };

    // 魚移除（死亡後清除）
    room.state.fishes.onRemove = (fish: FishState, key: string) => {
      const node = this.fishNodeMap.get(fish.id);
      if (node) {
        this.fishPoolManager.release(node);
        this.fishNodeMap.delete(fish.id);
      }
    };

    // 魚狀態變更（HP 變化）
    room.state.fishes.onChange = (fish: FishState, changes) => {
      const node = this.fishNodeMap.get(fish.id);
      if (!node) return;
      changes.forEach(change => {
        if (change.field === 'hp') {
          this.updateFishHPBar(node, fish.hp, fish.maxHp);
        }
        if (change.field === 'status' && fish.status === 1) {
          this.playFishDyingAnimation(node, fish);
        }
      });
    };

    // Jackpot 池變更
    room.state.onChange = (changes) => {
      changes.forEach(change => {
        if (change.field === 'jackpotPool') {
          this.hudComponent.updateJackpotBar(change.value);
        }
      });
    };
  }
}
```

### 3.3 本地 UI 狀態

UI 狀態採用輕量的 TypeScript 類別管理，不引入外部狀態庫（保持 Cocos 構建體積可控）：

```typescript
// UIStateStore：集中管理 UI 狀態
class UIStateStore {
  private static instance: UIStateStore;

  // Dialog 開關狀態
  shopDialogOpen = false;
  settingsDialogOpen = false;
  confirmDialogOpen = false;

  // HUD 狀態
  playerGold = 0;
  playerDiamonds = 0;
  currentRank = 1;
  localScore = 0;

  // 技能冷卻（本地計時，伺服器確認）
  skillCooldowns: Map<SkillType, number> = new Map();

  static getInstance(): UIStateStore {
    if (!this.instance) this.instance = new UIStateStore();
    return this.instance;
  }

  // 簡易訂閱機制（取代 Redux/MobX）
  private listeners: Map<string, Set<() => void>> = new Map();
  subscribe(key: string, fn: () => void): () => void { /* ... */ }
  notify(key: string): void { /* ... */ }
}
```

---

## 4. 網路層設計

### 4.1 WebSocket 連線管理

```typescript
class NetworkManager {
  private colyseusClient: Client;
  private currentRoom: Room<GameRoomState> | null = null;
  private reconnectAttempts = 0;
  private readonly MAX_RECONNECT_ATTEMPTS = 5;
  private readonly RECONNECT_DELAY_MS = [1000, 2000, 4000, 8000, 16000];

  // 連線狀態機
  private connectionState: 'disconnected' | 'connecting' | 'connected' | 'reconnecting' = 'disconnected';

  constructor() {
    this.colyseusClient = new Client(API_CONSTANTS.COLYSEUS_WS_URL);
  }

  async connect(token: string): Promise<void> {
    this.connectionState = 'connecting';
    this.colyseusClient = new Client(API_CONSTANTS.COLYSEUS_WS_URL);
    // token 透過 Room join options 傳遞，不在 WebSocket URL 中暴露
  }

  getConnectionState(): string {
    return this.connectionState;
  }
}
```

### 4.2 Colyseus Room API

**Room 連線與基礎用法**

```typescript
import { Client, Room } from 'colyseus.js';
import { GameRoomState } from '../data/schemas/GameRoomSchema';

class ColyseusClient {
  private client: Client;
  private room: Room<GameRoomState> | null = null;

  constructor() {
    this.client = new Client(API_CONSTANTS.COLYSEUS_WS_URL);
    // API_CONSTANTS.COLYSEUS_WS_URL = 'wss://game.fishing-arcade-game.com'
  }

  async joinOrCreateRoom(
    roomType: 'normal' | 'vip' | 'high_roller',
    authToken: string
  ): Promise<Room<GameRoomState>> {
    this.room = await this.client.joinOrCreate<GameRoomState>('game_room', {
      roomType,
      token: authToken,
    });

    this.setupRoomListeners(this.room);
    return this.room;
  }

  // 射擊指令（Server-Authoritative：命中由伺服器判定）
  sendShoot(weaponType: WeaponType, targetFishId?: string): void {
    if (!this.room) return;
    this.room.send('shoot', {
      weaponType,
      targetFishId: targetFishId ?? null,
    });
  }

  // 技能觸發
  sendSkillActivate(skillType: SkillType): void {
    if (!this.room) return;
    this.room.send('skill_activate', { skillType });
  }

  // 武器切換
  sendWeaponSwitch(weaponType: WeaponType, weaponLevel: number): void {
    if (!this.room) return;
    this.room.send('weapon_switch', { weaponType, weaponLevel });
  }

  private setupRoomListeners(room: Room<GameRoomState>): void {
    // 魚死亡（含金幣獎勵）
    room.onMessage('fish_died', (data: FishDiedMessage) => {
      EventBus.emit('FISH_DIED', data);
    });

    // Jackpot 觸發
    room.onMessage('jackpot_trigger', (data: JackpotTriggerMessage) => {
      EventBus.emit('JACKPOT_TRIGGERED', data);
    });

    // MVP 更新
    room.onMessage('mvp_update', (data: MVPUpdateMessage) => {
      EventBus.emit('MVP_UPDATED', data);
    });

    // Boss 進場
    room.onMessage('boss_spawn', (data: BossSpawnMessage) => {
      EventBus.emit('BOSS_SPAWNED', data);
    });

    // 冰凍技能生效
    room.onMessage('skill_freeze', (data: SkillFreezeMessage) => {
      EventBus.emit('SKILL_FREEZE', data);
    });

    // 全屏炸彈生效
    room.onMessage('skill_bomb', (data: SkillBombMessage) => {
      EventBus.emit('SKILL_BOMB', data);
    });

    // 遊戲結束
    room.onMessage('game_end', (data: GameEndMessage) => {
      EventBus.emit('GAME_ENDED', data);
    });

    // 連線錯誤
    room.onError((code, message) => {
      console.error(`[ColyseusClient] Room error ${code}: ${message}`);
      EventBus.emit('ROOM_ERROR', { code, message });
    });

    // 房間離開
    room.onLeave((code) => {
      console.log(`[ColyseusClient] Left room with code: ${code}`);
      EventBus.emit('ROOM_LEFT', { code });
    });
  }
}
```

### 4.3 HTTP REST API 整合

```typescript
class HttpClient {
  private readonly baseUrl: string;
  private accessToken: string | null = null;

  constructor() {
    this.baseUrl = API_CONSTANTS.REST_BASE_URL;
    // API_CONSTANTS.REST_BASE_URL = 'https://api.fishing-arcade-game.com/v1'
  }

  setAccessToken(token: string): void {
    this.accessToken = token;
  }

  private async request<T>(
    method: string,
    path: string,
    body?: unknown
  ): Promise<T> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };
    if (this.accessToken) {
      headers['Authorization'] = `Bearer ${this.accessToken}`;
    }

    const response = await fetch(`${this.baseUrl}${path}`, {
      method,
      headers,
      body: body ? JSON.stringify(body) : undefined,
    });

    if (!response.ok) {
      const error = await response.json();
      throw new ApiError(response.status, error.error?.code, error.error?.message);
    }
    return response.json();
  }

  // Auth APIs
  async login(email: string, password: string): Promise<AuthResponse> {
    return this.request<AuthResponse>('POST', '/auth/login', { email, password });
  }

  async register(payload: RegisterPayload): Promise<RegisterResponse> {
    return this.request<RegisterResponse>('POST', '/auth/register', payload);
  }

  async refreshToken(refreshToken: string): Promise<RefreshTokenResponse> {
    return this.request<RefreshTokenResponse>('POST', '/auth/refresh', { refresh_token: refreshToken });
  }

  // Player APIs
  async getPlayerProfile(): Promise<PlayerProfileResponse> {
    return this.request<PlayerProfileResponse>('GET', '/users/me');
  }

  async getBalance(): Promise<BalanceResponse> {
    return this.request<BalanceResponse>('GET', '/users/me/balance');
  }

  // Shop APIs
  async getProducts(): Promise<ProductListResponse> {
    return this.request<ProductListResponse>('GET', '/shop/products');
  }

  async createOrder(payload: CreateOrderPayload): Promise<OrderResponse> {
    return this.request<OrderResponse>('POST', '/shop/orders', payload);
  }

  async verifyIAPReceipt(orderId: string, receipt: string): Promise<OrderResponse> {
    return this.request<OrderResponse>('POST', `/shop/orders/${orderId}/verify-receipt`, { receipt });
  }

  // Game APIs
  async getRooms(roomType?: string): Promise<RoomListResponse> {
    const query = roomType ? `?room_type=${roomType}` : '';
    return this.request<RoomListResponse>('GET', `/game/rooms${query}`);
  }
}
```

### 4.4 離線/重連處理

**重連策略（對應 EDD §10.4 DISCONNECTED 狀態，PRD US-ROOM-001 AC-2）**

```typescript
class NetworkManager {
  // 斷線後自動重連（玩家有 30 秒重連視窗，伺服器維持其在房間的佔位）
  private async attemptReconnect(): Promise<void> {
    if (this.reconnectAttempts >= this.MAX_RECONNECT_ATTEMPTS) {
      this.connectionState = 'disconnected';
      EventBus.emit('RECONNECT_FAILED');
      return;
    }

    this.connectionState = 'reconnecting';
    EventBus.emit('RECONNECTING', { attempt: this.reconnectAttempts + 1 });

    const delay = this.RECONNECT_DELAY_MS[this.reconnectAttempts];
    await new Promise(resolve => setTimeout(resolve, delay));

    try {
      // 嘗試使用 reconnectionToken 重連（Colyseus 內建機制）
      const savedToken = StorageUtils.get<string>('reconnection_token');
      const roomId = StorageUtils.get<string>('current_room_id');

      if (savedToken && roomId) {
        this.room = await this.client.reconnect(roomId, savedToken);
        this.connectionState = 'connected';
        this.reconnectAttempts = 0;
        EventBus.emit('RECONNECTED');
      } else {
        throw new Error('No reconnection token available');
      }
    } catch {
      this.reconnectAttempts++;
      await this.attemptReconnect();
    }
  }

  // 離線訊息佇列：網路中斷期間的操作暫存（重連後丟棄，不重發遊戲指令）
  private messageQueue: Array<{ type: string; data: unknown }> = [];

  send(type: string, data: unknown): void {
    if (this.connectionState === 'connected' && this.room) {
      this.room.send(type, data);
    }
    // 遊戲指令（shoot/skill）在離線時直接丟棄，不進行佇列重發
    // 避免重連後批次射擊造成異常
  }
}
```

---

## 5. 遊戲核心模組

### 5.1 射擊系統 (Shooting System)

射擊系統採用 **Server-Authoritative 模式**：客戶端只負責發送意圖和播放視覺反饋，命中判定與金幣結算完全由伺服器執行（EDD ADR-003）。

```typescript
enum WeaponType {
  NORMAL = 0,    // 基礎砲台（1x-5x 倍率）
  LASER  = 1,    // 雷射炮（高精度，低 AOE）
  SCATTER = 2,   // 散射炮（廣範圍，低單體）
  LOCK_ON = 3,   // 鎖定炮（自動追蹤目標）
}

interface BulletData {
  id: string;
  weaponType: WeaponType;
  originX: number;
  originY: number;
  targetX: number;
  targetY: number;
  targetFishId?: string;
}

class ShootingSystem {
  private weaponType: WeaponType = WeaponType.NORMAL;
  private weaponLevel = 1;
  private shootCooldownMs = 0;
  private lastShootTime = 0;

  constructor(
    private networkManager: NetworkManager,
    private bulletPoolManager: BulletPoolManager,
    private effectPoolManager: EffectPoolManager,
    private uiStateStore: UIStateStore,
  ) {}

  // 發送射擊指令（Server-Authoritative）
  shoot(targetFishId?: string): void {
    if (!this.canShoot()) return;

    this.lastShootTime = Date.now();

    // 立即播放本地砲台動畫（樂觀反饋）
    this.playCannonFireAnimation();

    // 生成本地子彈視覺（子彈飛行動畫）
    const bulletData = this.createBulletData(targetFishId);
    this.onBulletFired(bulletData);

    // 發送至伺服器（命中計算在伺服器端）
    this.networkManager.send('shoot', {
      weaponType: this.weaponType,
      targetFishId: targetFishId ?? null,
    });
  }

  // 子彈發射視覺反饋（本地即時）
  onBulletFired(bulletData: BulletData): void {
    const bulletNode = this.bulletPoolManager.acquire(bulletData.weaponType);
    bulletNode.setWorldPosition(bulletData.originX, bulletData.originY, 0);
    this.animateBulletFlight(bulletNode, bulletData);
  }

  // 命中反饋（伺服器確認後觸發）
  onFishHit(fishId: string, damage: number): void {
    const fishNode = this.fishSystem.getFishNode(fishId);
    if (!fishNode) return;

    // 傷害數字彈出
    const damageNumber = this.effectPoolManager.acquireDamageNumber();
    damageNumber.setWorldPosition(fishNode.worldPosition);
    damageNumber.getComponent(DamageNumber)!.show(damage);

    // 命中閃爍特效
    const hitEffect = this.effectPoolManager.acquireHitEffect();
    hitEffect.setWorldPosition(fishNode.worldPosition);
    hitEffect.getComponent(HitEffect)!.play();
  }

  // 魚死亡反饋（含金幣收益動畫）
  onFishDied(fishId: string, multiplier: number, coinsAwarded: number): void {
    const fishNode = this.fishSystem.getFishNode(fishId);
    if (!fishNode) return;

    // 倍率爆字（VDD text-multiplier: 56px/font-weight-900）
    const multiplierPopup = this.effectPoolManager.acquireMultiplierPopup();
    multiplierPopup.getComponent(MultiplierPopup)!.show(multiplier);

    // 金幣飛濺動畫（VDD §2.2：200+ 粒子噴射）
    const coinEffect = this.effectPoolManager.acquireCoinEffect();
    coinEffect.setWorldPosition(fishNode.worldPosition);
    coinEffect.getComponent(CoinEffect)!.play(coinsAwarded);

    // 更新本地 UI 金幣計數
    this.uiStateStore.playerGold += coinsAwarded;
    this.uiStateStore.notify('playerGold');
  }

  // 驗證是否可射擊（冷卻時間驗證，伺服器也會驗證）
  canShoot(): boolean {
    const now = Date.now();
    return (now - this.lastShootTime) >= this.shootCooldownMs;
  }

  // 武器切換（含本地 UI 更新 + 通知伺服器）
  updateWeapon(weaponType: WeaponType, level: number): void {
    this.weaponType = weaponType;
    this.weaponLevel = level;
    this.shootCooldownMs = WEAPON_COOLDOWNS[weaponType][level];
    this.networkManager.send('weapon_switch', { weaponType, weaponLevel: level });
  }

  private createBulletData(targetFishId?: string): BulletData {
    const cannon = this.getCannonNode();
    return {
      id: generateId(),
      weaponType: this.weaponType,
      originX: cannon.worldPosition.x,
      originY: cannon.worldPosition.y,
      targetX: this.aimTargetX,
      targetY: this.aimTargetY,
      targetFishId,
    };
  }

  private playCannonFireAnimation(): void { /* 砲台後坐力動畫 */ }
  private animateBulletFlight(node: Node, data: BulletData): void { /* 子彈飛行動畫 */ }
  private getCannonNode(): Node { /* 取得本玩家砲台節點 */ return null!; }
  private aimTargetX = 0;
  private aimTargetY = 0;
  private fishSystem!: FishSystem;
}
```

### 5.2 魚群管理 (Fish Pool Manager)

```typescript
// 魚類型常數
enum FishType {
  NORMAL = 0,  // 普通魚：1-5x 倍率，64×48 px，無 HP 條（一擊即死）
  ELITE  = 1,  // 精英魚：10-50x 倍率，128×96 px，顯示 HP 條
  BOSS   = 2,  // Boss 魚：100-1000x 倍率，320×240 px，全屏進場動畫
}

class FishPoolManager {
  // 物件池尺寸（對應 §8.2 規格）
  private readonly POOL_SIZES: Record<FishType, number> = {
    [FishType.NORMAL]: 60,
    [FishType.ELITE]:  30,
    [FishType.BOSS]:   5,   // Boss 同時最多 1-2 條，保留 5 個安全餘量
  };

  private pools: Map<FishType, Node[]> = new Map();
  private activeNodes: Map<string, Node> = new Map();  // fishId → Node

  async initialize(): Promise<void> {
    for (const [type, size] of Object.entries(this.POOL_SIZES)) {
      const pool: Node[] = [];
      const prefabPath = FISH_PREFAB_PATHS[Number(type) as FishType];
      const prefab = await resources.loadAsync<Prefab>(prefabPath);

      for (let i = 0; i < size; i++) {
        const node = instantiate(prefab);
        node.active = false;
        this.gameScene.addChild(node);
        pool.push(node);
      }
      this.pools.set(Number(type) as FishType, pool);
    }
  }

  acquire(fishType: FishType): Node {
    const pool = this.pools.get(fishType) ?? [];
    const node = pool.find(n => !n.active);
    if (!node) {
      // 池耗盡時動態擴展（上限 pools size × 1.5）
      console.warn(`[FishPoolManager] Pool exhausted for type ${fishType}, expanding`);
      return this.expandPool(fishType);
    }
    node.active = true;
    return node;
  }

  release(node: Node): void {
    node.active = false;
    node.setWorldPosition(OFFSCREEN_POSITION);
    // 重置所有 Component 狀態
    node.getComponent(FishComponent)?.reset();
  }

  getFishNode(fishId: string): Node | undefined {
    return this.activeNodes.get(fishId);
  }

  private expandPool(fishType: FishType): Node { /* 動態擴展邏輯 */ return null!; }
}
```

### 5.3 武器系統 (Weapon System)

```typescript
// 武器設定（對應 PRD §4.1 武器系統）
const WEAPON_CONFIG: Record<WeaponType, WeaponConfig> = {
  [WeaponType.NORMAL]: {
    name: '基礎砲台',
    maxLevel: 5,
    bulletPrefab: 'prefabs/bullets/NormalBullet',
    cooldownMs: [300, 250, 200, 150, 100],   // Level 1-5 冷卻時間
    bulletSpeed: 800,
    aoeRadius: 0,
  },
  [WeaponType.LASER]: {
    name: '雷射炮',
    maxLevel: 5,
    bulletPrefab: 'prefabs/bullets/LaserBullet',
    cooldownMs: [500, 420, 360, 300, 250],
    bulletSpeed: 1500,  // 光速直線彈
    aoeRadius: 0,
  },
  [WeaponType.SCATTER]: {
    name: '散射炮',
    maxLevel: 5,
    bulletPrefab: 'prefabs/bullets/ScatterBullet',
    cooldownMs: [600, 520, 440, 360, 300],
    bulletSpeed: 600,
    aoeRadius: 100,     // 扇形散射範圍
  },
  [WeaponType.LOCK_ON]: {
    name: '鎖定炮',
    maxLevel: 5,
    bulletPrefab: 'prefabs/bullets/LockOnBullet',
    cooldownMs: [800, 680, 560, 440, 320],
    bulletSpeed: 1000,
    aoeRadius: 0,
  },
};

class WeaponSystem {
  private currentWeapon: WeaponType = WeaponType.NORMAL;
  private currentLevel = 1;

  switchWeapon(weaponType: WeaponType): void {
    if (!this.playerOwnsWeapon(weaponType)) {
      // 未擁有武器 → 引導至商城
      EventBus.emit('WEAPON_NOT_OWNED', { weaponType });
      return;
    }
    this.currentWeapon = weaponType;
    this.shootingSystem.updateWeapon(weaponType, this.currentLevel);
    this.hudComponent.updateWeaponDisplay(weaponType, this.currentLevel);
  }

  upgradeWeapon(weaponType: WeaponType): void {
    // 升級由伺服器確認；本地樂觀更新後等待確認
    const nextLevel = this.getWeaponLevel(weaponType) + 1;
    if (nextLevel > WEAPON_CONFIG[weaponType].maxLevel) return;

    this.networkManager.httpClient.upgradeWeapon(weaponType, nextLevel)
      .then(() => {
        this.setWeaponLevel(weaponType, nextLevel);
        EventBus.emit('WEAPON_UPGRADED', { weaponType, level: nextLevel });
      })
      .catch(() => EventBus.emit('UPGRADE_FAILED'));
  }

  private playerOwnsWeapon(type: WeaponType): boolean { /* 查詢本地玩家資料 */ return true; }
  private getWeaponLevel(type: WeaponType): number { return this.currentLevel; }
  private setWeaponLevel(type: WeaponType, level: number): void { this.currentLevel = level; }
}
```

### 5.4 技能系統 (Skill System)

```typescript
enum SkillType {
  FREEZE   = 0,   // 冰凍：全場魚群停止移動 3 秒（PRD §4.1）
  BOMB     = 1,   // 全屏炸彈：AOE 傷害所有魚群
  AUTO_LOCK = 2,  // 自動鎖定：10 秒內自動追蹤最高倍率魚
}

interface SkillConfig {
  cooldownSeconds: number;
  durationSeconds: number;
  diamondCost: number;  // 鑽石費用（0 = 免費技能）
}

const SKILL_CONFIG: Record<SkillType, SkillConfig> = {
  [SkillType.FREEZE]:    { cooldownSeconds: 30, durationSeconds: 3, diamondCost: 0 },
  [SkillType.BOMB]:      { cooldownSeconds: 60, durationSeconds: 0, diamondCost: 5 },
  [SkillType.AUTO_LOCK]: { cooldownSeconds: 45, durationSeconds: 10, diamondCost: 0 },
};

class SkillSystem {
  private cooldownTimers: Map<SkillType, number> = new Map();
  private activeSkills: Set<SkillType> = new Set();

  activateSkill(skillType: SkillType): void {
    if (this.isOnCooldown(skillType)) {
      // 視覺反饋：冷卻中提示
      EventBus.emit('SKILL_ON_COOLDOWN', { skillType });
      return;
    }

    const config = SKILL_CONFIG[skillType];
    if (config.diamondCost > 0) {
      // 付費技能：需扣除鑽石（伺服器確認）
      this.networkManager.send('skill_activate', { skillType });
    } else {
      // 免費技能：直接發送指令
      this.networkManager.send('skill_activate', { skillType });
    }

    // 本地冷卻計時開始（伺服器也驗證；本地冷卻防止重複點擊）
    this.startLocalCooldown(skillType);
  }

  // 技能效果由伺服器廣播後觸發（onMessage 'skill_freeze'/'skill_bomb' 等）
  onFreezeActivated(data: SkillFreezeMessage): void {
    this.activeSkills.add(SkillType.FREEZE);
    this.fishSystem.freezeAllFish(data.durationMs);
    this.playFreezeEffect();
    scheduler.schedule(() => {
      this.activeSkills.delete(SkillType.FREEZE);
      this.fishSystem.unfreezeAllFish();
    }, data.durationMs / 1000);
  }

  onBombActivated(data: SkillBombMessage): void {
    this.playBombEffect();
    // 各魚的 HP 變化由 State Change 驅動（不需本地計算）
  }

  private isOnCooldown(skillType: SkillType): boolean {
    return (this.cooldownTimers.get(skillType) ?? 0) > 0;
  }

  private startLocalCooldown(skillType: SkillType): void {
    const config = SKILL_CONFIG[skillType];
    this.cooldownTimers.set(skillType, config.cooldownSeconds);
    this.uiStateStore.skillCooldowns.set(skillType, config.cooldownSeconds);

    const interval = setInterval(() => {
      const remaining = (this.cooldownTimers.get(skillType) ?? 0) - 1;
      this.cooldownTimers.set(skillType, remaining);
      this.uiStateStore.skillCooldowns.set(skillType, remaining);
      this.uiStateStore.notify('skillCooldowns');
      if (remaining <= 0) clearInterval(interval);
    }, 1000);
  }
}
```

### 5.5 RTP/Jackpot 客戶端邏輯

**核心原則：客戶端不計算 RTP，只播放視覺反饋**

```typescript
// RTP 引擎完全在伺服器端執行（EDD ADR-003）
// 客戶端只負責：
// 1. 接收伺服器廣播的結果（fish_died / jackpot_trigger）
// 2. 播放對應的視覺和音效反饋

class RTPDisplayHandler {
  // 接收伺服器 fish_died 事件後的視覺處理
  onFishDied(data: FishDiedMessage): void {
    const { fishId, winnerId, coinsAwarded, multiplier, isJackpot } = data;

    if (isJackpot) {
      this.playJackpotSequence(data);
      return;
    }

    // 普通擊殺反饋
    this.shootingSystem.onFishDied(fishId, multiplier, coinsAwarded);
    this.audioManager.playSFX(multiplier >= 100 ? 'kill_boss' : 'kill_normal');
  }

  // Jackpot 觸發全屏特效（VDD §4.1 Boss 死亡特效規格）
  private playJackpotSequence(data: JackpotTriggerMessage): void {
    // 1. 全屏暗化（overlay）
    this.uiController.showOverlay();

    // 2. 全屏金光爆炸粒子（200+ 粒子，VDD §2.2 item 5 規格）
    const jackpotEffect = this.effectPoolManager.acquireJackpotEffect();
    jackpotEffect.getComponent(JackpotEffect)!.play({
      particleCount: 250,
      initialVelocityRange: [600, 1200],  // px/s
      gravityMultiplier: 0.3,
      spawnDuration: 1000,
    });

    // 3. 倍率數字衝屏（text-multiplier: 56px, font-weight-900）
    //    scale 0.5 → 3.0 → fade out 1s（VDD §4.2 Boss 死亡特效）
    const multiplierPopup = this.effectPoolManager.acquireMultiplierPopup();
    multiplierPopup.getComponent(MultiplierPopup)!.showJackpot(data.jackpotAmount);

    // 4. 更新玩家金幣（動態計數器效果）
    this.hudComponent.animateCoinCounter(data.jackpotAmount);

    // 5. Jackpot 進度條重置動畫
    this.hudComponent.resetJackpotBar();

    // 6. BGM 切換至 Jackpot 主題
    this.audioManager.playBGM('jackpot_fanfare');
  }
}
```

---

## 6. UI/UX 實作

### 6.1 場景列表 (Scenes)

| Scene 名稱 | 功能 | 主要 UI 元件 | 對應 PDD §節 |
|-----------|------|------------|-------------|
| LoadingScene | 啟動資源預載、版本檢查 | Logo 動畫、進度條 | §5.0 |
| LoginScene | 登入/註冊/年齡驗證 | LoginForm, RegisterForm, AgeVerifyModal | §5.1, §5.2 |
| OnboardingScene | 新手引導（首次登入）| 互動式引導氣泡、高亮遮罩 | §5.2 |
| LobbyScene | 大廳、房間選擇、公告 | RoomList, AnnouncementBanner, BottomNav | §5.3 |
| CannonSelectScene | 武器技能選擇 | WeaponGrid, SkillGrid, ConfirmButton | §5.5 |
| MatchmakingScene | 配對等待（30s 倒數）| PlayerAvatarRow, CountdownTimer, CancelBtn | §5.9 |
| GameScene | 主遊戲（核心玩法）| HUD, JackpotBar, BossHPBar, SkillButtons | §5.4 |
| SettlementScene | 局結算、MVP 展示 | ResultCard, MVPBadge, CoinSummary, ShareBtn | §5.8 |

### 6.2 預製體 (Prefabs)

**魚類 Prefab 規格（對應 VDD §4.2）**

| Prefab | 尺寸 | Sprite Sheet | 動畫狀態 |
|--------|------|-------------|---------|
| NormalFish.prefab | 64×48 px | 8 幀 loop | Swim, Death |
| EliteFish.prefab | 128×96 px | 12 幀 loop + 4 幀受擊 | Swim, Hit, Death |
| BossFish.prefab | 320×240 px | 進場16幀+攻擊8幀+死亡32幀 | Spawn, Idle, Attack, Death |

**Prefab Component 架構**

```typescript
// 每個 FishPrefab 掛載 FishComponent
@ccclass('FishComponent')
export class FishComponent extends Component {
  @property(Animation) animator: Animation = null!;
  @property(ProgressBar) hpBar: ProgressBar = null!;
  @property(Label) fishLabel: Label = null!;

  private fishData: FishState | null = null;

  init(fishState: FishState): void {
    this.fishData = fishState;
    this.hpBar.node.active = fishState.fishType > FishType.NORMAL;
    this.updateHPBar(fishState.hp, fishState.maxHp);
  }

  updateHPBar(hp: number, maxHp: number): void {
    this.hpBar.progress = hp / maxHp;
    // HP 顏色：#00FF88（高）→ #FFEB3B（中）→ #FF4444（低）
    const ratio = hp / maxHp;
    const color = ratio > 0.6
      ? new Color(0, 255, 136)
      : ratio > 0.3
        ? new Color(255, 235, 59)
        : new Color(255, 68, 68);
    this.hpBar.getComponent(Sprite)!.color = color;
  }

  playDeathAnimation(onComplete: () => void): void {
    this.animator.play('Death');
    this.animator.on(Animation.EventType.FINISHED, onComplete, this);
  }

  reset(): void {
    this.fishData = null;
    this.hpBar.progress = 1;
    this.animator.stop();
  }
}
```

### 6.3 UI 框架與元件庫

**設計 Token 在 Cocos 中的實作**

VDD §6.1-6.3 的 CSS Custom Property 在 Cocos Creator 中以 TypeScript 常數物件實作：

```typescript
// assets/scripts/data/constants/ui.constants.ts
// 直接映射自 VDD §6.1 Primitive Tokens

export const COLOR = {
  // Brand
  GOLD_400: new Color(245, 200, 66, 255),      // #F5C842 — 主行動按鈕
  GOLD_600: new Color(201, 154, 0, 255),        // #C99A00 — Hover 狀態
  GOLD_900: new Color(122, 92, 0, 255),         // #7A5C00 — 按下狀態

  // Background
  OCEAN_900: new Color(5, 20, 40, 255),         // #051428 — 主背景
  OCEAN_800: new Color(10, 35, 64, 255),        // #0A2340 — 卡片/面板
  OCEAN_700: new Color(13, 51, 96, 255),        // #0D3360 — 次級面板

  // Neon
  NEON_BLUE:  new Color(0, 212, 255, 255),      // #00D4FF — 鑽石/技能
  NEON_GREEN: new Color(0, 255, 136, 255),      // #00FF88 — 成功/HP 高段

  // Feedback
  RED_500:    new Color(255, 68, 68, 255),      // #FF4444 — 錯誤/危急
  WHITE_100:  new Color(255, 255, 255, 255),

  // HP 條
  HP_HIGH:  new Color(0, 255, 136, 255),
  HP_MID:   new Color(255, 235, 59, 255),       // #FFEB3B — 中段純黃
  HP_LOW:   new Color(255, 68, 68, 255),
} as const;

export const FONT_SIZE = {
  CAPTION:    12,
  BODY_SM:    14,
  BODY:       16,
  BUTTON:     18,
  HUD_COUNTER: 20,
  H3:         20,
  H2:         24,
  HUD_SCORE:  28,
  H1:         32,
  HEADING_LG: 36,
  DISPLAY:    48,
  MULTIPLIER: 56,
} as const;

export const DURATION_MS = {
  INSTANT: 0,
  FAST:    80,
  NORMAL:  200,
  SLOW:    500,
  XSLOW:   1000,
  JACKPOT: 3000,
} as const;

// Z-index（Cocos localZOrder 對應）
export const Z_INDEX = {
  BG:       0,
  GAME:     1,
  HUD:      10,
  OVERLAY:  20,
  MODAL:    30,
  TOAST:    40,
  TUTORIAL: 50,
} as const;
```

**通用元件規格**

```typescript
// ToastComponent：全局通知（對應 VDD §5 HUD 系統）
@ccclass('ToastComponent')
export class ToastComponent extends Component {
  static show(message: string, type: 'success' | 'error' | 'info' = 'info'): void {
    const colorMap = {
      success: COLOR.NEON_GREEN,
      error:   COLOR.RED_500,
      info:    COLOR.NEON_BLUE,
    };
    // 從全局 Toast 池取節點，播放滑入動畫（200ms ease-out），3s 後滑出
  }
}
```

### 6.4 動畫系統

**動畫分類與實作策略**

| 動畫類型 | 工具 | 說明 |
|---------|------|------|
| 介面進場/退場 | Cocos Tween API | 面板 scale/opacity 動畫（DURATION_MS.NORMAL = 200ms） |
| 魚群游動 | Cocos Animation | Sprite Sheet 幀動畫 + 路徑移動 |
| 特效粒子 | Cocos ParticleSystem | 金幣噴射、Jackpot 爆炸 |
| 數字跳動 | 自訂 Tween | 金幣計數器動態遞增 |
| VIP 光暈 | Cocos Shader + Particle | 環形旋轉光暈 |
| Boss 進場 | Cocos Animation + Camera Shake | 16 幀進場 + 全屏震動 2s |

**緩動函數對應（VDD §6.1 Motion Tokens）**

```typescript
// assets/scripts/utils/AnimationUtils.ts
import { tween, Node, Easing } from 'cc';

export class AnimationUtils {
  // --easing-expo-out: cubic-bezier(0.16, 1, 0.3, 1) → Cocos: EXPO_OUT
  static showPanel(node: Node, durationMs = 200): Promise<void> {
    return new Promise(resolve => {
      node.active = true;
      node.setScale(0.8, 0.8, 1);
      tween(node)
        .to(durationMs / 1000, { scale: new Vec3(1, 1, 1) }, { easing: 'expoOut' })
        .call(resolve)
        .start();
    });
  }

  static hidePanel(node: Node, durationMs = 150): Promise<void> {
    return new Promise(resolve => {
      tween(node)
        .to(durationMs / 1000,
          { scale: new Vec3(0.8, 0.8, 1) },
          { easing: 'expoIn' }
        )
        .call(() => { node.active = false; resolve(); })
        .start();
    });
  }

  // 倍率爆字動畫（scale 0 → 1.2 → 1.0，VDD §2.4 多巴胺刺激感）
  static multiplierBurst(node: Node, durationMs = 400): Promise<void> {
    return new Promise(resolve => {
      tween(node)
        .set({ scale: new Vec3(0, 0, 1) })
        .to(durationMs * 0.6 / 1000, { scale: new Vec3(1.2, 1.2, 1) }, { easing: 'backOut' })
        .to(durationMs * 0.4 / 1000, { scale: new Vec3(1, 1, 1) }, { easing: 'sineOut' })
        .call(resolve)
        .start();
    });
  }

  // 金幣計數器動態遞增
  static animateCounter(
    label: Label,
    from: number,
    to: number,
    durationMs = 800
  ): void {
    const startTime = Date.now();
    const update = () => {
      const elapsed = Date.now() - startTime;
      const progress = Math.min(elapsed / durationMs, 1);
      const eased = 1 - Math.pow(1 - progress, 3); // ease-out-cubic
      label.string = Math.floor(from + (to - from) * eased).toLocaleString();
      if (progress < 1) requestAnimationFrame(update);
    };
    requestAnimationFrame(update);
  }
}
```

---

## 7. 資源管理

### 7.1 Asset Bundle 規劃

| Bundle 名稱 | 包含資源 | 載入時機 | 預估大小 |
|-----------|---------|---------|---------|
| `core` | 登入場景、大廳場景、共用 UI 紋理、核心 Script | 啟動時必載 | ~3 MB |
| `game` | GameScene、所有魚類 Sprite、子彈特效、遊戲 BGM | 進入配對前預載 | ~8 MB |
| `shop` | ShopDialog 相關紋理、商品圖片 | 首次開啟商城時按需載入 | ~2 MB |
| `vip` | VIP 光暈 Shader、等級徽章紋理 | 大廳載入後後台預載 | ~1 MB |

**Bundle 載入策略**

```typescript
class AssetBundleManager {
  private loadedBundles: Set<string> = new Set();

  async loadBundle(bundleName: string): Promise<AssetManager.Bundle> {
    if (this.loadedBundles.has(bundleName)) {
      return assetManager.getBundle(bundleName)!;
    }
    const bundle = await new Promise<AssetManager.Bundle>((resolve, reject) => {
      assetManager.loadBundle(bundleName, (err, bundle) => {
        if (err) reject(err);
        else resolve(bundle);
      });
    });
    this.loadedBundles.add(bundleName);
    return bundle;
  }

  // 配對等待期間預載 game bundle（避免進場卡頓）
  async preloadGameBundle(): Promise<void> {
    await this.loadBundle('game');
  }

  // 釋放非當前場景的 Bundle（記憶體管理）
  releaseBundle(bundleName: string): void {
    const bundle = assetManager.getBundle(bundleName);
    if (bundle && bundleName !== 'core') {
      bundle.releaseAll();
      this.loadedBundles.delete(bundleName);
    }
  }
}
```

### 7.2 動態載入策略

```typescript
// 魚類設定 JSON 動態載入（不硬編碼在程式碼中，方便運營調整）
async function loadFishConfigs(): Promise<FishConfig[]> {
  const bundle = await assetBundleManager.loadBundle('core');
  return new Promise((resolve, reject) => {
    bundle.loadDir('fish-configs', JsonAsset, (err, assets) => {
      if (err) reject(err);
      else resolve(assets.map(a => a.json as FishConfig));
    });
  });
}

// 按需載入 Boss 魚特效（僅在 Boss 進場時才需要全解析度資源）
async function preloadBossEffects(bossType: BossType): Promise<void> {
  const bundle = await assetBundleManager.loadBundle('game');
  const prefabPath = `prefabs/fish/${BOSS_PREFAB_MAP[bossType]}`;
  await new Promise<void>((resolve, reject) => {
    bundle.preload(prefabPath, Prefab, (err) => {
      if (err) reject(err);
      else resolve();
    });
  });
}
```

### 7.3 記憶體管理

**目標：執行時記憶體 < 200 MB（中端設備）**

```typescript
class MemoryManager {
  // 場景切換時釋放前場景資源
  onSceneUnload(sceneName: string): void {
    // 1. 釋放物件池中所有非活躍節點
    if (sceneName === 'GameScene') {
      fishPoolManager.releaseAll();
      bulletPoolManager.releaseAll();
      effectPoolManager.releaseAll();
    }

    // 2. 釋放非 core bundle
    if (sceneName === 'GameScene') {
      assetBundleManager.releaseBundle('game');
    }

    // 3. 強制 GC（Cocos 提供）
    if (sys.isNative) {
      sys.garbageCollect();
    }
  }

  // 紋理壓縮格式選擇（依平台）
  static getTextureCompression(): string {
    if (sys.os === sys.OS.IOS) return 'ASTC';        // iOS: ASTC 4x4
    if (sys.os === sys.OS.ANDROID) return 'ETC2';    // Android: ETC2
    return 'WEBP';                                    // H5: WebP
  }
}
```

---

## 8. 效能最佳化

### 8.1 渲染效能

**目標：60 fps on 中端移動設備（高通 Snapdragon 730 / Apple A13 等級）**

```typescript
// DrawCall 最佳化策略
// 1. 所有魚類紋理合入同一個 Sprite Atlas（TexturePacker 生成）
//    → 同類魚的所有 Sprite 共享一個 Material → 減少 DrawCall

// 2. UI 元素同樣使用 Atlas，避免逐個 Sprite 產生 DrawCall
//    → HUD 所有圖示合入 ui-atlas.png

// 3. 設定 Cocos 合批渲染（Batching）
// 在 Project Settings → Graphics 啟用 Dynamic Batching

// 4. 避免在遊戲主迴圈中使用 find() 搜尋節點
//    → 所有頻繁訪問的節點在 onLoad 時快取

@ccclass('GameScene')
export class GameSceneComponent extends Component {
  // 快取關鍵節點（避免每幀 find）
  @property(Node) fishLayer: Node = null!;
  @property(Node) bulletLayer: Node = null!;
  @property(Node) effectLayer: Node = null!;
  @property(Node) hudLayer: Node = null!;
}

// 5. 使用 Node.active 控制顯隱（而非 opacity = 0）
//    → active = false 的節點不參與渲染管線

// 6. 背景 Shader 優化：水波動畫使用 UV Scroll Shader（GPU 計算）
//    → 不需要每幀更新 CPU 資料
```

**Frame Budget 分配（60 fps = 16.67 ms/frame）**

| 任務 | 目標耗時 | 說明 |
|------|---------|------|
| 遊戲邏輯更新（TS）| < 2 ms | 物件池查詢、狀態更新 |
| Colyseus Delta Apply | < 1 ms | Schema 差量更新 |
| UI 更新 | < 1 ms | HUD 數字更新 |
| 渲染（GPU）| < 8 ms | DrawCall 控制 < 50/frame |
| 音效混音（Web Audio）| < 1 ms | SFX 觸發 |
| 緩衝 | < 3.67 ms | 系統調度緩衝 |

### 8.2 物件池 (Object Pool)

**物件池規格（對應需求規格）**

| 池類型 | 初始化大小 | 最大擴展 | 說明 |
|--------|-----------|---------|------|
| FishNode（普通）| 60 | 90 | 常規遊戲場景同時最多 50 條普通魚 |
| FishNode（精英）| 30 | 45 | 精英魚通常同時 5-10 條 |
| FishNode（Boss）| 5 | 5 | Boss 同時最多 1-2 條，不擴展 |
| BulletNode | 200 | 300 | 4-6 人 × 高射速 × 在途子彈 |
| HitEffect | 50 | 80 | 命中特效（短時間播放即回收）|
| CoinEffect | 100 | 150 | 金幣飛出特效 |
| DamageNumber | 60 | 100 | 傷害數字（顯示 0.5s 後回收）|
| MultiplierPopup | 20 | 30 | 倍率爆字（大型特效）|

```typescript
// 通用物件池基類
class ObjectPool<T extends Component> {
  private pool: Node[] = [];
  private activeCount = 0;

  constructor(
    private prefab: Prefab,
    private parent: Node,
    private initialSize: number,
    private maxSize: number,
    private componentClass: new () => T,
  ) {}

  async initialize(): Promise<void> {
    for (let i = 0; i < this.initialSize; i++) {
      const node = instantiate(this.prefab);
      node.active = false;
      this.parent.addChild(node);
      this.pool.push(node);
    }
  }

  acquire(): Node {
    const node = this.pool.find(n => !n.active);
    if (!node) {
      if (this.pool.length < this.maxSize) {
        const newNode = instantiate(this.prefab);
        newNode.active = false;
        this.parent.addChild(newNode);
        this.pool.push(newNode);
        return this.activate(newNode);
      }
      // 超出最大池：回收最舊的活躍節點
      console.warn(`[ObjectPool] Max size ${this.maxSize} reached, recycling oldest`);
      return this.activate(this.pool[0]);
    }
    return this.activate(node);
  }

  release(node: Node): void {
    node.active = false;
    node.getComponent(this.componentClass)?.reset?.();
    this.activeCount--;
  }

  releaseAll(): void {
    this.pool.forEach(n => { if (n.active) this.release(n); });
  }

  private activate(node: Node): Node {
    node.active = true;
    this.activeCount++;
    return node;
  }

  getActiveCount(): number { return this.activeCount; }
  getPoolSize(): number { return this.pool.length; }
}
```

### 8.3 網路效能

**訊息頻率控制**

```typescript
// 射擊訊息節流：防止玩家超頻率發送（伺服器端也有 60 msg/s 限制）
class ShootingSystem {
  private readonly MIN_SHOOT_INTERVAL_MS = 80; // 對應最快武器 Level 5 冷卻

  private lastSendTime = 0;

  shoot(targetFishId?: string): void {
    const now = Date.now();
    if (now - this.lastSendTime < this.MIN_SHOOT_INTERVAL_MS) return;
    this.lastSendTime = now;
    // ... 發送邏輯
  }
}

// 狀態更新批次處理：同一幀內多個 Schema 變更合併處理
class FishSystem {
  private pendingUpdates: FishState[] = [];

  // Colyseus onChange 只收集變更
  queueFishUpdate(fish: FishState): void {
    this.pendingUpdates.push(fish);
  }

  // update() 每幀批次處理（減少 DOM/Canvas 操作次數）
  update(): void {
    if (this.pendingUpdates.length === 0) return;
    for (const fish of this.pendingUpdates) {
      this.applyFishUpdate(fish);
    }
    this.pendingUpdates.length = 0;
  }
}
```

---

## 9. 多平台支援

### 9.1 Web (H5) 平台

**目標規格**

| 指標 | 目標 | 說明 |
|------|------|------|
| 初始載入時間 | < 5 秒（4G 網路）| core bundle < 3 MB，gzip 壓縮 |
| 首屏渲染 | < 2 秒 | Loading Scene 資源精簡 |
| 執行幀率 | 60 fps（Chrome / Safari）| WebGL 2.0 渲染 |
| 記憶體 | < 200 MB | 瀏覽器 Tab 穩定不崩潰 |

**H5 特殊處理**

```typescript
// H5 平台音效：需要用戶手勢後才能播放（瀏覽器限制）
class AudioManager {
  private isAudioUnlocked = false;

  unlockAudio(): void {
    if (this.isAudioUnlocked) return;
    // 在用戶首次觸摸事件中解鎖 Web Audio Context
    const context = new AudioContext();
    context.resume().then(() => {
      this.isAudioUnlocked = true;
    });
  }
}

// H5 全屏支援
function requestFullscreen(): void {
  const canvas = document.getElementById('GameCanvas') as HTMLCanvasElement;
  if (canvas.requestFullscreen) {
    canvas.requestFullscreen();
  }
}

// H5 安全區域（瀏覽器工具列）
function applySafeArea(): void {
  // 偵測瀏覽器 URL bar 高度，調整 Canvas 尺寸
  const visualViewport = window.visualViewport;
  if (visualViewport) {
    visualViewport.addEventListener('resize', () => {
      cc.game.canvas.style.height = `${visualViewport.height}px`;
    });
  }
}
```

**H5 Bundle 優化**

```
// cocos.build.json（H5 構建設定）
{
  "platform": "web-mobile",
  "md5Cache": true,           // 資源 MD5 版本號（CDN 快取破除）
  "useCompressTexture": true, // 啟用紋理壓縮（WebP）
  "webgpu": false,            // 保持 WebGL 2.0 相容
  "sourceMap": false,         // 生產環境不產生 source map
  "inlineSpriteFrames": true, // 小圖示 Base64 內嵌
}
```

### 9.2 iOS 平台

**目標規格**

| 指標 | 目標 |
|------|------|
| 最低支援 | iOS 14+（iPhone SE 2nd gen 等級）|
| 紋理壓縮 | ASTC 4x4（PowerVR/Apple GPU）|
| 記憶體 | < 200 MB（防止 iOS 低記憶體 kill）|
| 幀率 | 60 fps（ProMotion 裝置 120 fps 上限）|

**iOS 特殊處理**

```typescript
// 安全區域（劉海/Home Bar）
if (sys.os === sys.OS.IOS) {
  // 取得 safeAreaInsets
  const safeArea = sys.getSafeAreaRect();
  // 調整 HUD 位置，避開劉海和 Home Bar
  this.hudNode.setPosition(
    this.hudNode.position.x,
    this.hudNode.position.y - safeArea.y / 2,
  );
}

// Metal 後端（iOS 14+ 使用 Metal 而非 OpenGL ES）
// Cocos 3.8 自動處理，無需手動切換
```

### 9.3 Android 平台

**目標規格**

| 指標 | 目標 |
|------|------|
| 最低支援 | Android 8.0（API Level 26）|
| 紋理壓縮 | ETC2（所有 OpenGL ES 3.0+ 裝置）|
| 包體大小 | APK < 80 MB（Google Play 限制）+ OBB/PAD |
| 記憶體 | < 200 MB（防止低記憶體殺程式）|

**Android 特殊處理**

```typescript
// 返回鍵處理（Android 實體返回鍵）
if (sys.os === sys.OS.ANDROID) {
  input.on(Input.EventType.KEY_DOWN, (event) => {
    if (event.keyCode === KeyCode.ESCAPE) {
      this.handleAndroidBack();
    }
  });
}

function handleAndroidBack(): void {
  // 如果有 Dialog 開啟，先關閉 Dialog
  if (UIController.hasOpenDialog()) {
    UIController.closeTopDialog();
    return;
  }
  // 在大廳顯示退出確認
  if (SceneManager.currentScene === GameScene.LOBBY) {
    ConfirmDialog.show('確定要退出遊戲嗎？', () => {
      sys.exit();
    });
  }
}
```

### 9.4 響應式適配

**設計寬度：720 px FIXED_WIDTH（對應 VDD §0 設計規格）**

```typescript
// Canvas 自適應策略：FIXED_WIDTH
// 固定寬度 720 px，高度依設備螢幕比例浮動
// 在 Cocos Project Settings 設定：
// - Design Resolution: 720 × 1280
// - Fit Width: true
// - Fit Height: false（高度自適應）

// 不同長寬比的適配
const DESIGN_WIDTH  = 720;
const DESIGN_HEIGHT = 1280;

function getScaleFactor(): number {
  const screenWidth  = sys.windowSize.width;
  const screenHeight = sys.windowSize.height;
  return screenWidth / DESIGN_WIDTH;
}

// HUD 元素位置適配
function adaptHUDPositions(safeArea: Rect): void {
  const scale = getScaleFactor();
  const actualHeight = sys.windowSize.height / scale;

  // 底部 HUD 適配（考慮 Home Bar）
  bottomHUD.setPosition(0, -actualHeight / 2 + safeArea.y + 60);

  // 頂部 HUD 適配（考慮狀態欄）
  topHUD.setPosition(0, actualHeight / 2 - safeArea.height - 60);
}
```

---

## 10. 安全性

### 10.1 前端安全原則

**遵循 EDD §4 Security 設計，前端實作以下原則：**

| 原則 | 實作方式 |
|------|---------|
| JWT Token 安全儲存 | access_token 存 memory（不寫 localStorage）；refresh_token 存 Cocos `sys.localStorage`（加密）|
| Token 自動刷新 | access_token 過期前 60 秒自動呼叫 `/v1/auth/refresh`；失敗時導向登入頁 |
| 敏感資料不暴露 | 不在前端 log 中輸出 token、密碼、金幣絕對值 |
| 本地儲存加密 | 使用 AES-GCM 加密 refresh_token 後再存 localStorage |
| HTTPS Only | 所有 REST API 強制 HTTPS；WebSocket 強制 WSS |

```typescript
// Token 管理（安全儲存）
class AuthManager {
  private accessToken: string | null = null;     // 純 memory，頁面刷新後消失
  private readonly TOKEN_STORAGE_KEY = 'rt_enc'; // 加密後的 refresh_token

  setTokens(accessToken: string, refreshToken: string): void {
    this.accessToken = accessToken;
    // refresh_token 加密存儲
    const encrypted = this.encrypt(refreshToken);
    sys.localStorage.setItem(this.TOKEN_STORAGE_KEY, encrypted);
  }

  getAccessToken(): string | null {
    return this.accessToken;
  }

  async getOrRefreshToken(): Promise<string | null> {
    if (this.accessToken && !this.isTokenExpired(this.accessToken)) {
      return this.accessToken;
    }
    // Token 過期，嘗試刷新
    const encryptedRefreshToken = sys.localStorage.getItem(this.TOKEN_STORAGE_KEY);
    if (!encryptedRefreshToken) return null;

    try {
      const refreshToken = this.decrypt(encryptedRefreshToken);
      const response = await httpClient.refreshToken(refreshToken);
      this.accessToken = response.data.access_token;
      return this.accessToken;
    } catch {
      this.clearTokens();
      EventBus.emit('AUTH_EXPIRED');
      return null;
    }
  }

  clearTokens(): void {
    this.accessToken = null;
    sys.localStorage.removeItem(this.TOKEN_STORAGE_KEY);
  }

  private isTokenExpired(token: string): boolean {
    try {
      const payload = JSON.parse(atob(token.split('.')[1]));
      return Date.now() / 1000 > payload.exp - 60; // 提前 60 秒判定過期
    } catch {
      return true;
    }
  }

  private encrypt(data: string): string { /* AES-GCM 加密 */ return data; }
  private decrypt(data: string): string { /* AES-GCM 解密 */ return data; }
}
```

### 10.2 Server-Authoritative 設計

**前端不信任、不計算任何影響金幣的邏輯（EDD ADR-003）：**

```typescript
// 錯誤做法（絕對禁止）：
// ❌ 客戶端自行計算命中率
// ❌ 客戶端本地修改 gold_balance
// ❌ 客戶端快取 RTP 值並自行判斷命中

// 正確做法：
// ✅ 所有結果等待伺服器 onMessage 確認後才更新 UI
// ✅ 金幣餘額以伺服器 Room Schema 中的 PlayerState.coins 為準
// ✅ 技能冷卻本地計時只是 UX 優化，伺服器拒絕時顯示錯誤

class ShootingSystem {
  // 伺服器拒絕射擊指令（例如金幣不足）時的處理
  onShootRejected(reason: ShootRejectReason): void {
    switch (reason) {
      case ShootRejectReason.INSUFFICIENT_FUNDS:
        // 引導至充值（自然變現，PDD §1.3 原則 3）
        UIController.showShopDialog('not_enough_gold');
        break;
      case ShootRejectReason.WEAPON_ON_COOLDOWN:
        // 靜默忽略（本地冷卻計時應已阻止，這裡是伺服器的雙重保障）
        break;
      case ShootRejectReason.ROOM_ENDED:
        UIController.showToast('遊戲已結束', 'info');
        break;
    }
  }
}
```

---

## 11. 測試策略

### 11.1 單元測試

**框架：Jest + ts-jest（對應 EDD §3.3 技術棧）**

**測試範圍：純 TypeScript 邏輯（零 Cocos 依賴）**

```typescript
// assets/scripts/utils/__tests__/AnimationUtils.test.ts
describe('AnimationUtils', () => {
  describe('multiplierBurst', () => {
    it('should resolve after animation duration', async () => {
      const mockNode = createMockNode();
      const startTime = Date.now();
      await AnimationUtils.multiplierBurst(mockNode, 400);
      expect(Date.now() - startTime).toBeGreaterThanOrEqual(380);
    });
  });
});

// assets/scripts/game/systems/__tests__/ShootingSystem.test.ts
describe('ShootingSystem', () => {
  describe('canShoot', () => {
    it('returns false when within cooldown period', () => {
      const system = new ShootingSystem(mockNetwork, mockBulletPool, mockEffectPool, mockUIStore);
      system.updateWeapon(WeaponType.NORMAL, 1);
      system.shoot();
      expect(system.canShoot()).toBe(false);
    });

    it('returns true after cooldown expires', async () => {
      const system = new ShootingSystem(mockNetwork, mockBulletPool, mockEffectPool, mockUIStore);
      system.updateWeapon(WeaponType.NORMAL, 1);
      system.shoot();
      await new Promise(r => setTimeout(r, 310)); // NORMAL Level 1 冷卻 300ms
      expect(system.canShoot()).toBe(true);
    });
  });

  describe('onFishDied', () => {
    it('increments playerGold in UIStateStore', () => {
      const mockUIStore = new UIStateStore();
      mockUIStore.playerGold = 1000;
      const system = new ShootingSystem(mockNetwork, mockBulletPool, mockEffectPool, mockUIStore);
      system.onFishDied('fish-001', 10, 500);
      expect(mockUIStore.playerGold).toBe(1500);
    });
  });
});

// assets/scripts/data/schemas/__tests__/GameRoomSchema.test.ts
describe('GameRoomState Schema', () => {
  it('should deserialize fish state correctly', () => {
    const state = new GameRoomState();
    const fish = new FishState();
    fish.id = 'fish-001';
    fish.fishType = FishType.BOSS;
    fish.hp = 500;
    fish.maxHp = 1000;
    state.fishes.push(fish);

    expect(state.fishes[0].id).toBe('fish-001');
    expect(state.fishes[0].hp / state.fishes[0].maxHp).toBe(0.5);
  });
});
```

**覆蓋率目標：≥ 80%（對應 common/testing.md 規範）**

```
// jest.config.ts
export default {
  preset: 'ts-jest',
  testEnvironment: 'node',
  testMatch: ['**/__tests__/**/*.test.ts'],
  collectCoverageFrom: [
    'assets/scripts/**/*.ts',
    '!assets/scripts/**/*.d.ts',
    '!assets/scripts/**/*.scene.ts',  // 排除 Scene 入口（Cocos 依賴）
  ],
  coverageThreshold: {
    global: {
      branches:   80,
      functions:  80,
      lines:      80,
      statements: 80,
    }
  },
  // Mock Cocos 模組
  moduleNameMapper: {
    '^cc$': '<rootDir>/test-mocks/cocos-mock.ts',
  },
};
```

### 11.2 整合測試

**Colyseus Room 整合測試（使用 Colyseus Testing 工具）**

```typescript
// assets/scripts/network/__tests__/ColyseusIntegration.test.ts
import { ColyseusTestServer, Room } from '@colyseus/testing';

describe('Colyseus Room Integration', () => {
  let server: ColyseusTestServer;

  beforeAll(async () => {
    server = await ColyseusTestServer.create(gameServerApp);
  });

  afterAll(() => server.shutdown());

  it('should sync fish state after fish spawn', async () => {
    const client1 = await server.connectTo('game_room', { token: mockToken });
    const client2 = await server.connectTo('game_room', { token: mockToken2 });

    await server.waitForMessage(client1, 'fish_spawn');
    expect(client1.state.fishes.size).toBeGreaterThan(0);
    // 兩個客戶端應看到相同的魚群狀態
    expect(client1.state.fishes.size).toBe(client2.state.fishes.size);
  });

  it('should broadcast fish_died after server hit detection', async () => {
    const client = await server.connectTo('game_room', { token: mockToken });
    client.send('shoot', { weaponType: WeaponType.NORMAL, targetFishId: 'fish-001' });

    const message = await server.waitForMessage(client, 'fish_died');
    expect(message).toMatchObject({
      fishId: 'fish-001',
      coinsAwarded: expect.any(Number),
    });
  });
});
```

**HTTP API 整合測試**

```typescript
// 驗證 HttpClient 與真實 API 的整合（staging 環境）
describe('HttpClient Integration', () => {
  const client = new HttpClient();

  it('should login and receive JWT tokens', async () => {
    const response = await client.login(
      process.env.TEST_USER_EMAIL!,
      process.env.TEST_USER_PASSWORD!
    );
    expect(response.data.access_token).toBeDefined();
    expect(response.data.refresh_token).toBeDefined();
  });
});
```

### 11.3 效能測試

**幀率效能測試（60 fps 目標驗證）**

```typescript
// 自動化效能測試：在 GameScene 中監測幀率下限
class PerformanceMonitor extends Component {
  private fpsHistory: number[] = [];
  private readonly SAMPLE_DURATION_S = 30; // 採樣 30 秒

  update(dt: number): void {
    const fps = 1 / dt;
    this.fpsHistory.push(fps);

    if (this.fpsHistory.length > this.SAMPLE_DURATION_S * 60) {
      this.reportPerformance();
    }
  }

  private reportPerformance(): void {
    const avg = this.fpsHistory.reduce((a, b) => a + b) / this.fpsHistory.length;
    const min = Math.min(...this.fpsHistory);
    const p5  = this.percentile(this.fpsHistory, 5);

    console.log(`[Perf] FPS: avg=${avg.toFixed(1)}, min=${min.toFixed(1)}, p5=${p5.toFixed(1)}`);

    // CI 中斷條件：p5 FPS < 45 視為不通過
    if (process.env.CI && p5 < 45) {
      throw new Error(`Performance regression: p5 FPS ${p5.toFixed(1)} < 45`);
    }
  }

  private percentile(arr: number[], p: number): number {
    const sorted = [...arr].sort((a, b) => a - b);
    return sorted[Math.floor(sorted.length * p / 100)];
  }
}
```

**記憶體洩漏檢測**

```typescript
// 場景切換後驗證物件池已正確回收
describe('Memory Management', () => {
  it('should release all pool nodes after scene unload', async () => {
    await SceneManager.loadScene(GameScene.GAME);
    const fishPoolBefore = fishPoolManager.getPoolSize();

    // 模擬一局遊戲
    await simulateGameSession();

    await SceneManager.loadScene(GameScene.LOBBY);
    MemoryManager.onSceneUnload('GameScene');

    expect(fishPoolManager.getActiveCount()).toBe(0);
    expect(bulletPoolManager.getActiveCount()).toBe(0);
  });
});
```

---

## 12. 關鍵技術決策 (ADR)

### ADR-FE-001：TypeScript 取代 Lua 作為客戶端主語言

| 欄位 | 內容 |
|------|------|
| **狀態** | ACCEPTED |
| **背景** | Cocos Creator 3.8 同時支援 TypeScript 和 Lua。EDD §3.3 已確認伺服器端使用 TypeScript 5.4。|
| **決策** | 全面採用 TypeScript，不使用 Lua |
| **理由** | (1) 客戶端/伺服器共享 Colyseus Schema 型別定義（型別安全）；(2) TypeScript IDE 支援優於 Lua；(3) 統一語言降低團隊學習成本；(4) Cocos Creator 3.8 對 TypeScript 的官方支援更完整 |
| **後果** | 需要在 CI 中執行 `tsc --noEmit` 型別檢查；Lua 模組無法直接複用（EDD 提及的 taishan6868 Lua 模組需要移植）|

### ADR-FE-002：物件池預分配策略

| 欄位 | 內容 |
|------|------|
| **狀態** | ACCEPTED |
| **背景** | 捕魚遊戲需要頻繁建立/銷毀魚節點和特效節點，若使用 `instantiate()` 動態創建會造成 GC 壓力和幀率抖動 |
| **決策** | 所有遊戲物件使用預分配物件池（見 §8.2）|
| **理由** | 消除運行時 instantiate/destroy 的 GC 壓力；場景進入時一次性分配完成；符合 60 fps 的幀時間預算 |
| **後果** | 增加初始載入時間（約 300-500ms）；需要在 CannonSelectScene 過場期間完成預分配 |

### ADR-FE-003：樂觀更新 + 伺服器確認的射擊模式

| 欄位 | 內容 |
|------|------|
| **狀態** | ACCEPTED |
| **背景** | Server-Authoritative 設計要求命中判定在伺服器執行，但玩家需要即時視覺反饋（否則感覺「輸入延遲」）|
| **決策** | 射擊動畫和子彈飛行立即播放（樂觀更新），金幣獎勵等待伺服器 `fish_died` 事件後才更新 UI |
| **理由** | 在伺服器確認延遲（P99 < 100ms，EDD §1.1）期間，用戶感受不到延遲；金幣作為真實資產需要伺服器確認 |
| **後果** | 偶發情況下本地動畫與伺服器結果不一致（射擊動畫播放但未命中）——視為正常博弈體驗 |

### ADR-FE-004：Asset Bundle 四分區策略

| 欄位 | 內容 |
|------|------|
| **狀態** | ACCEPTED |
| **背景** | 全部資源打入單一 Bundle 會導致首次載入時間過長（> 10 秒），影響新手留存 |
| **決策** | 分為 core / game / shop / vip 四個 Bundle（見 §7.1）|
| **理由** | core bundle < 3 MB 確保快速首屏；game bundle 在配對等待期間預載；shop/vip 按需載入 |
| **後果** | Bundle 邊界需要謹慎設計（跨 Bundle 引用可能造成重複包含）；需要 CI 驗證 Bundle 大小 |

### ADR-FE-005：設計 Token 以 TypeScript 常數物件實作

| 欄位 | 內容 |
|------|------|
| **狀態** | ACCEPTED |
| **背景** | VDD 定義了完整的 CSS Custom Property Token，但 Cocos Creator 使用 Canvas/WebGL 渲染，不支援 CSS |
| **決策** | 將 VDD §6.1-6.3 所有 Token 對應到 TypeScript 常數物件（`ui.constants.ts`）|
| **理由** | 保持設計一致性；VDD Token 修改只需更新 `ui.constants.ts` 一個文件；TypeScript const 有型別安全 |
| **後果** | 需要人工同步 VDD CSS Token 與 TS 常數（建議建立 Token 同步腳本）|

---

## Appendix A: API Response 型別定義

```typescript
// assets/scripts/data/types/api.types.ts
// 對應 API.md 全部 Endpoint Response Schema

// ── 通用 Wrapper ──
interface ApiResponse<T> {
  data: T;
  meta: {
    request_id: string;
    total?: number;    // 分頁用
    cursor?: string;   // Cursor-based 分頁
  };
}

interface ApiError {
  error: {
    code: string;
    message: string;
    errors?: Array<{ field: string; message: string }>; // VALIDATION_ERROR 詳情
  };
  meta: { request_id: string };
}

// ── Auth ──
interface AuthResponseData {
  access_token: string;
  refresh_token: string;
  expires_in: number;
  token_type: 'Bearer';
  user: {
    id: string;             // 'usr_01HX...' 格式
    email: string;          // 遮罩格式：'p***@example.com'
    role: 'player' | 'operator' | 'superadmin';
    vip_tier: number;       // 0-10
  };
}
type AuthResponse = ApiResponse<AuthResponseData>;

interface RegisterResponseData {
  user_id: string;
  email: string;
  display_name: string;
  age_verified: boolean;
  created_at: string;  // ISO 8601 UTC
}
type RegisterResponse = ApiResponse<RegisterResponseData>;

interface RefreshTokenResponseData {
  access_token: string;
  expires_in: number;
}
type RefreshTokenResponse = ApiResponse<RefreshTokenResponseData>;

// ── Player Profile ──
interface PlayerProfileData {
  id: string;
  email: string;
  display_name: string;
  avatar_url: string | null;
  role: 'player' | 'operator' | 'superadmin';
  vip_tier: number;
  vip_expires_at: string | null;
  age_verified: boolean;
  created_at: string;
}
type PlayerProfileResponse = ApiResponse<PlayerProfileData>;

interface BalanceData {
  user_id: string;
  gold_balance: number;
  diamond_balance: number;
  updated_at: string;
}
type BalanceResponse = ApiResponse<BalanceData>;

// ── Room ──
interface RoomInfo {
  room_id: string;
  room_type: 'normal' | 'vip' | 'high_roller';
  current_players: number;
  max_players: number;   // 4-6
  status: 'waiting' | 'playing' | 'full';
  jackpot_pool: number;
  min_bet: number;
  created_at: string;
}
type RoomListResponse = ApiResponse<RoomInfo[]>;

// ── Shop / Commerce ──
interface Product {
  product_id: string;     // 'diamonds_330' 等
  name: string;
  description: string;
  diamonds: number;
  price_usd: number;
  price_display: string;  // 本地貨幣顯示：'NT$ 99'
  is_featured: boolean;
  bonus_diamonds?: number; // 首充/促銷加贈
}
type ProductListResponse = ApiResponse<Product[]>;

interface OrderData {
  order_id: string;         // UUID v4，冪等 ID
  user_id: string;
  product_id: string;
  status: 'pending' | 'completed' | 'failed' | 'refunded';
  amount_usd: number;
  diamonds_granted: number;
  created_at: string;
  completed_at?: string;
}
type OrderResponse = ApiResponse<OrderData>;

interface TransactionResult {
  success: boolean;
  order_id: string;
  diamonds_granted: number;
  new_diamond_balance: number;
  transaction_at: string;
}
type TransactionResponse = ApiResponse<TransactionResult>;

// ── VIP ──
interface VIPSubscriptionData {
  subscription_id: string;
  user_id: string;
  vip_tier: number;
  status: 'active' | 'expired' | 'cancelled';
  activated_at: string;
  expires_at: string;
  daily_diamond_bonus: number;
  features: string[];
}
type VIPSubscriptionResponse = ApiResponse<VIPSubscriptionData>;

// ── Colyseus Room Messages ──
interface FishDiedMessage {
  fishId: string;
  winnerId: string;
  winnerNickname: string;
  fishType: number;
  multiplier: number;
  coinsAwarded: number;
  isJackpot: boolean;
}

interface JackpotTriggerMessage {
  winnerId: string;
  winnerNickname: string;
  jackpotAmount: number;
  newJackpotPool: number;  // 重置後的初始值
  triggeredAt: string;
}

interface MVPUpdateMessage {
  mvpPlayerId: string;
  score: number;
}

interface BossSpawnMessage {
  fishId: string;
  bossType: number;
  hp: number;
  maxHp: number;
  x: number;
  y: number;
}

interface SkillFreezeMessage {
  casterId: string;
  durationMs: number;
}

interface SkillBombMessage {
  casterId: string;
  affectedFishIds: string[];
}

interface GameEndMessage {
  sessionId: string;
  results: Array<{
    userId: string;
    nickname: string;
    score: number;
    coinsEarned: number;
    rank: number;
    isMvp: boolean;
  }>;
  endedAt: string;
}

// ── Register Payload ──
interface RegisterPayload {
  email: string;
  password: string;
  display_name: string;
  birthdate: string;   // 'YYYY-MM-DD'
  agree_terms: true;
}

// ── Create Order Payload ──
interface CreateOrderPayload {
  product_id: string;
  order_id: string;    // Client-generated UUID v4（冪等）
  platform: 'ios' | 'android' | 'web';
}

// ── Weapon / Skill Enums（共享自 game.types.ts）──
export enum WeaponType {
  NORMAL   = 0,
  LASER    = 1,
  SCATTER  = 2,
  LOCK_ON  = 3,
}

export enum SkillType {
  FREEZE    = 0,
  BOMB      = 1,
  AUTO_LOCK = 2,
}

export enum FishType {
  NORMAL = 0,
  ELITE  = 1,
  BOSS   = 2,
}

export enum ShootRejectReason {
  INSUFFICIENT_FUNDS = 'INSUFFICIENT_FUNDS',
  WEAPON_ON_COOLDOWN = 'WEAPON_ON_COOLDOWN',
  ROOM_ENDED         = 'ROOM_ENDED',
  NOT_AUTHORIZED     = 'NOT_AUTHORIZED',
}
```

---

## Appendix B: Colyseus Schema 型別

```typescript
// assets/scripts/data/schemas/GameRoomSchema.ts
// 客戶端 Colyseus Schema 鏡像（對應 EDD §3 GameRoomSchema）
// 必須與伺服器端 Schema 定義完全一致

import {
  Schema,
  MapSchema,
  ArraySchema,
  type,
} from '@colyseus/schema';

export class PlayerState extends Schema {
  @type('string')  id: string = '';
  @type('string')  nickname: string = '';
  @type('uint32')  level: number = 1;
  @type('int64')   coins: number = 0;         // 累積金幣（本局）
  @type('int64')   diamonds: number = 0;
  @type('uint8')   weaponLevel: number = 1;
  @type('uint8')   weaponType: number = 0;    // WeaponType enum
  @type('uint8')   vipTier: number = 0;       // 0-10
  @type('int32')   score: number = 0;         // 本局排名分數
  @type('boolean') isConnected: boolean = true;
  @type('boolean') isBot: boolean = false;    // Bot 補位標記
  @type('string')  avatarUrl: string = '';
}

export class FishState extends Schema {
  @type('string')  id: string = '';
  @type('uint8')   fishType: number = 0;      // FishType enum
  @type('float32') x: number = 0;
  @type('float32') y: number = 0;
  @type('float32') rotation: number = 0;
  @type('uint32')  hp: number = 1;
  @type('uint32')  maxHp: number = 1;
  @type('uint8')   status: number = 0;        // 0=active, 1=dying, 2=dead
  @type('float32') speed: number = 100;       // px/s
  @type('uint16')  multiplier: number = 1;    // 基礎倍率（1-1000）
  @type('boolean') isFrozen: boolean = false; // 冰凍技能狀態
}

export class BulletState extends Schema {
  @type('string')  id: string = '';
  @type('string')  ownerId: string = '';
  @type('float32') x: number = 0;
  @type('float32') y: number = 0;
  @type('float32') velocityX: number = 0;
  @type('float32') velocityY: number = 0;
  @type('uint8')   weaponType: number = 0;    // WeaponType enum
}

export class GameRoomState extends Schema {
  @type({ map: PlayerState })
  players = new MapSchema<PlayerState>();

  @type({ array: FishState })
  fishes = new ArraySchema<FishState>();

  @type({ array: BulletState })
  bullets = new ArraySchema<BulletState>();

  // 房間狀態
  @type('string')  roomStatus: string = 'waiting';  // 'waiting'|'playing'|'ending'
  @type('string')  roomType: string = 'normal';      // 'normal'|'vip'|'high_roller'

  // Jackpot
  @type('int64')   jackpotPool: number = 1000;
  @type('boolean') jackpotActive: boolean = true;

  // 計時
  @type('uint32')  timeRemaining: number = 180;     // 秒數（預設 3 分鐘一局）
  @type('uint32')  roundNumber: number = 1;

  // 排名
  @type('string')  currentMvpId: string = '';

  // Boss 狀態
  @type('boolean') bossActive: boolean = false;
  @type('string')  activeBossId: string = '';
}

// ── 型別輔助 ──

// 從 MapSchema 轉為普通陣列（排序/遍歷用）
export function playersToArray(players: MapSchema<PlayerState>): PlayerState[] {
  const arr: PlayerState[] = [];
  players.forEach(p => arr.push(p));
  return arr;
}

// 取得排名陣列（依分數降序）
export function getRanking(players: MapSchema<PlayerState>): PlayerState[] {
  return playersToArray(players).sort((a, b) => b.score - a.score);
}

// 取得活躍魚群（排除已死亡）
export function getActiveFishes(fishes: ArraySchema<FishState>): FishState[] {
  return fishes.filter(f => f.status === 0);
}

// Boss 魚篩選
export function getBossFishes(fishes: ArraySchema<FishState>): FishState[] {
  return fishes.filter(f => f.fishType === FishType.BOSS && f.status === 0);
}
```

---

*文件結束 — FRONTEND-FISHGAME-20260425 v1.0*
