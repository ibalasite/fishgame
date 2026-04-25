# ANIM — 動畫特效設計文件 (fishing-arcade-game)

<!-- 上游文件：PRD.md · EDD.md · PDD.md · VDD.md · FRONTEND.md -->

---

## Document Control

| 欄位 | 內容 |
|------|------|
| **DOC-ID** | ANIM-FISHGAME-20260425 |
| **專案名稱** | fishing-arcade-game（捕魚街機遊戲平台）|
| **文件版本** | 1.0 |
| **狀態** | APPROVED |
| **作者** | Animation Design Specialist |
| **日期** | 2026-04-25 |
| **上游 VDD** | [VDD.md](VDD.md)（VDD-FISHGAME-20260425）§6.5 Motion Tokens · §8 Screen Visual Specs |
| **上游 FRONTEND** | [FRONTEND.md](FRONTEND.md)（FRONTEND-FISHGAME-20260425）§6.4 動畫系統 |
| **上游 PDD** | [PDD.md](PDD.md)（PDD-FISHGAME-20260425）|
| **上游 PRD** | [PRD.md](PRD.md)（PRD-FISHGAME-20260424）|
| **審閱者** | Art Director, Engineering Lead, Game Designer Lead |
| **核准者** | Art Director / CTO |

---

## Change Log

| 版本 | 日期 | 作者 | 變更摘要 |
|------|------|------|---------|
| 1.0 | 2026-04-25 | Animation Design Specialist | 初版，涵蓋全部 11 章 |

---

## 目錄

1. 動畫設計概述
2. 動畫系統架構
3. 魚群動畫
4. 武器與子彈動畫
5. 技能特效
6. UI 動畫
7. Jackpot 特效系統
8. 環境動畫
9. 效能最佳化
10. 動畫命名規範
11. 驗收標準

---

## 1. 動畫設計概述

### 1.1 設計理念

FishGame 的動畫設計核心哲學源自 VDD §1.1「讓每一發炮彈落點、每一條魚爆金幣的瞬間，都成為可以截圖分享的多巴胺時刻」。整體動畫語言遵循 **Dark Luxury × Casino Arcade** 視覺方向，以「深海奢華黑金美學 + 霓虹活力特效」為基調。

**五大動畫設計原則（對應 VDD §1.2 設計原則）：**

| # | 原則 | 動畫語言 | 量測指標 |
|---|------|---------|---------|
| A1 | **多巴胺優先** | 每次擊殺必有金幣粒子爆炸 + 倍率爆字 + 光暈三層疊加；Jackpot 觸發全場暫停所有其他特效讓位 | 玩家爽感評分 ≥ 4.2/5 |
| A2 | **競爭感可見** | Boss HP 條 Tween 更新 300ms；MVP 稱號閃爍進場；即時排名數字跳動 | 5 秒可用性測試通過率 ≥ 85% |
| A3 | **速度分層** | 射擊反饋 ≤ 80ms（duration-fast）；UI 進退場 200ms（duration-normal）；特效高潮 500ms（duration-slow） | 玩家感知「即時」率 ≥ 90% |
| A4 | **物理真實感** | 金幣粒子受重力影響（gravityMultiplier 0.3）；子彈有弧線；彈簧緩動彈回 | — |
| A5 | **特效預算守門** | 任何時刻不得超過 500 active particles；常規遊玩上限 300 | Profiler 粒子計數 |

**視覺情感映射（來自 VDD §2.4）：**

| 情感目標 | 動效語言 | VDD Token 依據 |
|---------|---------|---------------|
| 多巴胺刺激感 | 擊殺數字 scale 0→1.2→1.0 彈入 80ms expo-out；金幣粒子初速 600–1200 px/s | `duration-fast`, `easing-expo-out` |
| 奢華地位感 | VIP 光暈 6s 緩慢旋轉；面板進場 500ms ease-out | `duration-slow`, `easing-ease-out` |
| 競技緊張感 | Boss 進場全屏震動 2s；計時器後 10 秒紅色脈衝；COMBO 字符 600ms 衝屏 | `duration-xslow`, 自訂脈衝 |

### 1.2 動畫技術棧

| 技術 | 版本 / 規格 | 適用場景 | 優先級 |
|------|-----------|---------|--------|
| **Cocos Creator Tween API** | cc.tween（Cocos 3.8 內建）| UI 進退場、數字動畫、Boss HP 條、金幣飛行 | Primary |
| **cc.Animation（幀動畫）** | Cocos Animation Component | 普通魚 / 精英魚 Sprite Sheet 循環動畫 | Primary |
| **cc.Spine（骨骼動畫）** | Spine 3.8 Runtime | 精英魚（複雜鰭動）、全 Boss 魚 | Secondary |
| **cc.ParticleSystem2D** | Cocos 2D 粒子系統 | 命中特效、金幣爆炸、Jackpot 粒子、環境氣泡 | Primary |
| **Custom Shader（GLSL）** | Cocos Effect 自訂材質 | 冰凍效果、Boss Outline、水面折射、VIP 光暈 | Advanced |
| **Camera Shake** | cc.Camera + Tween | Boss 進場震動、Jackpot 觸發 | Supplementary |

**技術選型決策：**

- **幀動畫 vs Spine**：普通魚（FishType.NORMAL）使用 cc.Animation 幀動畫（8–16 幀），內存佔用低，適合同時最多 60 條活躍魚的場景。精英魚 (FishType.ELITE) 和 Boss 魚 (FishType.BOSS) 使用 Spine，支援流暢的骨骼插值與動態換皮膚。
- **Tween vs Animator**：UI 過渡（面板滑入、數字跳動）全部使用 Tween API，避免預製體中掛載大量 AnimationClip，減少包體。
- **粒子系統限制**：ParticleSystem2D 採用物件池管理，`.plist` 格式配置，Jackpot 序列暫時暫停其他粒子系統以保障效能。

### 1.3 效能預算

**目標設備：Snapdragon 665（Android 中端）/ Apple A13 Bionic（iOS 中端）**

| 指標 | 目標值 | 警戒值 | 測試方法 |
|------|-------|--------|---------|
| 遊戲場景幀率 | **60 fps 持續** | < 45 fps 觸發降級 | Cocos Profiler |
| 低端機最低幀率 | **≥ 45 fps** (Snapdragon 665) | < 30 fps 不可接受 | 實機測試 |
| 最大活躍粒子數 | **500 / 幀** (Jackpot 瞬間) | 超過 500 觸發池限流 | Profiler 粒子計數 |
| 常規最大粒子數 | **300 / 幀** | 超過 300 降低非關鍵特效 | Profiler 粒子計數 |
| 粒子池預分配 | **600 粒子節點** | — | 啟動時預分配 |
| 最大並行 Spine 動畫 | **8 個** | 超過 8 停用最低優先 Spine | Profiler |
| 最大並行幀動畫 | **20 個** | 超過 20 停用畫面外動畫 | Profiler |
| 動畫資源記憶體佔用 | **< 30 MB** | 超過 30 MB 觸發強制 GC | Memory Profiler |
| Jackpot 音效同步誤差 | **≤ 33ms** | > 33ms 需修正時序 | 對照測試 |

**效能降級策略：**

```
Level 0（≥ 60 fps）：全特效開啟
Level 1（45–59 fps）：關閉背景氣泡粒子、降低普通命中粒子數量 50%
Level 2（30–44 fps）：關閉精英魚輪廓光 Shader、停用 VIP 光暈 Shader
Level 3（< 30 fps）：降為幀動畫模式（Spine 改為幀動畫），所有粒子數量減半
```

---

## 2. 動畫系統架構

### 2.1 Cocos Creator Tween 系統

**Tween 系統統一入口：`AnimationUtils`（FRONTEND.md §6.4）**

所有 Tween 呼叫必須透過 `AnimationUtils` 封裝，確保 Motion Token 一致性（對應 VDD §6.5）：

```typescript
// assets/scripts/utils/AnimationUtils.ts
import { tween, Node, Vec3, Label } from 'cc';
import { DURATION_MS } from '../data/constants/ui.constants';

export class AnimationUtils {
  // 面板進場：scale 0.8→1.0，200ms expo-out（VDD duration-normal）
  static showPanel(node: Node, durationMs = DURATION_MS.NORMAL): Promise<void> {
    return new Promise(resolve => {
      node.active = true;
      node.setScale(0.8, 0.8, 1);
      node.setScale(new Vec3(0.8, 0.8, 1));
      tween(node)
        .to(durationMs / 1000, { scale: new Vec3(1, 1, 1) }, { easing: 'expoOut' })
        .call(resolve)
        .start();
    });
  }

  // 面板退場：scale 1.0→0.8，150ms expo-in
  static hidePanel(node: Node, durationMs = 150): Promise<void> {
    return new Promise(resolve => {
      tween(node)
        .to(durationMs / 1000, { scale: new Vec3(0.8, 0.8, 1) }, { easing: 'expoIn' })
        .call(() => { node.active = false; resolve(); })
        .start();
    });
  }

  // 倍率爆字：scale 0→1.2→1.0，backOut（VDD easing-spring）
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

  // 金幣計數器動態遞增（ease-out-cubic，800ms）
  static animateCounter(label: Label, from: number, to: number, durationMs = 800): void {
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

  // 按鈕按下彈回（scale 0.95→1.0，bounce，duration-fast）
  static buttonPressRebound(node: Node): Promise<void> {
    return new Promise(resolve => {
      tween(node)
        .to(DURATION_MS.FAST / 1000, { scale: new Vec3(0.95, 0.95, 1) }, { easing: 'sineIn' })
        .to(DURATION_MS.FAST / 1000, { scale: new Vec3(1, 1, 1) }, { easing: 'bounceOut' })
        .call(resolve)
        .start();
    });
  }

  // 相機震動（Boss 進場）
  static cameraShake(camera: Node, intensity = 8, durationMs = 2000): Promise<void> {
    const originalPos = camera.position.clone();
    return new Promise(resolve => {
      let elapsed = 0;
      const shakeInterval = setInterval(() => {
        elapsed += 50;
        const decay = 1 - elapsed / durationMs;
        const offsetX = (Math.random() - 0.5) * 2 * intensity * decay;
        const offsetY = (Math.random() - 0.5) * 2 * intensity * decay;
        camera.setPosition(originalPos.x + offsetX, originalPos.y + offsetY, originalPos.z);
        if (elapsed >= durationMs) {
          clearInterval(shakeInterval);
          camera.setPosition(originalPos);
          resolve();
        }
      }, 50);
    });
  }
}
```

**Motion Token 對應表（VDD §6.5 → Cocos Tween）：**

| VDD Token | 值 | Cocos Tween 緩動 | 用途 |
|-----------|-----|-----------------|------|
| `duration-fast` | 80ms | `sineOut` / `backOut` | 按鈕 Hover/Active、命中閃光 |
| `duration-normal` | 200ms | `expoOut` | UI 面板淡入、Tween 過渡 |
| `duration-slow` | 500ms | `expoOut` | 模態進場、Boss HP Tween、Jackpot 面板滑入 |
| `duration-xslow` | 1000ms | `expoOut` | Boss 進場震動、倍率爆字 |
| `duration-jackpot` | 3000ms | 分段自訂 | Jackpot 完整序列 |
| `easing-expo-out` | cubic-bezier(0.16,1,0.3,1) | `expoOut` | 面板滑入、HP 條更新 |
| `easing-spring` | cubic-bezier(0.34,1.56,0.64,1) | `backOut` | 金幣飛出、倍率數字彈跳 |
| `easing-bounce` | cubic-bezier(0.68,-0.55,0.265,1.55) | `bounceOut` | 按鈕按下後彈回 |

### 2.2 ParticleSystem 2D 粒子系統

**粒子系統管理架構：**

```typescript
// assets/scripts/game/managers/EffectPoolManager.ts

// 粒子池配置
const PARTICLE_POOL_CONFIG = {
  hitNormal:       { size: 50,  plistPath: 'particles/effect_hit_normal.plist' },
  hitElite:        { size: 20,  plistPath: 'particles/effect_hit_elite.plist' },
  killExplosion:   { size: 30,  plistPath: 'particles/effect_kill_explosion.plist' },
  coinBurst:       { size: 100, plistPath: 'particles/effect_coin_burst.plist' },
  jackpotBurst:    { size: 5,   plistPath: 'particles/effect_jackpot_burst.plist' },
  freezeIce:       { size: 10,  plistPath: 'particles/effect_skill_freeze.plist' },
  bombExplosion:   { size: 5,   plistPath: 'particles/effect_skill_bomb.plist' },
  bubbleAmbient:   { size: 3,   plistPath: 'particles/effect_bubble_ambient.plist' },
  vipAura:         { size: 6,   plistPath: 'particles/effect_vip_aura.plist' },
} as const;
```

**粒子 .plist 設定準則：**

| 參數 | 普通命中 | 金幣爆炸 | Jackpot 爆炸 |
|------|---------|---------|-------------|
| `maxParticles` | 10 | 50 | 200 |
| `duration` | 0.2s | 0.8s | 2.0s |
| `emissionRate` | 50/s | 125/s | 200/s（burst） |
| `life` | 0.15–0.25s | 0.5–1.0s | 1.0–2.0s |
| `startSpeed` | 200–400 | 600–1200 | 800–1500 |
| `gravity.y` | -200 | -300 | -294 (0.3g) |
| `startColor` | #FFFFFF | #F5C842 | #F5C842→#FF8C00 |
| `blendMode` | NORMAL | ADD | ADD |

**粒子計數器（實時追蹤）：**

```typescript
class ParticleCounter {
  private static activeCount = 0;
  static readonly MAX_NORMAL = 300;
  static readonly MAX_JACKPOT = 500;

  static canSpawn(requested: number, isJackpot = false): boolean {
    const limit = isJackpot ? this.MAX_JACKPOT : this.MAX_NORMAL;
    return (this.activeCount + requested) <= limit;
  }

  static add(count: number): void { this.activeCount += count; }
  static remove(count: number): void { this.activeCount = Math.max(0, this.activeCount - count); }
  static get(): number { return this.activeCount; }
}
```

### 2.3 Spine 骨骼動畫（Elite/Boss 魚）

**Spine 資源規格：**

| 魚類 | Spine 版本 | Atlas 尺寸 | 骨骼數量 | 皮膚數量 |
|------|-----------|----------|---------|---------|
| 精英獅子魚 | 3.8 | 1024×1024 px | ≤ 40 | 2（普通/受擊紅色） |
| 精英鎚頭鯊 | 3.8 | 1024×1024 px | ≤ 40 | 2 |
| 精英電鰻 | 3.8 | 1024×1024 px | ≤ 45 | 2 |
| Boss 龍魚 | 3.8 | 2048×2048 px | ≤ 80 | 3（普通/受傷/憤怒） |
| Boss 海神鯊 | 3.8 | 2048×2048 px | ≤ 80 | 3 |
| Boss 深海女皇 | 3.8 | 2048×2048 px | ≤ 90 | 3 |

**Spine 元件使用規範：**

```typescript
import { sp } from 'cc';

// Spine 動畫播放封裝
export class SpineAnimationController {
  private spineComponent: sp.Skeleton;
  private currentAnimation = '';

  constructor(node: Node) {
    this.spineComponent = node.getComponent(sp.Skeleton)!;
  }

  // 播放動畫（自動處理過渡）
  play(animName: string, loop = false, mixDuration = 0.1): void {
    if (this.currentAnimation === animName) return;
    this.currentAnimation = animName;
    this.spineComponent.setAnimation(0, animName, loop);
    // 設定動畫混合時長（避免突兀切換）
    this.spineComponent.setMix(this.currentAnimation, animName, mixDuration);
  }

  // 播放一次性動畫，完成後回到目標動畫
  playOnce(animName: string, returnTo: string, onComplete?: () => void): void {
    this.spineComponent.setAnimation(0, animName, false);
    this.spineComponent.addAnimation(0, returnTo, true);
    if (onComplete) {
      this.spineComponent.setCompleteListener(() => {
        if (this.spineComponent.animation === animName) {
          onComplete();
        }
      });
    }
  }
}
```

### 2.4 Frame Animation（普通魚）

**cc.Animation 幀動畫管理：**

普通魚使用 Cocos Animation Component 播放 Sprite Sheet 幀動畫，每種魚對應一個 AnimationClip，儲存在 `assets/animations/fish/` 目錄。

```typescript
// FishComponent 中的幀動畫狀態機
export class FishFrameAnimator {
  private animator: Animation;
  private readonly clipNames = {
    swim:  'fish_swim',   // 常態游泳（loop）
    hit:   'fish_hit',    // 受擊閃爍（once）
    death: 'fish_death',  // 死亡爆炸（once）
  };

  setState(state: 'swim' | 'hit' | 'death'): void {
    const clip = this.clipNames[state];
    const isLoop = state === 'swim';
    this.animator.play(clip);
    this.animator.getState(clip).wrapMode = isLoop
      ? Animation.WrapMode.Loop
      : Animation.WrapMode.Normal;
  }

  onDeathComplete(callback: () => void): void {
    this.animator.on(Animation.EventType.FINISHED, callback, this, true);
    this.setState('death');
  }
}
```

---

## 3. 魚群動畫

### 3.1 普通魚動畫

普通魚（FishType.NORMAL）全部使用 Sprite Sheet 幀動畫，每幀固定間隔，達到資源佔用與視覺效果的最優平衡。

**幀動畫規格表：**

| 魚類 | FishType 常數 | 幀數 | FPS | 循環 | Sprite 尺寸 | Atlas 位置 |
|------|-------------|------|-----|------|------------|-----------|
| 小魚（小丑魚/藍刀/蝴蝶魚） | `FISH_SMALL` | 8 | 12 | Yes | 64×32 px | `atlas_fish_normal_01` |
| 中魚（神仙魚/鸚鵡魚） | `FISH_MEDIUM` | 12 | 12 | Yes | 96×48 px | `atlas_fish_normal_02` |
| 章魚 | `FISH_OCTOPUS` | 16 | 15 | Yes | 80×80 px | `atlas_fish_normal_03` |
| 海龜 | `FISH_TURTLE` | 10 | 10 | Yes | 96×64 px | `atlas_fish_normal_04` |
| 鯊魚 | `FISH_SHARK` | 14 | 12 | Yes | 128×64 px | `atlas_fish_normal_05` |

**普通魚動畫狀態機：**

```
[SPAWN] ──進場後立即→ [SWIM_LOOP]
[SWIM_LOOP] ──伺服器 status=1→ [DEATH]
[DEATH] ──動畫播完→ 回收入池
```

**游泳動畫技術要求：**
- 游泳循環動畫需確保首尾幀銜接流暢（第 1 幀與最後一幀的魚尾位置連續）
- 移動方向基於路徑切線方向旋轉節點（`node.angle = Math.atan2(dy, dx) * RAD_TO_DEG`）
- 同類魚群出現時，每條魚動畫相位偏移 `Math.random() * totalFrames`，避免同步感

**死亡特效（普通魚）：**

| 魚倍率 | 死亡動畫 | 粒子特效 | 持續時長 | 金幣數量 |
|--------|---------|---------|---------|---------|
| 1–2x | 魚體淡出 + 小金幣 ×1–2 | 10 粒子，`hitNormal` | 300ms | 1–2 枚 |
| 3–5x | 小爆炸 + 金幣飛散 | 15 粒子，`coinBurst` | 400ms | 3–5 枚 |

### 3.2 精英魚動畫

精英魚（FishType.ELITE）使用 Spine 骨骼動畫，支援流暢的鰭動、受擊閃爍、並通過換皮膚實現視覺狀態切換。

**精英魚 Spine 動畫狀態規格：**

| 動畫名稱 | 觸發條件 | 時長 | 過渡方式 | Loop |
|---------|---------|------|---------|------|
| `swim` | 常態移動 | 1.2s | 循環 | Yes |
| `hit` | 受到傷害（HP 變化） | 0.3s | 播完回 `swim` | No |
| `stunned` | 冰凍技能生效 | 持續 | 凍結在當前幀 | No（暫停） |
| `death` | HP = 0 | 0.5s | 播完移除節點 | No |

**精英魚視覺特徵：**
- 常態：2px Outline Shader，顏色對應主色（獅子魚 #E91E63，鎚頭鯊 #546E7A，電鰻 #FFEB3B）
- HP < 50%：Outline 顏色切換為 #FF4444，閃爍頻率 0.5Hz
- 受擊瞬間：`skin` 切換至「受擊紅色」皮膚，100ms 後恢復
- 電鰻特有：游動時附帶電弧粒子（`effect_eel_spark.plist`，5 粒子持續）

**HP 血條動畫（VDD §5.6 Boss HP Bar 規格延伸）：**

```typescript
// 精英魚 HP 條更新（Tween，對應 VDD --boss-hp-transition: 200ms expoOut）
updateEliteHPBar(node: Node, currentHP: number, maxHP: number): void {
  const ratio = currentHP / maxHP;
  const progressBar = node.getChildByName('HPBar')!.getComponent(ProgressBar)!;

  tween(progressBar)
    .to(DURATION_MS.NORMAL / 1000, { progress: ratio }, { easing: 'expoOut' })
    .start();

  // HP 顏色過渡
  const sprite = progressBar.getComponent(Sprite)!;
  sprite.color = ratio > 0.6 ? COLOR.HP_HIGH
               : ratio > 0.3 ? COLOR.HP_MID
               :               COLOR.HP_LOW;
}
```

### 3.3 Boss 動畫

Boss 魚（FishType.BOSS）使用完整的 Spine 骨骼動畫狀態機，是遊戲中最重要的視覺高潮點。

**Boss Spine 動畫狀態機規格：**

| 動畫名稱 | 觸發條件 | 時長 | 過渡方式 | Loop | 備註 |
|---------|---------|------|---------|------|------|
| `intro` | Boss 出現（boss_spawn 事件）| 2.5s | 接 `idle` | No | 全屏震動 2s 同步 |
| `idle` | 常態待機 | 3.0s | 循環 | Yes | 含輕微搖擺 |
| `swim` | 移動中 | 1.5s | 循環 | Yes | 含尾鰭推進 |
| `hit` | 受到傷害（Spine + Shader 泛紅）| 0.3s | 回 `swim` | No | Flash Shader 同步 |
| `roar` | HP 進入 < 50%（憤怒進場）| 2.0s | 回 `swim` | No | 配合吼叫 SFX |
| `attack` | Boss 特殊技能觸發 | 1.2s | 回 `swim` | No | 全場暗度降低 60% |
| `die` | HP = 0 | 3.0s | 播完移除 | No | 全屏金光 + 倍率爆字 |

**Boss 進場完整序列（`intro` 動畫，2.5s）：**

```
t=0ms    ：全屏震動開始（Camera Shake，intensity=8，duration=2000ms）
t=0ms    ：Boss 節點從畫面外滑入（Tween translateX/Y，500ms expoOut）
t=0ms    ：海浪裂開特效（粒子，wave_crack.plist，30 粒子）
t=200ms  ：Boss 主題 BGM 交叉淡入（300ms crossfade）
t=500ms  ：Boss 名稱框從頂部滑下（Tween translateY，300ms expoOut）
t=800ms  ：Boss HP 條淡入（opacity 0→1，200ms）
t=1000ms ：intro Spine 動畫高潮幀（龍魚張嘴/海神鯊翻騰）
t=2000ms ：相機震動結束
t=2500ms ：`intro` 動畫結束，自動切換至 `idle`
```

**Boss 受傷 Shader 效果（Hit Flash）：**

```glsl
// assets/effects/fish_hit_flash.effect（Custom GLSL）
// 受擊瞬間對 Sprite 進行紅色 Flash
CCEffect %{
  techniques:
  - passes:
    - vert: sprite-vs:vert
      frag: sprite-fs:frag
      blendState:
        targets:
          - blend: true
      properties:
        mainTexture: { value: white }
        flashColor: { value: [1, 0.2, 0.2, 1], editor: { type: color } }
        flashIntensity: { value: 0.0, range: [0, 1] }
}%
CCProgram sprite-fs %{
  precision highp float;
  in vec2 v_uv0;
  uniform sampler2D mainTexture;
  uniform ARGS { vec4 flashColor; float flashIntensity; };
  void main () {
    vec4 color = texture(mainTexture, v_uv0);
    gl_FragColor = mix(color, vec4(flashColor.rgb, color.a), flashIntensity * color.a);
  }
}%
```

**Boss 死亡完整序列（`die` 動畫，3.0s，Jackpot 規格）：**

```
t=0ms    ：`die` Spine 動畫開始
t=0ms    ：全屏暗化 overlay（opacity 0→0.7，300ms）
t=100ms  ：第一波金光粒子爆發（50 粒子，coinBurst）
t=300ms  ：全屏白色 Flash（3 幀，每幀 50ms）
t=400ms  ：倍率數字衝屏（text-multiplier 56px，scale 0.5→3.0，1000ms expoOut）
t=500ms  ：第二波大型粒子（100 粒子，jackpotBurst）
t=800ms  ：金幣飛向各玩家 HUD（playCoinsToHUD，see §6.4）
t=1000ms ：倍率數字開始 fade-out（1000ms linear）
t=2000ms ：Spine die 動畫播完，節點淡出（opacity 1→0，500ms）
t=2500ms ：全屏暗化 overlay 退出（opacity 0.7→0，300ms）
t=3000ms ：Boss 節點回收入池，spawn 下一批普通魚
```

### 3.4 魚群移動路徑系統

**路徑系統設計原則：**

魚群路徑由伺服器端定義並廣播（Server-Authoritative），客戶端根據路徑資料做本地位置插值（Tween）。

**路徑類型：**

| 路徑類型 | 描述 | 適用魚類 | 緩動函數 |
|---------|------|---------|---------|
| `LINEAR` | 直線穿越畫面 | 小魚群 | `linear` |
| `SINE_WAVE` | 正弦波浪游動 | 中魚、章魚 | 自訂 sine 插值 |
| `SPIRAL` | 螺旋進入 | 鯊魚、海龜 | `easeInOut` |
| `BOSS_ENTRY` | Boss 進場路徑（由固定點進入中央）| Boss | `expoOut` |
| `RANDOM_PATROL` | 隨機巡邏（Elite 魚）| 精英魚 | `sineInOut` |

**路徑插值實作：**

```typescript
// 魚群路徑 Tween（依伺服器廣播路徑點）
function moveFishAlongPath(
  fishNode: Node,
  pathPoints: Vec3[],
  totalDurationSec: number,
  onComplete: () => void
): void {
  if (pathPoints.length < 2) return;

  const segmentDuration = totalDurationSec / (pathPoints.length - 1);
  let t = tween(fishNode).to(0, { position: pathPoints[0] });

  for (let i = 1; i < pathPoints.length; i++) {
    const target = pathPoints[i];
    const prev   = pathPoints[i - 1];
    // 更新朝向
    const angle = Math.atan2(target.y - prev.y, target.x - prev.x) * (180 / Math.PI);
    t = t.to(segmentDuration, { position: target }, { easing: 'sineInOut' })
         .call(() => { fishNode.angle = angle; });
  }

  t.call(onComplete).start();
}
```

**魚群出現區域（VDD §8.5 GameScene 佈局）：**

- 有效遊戲區域：扣除 HUD 邊距後 680×1080 px
- 魚群生成邊界：從畫面四邊外 50px 處生成，防止突然閃現
- Boss 進場：固定從畫面右側或頂部中央進入

---

## 4. 武器與子彈動畫

### 4.1 砲台動畫

砲台動畫使用 cc.Animation 幀動畫，搭配 Tween 做後坐力位移，參考 VDD §4.1 動畫狀態機。

**砲台動畫狀態機規格（對應 VDD §4.1 Captain Triton 炮台）：**

| 狀態 | 觸發條件 | 幀數 | 時長 | 特效 | 備註 |
|------|---------|------|------|------|------|
| `idle` | 無操作 ≥ 2s | 8 幀 loop | 800ms/loop | 炮管微晃（±2px Y）| 等待玩家操作 |
| `aim` | 玩家按住畫面 | 4 幀 | 100ms | 準心出現，金色光環 | 砲管旋轉跟隨觸控 |
| `fire` | 觸發射擊 | 6 幀 | 120ms | 炮口橘焰噴射，後坐力上揚 | 見下方後坐力 Tween |
| `hit_normal` | 普通魚命中（伺服器確認）| 4 幀 | 80ms | 小金幣 ×3 飛出 | `duration-fast` |
| `kill_elite` | 精英魚死亡 | 8 幀 | 200ms | 大量金幣噴射 + 白色擊殺閃 | `duration-normal` |
| `kill_boss` | Boss 死亡 | 16 幀 | 500ms | 全屏金光 + 倍率數字爆字 | `duration-slow` |

**炮台後坐力 Tween：**

```typescript
// 發射後坐力動畫（上揚 4px → 回位，120ms）
function playCannonRecoil(cannonNode: Node): void {
  const origin = cannonNode.position.clone();
  tween(cannonNode)
    .to(0.04,  { position: new Vec3(origin.x, origin.y + 4, origin.z) },
        { easing: 'sineOut' })
    .to(0.08, { position: origin }, { easing: 'bounceOut' })
    .start();
}
```

**炮口橘焰粒子（發射瞬間，duration-fast = 80ms）：**

- 粒子數：5–8
- 顏色：#FF6D00→#FFEB3B（橘到黃）
- 生命週期：0.06–0.1s
- 初速：300–600 px/s（沿炮管方向）
- `blendMode`: ADD

**砲台朝向系統：**

```typescript
// 砲台跟隨觸控旋轉（每幀更新）
function updateCannonAim(cannonNode: Node, touchWorldPos: Vec3): void {
  const cannonPos = cannonNode.worldPosition;
  const dx = touchWorldPos.x - cannonPos.x;
  const dy = touchWorldPos.y - cannonPos.y;
  const targetAngle = Math.atan2(dy, dx) * (180 / Math.PI);

  // 平滑旋轉（Lerp，30° 每幀最大旋轉）
  const currentAngle = cannonNode.angle;
  const delta = targetAngle - currentAngle;
  const clampedDelta = Math.max(-30, Math.min(30, delta));
  cannonNode.angle += clampedDelta;
}
```

### 4.2 子彈軌跡動畫

**子彈類型與視覺規格：**

| 武器類型 | 子彈視覺 | 軌跡效果 | 速度（px/s） | 尺寸 |
|---------|---------|---------|------------|------|
| 基礎砲台（NORMAL） | 金色圓球，帶金光殘影 | 4 幀拖尾 | 800 | 16×16 px |
| 雷射炮（LASER） | 霓虹青光束 | 連續線段 Shader | 1500 | 480×4 px（光束） |
| 散射炮（SCATTER） | 橘色小彈片 ×5 | 扇形散射路徑 | 600 | 10×10 px × 5 |
| 鎖定炮（LOCK_ON） | 紫色追蹤彈 | 弧線貝茲曲線 | 1000 | 20×20 px |

**子彈飛行 Tween：**

```typescript
// 普通子彈飛行（直線，Tween position）
function animateBulletFlight(
  bulletNode: Node,
  from: Vec3,
  to: Vec3,
  speedPxPerSec: number,
  onHit: () => void
): void {
  const distance = Vec3.distance(from, to);
  const duration = distance / speedPxPerSec;

  bulletNode.setWorldPosition(from);
  tween(bulletNode)
    .to(duration, { worldPosition: to }, { easing: 'linear' })
    .call(() => {
      onHit();
      // 回收子彈節點入池
      BulletPoolManager.getInstance().release(bulletNode);
    })
    .start();
}

// 鎖定炮弧線飛行（貝茲曲線插值）
function animateLockOnBullet(
  bulletNode: Node,
  from: Vec3,
  target: Node,
  speedPxPerSec: number
): void {
  let elapsed = 0;
  const totalDist = Vec3.distance(from, target.worldPosition);
  const totalTime = totalDist / speedPxPerSec;
  const controlOffset = new Vec3(0, 100, 0); // 控制點偏移

  const updateFn = (dt: number) => {
    elapsed += dt;
    const t = Math.min(elapsed / totalTime, 1);
    const currentTarget = target.worldPosition;
    // 二次貝茲曲線
    const cp = Vec3.add(new Vec3(), Vec3.lerp(new Vec3(), from, currentTarget, 0.5), controlOffset);
    const pos = quadraticBezier(from, cp, currentTarget, t);
    bulletNode.setWorldPosition(pos);
    if (t >= 1) {
      bulletNode.getComponent(BulletComponent)!.onHitTarget(target);
    }
  };
  // 透過 Cocos scheduler 每幀更新
}
```

**雷射炮光束 Shader：**

```
- 使用 Line Renderer 風格（長條 Sprite）
- UV 滾動效果（UV scroll speed: 2.0）
- 顏色：#00D4FF（neon-blue）中心 → 透明邊緣
- 寬度：4px 中心光束 + 8px 外暈（ADD blendMode）
- 射擊結束後 100ms fade-out
```

### 4.3 命中特效

**命中特效總覽表：**

| 效果 | 技術 | 粒子數 | 時長 | 觸發條件 | 優先級 |
|------|------|-------|------|---------|--------|
| 普通命中閃光 | ParticleSystem2D | 10 | 0.2s | 任何命中 | P0 |
| 精英魚受傷 | ParticleSystem2D + Tween | 20 | 0.4s | 命中精英魚 | P0 |
| 魚死亡爆炸 | ParticleSystem2D + 碎片幀 | 50 | 0.8s | 任何魚死亡 | P0 |
| Boss 受傷 | Spine `hit` + Shader Flash | N/A | 0.3s | 命中 Boss | P0 |
| 冰凍命中 | Shader 冰晶 + Particles | 30 | 1.0s | 冰凍技能有效時 | P0 |
| 炸彈爆炸 | ParticleSystem2D（大型） | 200 | 1.5s | 炸彈技能觸發 | P0 |
| 鎖定炮命中 | 紫色爆炸粒子 | 25 | 0.5s | 鎖定炮命中 | P1 |
| 雷射切割 | 光束殘留 + 魚體切割幀 | 15 | 0.3s | 雷射炮命中 | P1 |

**命中特效執行流程（伺服器確認後）：**

```typescript
// 統一命中特效分發器
class HitEffectDispatcher {
  dispatch(data: {
    fishType: FishType;
    fishPos: Vec3;
    weaponType: WeaponType;
    isDead: boolean;
    isJackpot: boolean;
  }): void {
    const { fishType, fishPos, weaponType, isDead } = data;

    // 1. 命中閃光（所有命中均有）
    this.spawnHitFlash(fishPos, weaponType);

    // 2. 傷害數字（精英/Boss 才顯示）
    if (fishType >= FishType.ELITE) {
      this.spawnDamageNumber(fishPos);
    }

    // 3. 死亡特效
    if (isDead) {
      switch (fishType) {
        case FishType.NORMAL:
          this.spawnNormalDeathExplosion(fishPos);
          break;
        case FishType.ELITE:
          this.spawnEliteDeathExplosion(fishPos);
          break;
        case FishType.BOSS:
          // Boss 死亡由 playJackpotSequence 統一處理
          break;
      }
    }
  }
}
```

---

## 5. 技能特效

### 5.1 冰凍技能

**觸發條件：** 玩家使用 `SkillType.FREEZE`，伺服器廣播 `skill_freeze` 事件（cooldown 30s，duration 3s）

**視覺效果序列：**

```
t=0ms    ：冰霜 Shader 材質覆蓋全部魚類 Sprite（flashIntensity=0→1，200ms）
t=0ms    ：冰晶粒子從畫面中央向四方擴散（effect_skill_freeze.plist，30 粒子）
t=0ms    ：所有魚動畫暫停（Spine 暫停在當前幀；幀動畫 Animation.speed = 0）
t=0ms    ：全畫面藍色 Tint 疊加（rgba(0,212,255,0.15)，200ms 淡入）
t=200ms  ：冰晶粒子持續（loop，每秒 5 粒子維持冰凍感）
t=3000ms ：解凍！藍色 Tint 退出（200ms 淡出）
t=3000ms ：冰霜 Shader 材質退出（flashIntensity 1→0，300ms）
t=3000ms ：所有魚動畫恢復（Animation.speed = 1；Spine 繼續播放）
t=3000ms ：解凍粒子爆發（15 粒子，冰碎裂效果）
```

**冰凍 Shader（fish_freeze.effect）：**

```glsl
// 冰凍效果：藍色色調 + 白色結晶覆蓋
uniform sampler2D mainTexture;
uniform sampler2D iceTexture;   // 冰晶紋理（resources/textures/ice_overlay.png）
uniform float freezeIntensity;  // 0.0 - 1.0
uniform float icePattern;       // UV 偏移（時間驅動，產生閃爍感）

void main () {
  vec4 baseColor  = texture(mainTexture, v_uv0);
  vec4 iceColor   = texture(iceTexture, v_uv0 * 2.0 + icePattern);
  vec4 frozen     = mix(baseColor, vec4(0.7, 0.9, 1.0, baseColor.a), 0.6);
  gl_FragColor    = mix(baseColor, frozen + iceColor * 0.3, freezeIntensity * baseColor.a);
}
```

### 5.2 炸彈技能

**觸發條件：** 玩家使用 `SkillType.BOMB`（消耗 5 鑽石），伺服器廣播 `skill_bomb` 事件（cooldown 60s）

**全屏炸彈特效序列（1.5s）：**

```
t=0ms    ：全屏白色閃光（3 幀，每幀 50ms）
t=150ms  ：炸彈圓形衝擊波從玩家砲台位置擴散（環形 Shader，半徑 0→720px，400ms）
t=150ms  ：大型爆炸粒子中心爆發（200 粒子，effect_skill_bomb.plist，暫停其他特效）
t=200ms  ：所有魚 HP 急速下降動畫（HP 條 Tween，150ms expoOut）
t=300ms  ：碎片幀動畫（30 個小爆炸點，覆蓋畫面）
t=500ms  ：金幣粒子連環爆發（多魚死亡，coinBurst ×N，上限 300 粒子）
t=800ms  ：衝擊波動畫結束
t=1200ms ：爆炸粒子淡出
t=1500ms ：恢復正常特效預算（重新啟用 bubbleAmbient 等低優先粒子）
```

**衝擊波 Shader：**

```glsl
// 環形衝擊波 Shader（全屏 Post-Process 效果）
uniform float waveRadius;      // 0.0 - 1.0（標準化半徑）
uniform float waveWidth;       // 衝擊波寬度（0.05 推薦）
uniform vec2  waveCenter;      // 螢幕中心（0.5, 0.5）
uniform float waveIntensity;   // 扭曲強度

void main () {
  vec2 uv = v_uv0;
  float dist = distance(uv, waveCenter);
  float waveMask = smoothstep(waveRadius - waveWidth, waveRadius, dist)
                 * smoothstep(waveRadius + waveWidth, waveRadius, dist);
  vec2 distortedUV = uv + normalize(uv - waveCenter) * waveMask * waveIntensity;
  gl_FragColor = texture(mainTexture, distortedUV);
}
```

### 5.3 鎖定技能

**觸發條件：** 玩家使用 `SkillType.AUTO_LOCK`，伺服器廣播 `skill_auto_lock` 事件（cooldown 45s，duration 10s）

**鎖定目標框動畫：**

```typescript
// 鎖定框進場動畫（對準目標魚）
function showLockOnReticle(targetFishNode: Node): void {
  const reticle = effectPoolManager.acquireLockOnReticle();
  reticle.setWorldPosition(targetFishNode.worldPosition);

  // 鎖定框從 scale 2.0 縮小到 1.0（snap 感）
  tween(reticle)
    .set({ scale: new Vec3(2, 2, 1), opacity: 0 })
    .to(0.15, { scale: new Vec3(1, 1, 1), opacity: 255 }, { easing: 'expoOut' })
    .start();

  // 鎖定框持續旋轉（10s 周期）
  tween(reticle)
    .by(10, { angle: 360 }, { easing: 'linear' })
    .repeatForever()
    .start();

  // 跟隨目標魚移動（每幀更新）
  reticle.getComponent(LockOnReticle)!.followTarget(targetFishNode);
}
```

**技能冷卻 HUD 動畫（VDD §5.6 武器冷卻圓圈）：**

```typescript
// 技能冷卻圓弧動畫（48×48 px 圓圈進度條）
function updateSkillCooldown(cooldownBar: Node, progress: number): void {
  // progress: 0.0（已冷卻）→ 1.0（冷卻中）
  const arc = cooldownBar.getComponent(ProgressBar)!;
  tween(arc)
    .to(DURATION_MS.FAST / 1000, { progress: progress }, { easing: 'linear' })
    .start();

  // 冷卻完成時閃爍提示
  if (progress === 0) {
    tween(cooldownBar)
      .to(0.1, { scale: new Vec3(1.15, 1.15, 1) }, { easing: 'expoOut' })
      .to(0.1, { scale: new Vec3(1, 1, 1) }, { easing: 'bounceOut' })
      .start();
  }
}
```

---

## 6. UI 動畫

### 6.1 場景過渡動畫

**場景切換統一規範：**

所有場景切換使用全屏遮罩漸隱漸顯，確保無閃白或突切感。

| 場景切換 | 方向 | 時長 | 緩動 | 備註 |
|---------|------|------|------|------|
| Loading → Login | 淡入 | 500ms | `expoOut` | Logo 進場額外 400ms delay |
| Login → Lobby | 向上滑入 | 400ms | `expoOut` | 攜帶 auth token |
| Lobby → CannonSelect | 向右滑入 | 300ms | `expoOut` | — |
| CannonSelect → Matchmaking | 向上滑入 | 300ms | `expoOut` | — |
| Matchmaking → Game | 放射狀展開 | 600ms | `expoOut` | 全屏射線特效 |
| Game → Settlement | 全屏暗化 + 結算面板上滑 | 500ms | `expoOut` | — |
| Settlement → Lobby | 淡出 + 淡入 | 400ms + 300ms | `linear` | 音樂交叉淡化 |

**場景切換遮罩實作：**

```typescript
class SceneTransitionManager {
  private maskNode: Node; // 全屏黑色遮罩

  async fadeOut(durationMs = 400): Promise<void> {
    this.maskNode.active = true;
    await new Promise<void>(resolve => {
      tween(this.maskNode.getComponent(UIOpacity)!)
        .to(durationMs / 1000, { opacity: 255 }, { easing: 'linear' })
        .call(resolve)
        .start();
    });
  }

  async fadeIn(durationMs = 300): Promise<void> {
    await new Promise<void>(resolve => {
      tween(this.maskNode.getComponent(UIOpacity)!)
        .to(durationMs / 1000, { opacity: 0 }, { easing: 'expoOut' })
        .call(() => { this.maskNode.active = false; resolve(); })
        .start();
    });
  }
}
```

**LoadingScene 進場動畫（VDD §8.1）：**

```
t=0ms    ：深海背景出現（opacity 0→1，300ms linear）
t=0ms    ：氣泡粒子開始上升（bubbleAmbient，20–30 顆）
t=200ms  ：Logo 進場（fade-in + scale 0.8→1.0，400ms expoOut）
t=600ms  ：副標題滑入（translateY 20px→0，600ms expoOut，200ms delay）
t=800ms  ：進度條淡入（opacity 0→1，300ms）
t=800ms  ：進度條按資源載入進度驅動（Tween width，linear）
```

### 6.2 HUD 動畫

**分數動畫（競技緊張感）：**

```typescript
// 分數跳動：每次分數更新觸發 scale 彈跳
function animateScoreUpdate(scoreLabel: Node, newScore: number, oldScore: number): void {
  // 先做數字計數器動畫
  AnimationUtils.animateCounter(
    scoreLabel.getComponent(Label)!,
    oldScore,
    newScore,
    600 // 600ms 滾動
  );

  // 同時做 scale 彈跳
  tween(scoreLabel)
    .to(DURATION_MS.FAST / 1000, { scale: new Vec3(1.2, 1.2, 1) }, { easing: 'backOut' })
    .to(DURATION_MS.FAST / 1000, { scale: new Vec3(1, 1, 1) }, { easing: 'sineOut' })
    .start();
}
```

**Jackpot 進度條動畫（VDD §5.6 + §6.3 Component Tokens）：**

```typescript
// Jackpot 進度條更新（對應 --boss-hp-transition: 200ms expoOut）
function updateJackpotBar(progressBar: ProgressBar, newValue: number, maxValue: number): void {
  const newProgress = newValue / maxValue;

  tween(progressBar)
    .to(DURATION_MS.NORMAL / 1000, { progress: newProgress }, { easing: 'expoOut' })
    .start();

  // 接近觸發（>80%）：進度條金色閃爍
  if (newProgress > 0.8) {
    const barSprite = progressBar.getComponent(Sprite)!;
    tween(barSprite)
      .to(0.5, { color: new Color(255, 255, 100, 255) }, { easing: 'sineInOut' })
      .to(0.5, { color: COLOR.GOLD_400 }, { easing: 'sineInOut' })
      .repeatForever()
      .start();
  }
}
```

**Boss HP 條動畫（對應 VDD --boss-hp-transition: 200ms expoOut）：**

| HP 段 | 顏色 | 額外特效 |
|-------|------|---------|
| 100–60% | `#00FF88`（neon-green） | 無 |
| 60–30% | `#FFEB3B`（純黃）| 輕微脈衝 1Hz |
| 30–0% | `#FF4444`（red-500）| 快速脈衝 2Hz + 邊框閃爍 |

**計時器後 10 秒緊急動畫（VDD §2.4 競技緊張感）：**

```typescript
function startCountdownUrgency(timerLabel: Node): void {
  // 計時器文字變紅
  timerLabel.getComponent(Label)!.color = COLOR.RED_500;

  // 每秒脈衝（scale 1.0→1.15→1.0，duration-fast）
  tween(timerLabel)
    .to(DURATION_MS.FAST / 1000, { scale: new Vec3(1.15, 1.15, 1) }, { easing: 'expoOut' })
    .to(DURATION_MS.FAST / 1000, { scale: new Vec3(1, 1, 1) }, { easing: 'bounceOut' })
    .repeat(10) // 後 10 秒，每秒一次
    .start();
}
```

### 6.3 對話框動畫

**通用面板進退場規範（對應 VDD §6.5 Motion Tokens）：**

| 動畫方向 | 進場 | 退場 | 時長 |
|---------|------|------|------|
| 底部上滑 | translateY 200px→0 + opacity 0→1 | translateY 0→200px + opacity 1→0 | 500ms / 300ms |
| 中央縮放 | scale 0.8→1.0 + opacity 0→1 | scale 1.0→0.8 + opacity 1→0 | 300ms / 200ms |
| 全屏模態 | opacity 0→1（overlay）+ 子面板 scale 0.9→1.0 | opacity 1→0 | 300ms / 200ms |

**商城彈窗動畫（ShopDialog）：**

```typescript
// 商城面板進場：從底部上滑（VDD §8.5 場景規格）
async function openShopDialog(dialogNode: Node): Promise<void> {
  dialogNode.active = true;
  dialogNode.setPosition(0, -400);  // 初始位置在畫面下方

  await new Promise<void>(resolve => {
    tween(dialogNode)
      .to(DURATION_MS.SLOW / 1000,
          { position: new Vec3(0, 0, 0) },
          { easing: 'expoOut' })
      .call(resolve)
      .start();
  });
}
```

**VIP 升級彈窗特效：**

```
進場：scale 0.5→1.1→1.0（backOut，400ms）+ 全屏金色光芒（200ms）
持續：VIP 光圈旋轉動畫（--vip-badge-glow-radius 8px，對應等級色）
退場：scale 1.0→0.8 + opacity 1→0（200ms expoIn）
```

### 6.4 金幣/鑽石飛行動畫

**金幣飛向 HUD 動畫（對應 VDD Motion Tokens）：**

```typescript
// VDD token reference: --duration-normal = 200ms, --easing-expo-out
// 金幣數量決定飛出枚數（log2 壓縮，最多 8 枚視覺金幣）
function playCoinsToHUD(
  startPos: Vec3,
  amount: number,
  hudCoinPos: Vec3
): void {
  const count = Math.min(Math.ceil(Math.log2(amount + 1)), 8);

  for (let i = 0; i < count; i++) {
    const coin = coinPool.get();
    if (!coin) return;

    // 初始散射偏移（增加視覺豐富感）
    const offsetX = (Math.random() - 0.5) * 60;
    const offsetY = (Math.random() - 0.5) * 60;
    coin.setWorldPosition(
      startPos.x + offsetX,
      startPos.y + offsetY,
      startPos.z
    );
    coin.active = true;

    tween(coin)
      .delay(i * 0.05)                           // 每枚間隔 50ms，形成「傾瀉」感
      .to(0.2, { worldPosition: hudCoinPos },    // 200ms（duration-normal）
          { easing: 'quartOut' })
      .call(() => {
        coinPool.put(coin);
        updateHUDCoins();                          // 觸發 HUD 金幣數字跳動
      })
      .start();
  }
}
```

**鑽石飛行動畫（購買確認後）：**

- 顏色：`#00D4FF`（neon-blue）
- 路徑：arc 弧線（先上揚 80px 再落至 HUD）
- 時長：350ms（`duration-slow` 的 70%）
- 緩動：`expoOut`
- 每枚間隔：40ms
- 最大枚數：5 枚（鑽石價值較高，視覺上不宜過多）

---

## 7. Jackpot 特效系統

### 7.1 Jackpot 觸發動畫

Jackpot 是遊戲最重要的視覺高潮，所有其他特效在此期間讓位（暫停 `bubbleAmbient` 等低優先粒子系統）。

**完整 Jackpot 觸發動畫序列（總時長 ≥ 10.8s）：**

| 階段 | 時間點 | 事件 | 技術實作 |
|------|-------|------|---------|
| 1 | t=0ms | 全屏白色 Flash（3 幀，每幀 50ms）| `UIOpacity` Tween 3 次 |
| 2 | t=150ms | 遊戲暫停（其他特效暫停，粒子限額提升至 500）| `ParticleCounter.setMode('jackpot')` |
| 3 | t=300ms | BGM 交叉淡化至 Jackpot Stinger（300ms crossfade）| `AudioManager.crossFade()` |
| 4 | t=500ms | Jackpot 面板從底部滑入（500ms，expoOut）| `AnimationUtils.showPanel()` |
| 5 | t=600ms | 數字累計滾動開始（每位數 200ms）| `AnimationUtils.animateCounter()` |
| 6 | t=600ms | 金幣爆炸粒子觸發（200 粒子，`jackpotBurst`，2s）| `ParticleSystem2D.play()` |
| 7 | t=5600ms | 面板保持顯示（5000ms 持續展示）| `delay(5000)` |
| 8 | t=10600ms | 面板從底部滑出（300ms，expoIn）| `AnimationUtils.hidePanel()` |
| 9 | t=10800ms | 遊戲恢復（粒子限額降回 300，重啟背景特效）| `ParticleCounter.setMode('normal')` |

**Jackpot 面板進場：**

```typescript
async function triggerJackpotSequence(
  jackpotAmount: number,
  winnerId: string
): Promise<void> {
  // 1. Screen flash
  await screenFlash(3, 50);                           // 3 幀 × 50ms

  // 2. 提升粒子限額，暫停低優先特效
  ParticleCounter.setMode('jackpot');

  // 3. BGM 交叉淡化
  AudioManager.crossFade('bgm_jackpot_stinger', 0.3); // 300ms

  // 4. Jackpot 面板滑入
  await AnimationUtils.showPanel(jackpotPanelNode, DURATION_MS.SLOW);

  // 5. 金幣粒子爆炸（非 await，並行進行）
  spawnJackpotParticles(200);

  // 6. 數字滾動（JACKPOT_DURATION_MS per digit）
  const DIGIT_DURATION_MS = DURATION_MS.NORMAL; // 200ms per digit
  await AnimationUtils.animateCounter(
    jackpotAmountLabel,
    0,
    jackpotAmount,
    String(jackpotAmount).length * DIGIT_DURATION_MS
  );

  // 7. 展示 5 秒
  await delay(5000);

  // 8. 面板退場
  await AnimationUtils.hidePanel(jackpotPanelNode, DURATION_MS.NORMAL);

  // 9. 恢復正常模式
  ParticleCounter.setMode('normal');
}

async function screenFlash(times: number, frameDurationMs: number): Promise<void> {
  const overlay = getFlashOverlayNode();
  for (let i = 0; i < times; i++) {
    overlay.getComponent(UIOpacity)!.opacity = 255;
    await delay(frameDurationMs);
    overlay.getComponent(UIOpacity)!.opacity = 0;
    await delay(frameDurationMs);
  }
}
```

### 7.2 數字累計特效

**Jackpot 數字滾動視覺規格（VDD §5.2 text-display：48px，font-weight-700）：**

| 屬性 | 值 |
|------|-----|
| 字型 | `font-family-display`（Oswald） |
| 字號 | 48px（text-display）|
| 字重 | 700 |
| 字距 | -0.5px |
| 顏色 | `#F5C842`（color-gold-400）|
| 陰影 | `--shadow-glow-gold`（0 0 12px rgba(245,200,66,0.8)）|
| 滾動方式 | 每位數獨立滾動柱（Slot Machine 效果）|
| 每位數時長 | 200ms（duration-normal）|
| 緩動 | `expoOut` |
| 最終停止 | 數字 scale 1.0→1.1→1.0 彈跳確認（backOut，150ms）|

**槍聲式數字滾動（Slot Machine 風格）：**

```typescript
// 每位數獨立 Label 節點，模擬老虎機轉軸停止
async function rollDigits(
  digitLabels: Label[],  // 每位數一個 Label 節點
  finalNumber: number,
  digitDurationMs = DURATION_MS.NORMAL
): Promise<void> {
  const finalStr = String(finalNumber).padStart(digitLabels.length, '0');

  const promises = digitLabels.map((label, index) => {
    return new Promise<void>(resolve => {
      // 模擬快速滾動 → 減速停止
      let count = 0;
      const totalRolls = 8 + index * 3; // 後幾位滾動更多次（老虎機感）
      const finalDigit = parseInt(finalStr[index]);

      const rollInterval = setInterval(() => {
        label.string = String(Math.floor(Math.random() * 10));
        count++;
        if (count >= totalRolls) {
          clearInterval(rollInterval);
          label.string = String(finalDigit);
          // 停止彈跳
          tween(label.node)
            .to(0.08, { scale: new Vec3(1.1, 1.1, 1) }, { easing: 'expoOut' })
            .to(0.07, { scale: new Vec3(1, 1, 1) }, { easing: 'bounceOut' })
            .call(resolve)
            .start();
        }
      }, digitDurationMs / totalRolls);
    });
  });

  await Promise.all(promises);
}
```

### 7.3 金幣爆炸特效

**Jackpot 金幣爆炸粒子規格（對應 VDD §2.2 item 5）：**

| 參數 | 值 |
|------|-----|
| 粒子總數 | 200（Jackpot 模式上限 500 允許此值）|
| 發射模式 | Burst（瞬間全發）|
| 初速範圍 | 600–1200 px/s |
| 初速方向 | 隨機 360°（形成「金色爆炸雲」）|
| 重力係數 | 0.3g（294 px/s²）|
| 自旋轉速 | 2–8 rad/s（每粒子隨機）|
| 粒子生命週期 | 1.0–2.0s |
| Fade-out 起始 | 0.6s 後開始（VDD §2.2）|
| 粒子尺寸 | 12×12 px → 8×8 px（縮小至消亡）|
| 顏色 | `#F5C842`（主）→ `#FF8C00`（次，specular 光點效果）|
| blendMode | ADD（金色光芒感）|
| Specular 光點 | 每枚金幣帶 1 個白色高光 sprite（4×4 px）|

**金幣粒子爆炸函數：**

```typescript
function spawnJackpotParticles(count: number): void {
  const jackpotEffect = effectPoolManager.acquireJackpotEffect();
  const psComp = jackpotEffect.getComponent(ParticleSystem2D)!;

  // 動態設定粒子參數
  psComp.maxParticles = count;
  psComp.life = 1.0;
  psComp.lifeVar = 1.0;
  psComp.startSize = 12;
  psComp.endSize = 8;
  psComp.speed = 900;
  psComp.speedVar = 300;
  psComp.angle = 90;         // 基礎角度（90° = 向上，配合 gravity 形成拋物線）
  psComp.angleVar = 180;     // ±180° 使粒子向全方位散射
  psComp.gravity = new Vec2(0, -294); // 0.3g

  // 啟動粒子系統
  psComp.resetSystem();
  ParticleCounter.add(count);

  // 追蹤粒子完成，回收池
  scheduler.scheduleOnce(() => {
    jackpotEffect.getComponent(ParticleSystem2D)!.stopSystem();
    effectPoolManager.releaseJackpotEffect(jackpotEffect);
    ParticleCounter.remove(count);
  }, 2.5); // 2.5s 後確保所有粒子消亡
}
```

---

## 8. 環境動畫

### 8.1 海底背景動畫

**背景分層視差系統（VDD §4.3 海底世界設計）：**

| 層級 | 元素 | z-order | 視差速度 | 動畫說明 |
|------|------|---------|---------|---------|
| 遠景層（z=0） | 深海輪廓、珊瑚礁陰影 | 0 | 0.1× | 靜止，blur 4px 模擬景深 |
| 中景層（z=1） | 珊瑚群、海草、礁石 | 1 | 0.3× | 海草擺動 8s loop（±3° Tween）|
| 近景層（z=2） | 裝飾魚群、氣泡 | 2 | 0.6× | 氣泡上升 loop；裝飾小魚 opacity 0.3 |
| HUD 層（z=3） | 所有 UI 元素 | 10–50 | 無視差 | 固定位置 |

**海草擺動動畫（中景層）：**

```typescript
// 海草搖擺（正弦函數模擬）
function setupSeaweedSway(seaweedNodes: Node[]): void {
  seaweedNodes.forEach((node, index) => {
    const phaseOffset = index * 0.5; // 相位偏移，避免同步感
    const period = 7 + Math.random() * 2; // 7–9s 週期

    tween(node)
      .delay(phaseOffset)
      .to(period / 2, { angle: 3 }, { easing: 'sineInOut' })
      .to(period / 2, { angle: -3 }, { easing: 'sineInOut' })
      .repeatForever()
      .start();
  });
}
```

**背景 UV Scroll Shader（深海波紋）：**

```glsl
// bg_ocean_wave.effect — 背景波紋 Shader
uniform float uTime;
uniform float uWaveSpeed;   // 預設 0.02
uniform float uWaveAmp;     // 預設 0.005（微弱扭曲）

void main () {
  vec2 uv = v_uv0;
  // 水平波紋（雙頻疊加增加自然感）
  uv.x += sin(uv.y * 8.0 + uTime * uWaveSpeed) * uWaveAmp;
  uv.x += sin(uv.y * 5.0 + uTime * uWaveSpeed * 0.7) * uWaveAmp * 0.5;
  gl_FragColor = texture(mainTexture, uv);
}
```

**垂直光柱動畫（VDD §2.2 item 1 水下場景光影）：**

- 光柱 Sprite：白色漸層（頂部 opacity 0.6，底部 opacity 0），角度 20°
- 動畫：UV scroll Y 方向（speed 0.008）模擬光線流動
- 光柱數量：3–5 條，分布在畫面寬度
- 焦散（Caustic）光斑：獨立 Sprite Atlas，UV scroll 雙方向（模擬水面折射）

### 8.2 水面漣漪

**水面漣漪效果（用於 Boss 進場海浪裂開）：**

```typescript
// 圓形漣漪 Tween（Boss 進場時）
function spawnRipple(center: Vec3, maxRadius: number): void {
  const rippleNode = effectPoolManager.acquireRipple();
  rippleNode.setWorldPosition(center);
  rippleNode.setScale(0.1, 0.1, 1);

  const sprite = rippleNode.getComponent(Sprite)!;
  sprite.color = new Color(0, 212, 255, 200); // neon-blue，半透明

  tween(rippleNode)
    .to(0.8,
      { scale: new Vec3(maxRadius / 50, maxRadius / 50, 1) },
      { easing: 'sineOut' }
    )
    .start();

  tween(sprite)
    .delay(0.4)
    .to(0.4, { color: new Color(0, 212, 255, 0) }, { easing: 'linear' })
    .call(() => effectPoolManager.releaseRipple(rippleNode))
    .start();
}

// Boss 進場時生成多圈漣漪
function bossEntryRipples(bossPos: Vec3): void {
  [80, 160, 240, 320].forEach((radius, i) => {
    setTimeout(() => spawnRipple(bossPos, radius), i * 150);
  });
}
```

**氣泡上升系統（環境氛圍，常駐）：**

```typescript
// 氣泡粒子設定（bubbleAmbient.plist 參數）
const BUBBLE_CONFIG = {
  maxParticles: 30,
  emissionRate: 2,         // 每秒 2 顆（低密度，不干擾遊戲）
  life: 8.0, lifeVar: 3.0, // 8±3s，緩慢上升
  startSize: 8, endSize: 4,
  speed: 80, speedVar: 40, // 80±40 px/s
  angle: 90, angleVar: 10, // 主要向上，輕微偏斜
  startColor: 'rgba(0,212,255,0.6)',
  endColor:   'rgba(0,212,255,0)',
  blendMode: 'NORMAL',
  gravity: new Vec2(0, 0), // 無重力（純粹上升）
};
```

### 8.3 光線折射效果

**焦散光斑動畫（Caustic Light，VDD §2.2 水下場景光影）：**

| 元素 | 技術 | 規格 | 層級 |
|------|------|------|------|
| 焦散光斑 | Sprite Atlas UV Scroll | 256×256 px Atlas，X+Y 雙向 scroll | z=1（中景）|
| 垂直光柱 | Gradient Sprite + UV Scroll Y | 640×1280 px，角度 20° | z=0（遠景）|
| 水面反射 | Distortion Shader | 全屏 RenderTexture，uv 擾動 | z=3（HUD 後方）|

**焦散光斑 UV Scroll：**

```glsl
// caustic_light.effect
uniform float uTime;
void main () {
  vec2 uv = v_uv0;
  // 雙方向 UV 滾動模擬水面光折射
  vec2 scrollA = uv + vec2(uTime * 0.02, uTime * 0.015);
  vec2 scrollB = uv + vec2(-uTime * 0.018, uTime * 0.01);
  vec4 colorA  = texture(mainTexture, scrollA);
  vec4 colorB  = texture(mainTexture, scrollB);
  gl_FragColor = (colorA + colorB) * 0.5;
}
```

**大廳背景裝飾魚群（VDD §8.3 LobbyScene）：**

- 3–5 條小魚，opacity 0.3，不遮擋主要內容
- 使用幀動畫（8 幀 loop，12fps）
- 路徑：從畫面一側緩慢穿越到另一側（15–25s，`linear`）
- 每條魚生成間隔：3–8s 隨機

---

## 9. 效能最佳化

### 9.1 動畫 LOD（Level of Detail）

**動畫品質依據設備效能自動分級：**

```typescript
enum AnimLOD {
  HIGH   = 'high',    // 60fps 設備，全特效
  MEDIUM = 'medium',  // 45-59fps 設備，部分降級
  LOW    = 'low',     // 30-44fps 設備，大幅降級
}

class AnimLODManager {
  private static currentLOD: AnimLOD = AnimLOD.HIGH;
  private static fpsHistory: number[] = [];

  // 每秒採樣一次 FPS，連續 3 次低於閾值則降級
  static updateLOD(currentFPS: number): void {
    this.fpsHistory.push(currentFPS);
    if (this.fpsHistory.length > 5) this.fpsHistory.shift();

    const avgFPS = this.fpsHistory.reduce((a, b) => a + b, 0) / this.fpsHistory.length;

    const newLOD = avgFPS >= 58 ? AnimLOD.HIGH
                 : avgFPS >= 44 ? AnimLOD.MEDIUM
                 :                AnimLOD.LOW;

    if (newLOD !== this.currentLOD) {
      this.currentLOD = newLOD;
      this.applyLOD(newLOD);
    }
  }

  private static applyLOD(lod: AnimLOD): void {
    switch (lod) {
      case AnimLOD.HIGH:
        // 全特效
        setAmbientBubbles(true);
        setVIPShaderEnabled(true);
        setEliteOutlineShader(true);
        setParticleMaxBudget(300);
        break;
      case AnimLOD.MEDIUM:
        // 關閉背景氣泡、精英輪廓光
        setAmbientBubbles(false);
        setVIPShaderEnabled(true);   // VIP 光暈保留（商業核心體驗）
        setEliteOutlineShader(false);
        setParticleMaxBudget(200);
        break;
      case AnimLOD.LOW:
        // 關閉所有 Shader 特效，粒子大幅削減
        setAmbientBubbles(false);
        setVIPShaderEnabled(false);
        setEliteOutlineShader(false);
        setParticleMaxBudget(100);
        // Spine 改為幀動畫模式（如引擎支援 fallback）
        break;
    }
  }
}
```

**各 LOD 等級特效開關：**

| 特效 | LOD_HIGH | LOD_MEDIUM | LOD_LOW | 備註 |
|------|---------|-----------|---------|------|
| 環境氣泡粒子 | On | Off | Off | 最先關閉 |
| 精英魚 Outline Shader | On | Off | Off | — |
| 背景焦散光斑 | On | On | Off | — |
| VIP 光暈 Shader | On | On | Off | 核心付費體驗，盡量保留 |
| Boss Outline Shader | On | On | On | 遊戲核心，不降級 |
| 冰凍 Shader | On | On | On | — |
| 普通命中粒子數 | 10 | 6 | 4 | — |
| 死亡爆炸粒子數 | 50 | 30 | 15 | — |
| Jackpot 粒子數 | 200 | 150 | 100 | 降級仍保留視覺衝擊 |

### 9.2 粒子系統上限

**粒子預算管理器：**

```typescript
class ParticleCounter {
  private static activeCount = 0;

  static readonly BUDGETS = {
    normal:  300,  // 常規遊玩
    jackpot: 500,  // Jackpot 序列（短暫爆發）
    lod_med: 200,  // LOD_MEDIUM 模式
    lod_low: 100,  // LOD_LOW 模式
  } as const;

  private static currentBudget = this.BUDGETS.normal;

  static setMode(mode: keyof typeof ParticleCounter.BUDGETS): void {
    this.currentBudget = this.BUDGETS[mode];
    if (mode === 'jackpot') {
      // Jackpot 模式：暫停低優先粒子系統
      EffectPoolManager.getInstance().pauseLowPriorityEffects();
    } else if (mode === 'normal') {
      EffectPoolManager.getInstance().resumeLowPriorityEffects();
    }
  }

  static canSpawn(requested: number): boolean {
    return (this.activeCount + requested) <= this.currentBudget;
  }

  static add(count: number): void  { this.activeCount += count; }
  static remove(count: number): void { this.activeCount = Math.max(0, this.activeCount - count); }
  static get(): number { return this.activeCount; }
}
```

**粒子池預分配（啟動時）：**

| 粒子池 | 預分配數量 | 每個 Prefab 粒子數 | 總預算 |
|-------|---------|----------------|-------|
| hitNormal | 50 節點 | 10 粒子 | 500 |
| hitElite | 20 節點 | 20 粒子 | 400 |
| killExplosion | 30 節點 | 50 粒子 | 1500 |
| coinBurst | 100 節點 | 50 粒子 | 5000 |
| jackpotBurst | 5 節點 | 200 粒子 | 1000 |
| bubbleAmbient | 3 節點 | 30 粒子 | 90 |
| 合計節點 | **208 節點** | — | — |

> **注意**：「總預算」為各池的最大容量。實際同時活躍粒子受 `ParticleCounter` 嚴格限制在 300–500 範圍內，不存在所有粒子同時活躍的情況。

### 9.3 記憶體管理

**動畫資源記憶體目標：< 30 MB（對應 §1.3 效能預算）**

**各類型動畫資源估算：**

| 資源類型 | 數量 | 平均大小 | 總計 |
|---------|------|---------|------|
| 普通魚 Sprite Atlas（×5 種）| 5 Atlas | 512 KB | ~2.5 MB |
| 精英魚 Spine Atlas（×3 種）| 3 × 1024×1024 | 1 MB | ~3 MB |
| Boss Spine Atlas（×3 種）| 3 × 2048×2048 | 4 MB | ~12 MB |
| 特效 Sprite Atlas | 2 × 2048×2048 | 4 MB | ~8 MB |
| 粒子 .plist 檔案 | 10 個 | 5 KB | ~0.05 MB |
| Shader Effect 檔案 | 8 個 | 10 KB | ~0.08 MB |
| **合計** | — | — | **~25.6 MB** |

**記憶體最佳化策略：**

1. **Spine Atlas 壓縮**：使用 ASTC 4×4（iOS）/ ETC2（Android）格式，減少 50–70% 記憶體佔用
2. **普通魚 Atlas 合併**：5 種普通魚合入 2 個 2048×2048 Atlas（TexturePacker 最優打包）
3. **場景卸載時釋放**：GameScene 卸載時釋放所有魚類 Spine 資源，Shell 場景不持有 Game Bundle
4. **粒子節點複用**：所有粒子特效使用物件池，不在執行時 instantiate
5. **Spine 動畫快取**：已播放過的 Spine 動畫資料快取，避免重複解析

```typescript
// 場景卸載時的動畫資源釋放
class GameSceneLifecycle {
  onDestroy(): void {
    // 1. 停止所有 Tween
    tween(null).stop(); // 停止場景內所有 Tween（若使用 tag 管理則按 tag 停止）

    // 2. 停止所有粒子系統
    EffectPoolManager.getInstance().stopAllParticles();

    // 3. 釋放物件池
    FishPoolManager.getInstance().releaseAll();
    BulletPoolManager.getInstance().releaseAll();
    EffectPoolManager.getInstance().releaseAll();

    // 4. 重置粒子計數器
    ParticleCounter.remove(ParticleCounter.get());

    // 5. 強制 GC（Native 平台）
    if (sys.isNative) {
      sys.garbageCollect();
    }
  }
}
```

---

## 10. 動畫命名規範

### 10.1 檔案命名規範

**格式：** `{類別}_{名稱}_{狀態/動作}_{@倍率}.{副檔名}`

```
# 魚類幀動畫
fish_small_swim_@1x.png           # 普通小魚游泳
fish_medium_swim_@1x.png          # 普通中魚游泳
fish_octopus_swim_@1x.png         # 章魚游泳
fish_shark_swim_@1x.png           # 鯊魚游泳
fish_turtle_swim_@1x.png          # 海龜游泳
fish_elite_lionfish_idle_@1x.png  # 精英獅子魚（用幀動畫備用）

# Boss Spine 資源
spine_boss_dragon_@1x.atlas       # Boss 龍魚 Spine Atlas
spine_boss_dragon.skel            # Boss 龍魚骨骼資料
spine_boss_shark_@1x.atlas        # Boss 海神鯊 Spine Atlas
spine_boss_abyss_@1x.atlas        # Boss 深海女皇 Spine Atlas

# 特效粒子
particle_hit_normal.plist          # 普通命中粒子
particle_hit_elite.plist           # 精英魚命中粒子
particle_kill_explosion.plist      # 魚死亡爆炸
particle_coin_burst.plist          # 金幣爆炸
particle_jackpot_burst.plist       # Jackpot 金幣爆炸
particle_skill_freeze.plist        # 冰凍技能粒子
particle_skill_bomb.plist          # 炸彈技能粒子
particle_bubble_ambient.plist      # 環境氣泡
particle_vip_aura.plist            # VIP 光暈粒子
particle_eel_spark.plist           # 電鰻電弧粒子

# Shader Effect
effect_fish_hit_flash.effect       # 受擊泛紅 Shader
effect_fish_outline.effect         # 精英/Boss 輪廓光 Shader
effect_fish_freeze.effect          # 冰凍 Shader
effect_bg_ocean_wave.effect        # 背景波紋 Shader
effect_caustic_light.effect        # 焦散光斑 Shader
effect_bomb_shockwave.effect       # 炸彈衝擊波 Shader
effect_vip_glow.effect             # VIP 光暈旋轉 Shader

# UI 動畫 Atlas
ui_coin_spin_@2x.png              # 金幣旋轉 16 幀（VDD §2.3）
ui_jackpot_panel_bg_@2x.png       # Jackpot 面板背景
ui_vip_badge_level01_@2x.png      # VIP 徽章等級 01–10
ui_cannon_fire_@2x.png            # 砲台發射 6 幀
```

### 10.2 代碼命名規範

**AnimationClip 名稱（cc.Animation 用）：**

```
# 魚類動畫 Clip
fish_swim            # 游泳（loop）
fish_hit             # 受擊
fish_death           # 死亡
fish_spawn           # 生成出現

# Boss Spine 動畫名稱（必須與 Spine Editor 一致）
idle                 # 待機
swim                 # 游動
hit                  # 受傷
roar                 # 憤怒（HP < 50%）
attack               # 攻擊
die                  # 死亡
intro                # 進場
```

**Tween 標籤（用於精確停止特定 Tween）：**

```typescript
// Tween 標籤常數
export const TWEEN_TAGS = {
  FISH_PATH:       'fish_path',
  COIN_FLIGHT:     'coin_flight',
  HUD_SCORE:       'hud_score',
  JACKPOT_BAR:     'jackpot_bar',
  BOSS_HP:         'boss_hp',
  SKILL_COOLDOWN:  'skill_cooldown',
  VIP_AURA:        'vip_aura',
  SCENE_TRANSITION:'scene_transition',
} as const;
```

### 10.3 事件命名規範

**動畫觸發事件（EventBus）：**

```typescript
// 動畫相關 EventBus 事件名稱
export const ANIM_EVENTS = {
  FISH_SPAWN:           'anim:fish_spawn',
  FISH_DIED:            'anim:fish_died',
  FISH_HIT:             'anim:fish_hit',
  BOSS_SPAWNED:         'anim:boss_spawned',
  BOSS_ROAR:            'anim:boss_roar',
  BOSS_DIED:            'anim:boss_died',
  JACKPOT_TRIGGERED:    'anim:jackpot_triggered',
  JACKPOT_COMPLETE:     'anim:jackpot_complete',
  SKILL_FREEZE:         'anim:skill_freeze',
  SKILL_BOMB:           'anim:skill_bomb',
  SKILL_LOCK_ON:        'anim:skill_lock_on',
  CANNON_FIRE:          'anim:cannon_fire',
  COIN_FLIGHT_COMPLETE: 'anim:coin_flight_complete',
  MVP_UPDATED:          'anim:mvp_updated',
} as const;
```

---

## 11. 驗收標準

### 11.1 幀率與效能驗收

| 驗收項目 | 標準 | 測試方法 | 責任人 |
|---------|------|---------|--------|
| 幀率穩定性（中端設備）| 60fps 持續，無明顯掉幀（允許 < 5 幀偶發）| Cocos Profiler，GameScene 運行 10 分鐘 | Engineering |
| 幀率穩定性（低端設備）| Snapdragon 665 ≥ 45fps | 實機測試（紅米 Note 9 / Samsung A32）| Engineering |
| 粒子系統記憶體洩漏 | 連續運行 30 分鐘後記憶體無持續增長 | Android Profiler / Instruments 監測 | Engineering |
| 動畫記憶體上限 | 動畫資源 < 30 MB | Memory Profiler（GameScene 啟動後）| Engineering |
| Boss Spine 動畫流暢度 | 無卡頓、無幀跳躍，8 個並行 Spine 流暢播放 | 實機測試，同時觸發 2 個 Boss | Engineering |

### 11.2 動畫品質驗收

| 驗收項目 | 標準 | 測試方法 | 責任人 |
|---------|------|---------|--------|
| Jackpot 特效與音效同步 | 視覺 Flash 與音效觸發誤差 ≤ 33ms（1 幀容差）| 對照測試（螢幕錄製 + 音訊波形對齊）| QA + Engineering |
| 金幣飛行匹配 Motion Tokens | 飛行時長 200ms、緩動 quartOut，與 VDD §6.5 token 一致 | 設計師視覺審核 + Profiler 時間戳 | Art + Engineering |
| Boss 進場全屏震動 | 震動持續 2s，強度逐漸衰減（非突然停止）| 主觀視覺審核 + Profiler 確認無多餘 | QA |
| 倍率爆字動畫 | scale 0→1.2→1.0，80ms expo-out + backOut，字號 56px | 設計師對照 VDD §2.4 審核 | Art |
| 冰凍技能視覺效果 | 魚群停止動畫 + 藍色 Tint + 冰晶粒子，解凍時粒子爆發 | QA 功能測試 + 設計師視覺審核 | QA + Art |
| 普通魚游動無同步感 | 同類魚群間動畫相位差異明顯，不呈「齊步走」| 視覺審核（GameScene，5 條同類魚）| Art |

### 11.3 Motion Token 一致性驗收

| 驗收項目 | VDD Token | 實作值 | 檢查方式 |
|---------|----------|--------|---------|
| 面板進場時長 | `duration-normal: 200ms` | `DURATION_MS.NORMAL = 200` | Code Review |
| 面板緩動 | `easing-expo-out` | `tween.to(..., { easing: 'expoOut' })` | Code Review |
| 金幣飛行緩動 | `easing-spring`（quartOut 近似）| `{ easing: 'quartOut' }` | Code Review |
| 按鈕彈回緩動 | `easing-bounce` | `{ easing: 'bounceOut' }` | Code Review |
| Jackpot 最短播放 | `duration-jackpot: 3000ms` | `DURATION_MS.JACKPOT = 3000`，序列 ≥ 3000ms | QA 計時驗證 |
| Boss HP 過渡時長 | `--boss-hp-transition: 200ms expoOut` | `DURATION_MS.NORMAL` + `'expoOut'` | Code Review |

### 11.4 視覺設計驗收

| 驗收項目 | 標準 | 驗收方 |
|---------|------|--------|
| Dark Luxury × Casino Arcade 風格一致性 | 所有動畫特效色彩符合 VDD §3.2 主色盤（#F5C842 金色、#00D4FF 霓虹青、#051428 深海藍）| Art Director |
| 多巴胺優先原則 | 玩家爽感評分 ≥ 4.2/5（5 人以上 Persona A/B 用戶測試）| Product + Art |
| VIP 光暈彰顯地位感 | VIP 10 等彩虹流動光暈清晰可見，與普通玩家視覺差異顯著 | Art Director |
| Jackpot 全場沸騰感 | Jackpot 特效播放期間，測試玩家評分「震撼感」≥ 4.5/5 | Product |
| 新手首次命中金幣動畫 | 新手玩家描述「金幣噴出動畫好看，想繼續玩」（Persona C 驗收）| Product |

---

*本文件版本 1.0，最後更新 2026-04-25。所有動畫規格需在 GameScene 實機測試通過後方可標記 APPROVED。上游文件變更時，本文件需同步更新對應章節。*
