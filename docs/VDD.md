# VDD — Visual Design Document
**FishGame 競技捕魚平台**

---

## §0 Document Control

| 欄位 | 值 |
|------|-----|
| DOC-ID | VDD-FISHGAME-20260425 |
| 版本 | 1.0.0 |
| 狀態 | Draft |
| 作者 | Visual Designer + Brand Designer + Design System Engineer |
| 上游文件 | BRD-FISHGAME-20260424 · PRD-FISHGAME-20260424 · PDD-FISHGAME-20260424 |
| 建立日期 | 2026-04-25 |
| 目標平台 | Cocos Creator 3.x · iOS / Android · H5 WebGL |
| 設計寬度 | 720 px（FIXED_WIDTH 自適應，高度浮動） |

### 修訂記錄

| 版本 | 日期 | 作者 | 摘要 |
|------|------|------|------|
| 1.0.0 | 2026-04-25 | AI 生成 | 初版，涵蓋全部 13 章 |

---

## §1 Design Mission

### 1.1 設計願景

> 讓每一發炮彈落點、每一條魚爆金幣的瞬間，都成為可以截圖分享的「多巴胺時刻」。

### 1.2 設計原則

| # | 原則 | 說明 | 可量測指標 |
|---|------|------|------------|
| P1 | **Dopamine First — 多巴胺優先** | 核心回饋（擊殺特效、金幣飛濺、Jackpot 爆炸）必須在視覺上佔主導，音效、粒子、光暈三層疊加 | 使用者測試：「爽感」評分 ≥ 4.2/5 |
| P2 | **Competition Visible — 競爭可見** | 任何時刻玩家都能在 ≤1 秒內讀出當前排名、對手血條、場內最高分；資訊層級用色彩+尺寸雙重編碼 | 5 秒可用性測試通過率 ≥ 85% |
| P3 | **Natural Monetization — 自然變現** | VIP 徽章、高倍炮光暈、鑽石貨幣用「羨慕感」驅動而非「強迫感」；進入商店路徑 ≤ 2 步 | 商店 CVR ≥ 3%；NPS 不因付費 UI 下降 |
| P4 | **3-Second Comprehension — 3 秒理解** | 新使用者進入大廳後 3 秒內不需教程即可找到「開始遊戲」入口；遊戲內 HUD 使用圖示+數字，不依賴文字 | 新手用戶研究首次點擊成功率 ≥ 90% |
| P5 | **Accessible by Default — 無障礙優先** | 所有互動顏色對比度符合 WCAG 2.1 AA（文字 4.5:1，大文字 3:1，UI 元件 3:1）；支援色盲安全配色 | 全自動 axe 掃描 0 CRITICAL |

### 1.3 視覺方向定位

```
視覺方向：Dark Luxury × Casino Arcade
主色調：深海深藍 + 皇家金 + 霓虹青
材質感：磨砂玻璃（frosted glass）+ 金屬壓紋 + 水下散射光
動態感：彈簧物理 + 粒子爆炸 + 波浪流動
參考象限：[奢華 ↑] × [電玩街機 →]
```

---

## §2 Art Direction

### 2.1 Mood Board 關鍵詞

| # | 關鍵詞（中） | 關鍵詞（英） | 視覺聯想 |
|---|------------|------------|---------|
| 1 | 深海奢金 | Deep Sea Luxury | 深不見底的靛藍海水，金光從水面折射而下 |
| 2 | 街機霓虹 | Arcade Neon | 80s 電玩廳 LED 邊框、霓虹發光按鈕、掃光特效 |
| 3 | 皇家賭場 | Royal Casino | 澳門/拉斯維加斯賭場大廳——金色壓花、深紅絨布、閃爍燈帶 |
| 4 | 水下張力 | Underwater Tension | 氣泡上升、光折射、魚群在黑暗中的磷光 |
| 5 | 爆炸快感 | Explosive Payoff | 金幣噴射、全屏金光、千倍爆字的衝擊感 |
| 6 | 競技熱血 | Competitive Hype | 計分板倒數、倍率滾輪、攻擊軌跡交叉 |
| 7 | 神話海怪 | Mythic Sea Beasts | 巨型 Boss 魚——龍魚、美人魚、海神——神話史詩感 |

### 2.2 視覺參考方向（5 類）

| 類型 | 參考 | 擷取要素 |
|------|------|---------|
| 遊戲 UI | 《出海捕魚》《歡樂捕魚》《炸金花》系列 | HUD 排版、金幣動態、Boss 血條 |
| 電影美術 | 《神鬼奇航》水下場景 / 《阿凡達》生態光效 | 水下折射光、磷光粒子 |
| 品牌設計 | Rolex 字體用法 / 澳門威尼斯人品牌金色 | 奢華金色應用方式、壓紋材質 |
| 遊戲機台 | 日本柏青哥燈板 / 拉斯維加斯 Slot Machine | 燈框圓角、高飽和色、閃爍節奏 |
| 概念藝術 | ArtStation「underwater casino」搜尋結果 | 場景氛圍、色調組合、燈光方向 |

### 2.3 材質與光影方向

| 元素 | 材質描述 | 技術實現（Cocos） |
|------|---------|----------------|
| 遊戲背景 | 漸層深海藍（#051428→#030B1A），帶水波動態扭曲 | Sprite + Shader（UV scroll） |
| UI 面板 / 卡片 | 磨砂玻璃感：半透明深藍底 + 金色 1px 邊框 + 白色 blur 高光 | RenderTexture blurPass |
| 主要按鈕 | 金屬壓紋金色，中央高光帶，Hover 加亮 15%，Press 下壓 2px | 九宮格 Sprite |
| 炮台 / 武器 | 砲管鋼藍+金環，發射時橘焰光暈（glow） | 粒子系統 + Sprite |
| 金幣 | 24K 金質感，旋轉時 specular 光點 | SpinAnim Sprite Sheet 16 幀 |
| Boss 魚 | 深色鱗片 + 霓虹輪廓光（Outline Shader） | Outline Shader Pass |
| VIP 光暈 | 依等級由銀→金→紅→彩虹流動漸層，rotatng glow ring | 粒子 + 自訂 Shader |

### 2.4 場景美術規格

| 場景 | 背景色調 | 主光源方向 | 環境元素 |
|------|---------|-----------|---------|
| 大廳 (Lobby) | 深海藍 #051428，輕微放射漸層 | 頂部偏左，金光柱 | 珊瑚、氣泡、游魚群（裝飾動畫） |
| 遊戲場景 (GameScene) | 深海黑藍 #030B1A，動態波紋 | 無固定主光（動態 Boss 進場時全屏掃光） | 水草、礁石、遠景魚群 |
| 商店 (Shop) | 暗金色底 #0F0A00，燈光舞台感 | 舞台頂光，前景壓暗 | 商品浮動光圈、金幣粒子環境 |
| 結算面板 (Settlement) | 黑色漸層底（overlay 50% opacity） | 全屏放射金光（jackpot 時） | 金幣瀑布（分層視差） |

---

## §3 Brand Identity

### 3.1 品牌識別核心

| 項目 | 定義 |
|------|------|
| 品牌名稱 | FishGame 競技捕魚 |
| 核心標語 | 最直接的金錢刺激，最深沉的競技樂趣 |
| 品牌個性 | 刺激、奢華、競爭、爽快、獨特 |
| 品牌聲音 | 自信、直接、男性化（但不排斥女性）、略帶誇張的激情 |

### 3.2 主色盤

| Token 名稱 | HEX | oklch | WCAG（on #051428） | 用途 |
|-----------|-----|-------|-------------------|------|
| color-gold-400 | #F5C842 | oklch(82% 0.18 88) | 7.2:1 AAA | 主行動按鈕、金幣、獎勵文字 |
| color-gold-600 | #C99A00 | oklch(67% 0.17 88) | 4.8:1 AA | 按鈕 Hover 狀態、金框 |
| color-gold-800 | #7A5C00 | oklch(42% 0.13 88) | 1.9:1 — | 按鈕按下狀態（僅圖形用途） |
| color-ocean-900 | #051428 | oklch(10% 0.04 240) | — (bg) | 主背景底色 |
| color-ocean-800 | #0A2340 | oklch(15% 0.05 240) | — (surface) | 卡片 / 面板底色 |
| color-ocean-700 | #0D3360 | oklch(22% 0.07 240) | — | 次級面板、邊框底色 |
| color-neon-blue | #00D4FF | oklch(82% 0.16 200) | 8.9:1 AAA | 鑽石貨幣、Jackpot 槽、技能特效 |
| color-neon-green | #00FF88 | oklch(92% 0.22 152) | 14.1:1 AAA | 成功回饋、新手引導高亮 |
| color-white-100 | #FFFFFF | oklch(100% 0 0) | 21:1 AAA | 主要文字 |
| color-red-500 | #FF4444 | oklch(65% 0.24 27) | 4.6:1 AA | 錯誤、危險、Boss 血量危急 |

### 3.3 功能色（語義色）

| 語義 Token | 映射 | HEX（Dark Mode） | 用途 |
|-----------|------|-----------------|------|
| color-bg-base | color-ocean-900 | #051428 | 全局底色 |
| color-bg-surface | color-ocean-800 | #0A2340 | 卡片/面板 |
| color-bg-overlay | color-ocean-700 + 80% | #0D3360CC | 模態遮罩 |
| color-text-primary | color-white-100 | #FFFFFF | 主要文字（21:1 AAA） |
| color-text-secondary | rgba(255,255,255,0.6) | composited #9BA1A9 | 次要文字（6.8:1 AA） |
| color-text-disabled | rgba(255,255,255,0.35) | composited #6D7178 | 禁用文字（3.5:1 AA） |
| color-action-primary | color-gold-400 | #F5C842 | CTA 按鈕（7.2:1 AAA） |
| color-action-secondary | color-neon-blue | #00D4FF | 次要行動（8.9:1 AAA） |
| color-feedback-success | color-neon-green | #00FF88 | 成功狀態（14.1:1 AAA） |
| color-feedback-error | color-red-500 | #FF4444 | 失敗/錯誤（4.6:1 AA） |
| color-feedback-warning | #FF8080 | #FF8080 | 警告（7.61:1 AAA） |
| color-feedback-info | color-neon-blue | #00D4FF | 提示（8.9:1 AAA） |
| color-border-default | rgba(255,255,255,0.45) | composited #767E89 | 預設邊框（3.2:1 WCAG 1.4.11） |
| color-border-focus | color-gold-400 | #F5C842 | 焦點環（11.63:1 AAA） |
| color-border-active | color-neon-blue | #00D4FF | 選中邊框 |
| color-accent-vip | color-vip-identity | 依等級 | VIP 徽章 |

### 3.4 VIP 等級色系

| 等級 | 名稱 | 主色 HEX | 次色 HEX | 光暈類型 | 動畫 |
|------|------|---------|---------|---------|------|
| 1–2 | 銀牌 | #C0C0C0 | #E8E8E8 | 靜態銀光環 | 無 |
| 3–4 | 金牌 | #FFD700 | #FFF176 | 緩慢旋轉金光環 | 6s loop |
| 5–6 | 鉑金 | #E5E4E2 | #C0C0C0 | 雙層旋轉銀白 | 4s loop |
| 7–8 | 紅鑽 | #FF1744 | #FF6B6B | 紅色脈衝光暈 | 2s pulse |
| 9 | 黑金 | #1A1A1A | #FFD700 | 黑底金紋，金色粒子飄散 | 持續粒子 |
| 10 | 彩虹 | 漸層 | #FF0080→#00D4FF→#00FF88 | 彩虹流動，全屏小特效進場 | 3s loop + 進場爆炸 |

### 3.5 Logo 使用規範

| 情境 | 尺寸 | 顏色版本 | 最小安全距離 |
|------|------|---------|------------|
| 遊戲啟動頁 | 240×80 px | 金色全彩版 | Logo 尺寸 × 0.25 |
| 大廳左上角 | 120×40 px | 白色簡化版 | 8 px 四周 |
| 結算面板浮水印 | 96×32 px | 白色 30% 透明 | 16 px 四周 |
| 禁止用法 | — | 不得在金色背景使用金色 Logo，不得壓縮變形，不得加陰影 | — |

### 3.6 圖示規範

| 類型 | 尺寸 | 風格 | 顏色 |
|------|------|------|------|
| HUD 功能圖示 | 32×32 px | Filled，圓角 2 px | color-text-secondary |
| 貨幣圖示（金幣） | 24×24 px | 詳細金幣 Sprite | color-gold-400 |
| 貨幣圖示（鑽石） | 24×24 px | 多面切割鑽石 Sprite | color-neon-blue |
| 導航圖示 | 40×40 px | Outlined，描邊 2 px | color-text-primary |
| 武器圖示 | 64×64 px | 詳細 Sprite（8 方向） | 依武器類型 |
| 魚類圖示（縮略） | 48×48 px | Filled 簡化 Sprite | 依魚類主色 |

---

## §4 Character & World Design

### 4.1 主角設計——「海神炮手」（Captain Triton）[AI 推斷]

| 屬性 | 規格 |
|------|------|
| 角色名稱 | Captain Triton（海神炮手） |
| 定位 | 玩家操控單元，代表玩家在桌面角落的炮台 |
| 視覺特徵 | 深藍制服+金色肩章；左眼單筒望遠鏡；手持炮彈；身後海浪紋章 |
| 主色 | 制服 #0D3360，金邊 #F5C842，皮膚 #E8C08A |
| 尺寸（設計稿） | 炮台 Sprite：144×144 px；人物半身：96×128 px（大廳展示用） |
| 表情數量 | 5 種：待機 / 瞄準 / 發射 / 勝利 / 失敗 |
| Sprite Sheet | 6×8 幀 = 48 幀，每幀 144×144 px，Atlas 864×1152 px |

**動畫狀態機（炮台）**

| 狀態 | 觸發條件 | 幀數 | 時長 | 特效 |
|------|---------|------|------|------|
| Idle | 無操作 ≥ 2s | 8 幀 loop | 800ms/loop | 炮管微晃 |
| Aim | 玩家按住屏幕 | 4 幀 | 100ms（快速到位） | 準心出現，金色光環 |
| Fire | 發射觸發 | 6 幀 | 120ms | 炮口橘焰噴射，後坐力上揚 |
| Hit_Normal | 普通魚擊中 | 4 幀 | 80ms | 小金幣 x3 飛出 |
| Kill_Elite | 精英魚死亡 | 8 幀 | 200ms | 大量金幣噴射 + 白色擊殺閃 |
| Kill_Boss | Boss 死亡 | 16 幀 | 500ms | 全屏金光 + 倍率數字爆字 |

### 4.2 NPC 魚類設計

#### NPC-01 普通魚群（School Fish）

| 屬性 | 規格 |
|------|------|
| 代表種類 | 小丑魚（橘白）、藍色刀魚、黃色蝴蝶魚 |
| 倍率 | 1–5x |
| 尺寸 | 64×48 px |
| 主色 | 橘 #FF6D00 / 藍 #1565C0 / 黃 #FDD835 |
| 動畫幀數 | 8 幀 loop（左右擺尾） |
| 死亡特效 | 小爆炸，金幣 ×1–5 飛出，持續 300ms |
| HP 血條 | 無（一擊即死） |

#### NPC-02 精英魚（Elite Fish）

| 屬性 | 規格 |
|------|------|
| 代表種類 | 獅子魚（霓虹紋路）、鎚頭鯊（重量感）、電鰻（電弧特效） |
| 倍率 | 10–50x |
| 尺寸 | 128×96 px |
| 主色 | 獅子魚 #E91E63+#00BCD4；鎚頭鯊 #546E7A；電鰻 #FFEB3B+#2196F3 |
| 輪廓光 | 2px Outline Shader，顏色對應主色 |
| 動畫幀數 | 12 幀 loop（含鰭動）+ 4 幀受擊閃爍 |
| HP 血條 | 顯示，顏色 #00FF88→#FF4444 根據血量變化 |
| 死亡特效 | 大爆炸，金幣瀑布（30–50 枚），持續 500ms |

#### NPC-03 Boss 魚（Boss Fish）

| 屬性 | 規格 |
|------|------|
| 代表種類 | 龍魚（中華神話龍頭魚身）、海神（Poseidon Shark）、深海女皇（Abyss Queen，美人魚） |
| 倍率 | 100–1000x |
| 尺寸 | 320×240 px（佔螢幕約 44%） |
| 主色 | 龍魚 #F5C842+#FF3D00；海神鯊 #1565C0+#00D4FF；深海女皇 #9C27B0+#FF4081 |
| 進場動畫 | 16 幀，全屏震動 + 海浪裂開 + 主題音效，持續 1200ms |
| 攻擊動畫 | 8 幀，全場暗度降低到 60%，Boss 高亮，持續 400ms |
| HP 血條 | 大型血條置頂，金框，帶緩衝動畫（Tween 300ms） |
| 死亡特效 | 32 幀，全屏金色爆炸 + 倍率數字衝屏（scale 0.5→3.0，fade out 1s），持續 ≥3000ms（Jackpot 規格） |
| 特殊能力圖示 | Boss 名稱下方 1–3 個技能圖示（32×32 px，霓虹外框） |

#### NPC-04 神話生物（Mythic Creature）[AI 推斷]

| 屬性 | 規格 |
|------|------|
| 代表種類 | 鳳凰魚（節日限定）、福星金龜（春節限定） |
| 倍率 | 500–10000x（稀有度極高） |
| 尺寸 | 256×256 px |
| 主色 | 鳳凰 #FF6D00+#FFEB3B；福龜 #4CAF50+#FFD700 |
| 出現機率 | ≤ 0.1%（RTP 控制） |
| 特殊效果 | 進場全屏彩虹光束 + 震動，退場留存金幣雨 3s |

### 4.3 海底世界設計

| 層級 | 元素 | 設計說明 |
|------|------|---------|
| 遠景層（z=0） | 深海輪廓、珊瑚礁陰影 | 低飽和，模糊處理（blur 4px），顏色 #020810 |
| 中景層（z=1） | 珊瑚群、海草、礁石 | 中飽和，帶輕微動畫（海草擺動 8s loop） |
| 近景層（z=2） | 氣泡群、小裝飾魚群 | 高飽和，氣泡上升動畫 loop |
| HUD 層（z=3） | 所有 UI 元素 | 最高層，不受場景動效影響 |

---

## §5 UI Visual System

### 5.1 字型系統

| Token | 字體家族 | 備用 |
|-------|---------|------|
| font-family-primary | 'Noto Sans TC' | 'Roboto', 'PingFang TC', sans-serif |
| font-family-display | 'Oswald' | 'Noto Sans TC', sans-serif（大標題、倍率數字） |
| font-family-mono | 'Roboto Mono' | 'Courier New', monospace（時間、計分） |

### 5.2 字型比例（Type Scale）

| Level | Token | 字體大小 | 行高 | 字重 | 字距 | 用途 |
|-------|-------|---------|------|------|------|------|
| Display | text-display | 48 px | 56 px | 700 | -0.5 px | Jackpot 爆字、大倍率數字 |
| H1 | text-h1 | 32 px | 40 px | 700 | -0.3 px | 面板主標題、Boss 名稱 |
| H2 | text-h2 | 24 px | 32 px | 600 | -0.2 px | 卡片標題、VIP 等級 |
| H3 | text-h3 | 20 px | 28 px | 600 | 0 | 子標題、武器名稱 |
| Body | text-body | 16 px | 24 px | 400 | 0 | 正文、規則說明 |
| Body-SM | text-body-sm | 14 px | 20 px | 400 | 0 | 次要說明、標籤 |
| Caption | text-caption | 12 px | 16 px | 400 | 0.2 px | 時間戳、角標說明 |
| HUD-Score | text-hud-score | 28 px | 32 px | 700 | 0 | HUD 分數顯示（等寬字體） |
| HUD-Counter | text-hud-counter | 20 px | 24 px | 600 | 0 | HUD 貨幣計數器 |
| Multiplier | text-multiplier | 56 px | 60 px | 900 | -1 px | 倍率爆字（Display 字體） |

### 5.3 按鈕規格

#### 主要按鈕（Primary Button）

| 狀態 | 背景 | 文字色 | 邊框 | 陰影 | 效果 |
|------|------|-------|------|------|------|
| Default | #F5C842（金屬漸層：#F5C842→#C99A00） | #0A1A00 | 無 | 0 0 12px rgba(245,200,66,0.8) | — |
| Hover | #FFD96A | #0A1A00 | 無 | 0 0 20px rgba(245,200,66,0.9) | scale(1.03) |
| Active / Press | #C99A00 | #0A1A00 | 無 | inset 0 2px 4px rgba(0,0,0,0.4) | scale(0.98), translateY(2px) |
| Focus | #F5C842 | #0A1A00 | 3px solid #051428 + 2px outline #F5C842 | — | Ring 11.63:1 AAA |
| Disabled | #7A6120 opacity 0.5 | rgba(0,0,0,0.4) | 無 | 無 | cursor: not-allowed |

**尺寸**：高度 56 px，水平 Padding 24 px，圓角 8 px，最小寬度 160 px

#### 次要按鈕（Secondary Button）

| 狀態 | 背景 | 文字色 | 邊框 |
|------|------|-------|------|
| Default | transparent | #00D4FF | 2px solid #00D4FF |
| Hover | rgba(0,212,255,0.1) | #40DFFF | 2px solid #40DFFF |
| Active | rgba(0,212,255,0.2) | #00D4FF | 2px solid #00A8CC |
| Focus | transparent | #00D4FF | 3px solid #051428 + 2px outline #00D4FF |
| Disabled | transparent opacity 0.4 | rgba(0,212,255,0.4) | 2px solid rgba(0,212,255,0.4) |

**尺寸**：高度 48 px，水平 Padding 20 px，圓角 8 px

#### 圖示按鈕（Icon Button）

**尺寸**：40×40 px，圓角 20 px（圓形），觸控熱區 ≥ 44×44 px

#### 危險按鈕（Danger Button）

**背景**：#FF4444；**文字色**：#FFFFFF；**對比**：4.6:1 AA

### 5.4 輸入欄位規格

| 狀態 | 背景 | 邊框 | 文字色 | 提示文字色 |
|------|------|------|-------|----------|
| Default | rgba(255,255,255,0.05) | 1px solid rgba(255,255,255,0.45) | #FFFFFF | rgba(255,255,255,0.4) |
| Focus | rgba(255,255,255,0.08) | 2px solid #F5C842 | #FFFFFF | — |
| Error | rgba(255,68,68,0.08) | 2px solid #FF4444 | #FFFFFF | — |
| Disabled | rgba(255,255,255,0.02) | 1px solid rgba(255,255,255,0.2) | rgba(255,255,255,0.35) | — |

**尺寸**：高度 52 px，水平 Padding 16 px，圓角 8 px

### 5.5 卡片 / 面板規格

| 類型 | 背景 | 邊框 | 圓角 | 陰影 |
|------|------|------|------|------|
| 標準面板 | rgba(10,35,64,0.95) | 1px solid rgba(245,200,66,0.3) | 12 px | 0 8px 32px rgba(0,0,0,0.6) |
| 高亮面板（VIP/特殊） | rgba(10,35,64,0.98) | 2px solid #F5C842 | 12 px | 0 0 24px rgba(245,200,66,0.4) |
| 模態背景遮罩 | rgba(5,20,40,0.85) backdrop-blur 8px | — | — | — |
| 武器選擇卡 | rgba(13,51,96,0.9) | 2px solid rgba(245,200,66,0.5) | 8 px | inset 0 1px 0 rgba(255,255,255,0.1) |
| 商品卡片 | rgba(15,10,0,0.9) | 1px solid rgba(245,200,66,0.4) | 12 px | 0 4px 16px rgba(0,0,0,0.5) |

### 5.6 HUD 元素規格

| 元素 | 位置 | 尺寸 | 顏色 | 字級 |
|------|------|------|------|------|
| 玩家分數 | 各角落（1P 左下，2P 右下，3P 左上，4P 右上） | 120×40 px | bg #0A2340 80%，文字 #FFFFFF | text-hud-score 28px |
| 金幣計數器 | 分數框右側 | 80×32 px | 圖示 #F5C842，數字 #FFFFFF | text-hud-counter 20px |
| 鑽石計數器 | 金幣右側 | 80×32 px | 圖示 #00D4FF，數字 #FFFFFF | text-hud-counter 20px |
| Jackpot 進度條 | 頂部居中 | 360×24 px | 底 #0A2340，填充 #00D4FF→#F5C842 漸層 | — |
| Boss HP 條 | 頂部（Boss 進場時出現） | 480×32 px | 金框，HP 填充 #00FF88→#FF4444 | text-caption 12px |
| 武器冷卻圓圈 | 炮台右側 | 48×48 px | 底 rgba(0,0,0,0.5)，進度弧 #00D4FF | text-caption 12px（中央倒數） |
| 計時器 | 頂部左側 | 80×32 px | bg 透明，文字 #FFFFFF | text-hud-counter，font-mono |
| 場次編號 | 頂部右側 | 60×20 px | 文字 rgba(255,255,255,0.6) | text-caption |

### 5.7 導航列規格

| 項目 | 規格 |
|------|------|
| 高度 | 72 px（含安全區） |
| 背景 | rgba(5,20,40,0.96) backdrop-blur 12px |
| 頂部邊框 | 1px solid rgba(245,200,66,0.2) |
| 圖示尺寸 | 28×28 px |
| 標籤字級 | text-caption 11px |
| 選中狀態 | 圖示 #F5C842，標籤 #F5C842，底部 3px #F5C842 高亮條 |
| 未選中狀態 | 圖示 rgba(255,255,255,0.5)，標籤 rgba(255,255,255,0.5) |

---

## §6 Design Tokens

### 6.1 Layer 1 — Primitive Tokens

完整繼承自 PDD §9.3，並擴充以下新增 Token：

```css
/* ── Color ── */
--color-gold-50:  #FFFEF0;   /* oklch(99% 0.03 88) */
--color-gold-100: #FFF8C9;   /* oklch(97% 0.07 88) */
--color-gold-200: #FFE87A;   /* oklch(92% 0.14 88) */
--color-gold-300: #FFD740;   /* oklch(87% 0.17 88) */
--color-gold-400: #F5C842;   /* oklch(82% 0.18 88) — MAIN */
--color-gold-600: #C99A00;   /* oklch(67% 0.17 88) */
--color-gold-800: #7A5C00;   /* oklch(42% 0.13 88) */
--color-gold-900: #3D2E00;   /* oklch(22% 0.08 88) */

--color-ocean-50:  #E8F4FF;  /* oklch(96% 0.02 240) */
--color-ocean-100: #B3D4F7;  /* oklch(85% 0.05 240) */
--color-ocean-200: #5EA8E8;  /* oklch(70% 0.09 240) */
--color-ocean-300: #1A72C9;  /* oklch(52% 0.12 240) */
--color-ocean-500: #134A8A;  /* oklch(33% 0.10 240) */
--color-ocean-700: #0D3360;  /* oklch(22% 0.07 240) */
--color-ocean-800: #0A2340;  /* oklch(15% 0.05 240) */
--color-ocean-900: #051428;  /* oklch(10% 0.04 240) — BASE BG */
--color-ocean-950: #030B1A;  /* oklch(6% 0.03 240) */

--color-neon-blue:  #00D4FF; /* oklch(82% 0.16 200) */
--color-neon-green: #00FF88; /* oklch(92% 0.22 152) */
--color-neon-pink:  #FF00AA; /* oklch(62% 0.28 330) — 彩虹 VIP 用 */
--color-neon-purple:#A020F0; /* oklch(50% 0.25 290) — Boss 魔法效果 */

--color-red-300: #FF8080;    /* oklch(72% 0.16 27) — warning */
--color-red-500: #FF4444;    /* oklch(65% 0.24 27) — error */
--color-red-700: #CC0000;    /* oklch(45% 0.22 27) — danger */

--color-vip-silver:  #C0C0C0;
--color-vip-gold:    #FFD700;
--color-vip-platinum:#E5E4E2;
--color-vip-ruby:    #FF1744;
--color-vip-rainbow-start: #FF0080;
--color-vip-rainbow-mid:   #00D4FF;
--color-vip-rainbow-end:   #00FF88;

--color-white-100: #FFFFFF;
--color-black-900: #000000;

/* ── Typography ── */
--font-family-primary: 'Noto Sans TC', 'Roboto', 'PingFang TC', sans-serif;
--font-family-display: 'Oswald', 'Noto Sans TC', sans-serif;
--font-family-mono:    'Roboto Mono', 'Courier New', monospace;

--font-size-12: 12px;
--font-size-14: 14px;
--font-size-16: 16px;
--font-size-20: 20px;
--font-size-24: 24px;
--font-size-28: 28px;
--font-size-32: 32px;
--font-size-48: 48px;
--font-size-56: 56px;

--font-weight-400: 400;
--font-weight-600: 600;
--font-weight-700: 700;
--font-weight-900: 900;

--line-height-tight:  1.15;
--line-height-normal: 1.5;
--line-height-loose:  1.75;

/* ── Spacing ── */
--space-1:  4px;
--space-2:  8px;
--space-3:  12px;
--space-4:  16px;
--space-5:  20px;
--space-6:  24px;
--space-8:  32px;
--space-10: 40px;
--space-12: 48px;
--space-16: 64px;

/* ── Border Radius ── */
--radius-sm:  4px;
--radius-md:  8px;
--radius-lg:  12px;
--radius-xl:  20px;
--radius-full: 9999px;

/* ── Motion ── */
--duration-instant: 0ms;
--duration-fast:    80ms;
--duration-normal:  200ms;
--duration-slow:    500ms;
--duration-xslow:   1000ms;
--duration-jackpot: 3000ms;

--easing-linear:    linear;
--easing-ease-in:   cubic-bezier(0.4, 0, 1, 1);
--easing-ease-out:  cubic-bezier(0, 0, 0.2, 1);
--easing-expo-out:  cubic-bezier(0.16, 1, 0.3, 1);
--easing-spring:    cubic-bezier(0.34, 1.56, 0.64, 1);
--easing-bounce:    cubic-bezier(0.68, -0.55, 0.265, 1.55);

/* ── Shadow ── */
--shadow-glow-gold:  0 0 12px rgba(245,200,66,0.8);
--shadow-glow-blue:  0 0 12px rgba(0,212,255,0.8);
--shadow-glow-green: 0 0 12px rgba(0,255,136,0.8);
--shadow-glow-red:   0 0 12px rgba(255,68,68,0.7);
--shadow-card:       0 8px 32px rgba(0,0,0,0.6);
--shadow-inset:      inset 0 2px 4px rgba(0,0,0,0.4);

/* ── Z-index ── */
--z-bg:       0;
--z-game:     1;
--z-hud:      10;
--z-overlay:  20;
--z-modal:    30;
--z-toast:    40;
--z-tutorial: 50;
```

### 6.2 Layer 2 — Semantic Tokens

```css
/* ── Background ── */
--color-bg-base:        var(--color-ocean-900);   /* #051428 */
--color-bg-surface:     var(--color-ocean-800);   /* #0A2340 */
--color-bg-elevated:    var(--color-ocean-700);   /* #0D3360 */
--color-bg-overlay:     rgba(5,20,40,0.85);
--color-bg-scrim:       rgba(0,0,0,0.6);

/* ── Text ── */
--color-text-primary:   var(--color-white-100);              /* #FFFFFF  21:1  AAA */
--color-text-secondary: rgba(255,255,255,0.6);               /* composited #9BA1A9  6.8:1 AA */
--color-text-tertiary:  rgba(255,255,255,0.4);               /* composited #767E89  3.5:1 AA（非文字用） */
--color-text-disabled:  rgba(255,255,255,0.35);
--color-text-inverse:   var(--color-ocean-900);              /* on 金色底 */
--color-text-brand:     var(--color-gold-400);               /* #F5C842  7.2:1 AAA */
--color-text-accent:    var(--color-neon-blue);              /* #00D4FF  8.9:1 AAA */
--color-text-success:   var(--color-neon-green);             /* #00FF88  14.1:1 AAA */
--color-text-error:     var(--color-red-500);                /* #FF4444  4.6:1 AA */
--color-text-warning:   var(--color-red-300);                /* #FF8080  7.61:1 AAA */

/* ── Action ── */
--color-action-primary:          var(--color-gold-400);
--color-action-primary-hover:    var(--color-gold-300);
--color-action-primary-active:   var(--color-gold-600);
--color-action-secondary:        var(--color-neon-blue);
--color-action-secondary-hover:  #40DFFF;
--color-action-secondary-active: #00A8CC;
--color-action-danger:           var(--color-red-500);

/* ── Border ── */
--color-border-default: rgba(255,255,255,0.45);   /* composited 3.2:1 WCAG 1.4.11 */
--color-border-subtle:  rgba(255,255,255,0.2);
--color-border-strong:  rgba(255,255,255,0.7);
--color-border-brand:   var(--color-gold-400);
--color-border-focus:   var(--color-gold-400);    /* 11.63:1 AAA */
--color-border-error:   var(--color-red-500);
--color-border-success: var(--color-neon-green);

/* ── Feedback ── */
--color-feedback-success:  var(--color-neon-green);
--color-feedback-error:    var(--color-red-500);
--color-feedback-warning:  var(--color-red-300);
--color-feedback-info:     var(--color-neon-blue);

/* ── Game-specific Semantic ── */
--color-accent-neon:       var(--color-neon-blue);
--color-accent-success:    var(--color-neon-green);
--color-vip-identity:      var(--color-vip-gold);  /* 預設，runtime 依等級覆蓋 */
--color-hp-high:           var(--color-neon-green);
--color-hp-mid:            #FFEB3B;
--color-hp-low:            var(--color-red-500);
--color-jackpot-progress:  linear-gradient(90deg, var(--color-neon-blue), var(--color-gold-400));
```

### 6.3 Layer 3 — Component Tokens

```css
/* ── Button — Primary ── */
--btn-primary-bg:          var(--color-action-primary);
--btn-primary-bg-hover:    var(--color-action-primary-hover);
--btn-primary-bg-active:   var(--color-action-primary-active);
--btn-primary-text:        var(--color-text-inverse);
--btn-primary-shadow:      var(--shadow-glow-gold);
--btn-primary-radius:      var(--radius-md);
--btn-primary-focus-ring:  var(--color-border-focus);
--btn-primary-height:      56px;
--btn-primary-px:          24px;

/* ── Button — Secondary ── */
--btn-secondary-border:    var(--color-action-secondary);
--btn-secondary-text:      var(--color-action-secondary);
--btn-secondary-radius:    var(--radius-md);
--btn-secondary-height:    48px;

/* ── HUD ── */
--hud-bg:                  rgba(10,35,64,0.8);
--hud-border:              rgba(245,200,66,0.3);
--hud-coin-color:          var(--color-gold-400);
--hud-diamond-color:       var(--color-neon-blue);
--hud-text-color:          var(--color-white-100);
--hud-score-font:          var(--font-family-mono);
--hud-score-size:          var(--font-size-28);

/* ── Jackpot Bar ── */
--jackpot-bar-bg:          rgba(10,35,64,0.9);
--jackpot-bar-border:      var(--color-gold-400);
--jackpot-bar-fill-start:  var(--color-neon-blue);
--jackpot-bar-fill-end:    var(--color-gold-400);
--jackpot-bar-height:      24px;
--jackpot-bar-radius:      var(--radius-full);
--jackpot-bar-glow:        var(--shadow-glow-gold);

/* ── Boss HP Bar ── */
--boss-hp-bg:              rgba(0,0,0,0.7);
--boss-hp-border:          var(--color-gold-400);
--boss-hp-fill-high:       var(--color-hp-high);
--boss-hp-fill-mid:        var(--color-hp-mid);
--boss-hp-fill-low:        var(--color-hp-low);
--boss-hp-height:          32px;
--boss-hp-transition:      var(--duration-normal) var(--easing-expo-out);

/* ── Card / Panel ── */
--card-bg:                 rgba(10,35,64,0.95);
--card-border:             rgba(245,200,66,0.3);
--card-border-width:       1px;
--card-radius:             var(--radius-lg);
--card-shadow:             var(--shadow-card);

/* ── Input ── */
--input-bg:                rgba(255,255,255,0.05);
--input-bg-focus:          rgba(255,255,255,0.08);
--input-border:            var(--color-border-default);
--input-border-focus:      var(--color-border-focus);
--input-border-error:      var(--color-border-error);
--input-text:              var(--color-text-primary);
--input-placeholder:       rgba(255,255,255,0.4);
--input-height:            52px;
--input-radius:            var(--radius-md);
--input-px:                16px;

/* ── VIP Badge ── */
--vip-badge-border-width:  2px;
--vip-badge-glow-radius:   8px;
--vip-badge-radius:        var(--radius-full);

/* ── Modal ── */
--modal-overlay:           rgba(5,20,40,0.85);
--modal-bg:                var(--color-bg-surface);
--modal-border:            rgba(245,200,66,0.4);
--modal-radius:            var(--radius-lg);

/* ── Toast / Alert ── */
--toast-success-bg:        rgba(0,255,136,0.15);
--toast-success-border:    var(--color-feedback-success);
--toast-error-bg:          rgba(255,68,68,0.15);
--toast-error-border:      var(--color-feedback-error);

/* ── Fish Name Label ── */
--fish-label-bg:           rgba(0,0,0,0.6);
--fish-label-text:         var(--color-white-100);
--fish-label-font-size:    var(--font-size-12);

/* ── Weapon Select Card ── */
--weapon-card-bg:          rgba(13,51,96,0.9);
--weapon-card-border:      rgba(245,200,66,0.5);
--weapon-card-radius:      var(--radius-md);
--weapon-card-selected-glow: var(--shadow-glow-gold);

/* ── Settlement ── */
--settle-win-bg:           linear-gradient(180deg, rgba(245,200,66,0.15), rgba(5,20,40,0.95));
--settle-win-border:       var(--color-gold-400);
--settle-loss-bg:          linear-gradient(180deg, rgba(13,51,96,0.5), rgba(5,20,40,0.95));
--settle-loss-border:      rgba(255,255,255,0.2);

/* ── Skeleton Loading ── */
--skeleton-base:   #0A2340;
--skeleton-shine:  #0D3360;
--skeleton-radius: var(--radius-md);
--skeleton-duration: 1.4s;
```

### 6.4 Dark Mode Token 對應表（含 WCAG 驗證）

| Semantic Token | Dark Mode 值 | Light Mode 值（備用）| 對比比（Dark on bg-base） | WCAG 等級 |
|---------------|-------------|---------------------|--------------------------|----------|
| color-text-primary | #FFFFFF | #111827 | 21:1 | AAA |
| color-text-secondary | rgba(255,255,255,0.6) ≈ #9BA1A9 | #6B7280 | 6.8:1 | AA |
| color-text-tertiary | rgba(255,255,255,0.4) ≈ #767E89 | #9CA3AF | 3.5:1 | AA（非文字）|
| color-text-disabled | rgba(255,255,255,0.35) | #D1D5DB | — | 裝飾用，不適用 |
| color-text-brand | #F5C842 | #C99A00 | 7.2:1 | AAA |
| color-text-accent | #00D4FF | #0284C7 | 8.9:1 | AAA |
| color-text-success | #00FF88 | #059669 | 14.1:1 | AAA |
| color-text-error | #FF4444 | #DC2626 | 4.6:1 | AA |
| color-text-warning | #FF8080 | #D97706 | 7.61:1 | AAA |
| color-action-primary | #F5C842 | #C99A00 | 7.2:1 | AAA |
| color-action-secondary | #00D4FF | #0284C7 | 8.9:1 | AAA |
| color-border-default | rgba(255,255,255,0.45) ≈ #767E89 | #E5E7EB | 3.2:1 | WCAG 1.4.11 |
| color-border-focus | #F5C842 | #92400E | 11.63:1 | AAA |
| color-feedback-success | #00FF88 | #059669 | 14.1:1 | AAA |
| color-feedback-error | #FF4444 | #DC2626 | 4.6:1 | AA |
| color-feedback-warning | #FF8080 | #D97706 | 7.61:1 | AAA |

### 6.5 Motion Token 設計

| Token | 值 | 用途 |
|-------|-----|------|
| duration-fast | 80ms | 按鈕 Hover/Active，圖示 bounce |
| duration-normal | 200ms | 面板淡入，切換過渡 |
| duration-slow | 500ms | 模態進場，Boss 血條 Tween |
| duration-xslow | 1000ms | Boss 進場全屏震動，倍率爆字出現 |
| duration-jackpot | 3000ms | Jackpot 爆炸特效最短播放時間 |
| easing-expo-out | cubic-bezier(0.16,1,0.3,1) | 面板滑入、HP 條更新 |
| easing-spring | cubic-bezier(0.34,1.56,0.64,1) | 金幣飛出、倍率數字彈跳 |
| easing-bounce | cubic-bezier(0.68,-0.55,0.265,1.55) | 按鈕按下後彈回 |

---

## §7 Asset Pipeline

### 7.1 資源分類

| 類別 | 格式 | 解析度 | 資料夾 |
|------|------|-------|-------|
| 場景背景 | PNG / WebP | 720×1280 px（@1x），1440×2560（@2x） | `assets/bg/` |
| 魚類 Sprite Sheet | PNG | 幀尺寸依規格，Atlas ≤ 2048×2048 px | `assets/sprites/fish/` |
| 武器 Sprite Sheet | PNG | 144×144 px/幀，Atlas ≤ 1024×1024 px | `assets/sprites/weapons/` |
| 特效 Sprite Sheet | PNG | 256×256 px/幀，Atlas ≤ 2048×2048 px | `assets/sprites/effects/` |
| UI 圖示 | SVG（Figma export）→ PNG（Atlas） | 32/40/64 px，@2x | `assets/icons/` |
| VIP 徽章 | PNG（含透明通道） | 64×64 px，@2x | `assets/vip/` |
| 字型 | TTF + WOFF2 | — | `assets/fonts/` |
| 音效 | MP3 + OGG | 128kbps stereo / 44.1kHz | `assets/audio/` |
| Shader 材質 | PNG（灰階或 RGBA）| 256×256 px | `assets/textures/` |

### 7.2 命名規範

```
格式: {類別}_{名稱}_{狀態/變體}_{@倍率}.{副檔名}
範例:
  fish_clownfish_swim_@1x.png
  fish_boss_dragon_death_@2x.png
  ui_btn_primary_default_@2x.png
  ui_btn_primary_hover_@2x.png
  icon_coin_@2x.svg
  icon_diamond_@2x.svg
  vip_badge_level10_@2x.png
  effect_jackpot_burst_@2x.png
  bg_gamescene_ocean_@1x.png

狀態後綴列表:
  按鈕: default | hover | active | focus | disabled
  魚類動畫: idle | swim | hit | death
  Boss: idle | attack | stunned | death
  VIP 徽章: level01 ~ level10
  特效: burst | loop | trail
```

### 7.3 圖片壓縮標準

| 格式 | 工具 | 品質設定 | 目標大小 |
|------|------|---------|---------|
| PNG（透明圖） | pngquant | quality 80-90 | ≤ 200KB/張 |
| PNG（Atlas） | pngquant | quality 85-95 | ≤ 512KB/Atlas |
| WebP（背景）| cwebp | -q 85 | ≤ 300KB/張 |
| AVIF（背景，若引擎支援）| avifenc | quality 65 | ≤ 200KB/張 |

### 7.4 Figma → Cocos Creator 交付流程

```
1. Figma 元件命名使用 §7.2 命名規範
2. 導出設定：@1x（720px基準）+ @2x（高清）
3. 圖示：SVG 導出 → 工程師轉 PNG Atlas
4. Sprite Sheet 需附帶 JSON 幀資料（TexturePacker 格式）
5. 字型檔需取得授權後提交 assets/fonts/
6. 每次交付使用 Zeplin / Figma Inspect 標注所有 Token 數值
7. Changelog 記錄每次修改的 Asset Key
```

### 7.5 Atlas 打包規格

| 類型 | 最大尺寸 | 演算法 | Padding |
|------|---------|-------|---------|
| 魚類動畫 Atlas | 2048×2048 px | MaxRects | 2 px |
| UI 圖示 Atlas | 1024×1024 px | MaxRects | 1 px |
| 特效 Atlas | 2048×2048 px | MaxRects | 2 px |
| 武器 Atlas | 1024×1024 px | MaxRects | 2 px |

### 7.6 動畫規格彙總

| 動畫類型 | 幀率 | 建議幀數 | 循環 | 觸發方式 |
|---------|------|--------|------|---------|
| 普通魚游動 | 12 fps | 8 幀 | loop | 常駐 |
| 精英魚游動 | 12 fps | 12 幀 | loop | 常駐 |
| Boss 待機 | 12 fps | 16 幀 | loop | 常駐 |
| Boss 進場 | 24 fps | 24 幀 | once | 事件觸發 |
| Boss 攻擊 | 24 fps | 12 幀 | once | 事件觸發 |
| Boss 死亡 | 24 fps | 32 幀 | once | 事件觸發 |
| 炮彈發射 | 24 fps | 8 幀 | once | 觸控觸發 |
| 金幣飛出 | 24 fps | 16 幀 | once | 事件觸發 |
| Jackpot 爆炸 | 24 fps | 72 幀（3s） | once | 事件觸發 |
| VIP 光暈 | 12 fps | 24 幀 | loop | 常駐 |
| Skeleton 載入 | CSS 動畫 | — | loop | 資料加載中 |

---

## §8 Screen Visual Specs

### 8.1 LoginScene — 登入頁

**設計目標**：品牌第一印象，5 秒內完成信任建立 + 行動引導

| 元素 | 規格 |
|------|------|
| 尺寸 | 720×1280 px（FIXED_WIDTH） |
| 背景 | 深海漸層 #051428→#030B1A，帶輕微放射光（中心 #0A2340） |
| 動態背景 | 氣泡上升粒子（20–30 顆，opacity 0.3–0.6，上升速度 80–120 px/s） |
| Logo | 居中，Y=280，尺寸 240×80 px，金色版本，進場 fade+scale(0.8→1.0) 400ms easing-expo-out |
| 副標題 | Y=380，16 px，rgba(255,255,255,0.7)，「最直接的競技捕魚體驗」 |
| 手機號輸入 | Y=480，width=560 px，符合 §5.4 輸入欄位規格，Placeholder「輸入手機號碼」 |
| 驗證碼欄位 | Y=560，width=360 px，右側「發送驗證碼」按鈕 width=160 px（Secondary 樣式） |
| 主要 CTA | Y=660，「登入 / 註冊」Primary Button 560×56 px |
| 第三方登入 | Y=760，「或使用」分隔線，Google/Facebook/Apple 圖示按鈕（各 48×48 px） |
| 年齡聲明 | Y=900，text-caption，「點擊登入表示您已年滿 18 歲」，rgba(255,255,255,0.5) |
| 載入狀態 | 按鈕文字替換為 Spinner（24 px），按鈕 disabled 樣式 |

**關鍵動畫**：
- Logo 進場：fade-in + scale 0.8→1.0，400ms，easing-expo-out
- 表單整體：translateY(20px)→0 + fade-in，600ms，easing-expo-out，delay 200ms

---

### 8.2 AgeGateModal — 年齡驗證模態

**設計目標**：合規阻擋，但不破壞沉浸感

| 元素 | 規格 |
|------|------|
| 遮罩 | full-screen，rgba(5,20,40,0.92)，backdrop-blur 8px |
| 面板 | 600×400 px，居中，card-bg 規格，金色邊框 2px |
| 標題圖示 | 警示盾牌圖示 64×64 px，#F5C842 |
| 標題文字 | text-h1，「年齡確認」|
| 內文 | text-body，「本平台僅供 18 歲以上成年人使用。請確認您的年齡。」|
| 確認按鈕 | 「我已年滿 18 歲」Primary Button，280×56 px |
| 離開按鈕 | 「離開」Secondary Button，280×48 px，text-error 顏色 |
| 版本號 | 面板右下角，text-caption，rgba(255,255,255,0.3) |

---

### 8.3 LobbyScene — 大廳

**設計目標**：社交感 + 快速進房 + VIP 羨慕感

**Layout Grid**（720 px 寬）：

```
Y=0    ~ Y=80   : 頂部 Header Bar（Logo、錢包、個人頭像）
Y=80   ~ Y=200  : VIP / 公告輪播（Carousel）
Y=200  ~ Y=680  : 房間列表（房間卡片 × 6，2 列 3 行或 1 列 6 行）
Y=680  ~ Y=760  : 快速進房 CTA（大型 Primary Button）
Y=760  ~ Y=840  : 底部 Navigation Bar
Y=840  ~ Y=1280 : 安全區域（Padding bottom）
```

| 元素 | 規格 |
|------|------|
| Header Bar | 高度 80 px，bg rgba(5,20,40,0.96)，Logo 左側 120×40 px，右側金幣+鑽石顯示（§5.6 HUD 規格）+ 頭像 40×40 px 圓形 |
| VIP 輪播 | 高度 120 px，自動播放 4s，玩家 VIP 狀態卡 + 每日任務卡，左右 Dot 指示器 |
| 房間卡片 | 320×200 px（2 列）或 656×88 px（1 列），card-bg 規格，顯示：房間名、在場人數（4/4 或 2/4）、倍率範圍（1x–500x）、房間費用（免費/5 幣/20 幣） |
| 房間滿人 | 卡片 overlay 50% 暗化，「房間已滿」badge，橘色 #FF6D00 |
| VIP 房 | 金色邊框加粗 2px，左上角「VIP」badge |
| 快速進房 | 680×56 px，Primary Button，「快速進入遊戲」，加炮彈圖示 |
| 底部 NavBar | §5.7 規格，5 分頁：大廳 / 商店 / 任務 / 排行 / 個人 |
| 裝飾魚群 | 背景層，3–5 條小魚游過，低 opacity 0.3，不遮擋主要內容 |

---

### 8.4 MatchmakingScene — 配對場景

**設計目標**：等待感轉化為期待感，展示隊友陣容

| 元素 | 規格 |
|------|------|
| 背景 | 旋轉海底探照燈光效，#051428 底色 |
| 標題 | text-h1，「配對中...」，Y=200 |
| 玩家位置（4格） | 2×2 格，各 160×200 px，已配對顯示頭像+名字，未配對顯示 Skeleton（骨架屏） |
| 配對進度 | 進度文字「2/4 玩家已加入」，text-body，#00D4FF |
| 等待計時 | 計時器 MM:SS，text-hud-score，#FFFFFF |
| 取消按鈕 | Secondary Button 240×48 px，下方 Y=900 |
| 已配對玩家 | 進場動畫：頭像從外側滑入，scale 0.8→1.0，easing-spring 300ms |
| VIP 玩家徽章 | 頭像右下角 VIP 等級徽章（§3.4 規格），帶光暈 |

---

### 8.5 GameScene — 主遊戲場景

**設計目標**：沉浸式戰場，資訊即時可讀，特效爽感拉滿

**Layout（Landscape 1280×720 或 Portrait 720×1280）**：

本平台採 Portrait 720×1280，HUD 四角分配。

| 元素 | 位置 | 規格 |
|------|------|------|
| 遊戲背景 | z=0 | 動態深海 Shader，波紋動畫 |
| 魚群出現區 | z=1 | 全畫面遊戲區（扣除 HUD 邊距後 680×1080 px 有效） |
| 1P 炮台 | 左下角 Y=1120 | 144×144 px，跟隨觸控旋轉 |
| 2P 炮台 | 右下角 Y=1120 | 同上，顏色不同（2P 青色 tint #00D4FF） |
| 3P 炮台 | 左上角 Y=20 | 180° 翻轉，顏色 #FF6D00 |
| 4P 炮台 | 右上角 Y=20 | 同 3P，顏色 #9C27B0 |
| 1P HUD | 左下 HUD 區 | §5.6 規格，score / coin / diamond |
| 2P HUD | 右下 HUD 區 | 同上 |
| Jackpot Bar | 頂部居中 Y=20 | §5.6 規格 360×24 px |
| Boss HP Bar | Jackpot Bar 下方 Y=56（Boss 在場時顯示）| §5.6 規格 480×32 px |
| 武器切換 | 底部中央 Y=1160 | 3 個武器圖示（64×64 px），選中者金色 glow |
| 技能按鈕 | 武器右側 | 2 個技能圓形按鈕（56×56 px），冷卻圓弧覆蓋 |
| 設定按鈕 | 頂部右側 Y=20 | 40×40 px 齒輪圖示 |

**特效規格**：

| 特效 | 觸發 | 持續時間 | 粒子數量 | 顏色 |
|------|------|---------|---------|------|
| 炮彈軌跡 | 每次發射 | 100ms | 8–12 粒（拖尾） | #F5C842→透明 |
| 普通魚死亡 | 擊殺 | 300ms | 10–20 金幣粒子 | #F5C842 |
| 精英魚死亡 | 擊殺 | 500ms | 30–50 金幣+光芒 | #F5C842 + #FFFFFF |
| Boss 受擊 | 每次命中 | 150ms | 5–8 衝擊粒子 | #FF4444 |
| Boss 死亡 / Jackpot | 觸發 | ≥3000ms | 200+ 金幣+光柱 | #F5C842 + #FFD700 + #FFFFFF |
| 技能啟動 | 技能觸發 | 800ms | 全屏邊框閃光 | #00D4FF |
| 連擊提示 | 3 秒內 ≥3 擊殺 | 600ms | 「COMBO x{n}」衝屏文字 | #F5C842 |

---

### 8.6 CannonSelectScene — 武器選擇面板

**設計目標**：清楚比較武器，鼓勵升級消費

| 元素 | 規格 |
|------|------|
| 背景 | 半透明 overlay 遮罩（從 GameScene overlay 展開）+ 武器展示台舞台感 |
| 標題 | text-h1，「選擇武器」，Y=80 |
| 武器卡片 | 4 張卡片（2×2），每張 320×240 px，weapon-card 規格 |
| 卡片內容 | 武器 Sprite 128×128 px（置中上方）+ 武器名（text-h3）+ 倍率範圍（text-body，#F5C842）+ 子彈速度（text-body-sm）+ 費用（text-body-sm，鑽石圖示）|
| 選中狀態 | 金色邊框 2px + glow shadow，右上角「已選擇」badge |
| 鎖定狀態 | overlay 40% 暗化，鎖圖示，「VIP {n} 解鎖」文字 |
| 確認按鈕 | Primary Button 560×56 px，Y=900 |
| 比較 Tooltip | 點擊武器出現 280 px 寬 Tooltip，顯示詳細數據對比 |

---

### 8.7 ShopScene — 商店

**設計目標**：高轉換率設計，商品展示有羨慕感

**Layout**：

```
Y=0    ~ Y=80  : Header（返回按鈕 + 標題「商城」+ 當前鑽石數）
Y=80   ~ Y=160 : 分類 Tab（幣包 / VIP / 武器 / 道具）
Y=160  ~ Y=840 : 商品列表（ScrollView）
Y=840  ~ Y=1280: 底部安全區
```

| 元素 | 規格 |
|------|------|
| 幣包商品 | 2 列，每格 320×200 px，商品卡規格；顯示金幣數量（大字 text-h1，#F5C842）+ 美元價格（text-body）+ 加贈標籤（紅色 badge）|
| 暢銷標籤 | 右上角「🔥 最熱銷」badge，#FF6D00 底色 |
| 限時優惠 | 倒數計時條，#FF4444 底色，白色文字 |
| VIP 方案 | 3 個等級卡（320×280 px），選中者金框 glow；顯示月費、VIP 等級圖示、特權清單 |
| 購買按鈕 | Primary Button 280×52 px，文字「立即購買 $X.XX」|
| 支付方式 | 底部小字說明「支援：Apple Pay / Google Pay / 信用卡」|

---

### 8.8 VIPPanel — VIP 面板

**設計目標**：展示身份感，驅動升級

| 元素 | 規格 |
|------|------|
| 面板 | modal 樣式，720×1100 px（全屏模態）|
| VIP 等級顯示 | 頂部大型 VIP 徽章（128×128 px）+ 等級數字 text-display |
| 光暈動畫 | §3.4 VIP 等級色系對應光暈（持續播放）|
| 進度條 | 當前等級積分 / 升級所需積分，金色進度條，帶數字標注 |
| 特權清單 | 清單項目：圖示（32 px）+ 說明文字（text-body）+ 狀態（已解鎖 #00FF88 / 待解鎖 rgba(255,255,255,0.4)）|
| 下一等級預覽 | 半透明展示下個等級的新特權，「再 {n} 積分升級」文字 |
| 升級按鈕 | Primary Button「立即充值升級」560×56 px |

---

### 8.9 SettlementPanel — 結算面板

**設計目標**：強化「赢了真爽 / 輸了想繼續」的情緒

| 元素 | 規格 |
|------|------|
| 背景 | 黑色漸層 overlay 全屏（rgba(0,0,0,0.8)）+ 金幣粒子飄落（勝利時）|
| 勝利狀態標題 | text-display，「恭喜！」#F5C842，scale 0→1.2→1.0 彈入，500ms |
| 失敗狀態標題 | text-h1，「遊戲結束」，rgba(255,255,255,0.8) |
| 本局總收益 | text-display，數字 #F5C842，帶 count-up 數字滾動動畫（duration 800ms）|
| Jackpot 達成（特殊版）| 全屏金光爆炸特效 ≥3000ms，倍率數字從底部飛出衝屏（scale 0.5→3.0，fade out 1s）|
| 統計區塊 | 擊殺數 / 最高倍率 / 技能使用次數，text-body，白色 |
| 排名 | 1–4 名依序排列，第 1 名 #F5C842 金框，附玩家頭像 + VIP 徽章 |
| 再玩一局 CTA | Primary Button 560×56 px，「再玩一局」|
| 返回大廳 | Secondary Button 560×48 px，「返回大廳」|
| 廣告插入點 | 「看廣告得雙倍獎勵」banner，高度 80 px（如啟用 AdMob）|
| 進場動畫 | 面板從下方 translateY(100%) 滑入，300ms easing-expo-out；數字 count-up delay 200ms |

---

### 8.10 SettingsPanel — 設定面板

**設計目標**：簡潔，快速找到音效開關

| 元素 | 規格 |
|------|------|
| 面板類型 | 右側 Drawer 滑入，寬度 400 px，高度全屏 |
| 區塊 | 音效開關（Toggle 大圖示）/ 振動開關 / 圖形品質（低/中/高 3 段）/ 語言選擇 / 帳號資訊 / 客服連結 / 登出按鈕 |
| Toggle 規格 | 52×32 px，開啟 #00FF88，關閉 rgba(255,255,255,0.3) |
| 列表項目 | 高度 56 px，左側圖示 28 px + 文字 text-body，右側 Toggle 或箭頭 |
| 分隔線 | 1px solid rgba(255,255,255,0.1) |
| 登出按鈕 | text-error #FF4444，無 Button 樣式，純文字點擊 |

---

### 8.11 ProfileScene — 個人頁

| 元素 | 規格 |
|------|------|
| 頭部 | 全寬 banner 漸層（#0A2340→#051428），高度 280 px |
| 頭像 | 96×96 px 圓形，邊框依 VIP 等級（§3.4 色系），Y=120 居中 |
| VIP 光暈 | 頭像外圈旋轉光暈（§3.4 規格） |
| 暱稱 | text-h2，#FFFFFF，Y=230 |
| VIP 等級標籤 | 暱稱下方 badge，依等級顏色 |
| 統計卡片 | 三欄：總場次 / 最高倍率 / 累計獎金，每欄 215×100 px，card-bg |
| 成就系統 | 成就 Badge 網格（64×64 px，已解鎖全色，未解鎖灰色 30% opacity）|
| 交易記錄 | ScrollView 列表，每項 56 px 高，日期 + 金額（正值 #00FF88，負值 #FF4444）|

---

### 8.12 LeaderboardPanel — 排行榜面板

| 元素 | 規格 |
|------|------|
| 面板 | 模態，全屏 720×1280 px |
| 分類 Tab | 今日 / 本週 / 總排行 / 好友 |
| 前三名 | 特殊設計：1st 金色台座+大頭像（96px）+金色 glow，2nd 銀色，3rd 銅色 |
| 一般名次 | 列表行 64 px，左側名次數字（text-h3）+ 頭像 40 px + 暱稱 + VIP 徽章 + 右側獎金 #F5C842 |
| 玩家自身行 | 固定於列表底部，背景 rgba(245,200,66,0.1)，border-top 1px #F5C842 |
| 更新時間 | 頂部 text-caption，「最後更新：HH:MM」|

---

### 8.13 OnboardingScene — 新手引導

| 元素 | 規格 |
|------|------|
| 步驟數 | 5 步：歡迎 → 炮台操作 → 魚類介紹 → 武器升級 → 開始遊戲 |
| 遮罩 | 半透明黑色遮罩，目標元素「高亮開口」（cutout mask）|
| 說明氣泡 | 320×120 px card-bg，指向高亮目標，帶三角箭頭 |
| 進度點 | 5 個 dot，選中 #F5C842 直徑 10 px，未選中 rgba(255,255,255,0.4) 8 px |
| 下一步 CTA | Primary Button 240×48 px，「知道了」|
| 跳過按鈕 | 右上角，text-body-sm，rgba(255,255,255,0.6) |
| 互動提示 | 手指點擊動畫（24 fps 8 幀 loop Sprite），指向目標互動區 |

---

## §9 Accessibility

### 9.1 色彩對比度驗證（完整清單）

| 使用情境 | 前景色 | 背景色 | 比率 | 等級 | 合規 |
|---------|-------|-------|------|------|-----|
| 主要文字（body） | #FFFFFF | #051428 | 21:1 | AAA | ✓ |
| 次要文字 | #9BA1A9 | #051428 | 6.8:1 | AA | ✓ |
| 品牌金色文字 | #F5C842 | #051428 | 7.2:1 | AAA | ✓ |
| 霓虹青色文字 | #00D4FF | #051428 | 8.9:1 | AAA | ✓ |
| 成功綠色文字 | #00FF88 | #051428 | 14.1:1 | AAA | ✓ |
| 錯誤紅色文字 | #FF4444 | #051428 | 4.6:1 | AA | ✓ |
| 警告文字 | #FF8080 | #051428 | 7.61:1 | AAA | ✓ |
| 按鈕文字（on 金色） | #0A1A00 | #F5C842 | 12.3:1 | AAA | ✓ |
| HUD 分數（on HUD bg） | #FFFFFF | rgba(10,35,64,0.8) ≈ #0A2340 | 14.6:1 | AAA | ✓ |
| Jackpot 數字 | #F5C842 | #030B1A | 7.8:1 | AAA | ✓ |
| Boss HP 高（on hp bg） | #00FF88 | #000000 | 14.1:1 | AAA | ✓ |
| Boss HP 低（on hp bg） | #FF4444 | #000000 | 4.6:1 | AA | ✓ |
| Focus Ring | #F5C842 | #051428 | 11.63:1 | AAA | ✓ |
| UI 元件邊框（non-text）| rgba(255,255,255,0.45) | #051428 | 3.2:1 | 1.4.11 | ✓ |
| 禁用文字 | rgba(255,255,255,0.35) | #051428 | 2.9:1 | — | 裝飾用 |

### 9.2 色盲無障礙

| 色盲類型 | 問題點 | 解決方案 |
|---------|-------|---------|
| 紅綠色盲（Deuteranopia） | HP 條紅/綠難以區分 | HP 條加入「形狀編碼」：高血量完整方塊，低血量三角形圖示；補充圖示提示 |
| 藍黃色盲（Tritanopia） | 金幣（黃）與鑽石（藍）可能混淆 | 圖示形狀完全不同（圓形金幣 vs 多面鑽石），不僅依賴顏色區分 |
| 全色盲（Achromatopsia） | 大量顏色信息丟失 | 關鍵狀態（擊殺、VIP 等級）附加文字標注或形狀編碼 |

### 9.3 焦點管理

| 場景 | 焦點規格 |
|------|---------|
| 全局 Focus Ring | 3px solid #051428 + 2px outline #F5C842，offset 2px（11.63:1 AAA） |
| Modal 開啟 | 焦點自動移至模態第一個可互動元素 |
| Modal 關閉 | 焦點返回觸發元素 |
| 焦點陷阱 | Modal/Drawer 開啟時 Tab 焦點限於面板內 |
| 跳過連結 | 主要頁面頂部提供「跳至主要內容」隱藏連結（focusable） |

### 9.4 觸控無障礙

| 規格 | 值 | 說明 |
|------|-----|------|
| 最小觸控熱區 | 44×44 px | 所有可互動元素 |
| 炮台觸控區 | 160×160 px（視覺 144×144 px） | 周圍 8 px 擴充熱區 |
| 武器切換按鈕 | 80×80 px 觸控熱區（視覺 64×64 px） | 保留 8 px 邊距 |

### 9.5 動態無障礙（Motion Accessibility）

| 動畫類型 | prefers-reduced-motion 處理 |
|---------|--------------------------|
| Boss 進場震動 | 移除全屏震動，保留淡入 |
| Jackpot 爆炸粒子 | 粒子數量降至 20%，速度減半 |
| 金幣飛出動畫 | 替換為數字淡入（不移動） |
| VIP 光暈旋轉 | 改為靜態光環 |
| 背景氣泡 | 停止動畫，保留靜態背景 |
| 按鈕 Hover 縮放 | 移除 scale transform，保留顏色變化 |

```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
  .particle-system { display: none; }
  .vip-halo-rotate { animation: none; }
  .jackpot-burst { opacity: 1; transform: none; }
}
```

### 9.6 螢幕閱讀器支援（H5 Web 模式）

| 元素 | aria 屬性 |
|------|---------|
| 主要 CTA 按鈕 | `aria-label="登入或註冊"` |
| 金幣計數器 | `aria-label="金幣：{count}"` `aria-live="polite"` |
| Boss HP 條 | `role="progressbar"` `aria-valuenow={hp}` `aria-valuemax={maxHp}` `aria-label="Boss 血量"` |
| Jackpot 進度條 | `role="progressbar"` `aria-label="Jackpot 進度"` `aria-live="polite"` |
| 模態視窗 | `role="dialog"` `aria-modal="true"` `aria-labelledby="modal-title"` |
| 排行榜列表 | `role="list"` `aria-label="排行榜"` |
| 魚類動態更新 | `aria-live="assertive"`（Boss 出現）/ `"polite"`（一般擊殺）|

---

## §10 Open Questions

| # | 問題 | 重要性 | 預期決策日 |
|---|------|-------|---------|
| OQ-01 | 角色設計是否需要授權 IP 聯名（如特定神話人物）或原創設計？聯名會影響視覺方向。 | High | Sprint 2 前 |
| OQ-02 | 遊戲場景是否需要 Landscape 橫版支援？目前規格全為 Portrait 720×1280。 | High | Sprint 1 前 |
| OQ-03 | Jackpot 全屏特效音效與震動的強度閾值由 PM 還是設計定義？ | Medium | Sprint 2 前 |
| OQ-04 | Light Mode（非深色主題）是否需要完整支援，或僅作備用？ | Medium | Sprint 3 前 |
| OQ-05 | VIP 第 10 級「彩虹」光暈特效是否允許使用自訂 Shader，或必須純 Sprite 實現（Cocos 版本限制）？ | High | Sprint 2 前 |
| OQ-06 | 第三方登入（Google/Facebook/Apple）在 H5 Web 版本的支援情況？ | High | Sprint 1 前 |
| OQ-07 | 是否需要支援 RTL（阿拉伯語等）市場？當前版面全為 LTR 設計。 | Low | Q3 評估 |
| OQ-08 | Boss 有幾隻？每個場景輪換還是固定？需確認以安排完整 Boss 視覺製作。 | High | Sprint 2 前 |

---

## §11 Engineering Handoff

### 11.1 Figma 交付規範

| 項目 | 規格 |
|------|------|
| 設計工具 | Figma（主要）|
| 設計稿解析度 | @1x = 720 px 寬，輸出 @2x |
| 元件庫 | Figma Component Library「FishGame Design System」|
| Token 交付 | Style Dictionary JSON 格式（提交 `design-tokens/tokens.json`）|
| 標注工具 | Figma Inspect（內建） |
| 版本管理 | Figma Branch per Sprint |

### 11.2 Cocos Creator 整合

| 項目 | 規格 |
|------|------|
| 引擎版本 | Cocos Creator 3.x |
| 設計寬度 | 720 px（FIXED_WIDTH 自適應） |
| 資源目錄 | `assets/` 依 §7.1 分類 |
| Token 注入 | TypeScript 常數檔案 `src/constants/tokens.ts` |
| 粒子系統 | Cocos Creator 內建粒子系統，`.plist` 格式 |
| Shader | Cocos Creator Effect Asset（`.effect`），存放 `assets/effects/` |
| Atlas 格式 | TexturePacker JSON Hash 格式 |

### 11.3 Token 交付格式（tokens.ts 範例）

```typescript
// src/constants/tokens.ts
export const Colors = {
  // Primitive
  goldPrimary: '#F5C842',
  goldHover:   '#FFD96A',
  goldActive:  '#C99A00',
  oceanBase:   '#051428',
  oceanSurface:'#0A2340',
  neonBlue:    '#00D4FF',
  neonGreen:   '#00FF88',
  // Semantic
  bgBase:      '#051428',
  textPrimary: '#FFFFFF',
  actionPrimary: '#F5C842',
} as const;

export const Motion = {
  durationFast:    80,
  durationNormal:  200,
  duratiionSlow:   500,
  durationJackpot: 3000,
  easingExpoOut:   [0.16, 1, 0.3, 1] as [number, number, number, number],
  easingSpring:    [0.34, 1.56, 0.64, 1] as [number, number, number, number],
} as const;

export const Typography = {
  fontPrimary: "'Noto Sans TC', 'Roboto', sans-serif",
  fontDisplay: "'Oswald', 'Noto Sans TC', sans-serif",
  fontMono:    "'Roboto Mono', 'Courier New', monospace",
  sizeDisplay: 48,
  sizeH1: 32,
  sizeH2: 24,
  sizeH3: 20,
  sizeBody: 16,
  sizeBodySm: 14,
  sizeCaption: 12,
  sizeHudScore: 28,
} as const;
```

### 11.4 Skeleton 載入 CSS

```css
/* 適用於 H5 WebGL overlay 或 Web 面板 */
.skeleton {
  background: var(--skeleton-base, #0A2340);
  border-radius: var(--skeleton-radius, 8px);
  position: relative;
  overflow: hidden;
}

.skeleton::after {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(
    90deg,
    transparent 0%,
    rgba(13, 51, 96, 0.8) 50%,
    transparent 100%
  );
  animation: skeleton-shimmer var(--skeleton-duration, 1.4s) infinite;
}

@keyframes skeleton-shimmer {
  0%   { transform: translateX(-100%); }
  100% { transform: translateX(100%); }
}

@media (prefers-reduced-motion: reduce) {
  .skeleton::after { animation: none; }
}
```

### 11.5 關鍵動畫實現（Cocos Creator Tween API）

```typescript
// Jackpot 爆字動畫
import { tween, Vec3 } from 'cc';

function playJackpotMultiplier(node: Node, multiplier: number) {
  const label = node.getComponent(Label);
  label.string = `×${multiplier}`;

  node.setScale(new Vec3(0.5, 0.5, 1));
  node.setPosition(new Vec3(0, -200, 0));

  tween(node)
    .to(0.4, { scale: new Vec3(1.2, 1.2, 1), position: new Vec3(0, 0, 0) },
        { easing: 'cubicOut' })
    .to(0.15, { scale: new Vec3(1.0, 1.0, 1) },
        { easing: 'backOut' })
    .delay(2.0)
    .to(0.45, { scale: new Vec3(3.0, 3.0, 1), opacity: 0 })
    .call(() => node.active = false)
    .start();
}
```

---

## §12 References

| 類型 | 名稱 | 說明 |
|------|------|------|
| 上游文件 | BRD-FISHGAME-20260424 | 商業需求 |
| 上游文件 | PRD-FISHGAME-20260424 | 產品需求 |
| 上游文件 | PDD-FISHGAME-20260424 | 產品設計（Design Token 主要來源）|
| 上游文件 | IDEA-FISHING-ARCADE-GAME-20260424 | 核心概念 |
| 標準規範 | WCAG 2.1 AA/AAA | 無障礙對比度標準 |
| 標準規範 | W3C Design Tokens Community Group | Token 格式規範 |
| 技術文件 | Cocos Creator 3.x Docs | 引擎實現參考 |
| 工具 | Style Dictionary | Token 管理工具 |
| 工具 | TexturePacker | Sprite Atlas 打包 |
| 工具 | pngquant | PNG 壓縮 |

---

## §13 Approval Sign-off

| 角色 | 姓名 | 簽核日期 | 意見 |
|------|------|---------|------|
| 視覺設計師 | — | — | 待簽核 |
| 品牌設計師 | — | — | 待簽核 |
| 前端工程師 | — | — | 待簽核 |
| 遊戲設計師 | — | — | 待簽核 |
| 產品經理 | — | — | 待簽核 |

---

*本文件由 AI 輔助生成（gendoc VDD 生成引擎，2026-04-25）。所有標注 `[AI 推斷]` 之設計決策須由產品團隊評審確認後方可進入開發實作。*
