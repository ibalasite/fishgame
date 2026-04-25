# VDD — Visual Design Document
**FishGame 競技捕魚平台**

---

## §0 Document Control

| 欄位 | 值 |
|------|-----|
| DOC-ID | VDD-FISHGAME-20260425 |
| 版本 | 1.0.0 |
| 狀態 | IN REVIEW |
| 作者 | Visual Designer + Brand Designer + Design System Engineer |
| 審查者 | Art Director（TBD）/ Brand Strategist（TBD）/ Frontend Architect（TBD）|
| 上游文件 | BRD-FISHGAME-20260424 · PRD-FISHGAME-20260424 · PDD-FISHGAME-20260424 |
| 建立日期 | 2026-04-25 |
| 目標平台 | Cocos Creator 3.x · iOS / Android · H5 WebGL |
| 設計寬度 | 720 px（FIXED_WIDTH 自適應，高度浮動） |

### 修訂記錄

| 版本 | 日期 | 作者 | 摘要 |
|------|------|------|------|
| 1.0.0 | 2026-04-25 | AI 生成 | 初版，涵蓋全部 13 章 |
| 1.0.0 IN REVIEW | 2026-04-25 | Design System Engineer | 提審時間戳：2026-04-25；R3 四項 findings 修正（line-height-loose、按鈕/Input 圓角對齊 Token、審查者欄位、Motion Token reduced-motion 腳注） |

---

## §1 Design Mission

### 1.0 Brand Positioning

**For**：亞洲 18–45 歲手機休閒遊戲玩家，他們在碎片化時間中尋找即時刺激與社交競技樂趣。

**Who**：希望在 5 分鐘內獲得「打倒 Boss、爆金幣」的爽感，同時享受多人即時排名帶來的勝負張力。

**Is**：一款融合深海主題、多人即時競技與技能深度的捕魚射擊遊戲平台。

**Unlike**：泡泡捕魚（偏休閒、缺乏競技感）、歡樂捕魚王（視覺老舊、缺乏奢華感），FishGame 主打深海奢華黑金美學，以霓虹活力特效強化每一次擊殺瞬間的多巴胺反應。

**品牌承諾**：每局都有捕獲巨額獎勵的期待感。

**視覺主張**：深海奢華黑金美學 + 霓虹活力。

#### 與主要競品視覺差異化對比

| 維度 | 泡泡捕魚 | 歡樂捕魚王 | FishGame（本作） |
|------|---------|----------|----------------|
| 主色調 | 水藍 + 亮黃 | 暖橘 + 棕金 | 深海藍 + 皇家金 + 霓虹青 |
| 視覺風格 | Q 版卡通 | 傳統街機 | Dark Luxury × Casino Arcade |
| 材質語言 | 平面卡通 | 半寫實 | 磨砂玻璃 + 金屬壓紋 + 水下散射光 |
| 特效密度 | 低 | 中 | 高（全屏 Jackpot 爆炸、多粒子層疊）|
| 競技感設計 | 弱 | 中 | 強（四角 HUD + Boss 計時 + 即時排名）|

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

### 1.4 Visual Hierarchy Rules

視覺層次透過以下 4 個維度雙重編碼，確保玩家在任何場景下 ≤1 秒內辨識資訊優先級：

| 維度 | 規則 | 說明 |
|------|------|------|
| **Scale Contrast（尺寸對比）** | text-h1（32px）≥ text-body（16px）× 2；Jackpot 倍率數字 56px 為全局最高層級 | 核心獎勵資訊以最大字號佔據視覺焦點，輔助資訊逐級縮小，禁止出現相鄰層級尺寸差 < 4px 的情況 |
| **Weight Contrast（字重對比）** | 核心 CTA 文字使用 `font-weight-700`；輔助說明文字使用 `font-weight-400`；品牌名稱與獎勵倍率數字使用 `font-weight-900` | 字重梯度遵循：900（獎勵爆字）→ 700（行動按鈕 / 面板標題）→ 600（卡片標題）→ 400（正文說明） |
| **Color Emphasis（色彩強調）** | 主要操作使用 `color-action-primary`（#F5C842）；狀態告知使用 `color-feedback-*` 系列；背景層使用 `color-bg-base`（#051428）| 金色 = 可行動；霓虹青 = 資訊/次要；紅色 = 危急/錯誤；白色 = 內容；深藍 = 容器/背景；同層級禁止同時使用兩種強調色 |
| **Whitespace Rhythm（留白節奏）** | 卡片內部 padding：`--space-4`（16px）；卡片之間間距：`--space-3`（12px）；頁面左右邊距：`--space-4`（mobile）/ `--space-6`（tablet）| 留白不應均等分布，應透過疏密對比強化分組感；核心操作區（CTA 按鈕上下）留白應比一般元素多 50% |

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

#### 參考圖片清單（視覺方向錨定）

> 具體 Figma 連結待確認（見 OQ-10）。以下為每個方向的具體視覺描述與借鑑要素。

| # | 視覺方向 | 具體描述 | 重點借鑑元素 |
|---|---------|---------|------------|
| 1 | **水下場景光影** | 深海 3000 公尺深度感：頂部藍黑漸層，散射光束從水面折射而下，形成「神光照耀」的垂直柱光；中景氣泡群緩緩上升，近景珊瑚礁輪廓模糊化處理 | 垂直光柱角度 20°、焦散（Caustic）光斑 UV 動畫、冷藍-暖金的色溫對比 |
| 2 | **玻璃質感 UI 面板** | 磨砂玻璃（Frosted Glass）半透明面板：深藍底色帶 8px backdrop-blur，頂邊有細白高光線（1px rgba(255,255,255,0.15)），底邊有深色壓暗；整體如水下潛艇艙窗般的厚重透明感 | 高光線位置與寬度、blur 強度 vs 內容可讀性平衡、邊框漸層方向 |
| 3 | **金色裝飾紋樣** | 澳門賭場風格的金色壓花紋路：細線鏤空幾何（龍紋 / 波浪紋 / 魚鱗紋），用於面板邊框、Boss 名稱框、大廳背景底紋；金色需有立體感（高光 + 陰影雙色描邊） | 紋路密度（建議 repeat 8–16px）、金屬高光角度（左上 45°）、壓花深度感 |
| 4 | **遊戲機台夜燈氛圍** | 拉斯維加斯式 Slot Machine 邊框：高飽和 LED 燈串（暖白 + 金黃 + 橘）以 60fps 閃爍，閃爍節奏為 3 燈一組「跑馬燈」效果；整體暗場景讓燈光成為主體，不依賴環境光 | 燈串間距（建議 12px）、閃爍頻率（3 組 × 12fps）、燈光暈染半徑（glow radius 8–16px）|
| 5 | **動態粒子效果** | Jackpot 爆炸瞬間：200+ 金幣粒子從中心向外噴射，前 0.3s 高速擴散（easing expo-out），後 0.7s 受重力下墜旋轉；每枚金幣帶自旋 + specular 光點；整體形成「金色爆炸雲」後緩緩落下 | 初速度範圍（600–1200 px/s）、粒子自旋轉速（2–8 rad/s）、重力係數（0.3g）、fade-out 起始時間（0.6s 後開始）|

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

### 2.4 情感色調映射（Emotional Tone Mapping）

| 情感目標 | 視覺語言 | 動效語言 |
|---------|---------|---------|
| **多巴胺刺激感** | 金色爆字（text-multiplier 56px font-weight-900）+ 霓虹青光暈（--shadow-glow-neon）+ 高飽和金幣粒子爆炸 | 快速緩動 80ms expo-out；擊殺數字 scale 0→1.2→1.0 彈入；金幣粒子初速 600–1200 px/s |
| **奢華地位感** | 深海藍底（#051428）+ 金色細線邊框（1px rgba(245,200,66,0.3)）+ 磨砂玻璃面板 + 負字距（-0.3 to -0.5px）| 慢速進場 500ms easing-ease-out；VIP 光暈 6s 緩慢旋轉 loop；面板 backdrop-blur 8px |
| **競技緊張感** | 高對比警示紅（#FF4444）+ Boss 血條危急時變色（#00FF88→#FF4444）+ 計時器等寬字體（font-mono）<br>**視覺參考錨點**：日式格鬥遊戲 HUD（KOF／SF6 血條）的高對比警示設計——紅色緊迫色 + 等寬數字字體 + 邊框閃爍特效；以及彈珠台／柏青哥計時器的倒計時壓迫感（高亮倒數格、分段警示色、快速閃爍節奏） | Boss 進場全屏震動 2s；計時器後 10 秒紅色脈衝；連擊提示 「COMBO x{n}」600ms 衝屏 |

### 2.5 場景美術規格

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
| color-gold-900 | #7A5C00 | oklch(42% 0.13 88) | 1.9:1 — | 按鈕按下狀態（僅圖形用途） |
| color-ocean-900 | #051428 | oklch(10% 0.04 240) | — (bg) | 主背景底色 |
| color-ocean-800 | #0A2340 | oklch(15% 0.05 240) | — (surface) | 卡片 / 面板底色 |
| color-ocean-700 | #0D3360 | oklch(22% 0.07 240) | — | 次級面板、邊框底色 |
| color-neon-blue | #00D4FF | oklch(82% 0.16 200) | ~10.4:1 AAA | 鑽石貨幣、Jackpot 槽、技能特效 |
| color-neon-green | #00FF88 | oklch(92% 0.22 152) | 14.1:1 AAA | 成功回饋、新手引導高亮 |
| color-white-100 | #FFFFFF | oklch(100% 0 0) | 21:1 AAA | 主要文字 |
| color-red-500 | #FF4444 | oklch(65% 0.24 27) | 4.6:1 AA | 錯誤、危險、Boss 血量危急 |

### 3.3 功能色（語義色）

| 語義 Token | 映射 | HEX（Dark Mode） | 用途 |
|-----------|------|-----------------|------|
| color-bg-base | color-ocean-900 | #051428 | 全局底色 |
| color-bg-surface | color-ocean-800 | #0A2340 | 卡片/面板 |
| color-bg-overlay | color-ocean-900 @ 85% opacity | rgba(5,20,40,0.85) | 模態遮罩 |
| color-text-primary | color-white-100 | #FFFFFF | 主要文字（21:1 AAA） |
| color-text-secondary | color-white-60 | composited #9BA1A9 | 次要文字（6.8:1 AA） |
| color-text-disabled | color-white-35 | composited #5C6673 | 禁用文字（WCAG 1.4.3 豁免） |
| color-action-primary | color-gold-400 | #F5C842 | CTA 按鈕（7.2:1 AAA） |
| color-action-primary-active | color-gold-600 | #C99A00 | 按鈕按下（Active Press）狀態 |
| color-action-secondary | color-neon-blue | #00D4FF | 次要行動（~10.4:1 AAA） |
| color-feedback-success | color-neon-green | #00FF88 | 成功狀態（14.1:1 AAA） |
| color-feedback-error | color-red-500 | #FF4444 | 失敗/錯誤（4.6:1 AA） |
| color-feedback-warning | color-red-300 | #FF8080 | 警告（7.61:1 AAA） |
| color-feedback-info | color-neon-blue | #00D4FF | 提示（~10.4:1 AAA） |
| color-border-default | color-white-45 | composited #767E89 | 預設邊框（3.2:1 WCAG 1.4.11） |
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

**最小尺寸規格**：

| 平台 | 最小高度 | 說明 |
|------|---------|------|
| Digital（APP / H5） | 高度 ≥ 24px（寬度自適應） | 低於此尺寸 Logo 識別度不足，禁止使用 |
| Print（若適用） | 高度 ≥ 12mm | 印刷品最小可識別尺寸 |

**Safe Zone 統一規則**：Logo 高度 × 0.25 四周留白（適用遊戲啟動頁、大廳左上角、結算面板浮水印三個情境）。

**禁止用法列表**：
- 不得使用低於最小尺寸（Digital 高度 < 24px）
- 不得直接放在淺色背景（#FFFFFF 或亮度 > 70% 的背景）上使用金色版本
- 不得在金色背景使用金色 Logo（背景與 Logo 缺乏對比）
- 不得壓縮或拉伸變形（須保持原始寬高比）
- 不得加陰影、描邊、外發光（會破壞 Logo 精緻感）
- 不得使用低於品牌規定色以外的顏色版本

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

### 4.1 主角設計——「海神炮手」（Captain Triton）（待 OQ-09 確認後移除此標注）

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

#### NPC-04 神話生物（Mythic Creature）（待 OQ-09 確認後移除此標注）

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
| Body-MD | text-body-md | 18 px | 28 px | 400 | 0 | 引導氣泡說明（OnboardingScene）、次要正文 |
| HUD-Counter | text-hud-counter | 20 px | 24 px | 600 | 0 | HUD 貨幣計數器 |
| Heading-LG | text-heading-lg | 36 px | 44 px | 700 | -0.3 px | 大標題結算（MVP 結算、Jackpot 爆字輔助） |
| Multiplier | text-multiplier | 56 px | 60 px | 900 | -1 px | 倍率爆字（Display 字體） |
| Heading-MD | text-heading-md | 24 px | 32 px | 700 | -0.2 px | 面板中標題、VIP 等級標題（補充 H2 semibold，需要 bold 700 時使用）|
| Button-Label | text-button-label | 18 px | 22 px | 500 | 0 | CTA 按鈕文字（Primary / Secondary）|

### 5.3 按鈕規格

#### 主要按鈕（Primary Button）

| 狀態 | 背景 | 文字色 | 邊框 | 陰影 | 效果 |
|------|------|-------|------|------|------|
| Default | #F5C842（金屬漸層：#F5C842→#C99A00） | `var(--btn-primary-text)` #0A1A00 | 無 | 0 0 12px rgba(245,200,66,0.8) | — |
| Hover | #C99A00 | `var(--btn-primary-text)` #0A1A00 | 無 | 0 0 20px rgba(245,200,66,0.9) | scale(1.03) |
| Active / Press | #C99A00 | `var(--btn-primary-text)` #0A1A00 | 無 | inset 0 2px 4px rgba(0,0,0,0.4) | scale(0.98), translateY(2px) |
| Focus | #F5C842 | `var(--btn-primary-text)` #0A1A00 | 3px solid #051428 + 2px outline #F5C842 | — | Ring 11.63:1 AAA |
| Disabled | `btn-disabled-bg` = `color-bg-surface`（#0A2340） | `btn-disabled-text` = `color-text-disabled`（#5C6673） | 無 | 無 | opacity 0.5；cursor: not-allowed |

**尺寸**：高度 56 px，水平 Padding 24 px，圓角 `--radius-md`（16 px），最小寬度 160 px；字型：`text-button-label`（18 px / 22 px / 500）

#### 次要按鈕（Secondary Button）

| 狀態 | 背景 | 文字色 | 邊框 |
|------|------|-------|------|
| Default | transparent | `color-action-secondary`（#00D4FF） | 2px solid `color-action-secondary`（#00D4FF） |
| Hover | rgba(0,212,255,0.1) | `color-action-secondary-hover`（#40DFFF） | 2px solid `color-action-secondary-hover`（#40DFFF） |
| Active | rgba(0,212,255,0.2) | `color-action-secondary`（#00D4FF） | 2px solid `color-action-secondary-active`（#00A8CC） |
| Focus | transparent | `color-action-secondary`（#00D4FF） | 3px solid #051428 + 2px outline `color-action-secondary`（#00D4FF） |
| Disabled | transparent opacity 0.4 | rgba(0,212,255,0.4) | 2px solid rgba(0,212,255,0.4) |

**尺寸**：高度 48 px，水平 Padding 20 px，圓角 `--radius-md`（16 px）；字型：`text-button-label`（18 px / 22 px / 500）

#### 圖示按鈕（Icon Button）

| 狀態 | 圖示色 | 背景 | 效果 |
|------|-------|------|------|
| Default | `color-text-secondary` (#9BA1A9) | transparent | — |
| Hover | `color-text-primary` (#FFFFFF) | rgba(255,255,255,0.08) | — |
| Active | `color-text-primary` (#FFFFFF) | rgba(255,255,255,0.12) | scale(0.92) |
| Focus | `color-text-primary` (#FFFFFF) | transparent | 2px outline `color-border-focus` (#F5C842) |
| Disabled | `color-text-secondary` (#9BA1A9) opacity 0.4 | transparent | cursor: not-allowed |

**尺寸**：40×40 px，圓角 `--radius-icon`（20 px，圓形），觸控熱區 ≥ 44×44 px

#### 危險按鈕（Danger Button）

| 狀態 | 背景 | 文字色 | 邊框 | 效果 |
|------|------|-------|------|------|
| Default | `var(--color-action-danger)` = #FF4444 | #FFFFFF | 無 | — |
| Hover | `var(--color-red-700)` = #CC0000 | #FFFFFF | 無 | scale(1.02) |
| Active | #CC0000 | #FFFFFF | 無 | scale(0.98)，inset 0 2px 4px rgba(0,0,0,0.4) |
| Focus | #FF4444 | #FFFFFF | 3px solid #051428 + 2px outline #FF4444 | Ring 4.6:1 AA |
| Disabled | #FF4444 opacity 0.5 | rgba(255,255,255,0.4) | 無 | cursor: not-allowed |

**尺寸**：高度 48 px，水平 Padding 20 px，圓角 `--radius-md`（16px）；字型：`text-button-label`（18 px / 22 px / 500）

### 5.4 輸入欄位規格

| 狀態 | 背景 | 邊框 | 文字色 | 提示文字色 |
|------|------|------|-------|----------|
| Default | rgba(255,255,255,0.05) | 1px solid `color-border-default`（rgba(255,255,255,0.45)） | #FFFFFF | rgba(255,255,255,0.4) |
| Hover | rgba(255,255,255,0.07) | 1px solid `color-border-strong`（rgba(255,255,255,0.7)） | #FFFFFF | rgba(255,255,255,0.4) |
| Focus | rgba(255,255,255,0.08) | 2px solid `color-border-focus`（#F5C842）| #FFFFFF | — |
| Error | rgba(255,68,68,0.08) | 2px solid `color-border-error`（#FF4444） | #FFFFFF | — |
| Disabled | rgba(255,255,255,0.02) | 1px solid `color-border-subtle`（rgba(255,255,255,0.2)） | `color-text-disabled`（rgba(255,255,255,0.35)） | — |

**尺寸**：高度 52 px，水平 Padding 16 px，圓角 `--radius-md`（16 px）

### 5.5 卡片 / 面板規格

| 類型 | 背景 | 邊框 | 圓角 | 陰影 |
|------|------|------|------|------|
| 標準面板 | rgba(10,35,64,0.95) | 1px solid `var(--card-border)` (= rgba(245,200,66,0.55)) | `--radius-lg`（24px） | 0 8px 32px rgba(0,0,0,0.6) |
| 高亮面板（VIP/特殊） | rgba(10,35,64,0.98) | 2px solid #F5C842 | `--radius-lg`（24px） | 0 0 24px rgba(245,200,66,0.4) |
| 模態背景遮罩 | rgba(5,20,40,0.85) backdrop-blur 8px | — | — | — |
| 武器選擇卡 | rgba(13,51,96,0.9) | 2px solid rgba(245,200,66,0.5) | `--radius-md`（16px） | inset 0 1px 0 rgba(255,255,255,0.1) |
| 商品卡片 | rgba(15,10,0,0.9) | 1px solid rgba(245,200,66,0.4) | `--radius-lg`（24px） | 0 4px 16px rgba(0,0,0,0.5) |

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
| 標籤字級 | text-caption 12px |
| 選中狀態 | 圖示 #F5C842，標籤 #F5C842，底部 3px #F5C842 高亮條 |
| 未選中狀態 | 圖示 rgba(255,255,255,0.5)，標籤 rgba(255,255,255,0.5) |

### 5.8 Dropdown 元件規格

Dropdown 用於語言切換、圖形品質選擇、房間篩選等場景。所有值引用 Semantic Token。

#### 狀態視覺矩陣

| 狀態 | 背景 | 邊框 | 文字色 | 說明 |
|------|------|------|-------|------|
| Default | `color-bg-surface`（#0A2340） | 1px solid `color-border-default`（rgba(255,255,255,0.45)） | `color-text-primary`（#FFFFFF） | 預設收起狀態 |
| Hover | `color-bg-elevated`（#0D3360） | 1px solid `color-border-focus`（#F5C842） | `color-text-primary` | 滑鼠懸停 / 觸控長押前 |
| Focus | `color-bg-surface`（#0A2340） | 2px solid `color-border-focus`（#F5C842） + 2px outline `color-ocean-900`（#051428）| `color-text-primary` | 鍵盤 Tab 焦點；focus ring 外層深色確保可見（11.63:1 AAA）|
| Open（展開） | `color-bg-elevated`（#0D3360） | 2px solid `color-border-focus`（#F5C842） | `color-text-primary` | Dropdown list 顯示；list container 使用 `shadow-card`（0 8px 32px rgba(0,0,0,0.6)） |
| Selected（選中項） | `color-action-primary`（#F5C842） | 無 | `color-bg-base`（#051428，深色反白） | List item 已選中行，高亮區分 |
| Disabled | `color-bg-surface` opacity 40% | 1px solid `color-border-default` opacity 40% | `color-text-disabled` | 不可交互；cursor: not-allowed；pointer-events: none |

**尺寸規格**：高度 48 px，水平 Padding 16 px，圓角 `--radius-md`（16 px）；Dropdown list 最大高度 240 px（超出時啟用 ScrollView）

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
--color-gold-900: #7A5C00;   /* oklch(42% 0.13 88) */
--color-gold-950: #3D2E00;   /* oklch(22% 0.08 88) */

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
--color-neon-purple:#A020F0; /* oklch(50% 0.25 290) — Boss 魔法效果 */

--color-yellow-400: #FFEB3B; /* HP 條中段純黃（區別於品牌金 #F5C842，視覺更純正的黃色）*/

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
--color-white-70:  rgba(255,255,255,0.7);  /* color-border-strong */
--color-white-60:  rgba(255,255,255,0.6);
--color-white-45:  rgba(255,255,255,0.45);
--color-white-40:  rgba(255,255,255,0.4);
--color-white-35:  rgba(255,255,255,0.35);
--color-white-20:  rgba(255,255,255,0.2);
--color-neon-blue-light: #40DFFF;    /* color-action-secondary-hover */
--color-neon-blue-dark:  #00A8CC;    /* color-action-secondary-active */
--color-black-80:  rgba(0,0,0,0.8);  /* 技能冷卻遮罩（skill-cooldown-mask）*/
--color-black-60:  rgba(0,0,0,0.6);  /* color-bg-scrim / fish-label-bg */
--color-black-900: #000000;

/* ── Typography ── */
--font-family-primary: 'Noto Sans TC', 'Roboto', 'PingFang TC', sans-serif;
--font-family-display: 'Oswald', 'Noto Sans TC', sans-serif;
--font-family-mono:    'Roboto Mono', 'Courier New', monospace;

--font-size-12: 12px;
--font-size-14: 14px;
--font-size-16: 16px;
--font-size-18: 18px;
--font-size-20: 20px;
--font-size-24: 24px;
--font-size-28: 28px;
--font-size-32: 32px;
--font-size-36: 36px;
--font-size-48: 48px;
--font-size-56: 56px;

--font-weight-400: 400;
--font-weight-500: 500;
--font-weight-600: 600;
--font-weight-700: 700;
--font-weight-900: 900;

--line-height-tight:  1.2;
--line-height-normal: 1.5;
--line-height-loose:  1.8;

/* ── Spacing ──
   VDD CSS 命名規則：--space-{index}（4px 倍數 index）
   對應 PDD §9.3 spacing-{px} 命名：
     --space-1=4px   ↔ spacing-4
     --space-2=8px   ↔ spacing-8
     --space-3=12px  ↔ spacing-12
     --space-4=16px  ↔ spacing-16
     --space-6=24px  ↔ spacing-24
     --space-8=32px  ↔ spacing-32
     --space-12=48px ↔ spacing-48
     --space-5/10/16 = VDD-only extensions (20/40/64px，無 PDD 對應)
*/
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
--radius-sm:  8px;
--radius-md:  16px;
--radius-lg:  24px;
--radius-icon: 20px;   /* Component-specific：圖示按鈕圓角（視覺圓形，低於 lg=24px 以貼合 40×40px 尺寸比例） */
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
--easing-ease-out:  cubic-bezier(0.0, 0, 0.58, 1);
--easing-expo-out:  cubic-bezier(0.16, 1, 0.3, 1);
--easing-spring:    cubic-bezier(0.34, 1.56, 0.64, 1);
--easing-bounce:    cubic-bezier(0.68, -0.55, 0.265, 1.55);

/* ── Shadow ── */
--shadow-glow-gold:  0 0 12px rgba(245,200,66,0.8);
--shadow-glow-neon:  0 0 8px rgba(0,212,255,0.6);
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
--color-bg-overlay:     rgba(5,20,40,0.85);        /* = color-ocean-900 (#051428) @ 85% opacity */
--color-bg-scrim:       var(--color-black-60);    /* rgba(0,0,0,0.6) */

/* ── Text ── */
--color-text-primary:   var(--color-white-100);              /* #FFFFFF  21:1  AAA */
--color-text-secondary: var(--color-white-60);               /* composited #9BA1A9  6.8:1 AA */
--color-text-tertiary:  var(--color-white-40);               /* composited #767E89  3.5:1 AA（非文字用） */
--color-text-disabled:  var(--color-white-35);
--color-text-inverse:   #0A1A00;                             /* on 金色底；12.3:1 AAA（§9.1）；獨立值，非 ocean-900 別名 */
--color-text-brand:     var(--color-gold-400);               /* #F5C842  7.2:1 AAA */
--color-text-accent:    var(--color-neon-blue);              /* #00D4FF  ~10.4:1 AAA */
--color-text-success:   var(--color-neon-green);             /* #00FF88  14.1:1 AAA */
--color-text-error:     var(--color-red-500);                /* #FF4444  4.6:1 AA */
--color-text-warning:   var(--color-red-300);                /* #FF8080  7.61:1 AAA */

/* ── Action ── */
--color-action-primary:          var(--color-gold-400);
--color-action-primary-hover:    var(--color-gold-600);
--color-action-primary-active:   var(--color-gold-600);
--color-action-secondary:        var(--color-neon-blue);
--color-action-secondary-hover:  var(--color-neon-blue-light);   /* #40DFFF */
--color-action-secondary-active: var(--color-neon-blue-dark);    /* #00A8CC */
--color-action-danger:           var(--color-red-500);

/* ── Border ── */
--color-border-default: var(--color-white-45);    /* composited #767E89 3.2:1 WCAG 1.4.11 */
--color-border-subtle:  var(--color-white-20);    /* rgba(255,255,255,0.2) */
--color-border-strong:  var(--color-white-70);    /* rgba(255,255,255,0.7) */
--color-border-brand:   var(--color-gold-400);
--color-border-focus:   var(--color-gold-400);    /* 11.63:1 AAA */
--color-border-active:  var(--color-neon-blue);   /* #00D4FF；選中/Active 狀態（Tab Bar 高亮條、Dropdown 選中項輪廓）*/
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
--color-gold-border-subtle: rgba(245,200,66,0.55);  /* color-gold-400 @ 55%；WCAG 1.4.11 UI boundary ≥3:1（~4.2:1 on ocean-900）；Cocos 環境不支援 CSS color-mix，無法生成 opacity primitive；HUD/卡片玻璃面板邊框主題色（多個元件共用）*/
--color-vip-identity:      var(--color-vip-gold);  /* 預設，runtime 依等級覆蓋 */
--color-accent-vip:        var(--color-vip-identity); /* VIP 徽章強調色（PDD §9.3 Layer 2 color-accent-vip）*/
--color-hp-high:           var(--color-neon-green);
--color-hp-mid:            var(--color-yellow-400);  /* #FFEB3B，HP 中段（視覺純黃，區別於品牌金 #F5C842）*/
--color-hp-low:            var(--color-red-500);
/* --color-jackpot-progress: Jackpot 進度條漸層不使用 CSS Custom Property 定義，
   因為 CSS Custom Property 不支援 gradient 值作為 background 簡寫的部分。
   請使用 §6.3 的 --jackpot-bar-fill-start 和 --jackpot-bar-fill-end 兩個 Component Token 組成漸層：
   background: linear-gradient(90deg, var(--jackpot-bar-fill-start), var(--jackpot-bar-fill-end)); */
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
--btn-primary-focus-ring:  var(--color-ocean-900);  /* #051428；金色按鈕上的焦點環必須用深色，避免金-on-金不可見（11.6:1 AAA）*/
--btn-primary-height:      56px;
--btn-primary-px:          24px;

/* ── Button — Secondary ── */
--btn-secondary-border:    var(--color-action-secondary);
--btn-secondary-text:      var(--color-action-secondary);
--btn-secondary-bg-hover:  rgba(0,212,255,0.1);   /* neon-blue @ 10%，無匹配 primitive，直接值 */
--btn-secondary-bg-active: rgba(0,212,255,0.2);   /* neon-blue @ 20% */
--btn-secondary-radius:    var(--radius-md);
--btn-secondary-height:    48px;

/* ── HUD ── */
--hud-bg:                  rgba(10,35,64,0.8);    /* color-ocean-800 @ 80%，無匹配 primitive，直接值 */
--hud-border:              var(--color-gold-border-subtle);   /* color-gold-400 @ 55%；via --color-gold-border-subtle */
--hud-coin-color:          var(--color-gold-400);
--hud-diamond-color:       var(--color-neon-blue);
--hud-text-color:          var(--color-white-100);
--hud-score-font:          var(--font-family-mono);
--hud-score-size:          var(--font-size-28);

/* ── Jackpot Bar ── */
--jackpot-bar-bg:          rgba(10,35,64,0.9);    /* color-ocean-800 @ 90%，無匹配 primitive，直接值 */
--jackpot-bar-border:      var(--color-gold-400);
--jackpot-bar-fill-start:  var(--color-neon-blue);
--jackpot-bar-fill-end:    var(--color-gold-400);
--jackpot-bar-height:      24px;
--jackpot-bar-radius:      var(--radius-full);
--jackpot-bar-glow:        var(--shadow-glow-gold);

/* ── Boss HP Bar ── */
--boss-hp-bg:              rgba(0,0,0,0.7);    /* black @ 70%；無匹配 primitive（black-60=60%，black-80=80%），直接值 */
--boss-hp-border:          var(--color-gold-400);
--boss-hp-fill-high:       var(--color-hp-high);
--boss-hp-fill-mid:        var(--color-hp-mid);
--boss-hp-fill-low:        var(--color-hp-low);
--boss-hp-height:          32px;
--boss-hp-transition:      var(--duration-normal) var(--easing-expo-out);

/* ── Card / Panel ── */
--card-bg:                 rgba(10,35,64,0.95);   /* color-ocean-800 @ 95%，無匹配 primitive，直接值 */
--card-border:             var(--color-gold-border-subtle);   /* color-gold-400 @ 55%；via --color-gold-border-subtle */
--card-border-width:       1px;
--card-radius:             var(--radius-lg);
--card-shadow:             var(--shadow-card);

/* ── Input ── */
--input-bg:                rgba(255,255,255,0.05);  /* white @ 5%，無匹配 primitive，直接值 */
--input-bg-focus:          rgba(255,255,255,0.08);  /* white @ 8%，無匹配 primitive，直接值 */
--input-border:            var(--color-border-default);
--input-border-focus:      var(--color-border-focus);
--input-border-error:      var(--color-border-error);
--input-text:              var(--color-text-primary);
--input-placeholder:       var(--color-white-40);    /* rgba(255,255,255,0.4) */
--input-height:            52px;
--input-radius:            var(--radius-md);
--input-px:                16px;

/* ── Dropdown ── */
--dropdown-bg:              var(--color-bg-surface);    /* Default 收起背景 */
--dropdown-bg-hover:        var(--color-bg-elevated);   /* Hover / Open 背景 */
--dropdown-bg-open:         var(--color-bg-elevated);
--dropdown-border:          var(--color-border-default);
--dropdown-border-focus:    var(--color-border-focus);  /* 2px solid gold focus ring */
--dropdown-text:            var(--color-text-primary);
--dropdown-text-disabled:   var(--color-text-disabled);
--dropdown-radius:          var(--radius-md);           /* 16px */
--dropdown-height:          48px;
--dropdown-shadow-open:     var(--shadow-card);         /* Dropdown list 懸浮陰影 */
--dropdown-selected-bg:     var(--color-action-primary);
--dropdown-selected-text:   var(--color-bg-base);       /* #051428，深色反白 */

/* ── VIP Badge ── */
--vip-badge-border-width:  2px;
--vip-badge-glow-radius:   8px;
--vip-badge-radius:        var(--radius-full);

/* ── Modal ── */
--modal-overlay:           var(--color-bg-overlay);  /* rgba(5,20,40,0.85) */
--modal-bg:                var(--color-bg-surface);
--modal-border:            var(--color-gold-border-subtle);   /* rgba(245,200,66,0.55)；WCAG 1.4.11 ≥3:1（3.88:1 on ocean-800）*/
--modal-radius:            var(--radius-lg);

/* ── Toast / Alert ── */
--toast-success-bg:        rgba(0,255,136,0.15);  /* neon-green @ 15%，overlay tint，無匹配 primitive，直接值 */
--toast-success-border:    var(--color-feedback-success);
--toast-error-bg:          rgba(255,68,68,0.15);   /* red-500 @ 15%，overlay tint，無匹配 primitive，直接值 */
--toast-error-border:      var(--color-feedback-error);

/* ── Fish Name Label ── */
--fish-label-bg:           var(--color-black-60);   /* rgba(0,0,0,0.6) */
--fish-label-text:         var(--color-white-100);
--fish-label-font-size:    var(--font-size-12);

/* ── Weapon Select Card ── */
--weapon-card-bg:          rgba(13,51,96,0.9);    /* color-ocean-700 @ 90%，無匹配 primitive，直接值 */
--weapon-card-border:      rgba(245,200,66,0.5);   /* color-gold-400 @ 50%；武器卡片使用稍暗金色（視覺層次與 HUD/卡片 0.55 有意區分），無匹配 primitive，直接值 */
--weapon-card-radius:      var(--radius-md);
--weapon-card-selected-glow: var(--shadow-glow-gold);

/* ── Settlement ── */
--settle-win-bg:           linear-gradient(180deg, rgba(245,200,66,0.15), rgba(5,20,40,0.95));  /* 0.95 = color-ocean-900 @ 95%；CSS gradient 不支援 var()，共用值見 settle-loss-bg */
--settle-win-border:       var(--color-gold-400);
--settle-loss-bg:          linear-gradient(180deg, rgba(13,51,96,0.5), rgba(5,20,40,0.95));   /* 0.95 = color-ocean-900 @ 95%；CSS gradient 不支援 var()，共用值見 settle-win-bg */
--settle-loss-border:      var(--color-border-subtle);   /* rgba(255,255,255,0.2) = color-white-20 */

/* ── Skeleton Loading ── */
--skeleton-base:   var(--color-bg-surface);     /* #0A2340 = color-ocean-800 */
--skeleton-shine:  var(--color-bg-elevated);    /* #0D3360 = color-ocean-700 */
--skeleton-radius: var(--radius-md);
--skeleton-duration: 1.4s;
```

### 6.4 Dark Mode Token 對應表（含 WCAG 驗證）

> **Light Mode 欄說明**：v2.0 預留，v1.0 暫不實作。以下 Light Mode 值僅供未來規劃參考，不進入 v1.0 開發實作。

| Semantic Token | Dark Mode 值 | Light Mode 值（v2.0 預留）| 對比比（Dark on bg-base） | WCAG 等級 |
|---------------|-------------|---------------------|--------------------------|----------|
| color-text-primary | #FFFFFF | #111827 | 21:1 | AAA |
| color-text-secondary | rgba(255,255,255,0.6) ≈ #9BA1A9 | #6B7280 | 6.8:1 | AA |
| color-text-tertiary | rgba(255,255,255,0.4) ≈ #767E89 | #9CA3AF | 3.5:1 | AA（非文字）|
| color-text-disabled | rgba(255,255,255,0.35) | #D1D5DB | — | 裝飾用，不適用 |
| color-text-brand | #F5C842 | #C99A00 | 7.2:1 | AAA |
| color-text-accent | #00D4FF | #0284C7 | ~10.4:1 | AAA |
| color-text-success | #00FF88 | #059669 | 14.1:1 | AAA |
| color-text-error | #FF4444 | #DC2626 | 4.6:1 | AA |
| color-text-warning | #FF8080 | #D97706 | 7.61:1 | AAA |
| color-action-primary | #F5C842 | #C99A00 | 7.2:1 | AAA |
| color-action-secondary | #00D4FF | #0284C7 | ~10.4:1 | AAA |
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

> **注：Prefers-Reduced-Motion 替代值**
> 所有 `duration-*` Token 在 `prefers-reduced-motion: reduce` 環境下統一使用 `--duration-instant`（0ms）替代；
> 所有 `easing-*` Token 改為 `linear`。
> 詳細 CSS Override 規則及 prefers-reduced-motion 處理見 §9.5 動態無障礙。

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
| 粒子系統 | `.plist`（Cocos Particle Data）| — | `assets/particles/` |

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
  particle_jackpot_burst.plist
  particle_weapon_laser.plist

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
| 霓虹青色文字 | #00D4FF | #051428 | ~10.4:1 | AAA | ✓ |
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
| Modal/HUD/卡片邊框（non-text）| rgba(245,200,66,0.55) | #0A2340 | 3.88:1 | 1.4.11 | ✓ |
| 禁用文字 | rgba(255,255,255,0.35) | #051428 | 2.9:1 | — | 裝飾用 |
| 危險按鈕 Default 文字 | #FFFFFF | #FF4444 | 4.6:1 | AA | ✓ |
| 危險按鈕 Hover/Active 文字 | #FFFFFF | #CC0000 | 5.9:1 | AA | ✓ |

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
| Dropdown 焦點例外 | `2px solid #F5C842 + 2px outline #051428`（金色在前、深色在外），因元件本身底色為 `color-bg-surface`（#0A2340），pattern 反轉後焦點可見性相同（11.63:1 AAA）|
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
| OQ-04 | Light Mode（非深色主題）是否需要完整支援，或僅作備用？ | Medium | **已決定：v2.0 預留，v1.0 僅支援 Dark Mode** |
| OQ-05 | VIP 第 10 級「彩虹」光暈特效是否允許使用自訂 Shader，或必須純 Sprite 實現（Cocos 版本限制）？ | High | Sprint 2 前 |
| OQ-06 | 第三方登入（Google/Facebook/Apple）在 H5 Web 版本的支援情況？ | High | Sprint 1 前 |
| OQ-07 | 是否需要支援 RTL（阿拉伯語等）市場？當前版面全為 LTR 設計。 | Low | Q3 評估 |
| OQ-08 | Boss 有幾隻？每個場景輪換還是固定？需確認以安排完整 Boss 視覺製作。 | High | Sprint 2 前 |
| OQ-09 | 主角 Captain Triton 及神話生物（§4.4 NPC-04）設計方向是否確認？包含視覺特徵、配色方案、技能數量。決策人：遊戲設計師，deadline: 2026-05-15 | High | 2026-05-15 |
| OQ-10 | Figma File URL 及 P0 元件 Frame 連結待確認。決策人：設計師，deadline: 2026-05-15 | Medium | 2026-05-15 |

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
| **Figma File URL** | 見 OQ-10 |
| **P0 元件 Frame 連結** | 見 OQ-10 |
| **Auto Layout 使用狀態** | 所有 Component 使用 Auto Layout，Spacing 引用 Token |
| **Dev Mode 交付方式** | Figma Dev Mode + Handoff 說明文件 |

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
  goldHover:   '#C99A00',   // color-gold-600 / color-action-primary-hover
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
  durationSlow:    500,
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
  sizeBodyMd: 18,       // text-body-md — OnboardingScene 引導氣泡
  sizeHudCounter: 20,   // text-hud-counter — HUD 貨幣計數器
  sizeHeadingLg: 36,    // text-heading-lg — 結算 MVP/Jackpot 大標題
  sizeMultiplier: 56,   // text-multiplier — Jackpot/kill 爆字
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

## §13 Visual Variation Rules

本章定義哪些視覺元素可依節日活動、季節限定情境進行主題變體，哪些元素屬於品牌核心不可更動。

### 13.1 可變元素（Seasonal / Event Variants）

| 元素 | 變體範圍 | 範例 |
|------|---------|------|
| 節日活動 Banner 主題色 | 可替換 Banner 背景漸層色與邊框色 | 春節：大紅 #E53935 + 金黃 #FFD700；聖誕：墨綠 #1B5E20 + 紅白 |
| 季節限定 NPC 配色 | 季節限定 Boss / 神話生物的主色與輪廓光顏色 | 春節：鳳凰魚 #FF6D00+#FFEB3B；中秋：玉兔 #F0E68C+#00D4FF |
| 特效光暈色調 | Jackpot 爆炸粒子色、金幣粒子色可依活動主題調整 | 春節活動 Jackpot：紅金粒子；萬聖節：紫橘粒子 |
| 大廳背景裝飾元素 | 季節裝飾物（燈籠、雪花、彩蛋等）可疊加至背景層 | 春節：燈籠飄浮動畫；聖誕：雪花飄落粒子 |

### 13.2 不可變元素（Brand Core — 禁止在任何變體中修改）

| 元素 | 說明 |
|------|------|
| 主色系 Token（深海藍 / 皇家金） | `--color-ocean-900` / `--color-gold-400` 系列不可替換 |
| Logo 識別 | Logo 本體、比例、標準色版本不可修改 |
| 主字體系統 | Noto Sans TC / Oswald / Roboto Mono 三字體族不可替換 |
| 核心 HUD 佈局 | 四角炮台 HUD、Jackpot 條、Boss HP 條的位置與尺寸不可變動 |
| 無障礙對比度規範 | 即便在節日主題下，所有文字與 UI 元素須維持 WCAG 2.1 AA 以上對比度 |

---

## §14 Brand Extension Guidelines

> 目前 FishGame 僅有主品牌，尚無子品牌或聯名合作。本章為空白框架，具體規則待 v2.0 補充。

### 14.1 子品牌規範（Sub-brand Framework）

| 項目 | 規則 |
|------|------|
| 品牌識別組合 | 副標題 + 主 Logo 並排；副標文字位於主 Logo 右側或下方 |
| 字型限制 | 副標字型不得修改主品牌字型系統（Noto Sans TC / Oswald / Roboto Mono）；副標可使用 Noto Sans TC 的不同字重 |
| 色彩使用 | 子品牌強調色可在季節限定範圍內調整（參見 §13.1），但 `--color-ocean-900` / `--color-gold-400` 主色系不可替換 |
| 具體細則 | 待 v2.0 補充 |

### 14.2 聯名合作規範（Co-branding Framework）

| 項目 | 規則 |
|------|------|
| 合作方 Logo 位置 | 置於畫面右側（橫排）或下方（直排），與主 Logo 保持對等視覺重量 |
| 最小尺寸 | 合作方 Logo 高度 ≥ 主 Logo 高度 × 0.8（不得小於主 Logo） |
| 間距 | 主 Logo 與合作方 Logo 之間以分隔線（1px，rgba(255,255,255,0.3)）或等寬空白（≥ 主 Logo 高度）區隔 |
| 禁止用法 | 不得使合作方 Logo 壓過主 Logo；不得在合作版本中移除主品牌金色主色系 |
| 具體細則 | 待有聯名項目時由品牌設計師補充至 v2.0 |

---

## §15 Approval Sign-off

| 角色 | 姓名 | 簽核日期 | 狀態 | 意見 |
|------|------|---------|------|------|
| 視覺設計師 | （待 OQ-09/OQ-10 關閉後簽核，目標 2026-05-15） | — | 審查中 | — |
| 品牌設計師 | （待 OQ-09/OQ-10 關閉後簽核，目標 2026-05-15） | — | 審查中 | — |
| 前端工程師 | （待 OQ-09/OQ-10 關閉後簽核，目標 2026-05-15） | — | 審查中 | — |
| 遊戲設計師 | （待 OQ-09/OQ-10 關閉後簽核，目標 2026-05-15） | — | 審查中 | — |
| 產品經理 | （待 OQ-09/OQ-10 關閉後簽核，目標 2026-05-15） | — | 審查中 | — |

---

*本文件由 AI 輔助生成（gendoc VDD 生成引擎，2026-04-25）。所有標注 `[AI 推斷]` 之設計決策須由產品團隊評審確認後方可進入開發實作。*
