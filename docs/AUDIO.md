# AUDIO — 音效設計文件 (fishing-arcade-game)

<!-- 上游文件：PRD-FISHGAME-20260424 · EDD-FISHGAME-20260424 · PDD-FISHGAME-20260425 · VDD-FISHGAME-20260425 -->

---

## Document Control

| 欄位 | 內容 |
|------|------|
| **DOC-ID** | AUDIO-FISHGAME-20260425 |
| **版本** | 1.0 |
| **狀態** | APPROVED |
| **日期** | 2026-04-25 |
| **作者** | Audio Design (AI Generated) |
| **上游 PRD** | [PRD.md](PRD.md) |
| **上游 EDD** | [EDD.md](EDD.md) |
| **上游 PDD** | [PDD.md](PDD.md) |
| **上游 VDD** | [VDD.md](VDD.md) |
| **審閱者** | Art Director, Engineering Lead, 遊戲策劃 Lead |
| **核准者** | Executive Sponsor |

---

## Change Log

| 版本 | 日期 | 作者 | 變更摘要 |
|------|------|------|---------|
| 1.0 | 2026-04-25 | AI Generated | 初始生成，涵蓋全部 10 章 |

---

## 1. 音效設計概述

### 1.1 音效設計理念

FishGame 競技捕魚平台的視覺方向定位為「Dark Luxury × Casino Arcade」——深海奢華黑金美學搭配霓虹活力特效（VDD §1.3）。音效設計必須與此視覺方向形成一致的感官體驗，從聽覺維度強化每一個「多巴胺時刻」。

**三大設計支柱：**

#### 支柱 A — 多巴胺驅動（Dopamine-Driven Audio）
每一發砲彈命中、每一條魚的死亡特效、每一次 Jackpot 觸發，音效必須即時、清晰、爽快。命中音效以隨機音高（pitch randomization）維持聽覺新鮮感，避免重複疲勞；Jackpot 觸發音效設計為「不可中斷的儀式感」——全屏視覺爆炸與音效衝擊同步，形成完整的獎勵感知閉環。

#### 支柱 B — 競技緊張感（Competitive Tension）
BGM 自適應系統隨場景動態調整：魚群密度升高時節奏加快，Boss 出現時音樂層疊切換，計時器倒數最後 10 秒配合視覺脈衝增加心跳壓迫感。音樂 BPM 與 VDD §2.4 中「競技緊張感」的視覺語言（Boss 進場全屏震動、計時器等寬字體倒數）相互呼應。

#### 支柱 C — 奢華地位感（Luxury Status Audio）
VIP 升級、Jackpot 大獎、Boss 死亡等高階事件使用管弦樂 + 電子音樂混合編曲，傳遞出別於普通手機遊戲的品質感。VIP 老闆（Persona B）在觸發 Jackpot 時需要「全場沸騰」的存在感，音效設計配合 VDD §3.4 VIP 光環視覺系統，為高付費玩家提供專屬的聽覺地位象徵。

**設計原則與 VDD 對照：**

| VDD 設計原則 | 音效對應實現 |
|------------|------------|
| P1 多巴胺優先 | 命中/死亡/Jackpot 音效三層疊加（SFX + 環境殘響 + 旋律 Stinger） |
| P2 競爭可見 | BGM 自適應強度反映場面緊張程度，Boss 出現使用壓制性 Stinger |
| P3 自然變現 | VIP 升級、購買成功音效提供強烈正向回饋，強化付費感知價值 |
| P4 3 秒理解 | UI 音效即時回饋（< 16ms 延遲），按鈕點擊 / 對話框音效清晰可辨 |

### 1.2 技術規格

#### BGM 格式規格

| 平台 | 格式 | 位元率 | 聲道 | 取樣率 | 迴圈 |
|------|------|--------|------|--------|------|
| Web / H5 | OGG Vorbis | 128 kbps | Stereo | 44.1 kHz | 無縫迴圈 |
| iOS | AAC (M4A) | 128 kbps | Stereo | 44.1 kHz | 無縫迴圈 |
| Android | OGG Vorbis | 128 kbps | Stereo | 44.1 kHz | 無縫迴圈 |

**無縫迴圈要求：** 所有 BGM 必須在 DAW 中完成精確的 loop-in / loop-out 標記，避免爆音與靜音間隙。測試標準：耳聽 20 次連續迴圈，感知到切點則需重新剪輯。

#### SFX 格式規格

| 用途 | 格式 | 聲道 | 取樣率 | 位深 |
|------|------|------|--------|------|
| 遊戲核心 SFX | OGG Vorbis | Mono | 44.1 kHz | 16-bit |
| UI 音效 | OGG Vorbis | Mono | 44.1 kHz | 16-bit |
| 環境音效 | OGG Vorbis | Stereo | 44.1 kHz | 16-bit |
| 語音 (VO) | OGG Vorbis | Mono | 22.05 kHz | 16-bit |
| 製作中間格式 | WAV | — | 48 kHz | 24-bit |

#### Web AudioContext 解鎖規範

受瀏覽器自動播放政策（Autoplay Policy）限制，Web 平台必須在玩家首次互動後才能啟動 AudioContext：

```typescript
// AudioContext 解鎖入口 — 掛載在首次用戶互動事件
document.addEventListener('touchstart', unlockAudioContext, { once: true });
document.addEventListener('mousedown', unlockAudioContext, { once: true });

async function unlockAudioContext(): Promise<void> {
  const ctx = cc.director.getSystem(cc.AudioSystem) as any;
  if (ctx?.audioContext?.state === 'suspended') {
    await ctx.audioContext.resume();
  }
  // 播放靜音緩衝確保解鎖
  AudioManager.getInstance().playUnlockBuffer();
}
```

**注意事項：**
- BGM 必須等待 AudioContext 解鎖後才能開始播放
- 解鎖前使用視覺動畫（Splash 畫面）填充等待時間
- 解鎖後立即開始 BGM 淡入（fadeDuration: 1000ms）

### 1.3 音效架構

```
FishGame Audio Architecture
│
├── BGM Layer（背景音樂層）
│   ├── Base Loop（主旋律迴圈，可切換）
│   ├── Intensity Overlay（強度疊加層，根據場景動態混合）
│   └── Stinger Channel（Stinger 播放通道，非阻塞）
│
├── SFX Layer（音效層）
│   ├── Core Game SFX Pool（遊戲核心音效池，32 通道上限）
│   ├── UI SFX Channel（UI 音效通道，固定 2 通道）
│   └── Ambient Channel（環境音效通道，2 通道）
│
├── VO Layer（語音層，預留）
│   └── Announcer Channel（播報員語音，1 通道）
│
└── AudioManager（統一管理器）
    ├── 音量控制（BGM / SFX / VO 分離）
    ├── 音效開關（BGM / SFX 獨立）
    ├── AudioContext 解鎖管理
    └── 設定持久化（localStorage）
```

---

## 2. 音樂系統 (BGM)

### 2.1 場景音樂列表

| 場景 | 曲目名稱 | 風格描述 | BPM | 時長 | 迴圈 | 音量（正規化） | 備注 |
|------|---------|---------|-----|------|------|--------------|------|
| 啟動畫面 / Splash | bgm_splash | Deep Sea Ambient，水波聲 + 遠景鋼琴 | 70 | 0:45 | No | -12 dBFS | 隨 Splash 結束自動停止 |
| 主選單 (MainMenu) | bgm_main_menu | 神秘海洋 Dark Jazz，低音貝斯 + 爵士鋼琴 | 90 | 3:00 | Yes | -12 dBFS | 含大廳 (Lobby) 場景 |
| 一般房間 (NormalRoom) | bgm_normal_room | Casino Electro Beat，合成器節拍 + 金屬打擊 | 120 | 4:00 | Yes | -12 dBFS | 普通房間預設 BGM |
| 精英房間 (EliteRoom) | bgm_elite_room | Intense Electronic，加速節拍 + 低音炮掃頻 | 135 | 3:30 | Yes | -12 dBFS | 精英 / 競技房間 |
| Boss 戰 (BossRoom) | bgm_boss_battle | Epic Orchestral，弦樂 + 電子鼓 + 合唱 | 150 | 2:00 | Yes | -10 dBFS | Boss 存活期間循環播放 |
| 商店 (Shop) | bgm_shop | Relaxed Casino Lounge，爵士鋼琴 + 輕打擊 | 100 | 2:30 | Yes | -14 dBFS | 商城及個人中心共用 |
| 結算畫面 (Settlement) | bgm_settlement | Celebratory Fanfare，管弦 + 電子慶祝音效 | 120 | 0:30 | No | -8 dBFS | 一次性播放，不循環 |
| MVP 結算 | bgm_mvp_fanfare | Triumphant Fanfare，號角 + 鼓聲衝擊 | 140 | 0:20 | No | -8 dBFS | MVP 獲得者觸發 |
| Jackpot 爆獎 | bgm_jackpot_climax | Full Orchestral Explosion，全樂器齊奏 | 160 | 1:30 | No | -6 dBFS | 替換所有 BGM，優先級最高 |

**場景 BGM 切換規則：**

```
Splash → bgm_splash（立即播放，無淡入）
Splash → MainMenu → bgm_main_menu（淡出 500ms → 淡入 1000ms）
MainMenu → NormalRoom → bgm_normal_room（淡出 800ms → 淡入 500ms）
MainMenu → EliteRoom → bgm_elite_room（淡出 800ms → 淡入 500ms）
NormalRoom → Boss 進場 → bgm_boss_battle（Stinger sfx_boss_appear 壓制 → 淡入 200ms）
Boss 死亡 → bgm_settlement（立即切換，無淡入淡出）
Settlement → MainMenu → bgm_main_menu（淡出 1000ms → 淡入 1000ms）
任意場景 → Jackpot 觸發 → bgm_jackpot_climax（立即切換，最高優先級）
```

### 2.2 自適應音樂系統

自適應音樂系統（Adaptive Music System）根據遊戲場景的動態狀態即時調整 BGM 的強度與情緒層次，與 VDD §2.4 情感色調映射中「多巴胺刺激感」和「競技緊張感」的視覺設計保持聽覺一致。

#### 魚群密度適應

| 場內魚群數量 | 強度層級 | 音樂調整 | 過渡時間 |
|------------|---------|---------|---------|
| ≤ 5 條 | Level 1（平靜） | 僅主旋律 Base Loop，無附加層 | 3s 淡入 |
| 6–10 條 | Level 2（活躍） | + 輕量打擊樂 Overlay（音量 -8 dB）| 2s 淡入 |
| 11–19 條 | Level 3（熱烈） | + 低音線 + 打擊樂全開（音量 -4 dB）| 1.5s 淡入 |
| ≥ 20 條 | Level 4（激烈） | 全音軌播放，額外 synth fill（音量 0 dB）| 1s 淡入 |

**實作方式：** 使用 Cocos AudioSource 的 `volume` 屬性動態調整各 Overlay 音軌音量，Base Loop 與 Overlay 音軌需精確對齊 BPM 時間格（Beat-aligned），確保切換在小節邊界進行，避免節奏錯位。

#### Boss 出現適應

```
觸發條件：伺服器廣播 BossAppeared 事件（EDD §4.5）
觸發流程：
  1. sfx_boss_appear（2.0s Stinger，最高優先級，不可中斷）播放
  2. 同步觸發 VDD §4.3 Boss 進場動畫（全屏震動 2s）
  3. Stinger 播放完畢後自動切換至 bgm_boss_battle（淡入 200ms）
  4. bgm_boss_battle 持續循環至 Boss 死亡或逃跑

Boss 死亡：
  1. sfx_boss_die（3.0s）播放
  2. bgm_boss_battle 立即靜音（無淡出）
  3. sfx_jackpot_trigger 接力播放（若觸發 Jackpot 條件）
  4. 切換至 bgm_settlement 或 bgm_normal_room（依結算狀態）

Boss 逃跑：
  1. sfx_boss_escape（0.8s，與魚逃跑音效同音色但更低沉）播放
  2. 淡出 bgm_boss_battle（1000ms）
  3. 恢復原場景 BGM（bgm_normal_room / bgm_elite_room）
```

#### Jackpot 自適應

```
Jackpot 進度條 < 80%：正常場景 BGM
Jackpot 進度條 80–99%：添加 jackpot_buildup_layer（持續低音 drone + 上升音調）
Jackpot 觸發（100%）：
  1. sfx_jackpot_trigger（5.0s，不可中斷）立即切入
  2. 所有其他 BGM 靜音（不淡出，立即停止）
  3. sfx_jackpot_trigger 結束後自動接入 bgm_jackpot_climax
  4. bgm_jackpot_climax 播放完畢後播放 sfx_jackpot_rollup（Jackpot 數字滾動）
  5. 結算完成後切換至 bgm_settlement
```

### 2.3 音樂過渡設計

| 過渡類型 | 技術方法 | 時長 | 使用場景 |
|---------|---------|------|---------|
| 硬切（Hard Cut） | 停止當前 → 立即播放新曲 | 0ms | Jackpot 觸發、Boss 進場 Stinger |
| 淡出淡入（Crossfade） | 雙軌疊加，淡出+淡入 | 500–1000ms | 一般場景切換（大廳→遊戲房間）|
| 圖層混合（Layer Blend） | 音量調整 Overlay 音軌 | 1000–3000ms | 自適應強度變化 |
| 拍子對齊切換（Beat-Sync） | 等待下一個小節邊界 | 0–2000ms | Overlay 音軌開關，防止節奏錯位 |
| Stinger 接管（Stinger Takeover） | SFX 疊加在 BGM 上，BGM 音量降低 -12 dB | Stinger 時長 | Boss 出現、Jackpot 觸發 |

**Stinger 接管時 BGM 音量降低邏輯（閃避，Ducking）：**

```typescript
// BGM Ducking — Stinger 播放期間降低 BGM 音量
const DUCK_VOLUME = 0.2;  // -14 dB 等效
const DUCK_FADE_IN = 200;  // ms — 快速降低
const DUCK_FADE_OUT = 800; // ms — 緩慢恢復

AudioManager.getInstance().playStinger('sfx_boss_appear').then(() => {
  // Stinger 結束後 BGM 淡回原音量
  AudioManager.getInstance().restoreBGMVolume(DUCK_FADE_OUT);
});
AudioManager.getInstance().duckBGM(DUCK_VOLUME, DUCK_FADE_IN);
```

---

## 3. 音效系統 (SFX)

### 3.1 遊戲核心音效

| SFX ID | 觸發事件 | 檔案名稱 | 時長 | 音高隨機 | 並發上限 | 備注 |
|--------|---------|---------|------|---------|---------|------|
| SFX-001 | 射擊普通砲（Cannon Fire） | sfx_shoot_normal | 0.2s | ±3% | 8 | 可疊加，短爆發音效 |
| SFX-002 | 射擊雷射（Laser Fire） | sfx_shoot_laser | 0.5s | 無 | 4 | 持續音，有開始/結束音效 |
| SFX-003 | 射擊散射（Scatter Fire） | sfx_shoot_scatter | 0.3s | ±5% | 4 | 3 連音序列（0ms / 50ms / 100ms 延遲） |
| SFX-004 | 命中普通魚 | sfx_hit_normal | 0.1s | 0.9–1.1 隨機 | 16 | 音高隨機維持新鮮感 |
| SFX-005 | 命中精英魚 | sfx_hit_elite | 0.2s | 0.95–1.05 隨機 | 8 | 比普通命中更厚實 |
| SFX-006 | 命中 Boss 魚 | sfx_hit_boss | 0.3s | 無 | 4 | 金屬撞擊感，低頻沉重 |
| SFX-007 | 魚死亡——普通 | sfx_fish_die_normal | 0.5s | ±8% | 8 | 爆炸 + 金幣飛散聲 |
| SFX-008 | 魚死亡——精英 | sfx_fish_die_elite | 0.8s | ±5% | 4 | 大爆炸 + 金幣瀑布聲 |
| SFX-009 | Boss 出現 | sfx_boss_appear | 2.0s | 無 | 1（不可中斷）| 全屏震動 + 低頻 sub-bass 衝擊，壓制 BGM |
| SFX-010 | Boss 死亡 | sfx_boss_die | 3.0s | 無 | 1（不可中斷）| 觸發 Jackpot 條件的前置音效，史詩感 |
| SFX-011 | Boss 逃跑 | sfx_boss_escape | 0.8s | 無 | 1 | 失落感低沉音調 |
| SFX-012 | 金幣收集 | sfx_coin_collect | 0.3s | 隨倍率線性升高 | 16 | 低倍率 pitch 低，高倍率 pitch 高（1x=100%，最高 200%）|
| SFX-013 | 金幣瀑布（連續收集）| sfx_coin_stream | 2.0s | 無 | 2 | 循環播放，直到金幣收完 |
| SFX-014 | Jackpot 觸發 | sfx_jackpot_trigger | 5.0s | 無 | 1（不可中斷）| 全場最重要音效，5 秒完整播放，不允許被中斷或覆蓋 |
| SFX-015 | Jackpot 數字滾動 | sfx_jackpot_rollup | 3.0s | 無 | 1（循環）| 數字計數滾動聲，循環至結算完成 |
| SFX-016 | 冰凍技能啟動 | sfx_skill_freeze | 1.0s | 無 | 2 | 冰晶碎裂 + 低溫嗡聲 |
| SFX-017 | 炸彈技能啟動 | sfx_skill_bomb | 1.5s | 無 | 2 | 倒數嘀嗒 + 爆炸 |
| SFX-018 | 鎖定技能啟動 | sfx_skill_lock | 0.5s | 無 | 2 | 機械鎖定咔嗒聲 |
| SFX-019 | 連擊 Combo（2–4 連擊）| sfx_combo_low | 0.3s | 線性升高 | 4 | 連擊數越高 pitch 越高 |
| SFX-020 | 連擊 Combo（5+ 連擊）| sfx_combo_high | 0.5s | 無 | 2 | 達成 5 連擊的特別音效 |
| SFX-021 | MVP 獲得 | sfx_mvp_award | 1.5s | 無 | 1 | 勝利感，號角 + 金幣噴射聲 |
| SFX-022 | 搶魚成功（先手擊殺）| sfx_steal_kill | 0.6s | 無 | 4 | 競爭搶魚成功的特有滿足感音效 |

### 3.2 UI 音效

| SFX ID | 觸發事件 | 檔案名稱 | 時長 | 備注 |
|--------|---------|---------|------|------|
| SFX-101 | 按鈕點擊（主要 CTA）| sfx_btn_click_primary | 0.1s | 金屬感點擊，與金色按鈕視覺對應 |
| SFX-102 | 按鈕點擊（次要）| sfx_btn_click_secondary | 0.1s | 輕柔點擊 |
| SFX-103 | 按鈕懸停（Hover）| sfx_btn_hover | 0.08s | 極短輕聲，不影響體驗 |
| SFX-104 | 按鈕禁用點擊 | sfx_btn_disabled | 0.1s | 低沉無響聲，告知玩家不可用 |
| SFX-105 | 對話框 / 面板開啟 | sfx_dialog_open | 0.2s | 磨砂玻璃展開感（對應 VDD §5.5 面板）|
| SFX-106 | 對話框 / 面板關閉 | sfx_dialog_close | 0.2s | 玻璃收縮聲 |
| SFX-107 | 標籤頁切換 | sfx_tab_switch | 0.12s | 短促滑動聲 |
| SFX-108 | 滑動列 / 音量調節 | sfx_slider_drag | 0.05s | 持續拖動音（每 step 觸發一次）|
| SFX-109 | 開關切換（Toggle On）| sfx_toggle_on | 0.15s | 清脆啟用聲 |
| SFX-110 | 開關切換（Toggle Off）| sfx_toggle_off | 0.15s | 低沉關閉聲 |
| SFX-111 | 配對成功（Match Found）| sfx_match_found | 0.8s | 電子嗶聲 + 上升音調，玩家頭像飛入時同步觸發（PDD §5.9）|
| SFX-112 | 配對倒數（每秒）| sfx_match_countdown | 0.1s | 節拍器滴答聲，配合 30s 倒數（PDD §5.9）|
| SFX-113 | 錯誤 / 操作失敗 | sfx_error | 0.3s | 低沉警示聲，不使用刺耳音效 |
| SFX-114 | 通知 / Toast 顯示 | sfx_notification | 0.25s | 輕柔提示聲 |
| SFX-115 | VIP 升級 | sfx_vip_upgrade | 2.0s | 奢華感升級音效，金幣噴射 + 光暈啟動聲（配合 VDD §3.4 VIP 等級色系進場動畫）|
| SFX-116 | 購買成功 | sfx_purchase_success | 0.8s | 清脆成功聲 + 金幣音，對應商城 CVR 強化 |
| SFX-117 | 鑽石充值成功 | sfx_diamond_credited | 1.0s | 鑽石音色 + 數字計數聲（配合 VDD §3.6 鑽石圖示色 #00D4FF）|
| SFX-118 | 倒數計時警示（Boss 計時最後 10s）| sfx_timer_alert | 0.3s | 每秒觸發，音高逐漸升高，配合 VDD §2.4 紅色脈衝視覺 |
| SFX-119 | Jackpot 進度條充滿警示 | sfx_jackpot_nearfull | 0.5s | 緊張顫音，提示玩家 Jackpot 即將觸發 |
| SFX-120 | 排行榜順位上升 | sfx_rank_up | 0.4s | 上升音調，即時排名 HUD 更新時觸發 |
| SFX-121 | 訂單異常 / 支付失敗 | sfx_payment_error | 0.5s | 明顯但不刺耳的警示聲（對應 PDD §4.3.1 IAP 失敗流程）|

### 3.3 環境音效

| SFX ID | 觸發事件 | 檔案名稱 | 時長 | 聲道 | 備注 |
|--------|---------|---------|------|------|------|
| AMB-001 | 海洋背景環境音 | amb_ocean_base | 60s | Stereo | 全程持續循環，深海低頻水流聲 |
| AMB-002 | 氣泡上升音效 | amb_bubbles | 5s | Stereo | 隨機觸發（每 3–8s 一次），配合 VDD §4.3 近景層氣泡動畫 |
| AMB-003 | 水流聲（動態水波）| amb_water_flow | 30s | Stereo | 隨 VDD §2.3 背景 Shader UV scroll 動態音量 |
| AMB-004 | 魚群游動聲 | amb_fish_school | 8s | Stereo | 大量魚群出現時觸發，隨機偶發 |
| AMB-005 | 深海低鳴（Boss 房間氛圍）| amb_boss_room | 20s | Stereo | 僅在 Boss 房間 bgm_boss_battle 播放期間疊加 |
| AMB-006 | 商城背景（玻璃杯碰撞 / 輕音樂廳環境）| amb_casino_lounge | 30s | Stereo | 商城場景（VDD §2.5 暗金色底場景氛圍）|
| AMB-007 | 大廳背景（珊瑚礁水波）| amb_lobby_ocean | 45s | Stereo | 大廳 / 主選單持續播放 |

**環境音效混音規則：**
- 環境音效音量固定為 SFX 音量的 30%（防止遮蓋遊戲核心音效）
- 環境音效不受玩家 SFX 開關控制（始終保持環境感，但受主音量控制）
- 游戲進行中，amb_ocean_base 音量動態降低至 20%，避免干擾遊戲 SFX

---

## 4. 音效資源規格

### 4.1 BGM 規格表

| 檔案名稱 | 格式（Web） | 格式（iOS）| 格式（Android）| 時長 | 迴圈標記 | 檔案大小（估算，OGG 128kbps）|
|---------|-----------|-----------|----------------|------|---------|---------------------------|
| bgm_splash.ogg / .m4a | OGG | AAC | OGG | 0:45 | No | ≈ 720 KB |
| bgm_main_menu.ogg / .m4a | OGG | AAC | OGG | 3:00 | Yes | ≈ 2.9 MB |
| bgm_normal_room.ogg / .m4a | OGG | AAC | OGG | 4:00 | Yes | ≈ 3.9 MB |
| bgm_elite_room.ogg / .m4a | OGG | AAC | OGG | 3:30 | Yes | ≈ 3.4 MB |
| bgm_boss_battle.ogg / .m4a | OGG | AAC | OGG | 2:00 | Yes | ≈ 1.9 MB |
| bgm_shop.ogg / .m4a | OGG | AAC | OGG | 2:30 | Yes | ≈ 2.4 MB |
| bgm_settlement.ogg / .m4a | OGG | AAC | OGG | 0:30 | No | ≈ 480 KB |
| bgm_mvp_fanfare.ogg / .m4a | OGG | AAC | OGG | 0:20 | No | ≈ 320 KB |
| bgm_jackpot_climax.ogg / .m4a | OGG | AAC | OGG | 1:30 | No | ≈ 1.4 MB |

**BGM 總計（OGG 版本）：≈ 17.5 MB**（流式載入，不全部預載入記憶體）

**BGM Overlay 音軌（自適應音樂系統用）：**

| 檔案名稱 | 關聯主曲 | 時長 | 備注 |
|---------|---------|------|------|
| bgm_normal_room_overlay_mid.ogg | bgm_normal_room | 4:00 | 中等密度疊加層 |
| bgm_normal_room_overlay_high.ogg | bgm_normal_room | 4:00 | 高密度疊加層 |
| bgm_elite_room_overlay_mid.ogg | bgm_elite_room | 3:30 | 同上 |
| bgm_elite_room_overlay_high.ogg | bgm_elite_room | 3:30 | 同上 |
| bgm_jackpot_buildup_layer.ogg | 任意遊戲場景 | 60s | Jackpot 80% 觸發，循環 |

### 4.2 SFX 規格表

| SFX ID | 檔案名稱 | 格式 | 時長 | 大小（估算）| 預載入 |
|--------|---------|------|------|-----------|-------|
| SFX-001 | sfx_shoot_normal.ogg | OGG Mono 44.1kHz 16bit | 0.2s | ≈ 10 KB | Yes |
| SFX-002 | sfx_shoot_laser.ogg | OGG Mono 44.1kHz 16bit | 0.5s | ≈ 25 KB | Yes |
| SFX-003 | sfx_shoot_scatter.ogg | OGG Mono 44.1kHz 16bit | 0.3s | ≈ 15 KB | Yes |
| SFX-004 | sfx_hit_normal.ogg | OGG Mono 44.1kHz 16bit | 0.1s | ≈ 5 KB | Yes |
| SFX-005 | sfx_hit_elite.ogg | OGG Mono 44.1kHz 16bit | 0.2s | ≈ 10 KB | Yes |
| SFX-006 | sfx_hit_boss.ogg | OGG Mono 44.1kHz 16bit | 0.3s | ≈ 15 KB | Yes |
| SFX-007 | sfx_fish_die_normal.ogg | OGG Mono 44.1kHz 16bit | 0.5s | ≈ 25 KB | Yes |
| SFX-008 | sfx_fish_die_elite.ogg | OGG Mono 44.1kHz 16bit | 0.8s | ≈ 40 KB | Yes |
| SFX-009 | sfx_boss_appear.ogg | OGG Mono 44.1kHz 16bit | 2.0s | ≈ 100 KB | Yes |
| SFX-010 | sfx_boss_die.ogg | OGG Mono 44.1kHz 16bit | 3.0s | ≈ 150 KB | Yes |
| SFX-011 | sfx_boss_escape.ogg | OGG Mono 44.1kHz 16bit | 0.8s | ≈ 40 KB | Yes |
| SFX-012 | sfx_coin_collect.ogg | OGG Mono 44.1kHz 16bit | 0.3s | ≈ 15 KB | Yes |
| SFX-013 | sfx_coin_stream.ogg | OGG Mono 44.1kHz 16bit | 2.0s | ≈ 100 KB | Yes |
| SFX-014 | sfx_jackpot_trigger.ogg | OGG Stereo 44.1kHz 16bit | 5.0s | ≈ 500 KB | Yes |
| SFX-015 | sfx_jackpot_rollup.ogg | OGG Mono 44.1kHz 16bit | 3.0s | ≈ 150 KB | Yes |
| SFX-016 | sfx_skill_freeze.ogg | OGG Mono 44.1kHz 16bit | 1.0s | ≈ 50 KB | Yes |
| SFX-017 | sfx_skill_bomb.ogg | OGG Mono 44.1kHz 16bit | 1.5s | ≈ 75 KB | Yes |
| SFX-018 | sfx_skill_lock.ogg | OGG Mono 44.1kHz 16bit | 0.5s | ≈ 25 KB | Yes |
| SFX-019 | sfx_combo_low.ogg | OGG Mono 44.1kHz 16bit | 0.3s | ≈ 15 KB | Yes |
| SFX-020 | sfx_combo_high.ogg | OGG Mono 44.1kHz 16bit | 0.5s | ≈ 25 KB | Yes |
| SFX-021 | sfx_mvp_award.ogg | OGG Mono 44.1kHz 16bit | 1.5s | ≈ 75 KB | Yes |
| SFX-022 | sfx_steal_kill.ogg | OGG Mono 44.1kHz 16bit | 0.6s | ≈ 30 KB | Yes |
| SFX-101 | sfx_btn_click_primary.ogg | OGG Mono 44.1kHz 16bit | 0.1s | ≈ 5 KB | Yes |
| SFX-102 | sfx_btn_click_secondary.ogg | OGG Mono 44.1kHz 16bit | 0.1s | ≈ 5 KB | Yes |
| SFX-103 | sfx_btn_hover.ogg | OGG Mono 44.1kHz 16bit | 0.08s | ≈ 4 KB | Yes |
| SFX-104 | sfx_btn_disabled.ogg | OGG Mono 44.1kHz 16bit | 0.1s | ≈ 5 KB | Yes |
| SFX-105 | sfx_dialog_open.ogg | OGG Mono 44.1kHz 16bit | 0.2s | ≈ 10 KB | Yes |
| SFX-106 | sfx_dialog_close.ogg | OGG Mono 44.1kHz 16bit | 0.2s | ≈ 10 KB | Yes |
| SFX-107 | sfx_tab_switch.ogg | OGG Mono 44.1kHz 16bit | 0.12s | ≈ 6 KB | Yes |
| SFX-108 | sfx_slider_drag.ogg | OGG Mono 44.1kHz 16bit | 0.05s | ≈ 3 KB | Yes |
| SFX-109 | sfx_toggle_on.ogg | OGG Mono 44.1kHz 16bit | 0.15s | ≈ 8 KB | Yes |
| SFX-110 | sfx_toggle_off.ogg | OGG Mono 44.1kHz 16bit | 0.15s | ≈ 8 KB | Yes |
| SFX-111 | sfx_match_found.ogg | OGG Mono 44.1kHz 16bit | 0.8s | ≈ 40 KB | Yes |
| SFX-112 | sfx_match_countdown.ogg | OGG Mono 44.1kHz 16bit | 0.1s | ≈ 5 KB | Yes |
| SFX-113 | sfx_error.ogg | OGG Mono 44.1kHz 16bit | 0.3s | ≈ 15 KB | Yes |
| SFX-114 | sfx_notification.ogg | OGG Mono 44.1kHz 16bit | 0.25s | ≈ 12 KB | Yes |
| SFX-115 | sfx_vip_upgrade.ogg | OGG Stereo 44.1kHz 16bit | 2.0s | ≈ 200 KB | Yes |
| SFX-116 | sfx_purchase_success.ogg | OGG Mono 44.1kHz 16bit | 0.8s | ≈ 40 KB | Yes |
| SFX-117 | sfx_diamond_credited.ogg | OGG Mono 44.1kHz 16bit | 1.0s | ≈ 50 KB | Yes |
| SFX-118 | sfx_timer_alert.ogg | OGG Mono 44.1kHz 16bit | 0.3s | ≈ 15 KB | Yes |
| SFX-119 | sfx_jackpot_nearfull.ogg | OGG Mono 44.1kHz 16bit | 0.5s | ≈ 25 KB | Yes |
| SFX-120 | sfx_rank_up.ogg | OGG Mono 44.1kHz 16bit | 0.4s | ≈ 20 KB | Yes |
| SFX-121 | sfx_payment_error.ogg | OGG Mono 44.1kHz 16bit | 0.5s | ≈ 25 KB | Yes |
| AMB-001 | amb_ocean_base.ogg | OGG Stereo 44.1kHz 16bit | 60s | ≈ 1.8 MB | 流式 |
| AMB-002 | amb_bubbles.ogg | OGG Stereo 44.1kHz 16bit | 5s | ≈ 150 KB | Yes |
| AMB-003 | amb_water_flow.ogg | OGG Stereo 44.1kHz 16bit | 30s | ≈ 900 KB | 流式 |
| AMB-004 | amb_fish_school.ogg | OGG Stereo 44.1kHz 16bit | 8s | ≈ 240 KB | Lazy |
| AMB-005 | amb_boss_room.ogg | OGG Stereo 44.1kHz 16bit | 20s | ≈ 600 KB | Lazy |
| AMB-006 | amb_casino_lounge.ogg | OGG Stereo 44.1kHz 16bit | 30s | ≈ 900 KB | Lazy |
| AMB-007 | amb_lobby_ocean.ogg | OGG Stereo 44.1kHz 16bit | 45s | ≈ 1.35 MB | 流式 |

**SFX 總快取估算：≈ 6.5 MB**（預載入項目）
**環境音效流式項目：≈ 4.0 MB**（不計入快取預算）

### 4.3 語音規格 (VO)

語音系統（VO）列為 P1 功能，MVP 版本預留架構介面，Phase 2 正式實作。

**語音類型規劃（Phase 2）：**

| VO ID | 觸發場景 | 腳本範例（繁中）| 腳本範例（泰文）| 格式 |
|-------|---------|-------------|-------------|------|
| VO-001 | 新手引導開始 | 「歡迎來到深海競技場！」| 「ยินดีต้อนรับสู่สนามแข่งขันใต้ทะเลลึก！」| OGG Mono 22kHz |
| VO-002 | Jackpot 觸發 | 「Jackpot！頭獎爆出！」| 「แจ็คพอต！รางวัลใหญ่！」| OGG Mono 22kHz |
| VO-003 | MVP 宣告 | 「本局 MVP 誕生！」| 「MVP ของเกมนี้！」| OGG Mono 22kHz |
| VO-004 | Boss 進場 | 「警告！Boss 出現！」| 「คำเตือน！บอสปรากฏตัว！」| OGG Mono 22kHz |
| VO-005 | VIP 升級 | 「恭喜升級 VIP！」| 「ยินดีด้วย VIP！」| OGG Mono 22kHz |

**語音本地化優先順序（依目標市場）：**
1. 繁體中文（台灣，Persona A 主要市場）
2. 泰文（東南亞，Persona B 主要市場）
3. 越南文（Persona C 市場擴展）
4. 英文（通用備選）

---

## 5. 技術實作

### 5.1 Cocos Creator AudioManager

AudioManager 為全局單例，掛載於常駐場景節點，負責管理所有 BGM、SFX、VO 的生命週期。

```typescript
// audio/AudioManager.ts
import { _decorator, Component, AudioSource, AudioClip, Node, game } from 'cc';
const { ccclass, property } = _decorator;

export interface AudioSettings {
  bgmEnabled: boolean;
  sfxEnabled: boolean;
  bgmVolume: number;   // 0.0 – 1.0
  sfxVolume: number;   // 0.0 – 1.0
}

@ccclass('AudioManager')
export class AudioManager extends Component {
  private static _instance: AudioManager | null = null;
  private _bgmSource: AudioSource | null = null;
  private _sfxPool: Map<string, AudioSource[]> = new Map();
  private _ambientSources: AudioSource[] = [];
  private _settings: AudioSettings = {
    bgmEnabled: true,
    sfxEnabled: true,
    bgmVolume: 0.8,
    sfxVolume: 1.0,
  };
  private _isAudioUnlocked: boolean = false;
  private _pendingBGM: string | null = null;

  static getInstance(): AudioManager {
    return AudioManager._instance!;
  }

  protected onLoad(): void {
    if (AudioManager._instance) {
      this.node.destroy();
      return;
    }
    AudioManager._instance = this;
    game.addPersistRootNode(this.node);
    this.loadSettings();
    this._initAudioSources();
  }

  // ── BGM ─────────────────────────────────────────────────────────────

  playBGM(bgmId: string, fadeDuration: number = 500): void {
    if (!this._isAudioUnlocked) {
      // 未解鎖時暫存，解鎖後自動播放
      this._pendingBGM = bgmId;
      return;
    }
    if (!this._settings.bgmEnabled) return;
    this._crossfadeBGM(bgmId, fadeDuration);
  }

  stopBGM(fadeDuration: number = 500): void {
    if (!this._bgmSource) return;
    this._fadeVolume(this._bgmSource, 0, fadeDuration, () => {
      this._bgmSource!.stop();
    });
  }

  setBGMVolume(volume: number): void {
    this._settings.bgmVolume = Math.max(0, Math.min(1, volume));
    if (this._bgmSource) {
      this._bgmSource.volume = this._settings.bgmVolume;
    }
    this.saveSettings();
  }

  duckBGM(targetVolume: number, fadeDuration: number): void {
    if (this._bgmSource) {
      this._fadeVolume(this._bgmSource, targetVolume * this._settings.bgmVolume, fadeDuration);
    }
  }

  restoreBGMVolume(fadeDuration: number): void {
    if (this._bgmSource) {
      this._fadeVolume(this._bgmSource, this._settings.bgmVolume, fadeDuration);
    }
  }

  // ── SFX ─────────────────────────────────────────────────────────────

  playSFX(sfxId: string, pitch: number = 1.0): void {
    if (!this._settings.sfxEnabled) return;
    const source = this._acquireSFXSource(sfxId);
    if (!source) return; // 超出並發上限
    source.volume = this._settings.sfxVolume;
    // Cocos Creator 3.x 使用 AudioSource.pitch（需確認版本支援）
    (source as any).pitch = pitch;
    source.play();
  }

  stopSFX(sfxId: string): void {
    const sources = this._sfxPool.get(sfxId);
    sources?.forEach(s => s.playing && s.stop());
  }

  setSFXVolume(volume: number): void {
    this._settings.sfxVolume = Math.max(0, Math.min(1, volume));
    this.saveSettings();
  }

  // ── Stingers（不可中斷優先級） ───────────────────────────────────────

  async playStinger(stingerId: string): Promise<void> {
    return new Promise<void>((resolve) => {
      const source = this._acquireSFXSource(stingerId);
      if (!source) { resolve(); return; }
      source.volume = this._settings.sfxVolume;
      source.play();
      // 等待 Stinger 播放完畢
      const checkInterval = this.schedule(() => {
        if (!source.playing) {
          this.unschedule(checkInterval as unknown as () => void);
          resolve();
        }
      }, 0.05);
    });
  }

  // ── 音效解鎖（Web AudioContext）──────────────────────────────────────

  unlockAudio(): void {
    if (this._isAudioUnlocked) return;
    this._isAudioUnlocked = true;
    // 播放靜音緩衝，確保 AudioContext 解鎖
    this._playUnlockBuffer();
    // 播放等待中的 BGM
    if (this._pendingBGM) {
      this.playBGM(this._pendingBGM, 1000);
      this._pendingBGM = null;
    }
  }

  // ── 設定 ─────────────────────────────────────────────────────────────

  toggleBGM(enabled: boolean): void {
    this._settings.bgmEnabled = enabled;
    if (!enabled) this.stopBGM(300);
    else if (this._pendingBGM) this.playBGM(this._pendingBGM);
    this.saveSettings();
  }

  toggleSFX(enabled: boolean): void {
    this._settings.sfxEnabled = enabled;
    this.saveSettings();
  }

  saveSettings(): void {
    localStorage.setItem('fishgame_audio_settings', JSON.stringify(this._settings));
  }

  loadSettings(): void {
    const stored = localStorage.getItem('fishgame_audio_settings');
    if (stored) {
      try {
        this._settings = { ...this._settings, ...JSON.parse(stored) };
      } catch {
        // 讀取失敗使用預設值
      }
    }
  }

  getSettings(): Readonly<AudioSettings> {
    return { ...this._settings };
  }

  // ── 私有方法 ──────────────────────────────────────────────────────────

  private _crossfadeBGM(bgmId: string, duration: number): void {
    // 具體實現：載入新 BGM AudioClip → 淡出舊 → 淡入新
    // 略（由資源管理系統非同步載入）
  }

  private _fadeVolume(
    source: AudioSource,
    targetVolume: number,
    duration: number,
    onComplete?: () => void,
  ): void {
    // 使用 Tween 漸變音量
    // 略
  }

  private _acquireSFXSource(sfxId: string): AudioSource | null {
    // 從音效池取得可用 AudioSource，超出限制回傳 null
    return this._sfxPool.get(sfxId)?.find(s => !s.playing) ?? null;
  }

  private _initAudioSources(): void {
    // 初始化 BGM AudioSource 和 SFX Pool
  }

  private _playUnlockBuffer(): void {
    // 播放無聲緩衝解鎖 AudioContext
  }
}
```

### 5.2 音效池管理

音效池（Audio Pool）預先建立固定數量的 `AudioSource` 元件，避免執行期動態建立節點造成 GC 壓力。

#### 並發上限配置

| 音效類別 | 並發上限 | 超出策略 |
|---------|---------|---------|
| 射擊音效（sfx_shoot_*）| 8 | 最舊的丟棄（Oldest-First Drop）|
| 命中音效（sfx_hit_*）| 16 | 最舊的丟棄 |
| 魚死亡音效（sfx_fish_die_*）| 8 | 最舊的丟棄 |
| Stinger（sfx_boss_appear, sfx_jackpot_trigger）| 1（每種）| 不可中斷，新請求等待 |
| 技能音效（sfx_skill_*）| 2（每種）| 重置播放起點 |
| UI 音效（sfx_btn_*, sfx_dialog_*）| 4 | 最舊的丟棄 |
| 環境音效（amb_*）| 2（通道）| 替換舊通道 |
| **合計通道數上限** | **32** | — |

```typescript
// audio/SFXPool.ts — 音效池實作要點

interface PoolEntry {
  sources: AudioSource[];
  maxConcurrent: number;
  dropPolicy: 'oldest' | 'reject' | 'restart';
}

const SFX_POOL_CONFIG: Record<string, Pick<PoolEntry, 'maxConcurrent' | 'dropPolicy'>> = {
  sfx_shoot_normal:    { maxConcurrent: 8,  dropPolicy: 'oldest' },
  sfx_shoot_laser:     { maxConcurrent: 4,  dropPolicy: 'oldest' },
  sfx_shoot_scatter:   { maxConcurrent: 4,  dropPolicy: 'oldest' },
  sfx_hit_normal:      { maxConcurrent: 16, dropPolicy: 'oldest' },
  sfx_hit_elite:       { maxConcurrent: 8,  dropPolicy: 'oldest' },
  sfx_hit_boss:        { maxConcurrent: 4,  dropPolicy: 'oldest' },
  sfx_boss_appear:     { maxConcurrent: 1,  dropPolicy: 'reject' },
  sfx_jackpot_trigger: { maxConcurrent: 1,  dropPolicy: 'reject' },
  sfx_boss_die:        { maxConcurrent: 1,  dropPolicy: 'reject' },
  // ... 其餘音效
};
```

#### 隨機音高實作

```typescript
// 命中音效隨機音高（0.9–1.1），維持聽覺新鮮感
function playHitSFX(sfxId: string): void {
  const pitch = 0.9 + Math.random() * 0.2; // [0.9, 1.1]
  AudioManager.getInstance().playSFX(sfxId, pitch);
}

// 金幣收集音高隨倍率線性升高
function playCoinSFX(multiplier: number): void {
  const maxMultiplier = 1000;
  const minPitch = 1.0;
  const maxPitch = 2.0;
  const pitch = minPitch + (Math.min(multiplier, maxMultiplier) / maxMultiplier) * (maxPitch - minPitch);
  AudioManager.getInstance().playSFX('sfx_coin_collect', pitch);
}
```

### 5.3 空間音效 (2D/3D)

本遊戲為固定視角 2D 俯視競技場景，採用**偽 2D 空間音效**（Pseudo-2D Spatialization），不使用 3D AudioListener：

| 音效類型 | 空間化方式 | 實作 |
|---------|----------|------|
| 魚死亡音效 | 基於螢幕 X 座標左右聲道平移（Pan）| `panning = (fishScreenX / screenWidth) * 2 - 1` → 左 -1 / 右 +1 |
| 砲彈命中音效 | 同上 | 依命中點 X 座標計算 |
| Boss 音效 | 置中（Pan = 0），低頻強化 | Boss 佔螢幕中央 44%（VDD §4.2）|
| Jackpot / MVP 音效 | 置中 Stereo（全景）| 重大事件不空間化，確保全場感知 |
| UI 音效 | 無空間化 | 永遠置中 |
| BGM / 環境音效 | Stereo 置中 | 流式播放 |

```typescript
// 偽 2D Pan 計算
function playPositionalSFX(sfxId: string, worldX: number): void {
  const canvas = cc.view.getVisibleSize();
  const screenX = worldX + canvas.width / 2; // 假設世界座標 0 = 螢幕中央
  const pan = (screenX / canvas.width) * 2 - 1; // -1（左）→ +1（右）
  const clampedPan = Math.max(-0.8, Math.min(0.8, pan)); // 限制極端 pan
  AudioManager.getInstance().playSFXWithPan(sfxId, 1.0, clampedPan);
}
```

### 5.4 音效壓縮與打包

#### Bundle 策略

| Bundle 名稱 | 內容 | 載入時機 | 記憶體預算 |
|------------|------|---------|----------|
| `audio-core` | sfx_shoot_*, sfx_hit_*, sfx_fish_die_*, sfx_coin_collect, UI SFX 全部 | 遊戲首次載入（Splash）| ≤ 3 MB |
| `audio-events` | sfx_boss_*, sfx_jackpot_*, sfx_skill_*, sfx_vip_upgrade, sfx_mvp_award | 進入遊戲房間前預載 | ≤ 5 MB |
| `audio-ambient` | amb_ocean_base, amb_lobby_ocean, amb_water_flow | 流式播放，不完整預載 | ≤ 2 MB |
| `audio-ambient-lazy` | amb_boss_room, amb_casino_lounge, amb_fish_school | 懶載入（進入對應場景時）| ≤ 2 MB |
| `audio-bgm` | 所有 bgm_*.ogg | 流式播放 | ≤ 2 MB（任何時刻最多 1–2 首在記憶體）|

**音效壓縮設定（Cocos Creator Build 設定）：**

```json
{
  "audio": {
    "forceOGG": true,
    "quality": 0.7,
    "sampleRate": 44100,
    "channels": "mono-where-possible"
  }
}
```

---

## 6. 平台適配

### 6.1 Web / H5 AudioContext

**核心問題：** 瀏覽器（Chrome 66+、Safari 11+）要求 AudioContext 必須在用戶手勢（touch / click）之後才能啟動。

**解決方案架構：**

```typescript
// 掛載在 Splash Scene 的 AudioUnlockHandler
@ccclass('AudioUnlockHandler')
export class AudioUnlockHandler extends Component {
  protected onLoad(): void {
    // 監聽首次互動事件（touchstart 優先，確保 iOS 相容）
    document.addEventListener('touchstart', this._onFirstInteraction, { once: true, passive: true });
    document.addEventListener('mousedown', this._onFirstInteraction, { once: true });
  }

  private _onFirstInteraction = (): void => {
    AudioManager.getInstance().unlockAudio();
    // 清除監聽器
    document.removeEventListener('touchstart', this._onFirstInteraction);
    document.removeEventListener('mousedown', this._onFirstInteraction);
  };
}
```

**視覺補償設計（AudioContext 解鎖前）：**
- Splash 畫面播放品牌 Logo 動畫（VDD §3.5）
- 顯示「點擊任意位置開始」提示（無文字，圖示引導）
- 玩家點擊後 AudioContext 解鎖，BGM 開始淡入

**已知 Web 音頻限制：**

| 限制 | 影響 | 對策 |
|------|------|------|
| Safari AudioContext 並發 4 個通道上限（舊版）| 射擊密集時音效丟失 | 音效池優先級：Stinger > SFX > 環境音 |
| Chrome 自動播放政策 | 頁面載入後 BGM 靜音 | unlockAudio() + pendingBGM 機制 |
| iOS Safari 音頻 interruption（電話 / Siri）| BGM 突然中斷 | 監聽 `pagehide` / `visibilitychange` 事件暫停恢復 |
| 記憶體限制（低端 Android）| OOM 崩潰風險 | audio-ambient-lazy 懶載入 + BGM 流式播放 |

### 6.2 iOS 靜音模式

iOS 靜音撥片啟用時，系統音頻全部靜音，但 **遊戲視覺回饋不受影響**。

**靜音模式回饋補償設計：**

| 遊戲事件 | 靜音模式補償視覺 |
|---------|----------------|
| 射擊命中 | 炮口橘焰光暈（VDD §4.1 Fire 特效，120ms）|
| 魚死亡 | 爆炸粒子特效（VDD §4.2 死亡特效，300–500ms）|
| Jackpot 觸發 | 全屏金色爆炸特效（VDD §4.3，≥ 3000ms）|
| Boss 出現 | 全屏震動 2s（VDD §2.4，device.vibrate 200ms）|
| VIP 升級 | 光暈動畫啟動（VDD §3.4）|
| 按鈕點擊 | 按鈕 scale(0.98) → scale(1.03) 彈跳回饋（PDD §4）|

**iOS 振動回饋（Haptic Feedback）：**

```typescript
// HapticManager.ts — iOS 振動
export class HapticManager {
  static light(): void {
    if ('vibrate' in navigator) navigator.vibrate(10);
  }
  static medium(): void {
    if ('vibrate' in navigator) navigator.vibrate(50);
  }
  static heavy(): void {
    if ('vibrate' in navigator) navigator.vibrate([100, 50, 100]);
  }
  
  // 對應遊戲事件
  static onShoot(): void { HapticManager.light(); }
  static onFishDie(): void { HapticManager.medium(); }
  static onBossAppear(): void { HapticManager.heavy(); }
  static onJackpot(): void { HapticManager.heavy(); }
}
```

**技術備注：** iOS Safari 的振動 API 支援有限，`navigator.vibrate()` 在部分 iOS 版本無效。建議搭配 Native Bridge（Phase 2 iOS App 版本）實作 UIImpactFeedbackGenerator。

### 6.3 Android 音頻焦點

Android 系統的音頻焦點（Audio Focus）機制會在其他 App 播放音頻時中斷遊戲 BGM。

**音頻焦點處理策略：**

```typescript
// 監聽 App 生命週期管理音頻焦點
export class AppLifecycleAudioHandler {
  static init(): void {
    // Cocos Creator 3.x 生命週期事件
    game.on(Game.EVENT_HIDE, AppLifecycleAudioHandler._onBackground);
    game.on(Game.EVENT_SHOW, AppLifecycleAudioHandler._onForeground);
  }

  private static _bgmVolumeBeforePause = 0;

  private static _onBackground(): void {
    const am = AudioManager.getInstance();
    AppLifecycleAudioHandler._bgmVolumeBeforePause = am.getSettings().bgmVolume;
    am.setBGMVolume(0); // 靜音（不停止，避免重新播放的延遲）
  }

  private static _onForeground(): void {
    const am = AudioManager.getInstance();
    am.setBGMVolume(AppLifecycleAudioHandler._bgmVolumeBeforePause);
  }
}
```

**Android 音頻延遲（Audio Latency）注意事項：**
- Android 低端裝置（< 4GB RAM）可能存在 30–80ms 額外音頻延遲
- 射擊音效（SFX-001）需確保在 < 80ms 總延遲內播放（包含 16ms 目標 + 64ms 裝置容差）
- 環境音效（AMB）可接受較高延遲，不影響遊戲體驗

---

## 7. 玩家偏好設定

### 7.1 音量控制

音量控制介面設計於設定面板（PDD §5.10 SettingScene），採分離音量控制策略。

| 控制項 | 範圍 | 預設值 | 控制 UI |
|-------|------|--------|---------|
| 主音量（Master Volume）| 0–100% | 80% | 滑動條 + 數值顯示 |
| BGM 音量 | 0–100% | 80% | 滑動條（受主音量影響）|
| SFX 音量 | 0–100% | 100% | 滑動條（受主音量影響）|
| 語音音量（VO，Phase 2）| 0–100% | 100% | 滑動條 |

**音量關係：**
```
實際 BGM 音量 = masterVolume × bgmVolume
實際 SFX 音量 = masterVolume × sfxVolume
```

**即時預覽：** 拖動音量滑動條時（PDD §5.10 設計，SFX-108 sfx_slider_drag），即時更新播放中音效音量，讓玩家立即感知變化，無需退出設定面板。

**持久化方案：**

```typescript
// 儲存至 localStorage（Web）/ PlayerPrefs（Native，Phase 2）
const AUDIO_SETTINGS_KEY = 'fishgame_audio_settings';

interface AudioSettingsStorage {
  masterVolume: number;
  bgmVolume: number;
  sfxVolume: number;
  bgmEnabled: boolean;
  sfxEnabled: boolean;
  version: number; // 版本號，用於遷移
}
```

### 7.2 音效開關

| 開關項目 | 預設 | 說明 |
|---------|------|------|
| BGM 開關 | ON | 關閉時停止 BGM，開啟時從當前場景 BGM 淡入 |
| SFX 開關 | ON | 關閉時靜音所有 SFX（含 UI 音效），環境音效不受影響 |
| 環境音效開關 | ON | 獨立控制環境音效，不影響遊戲核心 SFX |
| 語音開關（VO，Phase 2）| ON | 獨立控制播報員語音 |

**注意：** 環境音效（AMB-001 至 AMB-007）設計為增強沉浸感，不建議預設關閉。環境音效音量固定為 SFX 音量的 30%，即使 SFX 音量較高也不會遮蓋遊戲核心音效。

**操作回饋一致性：**
- 切換 BGM 開關時播放 sfx_toggle_on / sfx_toggle_off（即使 SFX 已關閉，此操作確認音效仍播放一次，讓玩家知道切換生效）
- 音量拖動期間播放 sfx_slider_drag（拖動步進每 5% 觸發一次）

---

## 8. 效能最佳化

### 8.1 記憶體管理

**記憶體預算：**

| 類別 | 預算上限 | 說明 |
|------|---------|------|
| BGM（流式，最多 1–2 首同時在記憶體）| < 2 MB | 流式載入，播放完即釋放 |
| SFX 快取（audio-core + audio-events）| < 8 MB | 預載入，常駐記憶體 |
| 環境音效快取（非流式部分）| < 4 MB | amb_bubbles + amb_fish_school 等短片段 |
| 環境音效流式（amb_ocean_base 等）| < 1 MB（緩衝區）| 流式讀取，不全部載入 |
| **音頻總計** | **< 15 MB** | 目標：< 15 MB |

**記憶體釋放策略：**

```typescript
// 場景切換時釋放不再需要的音效資源
export class SceneAudioManager {
  private static readonly PERSISTENT_SFX = [
    'sfx_shoot_normal', 'sfx_hit_normal', 'sfx_coin_collect',
    'sfx_btn_click_primary', 'sfx_dialog_open', 'sfx_dialog_close',
    // 核心 SFX 常駐，其餘場景切換時釋放
  ];

  static onSceneUnload(sceneName: string): void {
    // 釋放非常駐音效資源
    // BGM 流式資源隨場景釋放
  }

  static preloadForScene(sceneName: string): Promise<void> {
    const sfxList = SCENE_SFX_MAP[sceneName] ?? [];
    return AudioManager.getInstance().preloadSFXBatch(sfxList);
  }
}

const SCENE_SFX_MAP: Record<string, string[]> = {
  'GameScene':      ['sfx_boss_appear', 'sfx_boss_die', 'sfx_jackpot_trigger', 'sfx_skill_freeze', 'sfx_skill_bomb', 'sfx_skill_lock', 'sfx_mvp_award'],
  'ShopScene':      ['sfx_purchase_success', 'sfx_diamond_credited', 'sfx_payment_error'],
  'SettlementScene': ['sfx_mvp_award', 'sfx_jackpot_rollup'],
};
```

### 8.2 音頻預載策略

**三級載入策略：**

```
Level 1 — 首次啟動預載（Splash 畫面期間，無阻塞）
  目標：audio-core bundle（≤ 3 MB）
  內容：sfx_shoot_*, sfx_hit_*, sfx_coin_collect, 全部 UI SFX
  完成時間：< 3s（4G 網路）

Level 2 — 場景進入前預載（砲台選擇畫面 CannonSelectScene 期間）
  目標：audio-events bundle（≤ 5 MB）
  內容：sfx_boss_*, sfx_jackpot_*, sfx_skill_*, sfx_mvp_award
  完成時間：< 5s（4G 網路，配對等待 30s 內有充裕時間）

Level 3 — 懶載入（進入對應場景時，背景載入）
  目標：audio-ambient-lazy bundle（≤ 2 MB）
  內容：amb_boss_room, amb_casino_lounge
  觸發時機：進入 Boss 房間 / 商城場景

BGM — 流式播放（Streaming）
  播放前預取 2s 緩衝，無需全檔預載
  BGM 切換：提前 2s 預取下一個 BGM 頭部資料
```

**載入進度與用戶體驗：**
- Level 1 預載期間，Splash 動畫（bgm_splash 靜音播放）填充等待感
- Level 2 預載期間，砲台選擇 UI（CannonSelectScene）可正常互動，預載在背景執行
- 若預載未完成玩家已進入遊戲，使用 on-demand 載入（增加 < 100ms 延遲可接受）

---

## 9. 音效命名規範

### 9.1 命名格式

```
{類別前綴}_{場景/功能}_{動作/描述}[_{變體索引}]

類別前綴：
  bgm_    — 背景音樂
  sfx_    — 遊戲 / UI 音效
  amb_    — 環境音效
  vo_     — 語音
  sting_  — Stinger（短暫插入 BGM 的音效，≤ 5s）

場景/功能：
  shoot, hit, fish, boss, jackpot, skill, coin,
  btn, dialog, tab, slider, toggle, match,
  vip, purchase, rank, timer,
  ocean, bubbles, water, casino, lobby,
  main_menu, normal_room, elite_room, boss_battle, shop, settlement

動作/描述：
  normal, elite, boss, laser, scatter, freeze, bomb, lock,
  appear, die, escape, trigger, rollup, collect, stream,
  open, close, click, hover, on, off, found, countdown,
  upgrade, success, error, alert, nearfull, up, credited

變體索引（可選）：
  _01, _02 — 多個音高 / 音色變體（隨機選一播放）
```

### 9.2 命名範例

```
bgm_main_menu.ogg           — 主選單 BGM
bgm_boss_battle.ogg         — Boss 戰 BGM
sfx_shoot_normal.ogg        — 普通砲射擊
sfx_shoot_laser.ogg         — 雷射砲射擊
sfx_hit_normal.ogg          — 命中普通魚
sfx_fish_die_elite.ogg      — 精英魚死亡
sfx_boss_appear.ogg         — Boss 出現 Stinger
sfx_jackpot_trigger.ogg     — Jackpot 觸發 Stinger
sfx_skill_freeze.ogg        — 冰凍技能
sfx_btn_click_primary.ogg   — 主要按鈕點擊
sfx_dialog_open.ogg         — 對話框開啟
sfx_vip_upgrade.ogg         — VIP 升級
amb_ocean_base.ogg          — 海洋基礎環境音
amb_bubbles.ogg             — 氣泡環境音
vo_jackpot_zh.ogg           — Jackpot 語音（繁中版）
vo_jackpot_th.ogg           — Jackpot 語音（泰文版）
```

### 9.3 目錄結構

```
assets/
└── audio/
    ├── bgm/
    │   ├── bgm_main_menu.ogg
    │   ├── bgm_main_menu.m4a
    │   ├── bgm_normal_room.ogg
    │   ├── bgm_normal_room_overlay_mid.ogg
    │   ├── bgm_normal_room_overlay_high.ogg
    │   ├── bgm_elite_room.ogg
    │   ├── bgm_boss_battle.ogg
    │   ├── bgm_shop.ogg
    │   ├── bgm_settlement.ogg
    │   ├── bgm_mvp_fanfare.ogg
    │   ├── bgm_jackpot_climax.ogg
    │   └── bgm_jackpot_buildup_layer.ogg
    ├── sfx/
    │   ├── gameplay/
    │   │   ├── sfx_shoot_normal.ogg
    │   │   ├── sfx_shoot_laser.ogg
    │   │   ├── sfx_shoot_scatter.ogg
    │   │   ├── sfx_hit_normal.ogg
    │   │   ├── sfx_hit_elite.ogg
    │   │   ├── sfx_hit_boss.ogg
    │   │   ├── sfx_fish_die_normal.ogg
    │   │   ├── sfx_fish_die_elite.ogg
    │   │   ├── sfx_boss_appear.ogg
    │   │   ├── sfx_boss_die.ogg
    │   │   ├── sfx_boss_escape.ogg
    │   │   ├── sfx_coin_collect.ogg
    │   │   ├── sfx_coin_stream.ogg
    │   │   ├── sfx_jackpot_trigger.ogg
    │   │   ├── sfx_jackpot_rollup.ogg
    │   │   ├── sfx_skill_freeze.ogg
    │   │   ├── sfx_skill_bomb.ogg
    │   │   ├── sfx_skill_lock.ogg
    │   │   ├── sfx_combo_low.ogg
    │   │   ├── sfx_combo_high.ogg
    │   │   ├── sfx_mvp_award.ogg
    │   │   └── sfx_steal_kill.ogg
    │   └── ui/
    │       ├── sfx_btn_click_primary.ogg
    │       ├── sfx_btn_click_secondary.ogg
    │       ├── sfx_btn_hover.ogg
    │       ├── sfx_btn_disabled.ogg
    │       ├── sfx_dialog_open.ogg
    │       ├── sfx_dialog_close.ogg
    │       ├── sfx_tab_switch.ogg
    │       ├── sfx_slider_drag.ogg
    │       ├── sfx_toggle_on.ogg
    │       ├── sfx_toggle_off.ogg
    │       ├── sfx_match_found.ogg
    │       ├── sfx_match_countdown.ogg
    │       ├── sfx_error.ogg
    │       ├── sfx_notification.ogg
    │       ├── sfx_vip_upgrade.ogg
    │       ├── sfx_purchase_success.ogg
    │       ├── sfx_diamond_credited.ogg
    │       ├── sfx_timer_alert.ogg
    │       ├── sfx_jackpot_nearfull.ogg
    │       ├── sfx_rank_up.ogg
    │       └── sfx_payment_error.ogg
    ├── ambient/
    │   ├── amb_ocean_base.ogg
    │   ├── amb_bubbles.ogg
    │   ├── amb_water_flow.ogg
    │   ├── amb_fish_school.ogg
    │   ├── amb_boss_room.ogg
    │   ├── amb_casino_lounge.ogg
    │   └── amb_lobby_ocean.ogg
    └── vo/                         # Phase 2 語音
        ├── zh/
        │   ├── vo_welcome_zh.ogg
        │   ├── vo_jackpot_zh.ogg
        │   └── vo_mvp_zh.ogg
        └── th/
            ├── vo_welcome_th.ogg
            ├── vo_jackpot_th.ogg
            └── vo_mvp_th.ogg
```

---

## 10. 驗收標準

### 10.1 功能驗收

| 驗收項目 | 標準 | 測試方法 | 優先級 |
|---------|------|---------|-------|
| 射擊音效延遲 | < 16ms（目標），< 80ms（Android 低端裝置容差）| 音頻延遲測試工具（Web Audio Worklet 計時）| P0 |
| BGM 循環無縫 | 無明顯切點，耳聽 20 次連續循環無感知 | 耳聽測試 + DAW 波形對齊檢查 | P0 |
| Web AudioContext 解鎖 | 首次用戶互動後 < 100ms 開始播放 BGM | H5 瀏覽器測試（Chrome / Safari / Firefox）| P0 |
| iOS 靜音模式 | 靜音時有完整視覺回饋（爆炸特效 + 振動）| iPhone 實機靜音模式測試 | P0 |
| 並發音效無爆音 | 32 通道同時觸發無削波（Clipping）或爆音 | 壓力測試腳本（自動化射擊 100 次/秒）| P0 |
| 記憶體占用 | < 15 MB（SFX 快取），< 20 MB（含流式緩衝）| Chrome DevTools Memory Profiler / Android Profiler | P0 |
| BGM 自適應切換 | 魚群密度變化後 3s 內 BGM 強度對應調整 | 自動化功能測試（模擬魚群密度 5→20+）| P0 |
| Boss 音效不可中斷 | sfx_boss_appear / sfx_jackpot_trigger 播放中不被其他 SFX 中斷 | 測試腳本：Stinger 播放中觸發高頻射擊 | P0 |
| 設定持久化 | 重啟遊戲後音量設定正確恢復 | localStorage 讀寫測試 | P0 |
| 音效命名規範合規 | 所有音效檔案符合 §9.1 命名格式，無錯字 | 命名規範自動化掃描腳本 | P1 |
| 音高隨機化 | sfx_hit_normal 連續播放 20 次，音高分布在 0.9–1.1 範圍 | 頻譜分析工具 | P1 |
| 金幣倍率音高 | 1x 倍率 pitch=1.0，1000x 倍率 pitch=2.0，線性關係 | 自動化單元測試 | P1 |
| BGM Ducking | Stinger 播放期間 BGM 音量降低至 20%，結束後 800ms 恢復 | 音量計量測試 | P1 |
| Android 背景靜音 | App 切至背景時 BGM 靜音，回到前台後恢復 | Android 實機切換後台測試 | P1 |
| 語音本地化（Phase 2）| 繁中 / 泰文 VO 根據系統語言自動切換 | 語言切換功能測試 | P2 |

### 10.2 音頻品質驗收

| 驗收項目 | 標準 | 工具 |
|---------|------|------|
| 輸出電平（Loudness）| BGM：-14 LUFS（Streaming 標準）；SFX 峰值：< -6 dBFS | Loudness Meter（iZotope Insight / free tools）|
| 削波（Clipping）| 零削波（所有輸出峰值 < -0.1 dBFS）| True Peak Meter |
| 底噪（Noise Floor）| < -80 dBFS（無音效時）| 靜音片段量測 |
| BGM 迴圈點無縫 | 迴圈前後 0 crossing 對齊，波形連續 | DAW 波形觀測 |
| SFX 音色一致性 | 同類音效（不同 Variant）音色感知一致，無明顯品質落差 | 耳聽 A/B 測試 |
| 壓縮比特率 | OGG 128kbps 輸出感知品質可接受（A/B 對比原始 WAV 無明顯失真）| 耳聽 A/B 測試 |

### 10.3 效能驗收

| 驗收項目 | 標準 | 測試環境 |
|---------|------|---------|
| 首次載入時間（audio-core）| < 3s（4G 網路，< 3 MB bundle）| Chrome DevTools Network Throttle |
| 場景預載時間（audio-events）| < 5s（4G 網路，< 5 MB bundle）| 配對等待 30s 內完成 |
| SFX 播放延遲（觸發到出聲）| < 16ms（Chrome Desktop），< 80ms（低端 Android）| Web Audio API timing measurement |
| 記憶體（SFX 快取）| < 8 MB | Chrome Memory Panel |
| 記憶體（總音頻）| < 15 MB | Chrome / Android Profiler |
| BGM 流式緩衝延遲 | 首次播放 < 500ms，後續切換 < 1000ms | 計時測試 |
| CPU 占用（音頻相關）| < 5% CPU（60fps 遊戲進行中，低端 Android）| Android Profiler CPU |

### 10.4 跨平台驗收矩陣

| 測試項目 | Chrome（Desktop）| Chrome（Android）| Safari（iOS）| 測試優先級 |
|---------|-----------------|-----------------|-------------|----------|
| AudioContext 解鎖 | ✅ | ✅ | ✅（需 touchstart）| P0 |
| BGM 播放 + 循環 | ✅ | ✅ | ✅ | P0 |
| SFX 並發 16+ | ✅ | 需測試 | 需測試 | P0 |
| iOS 靜音模式補償 | N/A | N/A | ✅ 視覺振動 | P0 |
| 背景靜音 / 恢復 | ✅ | ✅ | ✅ | P0 |
| OGG 格式支援 | ✅ | ✅ | ✅（iOS 11+）| P0 |
| AAC 格式備用 | ✅ | ✅ | ✅ | P1 |
| 音量設定持久化 | ✅ | ✅ | ✅（Private Mode 除外）| P1 |

---

*本文件由 Audio Design（AI Generated）依據 PRD-FISHGAME-20260424、EDD-FISHGAME-20260424、PDD-FISHGAME-20260425、VDD-FISHGAME-20260425 生成。*
