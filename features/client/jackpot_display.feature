# features/client/jackpot_display.feature
# 來源：PRD US-RTP-001；PDD §6.5 Jackpot 全屏特效微互動；VDD §2.4 情感色調映射（多巴胺刺激感）
# FRONTEND.md §5 JackpotBar.ts；VDD §4.2 NPC-03 Boss 死亡特效規格
# Client 層面：Jackpot 進度條、貢獻動畫、觸發全屏序列、返回正常 UI

Feature: Jackpot 顯示與觸發動畫
  作為遊戲中的玩家
  我希望在大廳和遊戲中清楚看到 Jackpot 獎池累積進度
  以便感受到每次射擊都在累積大獎的期待感，並在 Jackpot 觸發時享受全場沸騰的視覺盛宴

  Background:
    Given 玩家已登入
    And Colyseus 服務狀態正常

  # ─── 大廳 Jackpot 顯示 ──────────────────────────────────────

  @client @p0 @visual
  Scenario: 大廳顯示當前 Jackpot 獎池金額（靜態顯示）
    Given 玩家進入 LobbyScene
    When LobbyUI 從 Colyseus 或 REST API 取得 Jackpot 狀態
    Then 大廳頂部顯示 Jackpot 獎池金額（例如 "¥1,234,567"）
    And 金額使用 VDD "text-display"（48px / font-weight-700 / font-family-display）
    And 文字顏色使用 color-neon-blue（#00D4FF，--color-action-secondary）
    And 「JACKPOT」標題文字使用 color-gold-400（#F5C842）
    And 標題區域有輕微霓虹光暈（shadow-glow-neon）

  @client @p0 @visual
  Scenario: 遊戲中 HUD 底部顯示 Jackpot 進度條
    Given 玩家已進入 GameScene
    When JackpotBar 元件初始化並從 Colyseus state 讀取進度
    Then HUD 底部顯示 Jackpot 進度條（寬度與屏幕同寬 720px，高度 8px）
    And 進度條填充色使用 color-neon-blue（#00D4FF，漸層→color-gold-400）
    And 進度條右端顯示當前 Jackpot 金額數字（text-hud-counter，20px）
    And 進度條背景使用 color-bg-overlay（rgba(5,20,40,0.85)）

  # ─── 其他玩家貢獻時進度條動畫 ────────────────────────────────

  @client @p1 @interaction
  Scenario: 其他玩家射擊時 Jackpot 進度條跳動
    Given GameScene Jackpot 進度條已顯示（當前進度 45%）
    When 任意玩家命中魚（Colyseus jackpot_increment 事件）
    Then 進度條以 Tween（150ms，ease-out）動畫向右延伸，新進度比例更新
    And Jackpot 金額數字以滾動動畫（Tween 300ms）更新為新數值
    And 進度條閃爍一次（opacity 1.0→0.7→1.0，200ms）

  @client @p1 @visual
  Scenario: Jackpot 進度接近滿格時進度條顏色警示
    Given Jackpot 進度條當前進度為 90%
    When Colyseus jackpot_increment 事件使進度更新至 95%
    Then 進度條顏色從 color-neon-blue 漸變至 color-gold-400（#F5C842）
    And 進度條邊緣顯示金色光暈（glow 效果，radius 4px）
    And Jackpot 金額數字字體切換至 font-family-display（強調即將觸發）

  # ─── Jackpot 觸發全屏動畫序列 ────────────────────────────────

  @client @p0 @visual
  Scenario: Jackpot 觸發後播放全屏動畫序列（Happy Path）
    # VDD §2.4 多巴胺刺激感：全屏 Jackpot 爆炸，200+ 金幣粒子，PDD §6.5
    Given Jackpot 進度條達到 100%（jackpot_triggered Colyseus 事件）
    When JackpotBar 接收到觸發事件
    Then 遊戲場景暫停（魚群停止移動，砲台禁用操作）
    And 全屏顯示 Jackpot 觸發動畫序列，共 5 階段：
      | 階段 | 效果                                                  | 持續時間 |
      | 1    | 全屏金色閃光（Fade to white，200ms）                   | 200ms    |
      | 2    | 「JACKPOT！」大字爆出（text-multiplier 56px，scale 0.5→3.0） | 600ms    |
      | 3    | 200+ 金幣粒子從屏幕中央向外噴射（初速 600–1200 px/s）  | 1000ms   |
      | 4    | Jackpot 金額數字大字計數動畫（從 0 滾至最終金額）       | 2000ms   |
      | 5    | 獲獎玩家名稱 + 特效 Banner                            | 1500ms   |
    And 動畫序列總時長約 5300ms

  @client @p0 @visual
  Scenario: Jackpot 觸發後獎池金額計數動畫
    # VDD §5.2 text-display（48px）+ font-family-display（Oswald）
    Given Jackpot 觸發，獎池金額為 "¥1,234,567"
    When 觸發動畫第 4 階段（金額計數滾動）
    Then 金額數字以等寬字體（font-family-mono Roboto Mono）從 "¥0" 滾動至 "¥1,234,567"
    And 滾動計數動畫時長 2000ms，使用 ease-in-out 緩動
    And 數字每次更新時閃爍金色光暈（--shadow-glow-neon）
    And 達到最終金額時數字「定格」動畫（scale 1.0→1.2→1.0，300ms）

  @client @p0 @visual
  Scenario: Jackpot 觸發期間其他玩家也能看到動畫
    # Jackpot 特效對房間全體玩家廣播
    Given 房間中有 4 名玩家，其中 player-001 觸發 Jackpot
    When jackpot_triggered 事件廣播至所有客戶端
    Then 所有 4 名玩家的 GameScene 均顯示全屏 Jackpot 動畫
    And 觸發者名稱在 Jackpot Banner 中高亮顯示（color-gold-400，font-weight-700）
    And 非觸發玩家顯示「[玩家名稱] 觸發了 JACKPOT！」的副標題

  # ─── Jackpot 後恢復正常 UI ────────────────────────────────────

  @client @p0 @interaction
  Scenario: Jackpot 動畫結束後遊戲自動恢復並重置進度條
    Given Jackpot 全屏動畫序列已播完（約 5300ms）
    When 動畫最後階段結束
    Then 全屏 Jackpot 覆層以 Fade Out（500ms）消失
    And 遊戲場景恢復（魚群重新開始移動，砲台恢復可操作）
    And Jackpot 進度條重置至 0%（Tween 300ms 縮短至空）
    And Jackpot 金額重置為初始種子值（Colyseus jackpot_reset 事件同步）
    And HUD 所有元素恢復正常操作狀態

  @client @p1 @interaction
  Scenario: 玩家在 Jackpot 動畫播放中點擊屏幕不觸發射擊
    Given Jackpot 全屏動畫正在播放（遊戲暫停狀態）
    When 玩家多次點擊屏幕
    Then ShootingSystem 不處理任何點擊事件（事件攔截）
    And 無子彈節點生成
    And 無射擊音效觸發

  # ─── 大廳 Jackpot 金額即時更新 ──────────────────────────────

  @client @p1 @interaction
  Scenario: 大廳顯示時 Jackpot 金額因其他房間貢獻而更新
    Given 玩家正在 LobbyScene 瀏覽房間列表
    When 背景遊戲房間的 jackpot_increment 廣播事件到達
    Then 大廳 Jackpot 金額以滾動動畫（Tween 500ms）更新為新數值
    And 金額更新時大廳頂部 Jackpot 區域閃爍金色（pulse 效果，200ms）

  # ─── 錯誤路徑 ─────────────────────────────────────────────────

  @client @p1 @visual
  Scenario: Jackpot 資料載入失敗時進度條顯示空態
    Given LobbyScene 嘗試取得 Jackpot 狀態但 API 回傳 503
    When JackpotBar 接收到載入錯誤
    Then Jackpot 進度條顯示灰色（disabled 狀態，opacity 0.5）
    And 金額文字顯示「---」（表示資料不可用）
    And 不顯示錯誤 Modal（非關鍵功能，靜默降級）
    And 背景每 30 秒自動重試取得 Jackpot 狀態

  @client @p1 @visual
  Scenario: Jackpot 觸發動畫期間若 WebSocket 中斷則跳過動畫返回大廳
    Given Jackpot 觸發全屏動畫正在播放
    When Colyseus WebSocket 在動畫播放中突然中斷
    Then 動畫立即停止（跳過剩餘幀）
    And 顯示「連線中斷，已保存遊戲結果」Modal
    And 點擊「返回大廳」按鈕後跳轉 LobbyScene
    And 若 Jackpot 由當前玩家觸發，Toast 提示「Jackpot 獎勵將在重新登入後發放」
