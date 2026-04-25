# features/client/room_selection_ui.feature
# 來源：PRD US-ROOM-001；PDD §5.3 LobbyScene、§5.9 MatchmakingScene（配對等待）；
# PDD §4.1 主流程（快速匹配、Bot 補位）；FRONTEND.md §6 ui/lobby/LobbyUI.ts、MatchmakingUI.ts
# Client 層面：房間列表顯示、快速匹配入口、配對等待 UI、Bot 補位提示、取消配對

Feature: 房間選擇與配對等待 UI
  作為一名玩家
  我希望在大廳快速找到適合的房間並進入配對
  以便在 30 秒內開始競技局而不因等待流程感到不耐

  Background:
    Given 玩家已登入並進入 LobbyScene
    And Colyseus 伺服器狀態正常
    And 玩家當前金幣餘額為 "2000"

  # ─── 大廳載入狀態 ─────────────────────────────────────────────

  @client @p0 @visual
  Scenario: 大廳進入時房間列表載入中顯示骨架屏（Loading 態）
    When LobbyScene 首次進入，房間列表 API 尚未回應
    Then 房間列表區域顯示 3 個骨架佔位卡片（Skeleton Loading，shimmer 光效 1.5s loop）
    And 「快速匹配」Primary Button 處於 Loading 狀態（Disabled + Spinner）
    And 背景顯示深海場景動態底圖（珊瑚、氣泡、裝飾魚群動畫）

  @client @p0 @visual
  Scenario: 房間列表成功載入後正確顯示各房間資訊（正常態）
    When LobbyUI 成功取得房間列表（API GET /v1/rooms 回傳）
    Then 骨架屏以 Fade Out（200ms）消失
    And 每個房間卡片（RoomListItem）顯示：
      - 房間名稱（text-h3，20px）
      - 房間類型標籤（普通 / 競技，使用對應色標）
      - 當前人數 / 最大人數（例如「3/6」，text-body）
      - 入場費用（金幣數量，金幣圖示 + text-body-sm）
      - 房間狀態（等待中 / 遊戲中）
    And 「快速匹配」Primary Button 恢復可點擊狀態（color-action-primary #F5C842）
    And CTA 按鈕是大廳最視覺突出的元素（符合 VDD §1.4 視覺層次規則）

  # ─── 房間類型選擇 ─────────────────────────────────────────────

  @client @p0 @interaction
  Scenario: 選擇普通房間類型後過濾房間列表
    Given 大廳顯示「普通」和「競技」房間切換標籤
    When 玩家點擊「普通」標籤
    Then 房間列表只顯示普通房間卡片
    And「普通」標籤使用 Selected 狀態（color-action-primary 底色，scale 1.0 active）
    And「競技」標籤恢復 Default 狀態

  @client @p0 @interaction
  Scenario: 選擇競技房間後金幣不足的房間顯示禁用狀態
    Given 大廳顯示競技房間列表
    And 某競技房間入場費為 "5000" 金幣，玩家金幣餘額為 "2000"
    When 房間列表渲染完成
    Then 該房間卡片顯示禁用外觀（opacity 0.5，按鈕 Disabled）
    And 卡片顯示「金幣不足，需要 5000」提示文字（color-feedback-error，text-caption）
    And 其他金幣足夠的房間正常顯示可點擊狀態

  # ─── 快速匹配流程 ─────────────────────────────────────────────

  @client @p0 @interaction
  Scenario: 點擊快速匹配後進入砲台選擇介面
    # PDD §4.1 主流程：S9 點擊「快速匹配」→ S8 砲台+技能選擇介面
    Given 大廳「快速匹配」Primary Button 可點擊
    When 玩家點擊「快速匹配」按鈕
    Then 按鈕播放 Press 動畫（scale 0.95，100ms）
    And LobbyScene 以 Fade Out（300ms）過渡至 CannonSelectScene

  @client @p0 @interaction
  Scenario: CannonSelectScene 顯示砲台與技能選擇後進入配對等待
    Given 玩家已進入 CannonSelectScene
    When 玩家選擇砲台並點擊「確認進入」按鈕
    Then CannonSelectScene 過渡至 MatchmakingScene（Fade Out/In，300ms）
    And MatchmakingUI 初始化並開始配對倒數（30 秒計時器啟動）

  # ─── 配對等待 UI ──────────────────────────────────────────────

  @client @p0 @visual
  Scenario: 配對等待畫面顯示倒數計時與玩家槽位（等待態）
    Given 玩家進入 MatchmakingScene，配對進行中
    When MatchmakingUI 渲染
    Then 顯示 30 秒倒數計時器（font-family-mono Roboto Mono，text-hud-score 28px）
    And 顯示 6 個玩家頭像槽位（已加入玩家顯示頭像 + 名稱，空槽位顯示灰色 Skeleton）
    And 倒數計時器每秒更新（精度 1 秒）
    And 進度指示條（細線，color-neon-blue）從 100% 隨時間縮短

  @client @p0 @visual
  Scenario: 新玩家加入配對時頭像飛入動畫
    # PDD §5.9：玩家頭像飛入動畫傳遞「真人對戰」氛圍
    Given 配對等待畫面顯示 2 個已加入玩家
    When 第 3 名玩家完成配對加入（Colyseus onJoin 事件）
    Then 第 3 名玩家頭像以飛入動畫（scale 0→1.0 + Fade In，300ms ease-out）出現在對應槽位
    And 頭像飛入時播放輕微音效（chime SFX）
    And 已加入玩家數更新（例如「3/6 人已就緒」）

  @client @p1 @visual
  Scenario: 配對達到最少人數（4 人）後顯示可開始遊戲提示
    Given 配對等待畫面顯示 4 名玩家已加入（最少人數）
    When 第 4 名玩家加入（Colyseus 狀態更新）
    Then 顯示「已達最少人數！等待更多玩家或倒數開始」系統提示（text-body，color-neon-green）
    And 已加入的 4 個頭像槽位邊框亮起（color-neon-green，pulse 動畫）

  # ─── Bot 補位提示 ────────────────────────────────────────────

  @client @p1 @interaction
  Scenario: 配對超時後以 Bot 補位並顯示友好提示
    # PDD §4.1：配對超時 → Bot 補位通知 → 房間就緒
    Given 配對倒數已到 0 秒，玩家數量不足 4 人（例如只有 2 人）
    When 倒數計時歸零
    Then 空缺槽位以 Bot 玩家頭像填入（Bot 標識圖示，灰色名稱「AI 玩家」）
    And 顯示系統提示「部分玩家由 AI 補位，準備開始！」（text-body，color-text-secondary）
    And Bot 補位明確但語氣平和（不打擊玩家信心）
    And 3 秒後自動進入 GameScene

  @client @p1 @visual
  Scenario: Bot 補位頭像外觀與真實玩家明確區分
    Given Bot 補位完成，配對畫面顯示部分 Bot 頭像
    When 配對畫面最終渲染
    Then Bot 頭像顯示機器人圖示（或 AI 標識，color-text-secondary 灰色）
    And Bot 名稱文字使用斜體或「AI」前綴以示區分
    And 真實玩家頭像正常顯示（無 AI 標識）

  # ─── 取消配對 ────────────────────────────────────────────────

  @client @p0 @interaction
  Scenario: 配對等待中點擊取消返回大廳
    Given 玩家在 MatchmakingScene，配對進行中（15 秒倒數）
    When 玩家點擊「取消配對」Secondary Button
    Then Colyseus 發送 leave 事件（ColyseusClient.leaveRoom）
    And MatchmakingScene 以 Fade Out（300ms）過渡回 LobbyScene
    And 大廳房間列表重新載入（確保最新狀態）
    And 已消耗的配對時間不影響玩家任何資源

  @client @p1 @interaction
  Scenario: 配對等待中誤按返回鍵顯示確認 Modal（防誤觸）
    Given 玩家在 MatchmakingScene（Android 實體返回鍵 或 iOS 手勢）
    When 玩家按下系統返回按鈕
    Then 顯示確認 Modal「確定要取消配對嗎？」
    And 提供「取消配對」Secondary Button 和「繼續等待」Primary Button
    And 「繼續等待」為預設 focused 按鈕（防止誤觸）

  # ─── 錯誤狀態 ─────────────────────────────────────────────────

  @client @p0 @interaction
  Scenario: 房間列表 API 失敗時顯示空態與重試入口（Error 態）
    Given LobbyScene 取得房間列表 API 回傳 503
    When 載入失敗
    Then 房間列表顯示「載入失敗」空態圖示（灰色雲端 + X）
    And 顯示「重新載入」Secondary Button（color-action-secondary #00D4FF）
    And 「快速匹配」按鈕維持 Disabled（不允許在無房間資訊時操作）
    And 不顯示骨架屏（已確認為錯誤狀態，非載入中）

  @client @p1 @interaction
  Scenario: 配對過程中 Colyseus 連線失敗時顯示錯誤並返回大廳
    Given 配對等待進行中（10 秒倒數）
    When Colyseus WebSocket 連線中斷（onError 事件）
    Then MatchmakingUI 停止倒數計時
    And 顯示 Modal「配對失敗，請稍後重試」（Fade In，200ms）
    And 提供「返回大廳」Primary Button
    And 玩家點擊後跳轉 LobbyScene（不消耗任何遊戲資源）

  @client @p0 @interaction
  Scenario: 大廳顯示空房間列表時提示引導（空態）
    Given 當前伺服器無任何可加入的房間
    When 房間列表 API 回傳空陣列
    Then 房間列表顯示空態提示「目前沒有進行中的房間，快速匹配開始！」
    And 空態圖示（魚群圖示，64×64 px，opacity 0.5）可見
    And「快速匹配」Primary Button 仍可點擊（引導建立/加入新房間）
