# features/client/skill_ui.feature
# 來源：PRD US-WPSK-001；PDD §5.4 GameScene HUD 技能按鈕（I-5 insight：技能冷卻不可見導致挫折）
# VDD §5.x 按鈕規格；FRONTEND.md §5 SkillSystem.ts
# Client 層面：技能按鈕狀態、冷卻弧、啟動動畫、多技能同時冷卻

Feature: 技能 UI 互動
  作為遊戲中的玩家
  我希望技能按鈕清晰顯示冷卻狀態和可用狀態
  以便在正確時機使用技能而不感到操作挫折

  Background:
    Given 玩家已進入 GameScene
    And 遊戲房間狀態為 "PLAYING"
    And HUD 技能按鈕區域已初始化（三個技能按鈕：冰凍 / 全屏炸彈 / 自動鎖定）

  # ─── 技能就緒狀態 ─────────────────────────────────────────────

  @client @p0 @visual
  Scenario: 技能按鈕就緒時顯示可用狀態（Ready State）
    Given 玩家三個技能均已冷卻完畢
    When 玩家進入 GameScene 或技能冷卻時間結束
    Then 技能按鈕顯示完整圖示（技能圖示 64×64 px，全亮，opacity 1.0）
    And 按鈕底色使用 VDD "color-bg-surface"（#0A2340）
    And 無冷卻遮罩或弧形覆蓋
    And 技能就緒音效輕微提示（短促 chime SFX，低音量）

  # ─── 技能冷卻弧顯示 ──────────────────────────────────────────

  @client @p0 @visual
  Scenario: 使用技能後按鈕進入冷卻狀態（冷卻弧順時針縮短）
    Given 冰凍技能按鈕處於就緒狀態
    When 玩家點擊冰凍技能按鈕（SkillSystem 發送 skill_use 事件）
    Then 技能按鈕圖示變暗（opacity 降至 0.4）
    And 按鈕上覆蓋半透明灰色扇形遮罩（順時針從 360° 遞減至 0°）
    And 遮罩背景使用 rgba(0,0,0,0.65)
    And 按鈕中央顯示剩餘冷卻秒數（Roboto Mono 字型，text-h3 20px，白色）
    And 冷卻弧持續動畫更新（每 100ms 刷新，精度 ≤ 0.1s）

  @client @p0 @interaction
  Scenario: 技能冷卻中點擊按鈕不觸發技能
    Given 冰凍技能正在冷卻（剩餘 8 秒）
    When 玩家點擊冷卻中的技能按鈕
    Then SkillSystem 不發送任何 skill_use 事件
    And 按鈕播放輕微震動動畫（shake，2 幀 50ms，不移動按鈕位置）
    And 技能按鈕無音效（不觸發使用音效）
    And 顯示短暫 Toast「冰凍技能冷卻中（8s）」（duration 1.5s，color-text-secondary 顏色）

  @client @p0 @visual
  Scenario: 冷卻時間到後按鈕從冷卻態切換至就緒態
    Given 冰凍技能冷卻剩餘 1 秒
    When 冷卻計時歸零（SkillSystem 本地計時 + Colyseus 狀態確認）
    Then 冷卻遮罩以 Fade Out（200ms）消失
    And 技能圖示亮度恢復（opacity Tween 0.4→1.0，200ms）
    And 技能就緒提示動畫（按鈕 scale 1.0→1.15→1.0，300ms 彈入）
    And 技能就緒音效觸發

  # ─── 技能啟動動畫 ─────────────────────────────────────────────

  @client @p0 @visual
  Scenario: 冰凍技能啟動後全場魚顯示冰凍特效視覺確認
    Given 冰凍技能處於就緒狀態
    When 玩家點擊冰凍技能按鈕
    Then 技能按鈕播放激活動畫（scale 1.0→1.3→1.0，150ms，霓虹青光暈閃爍）
    And 場景中所有存活魚觸發冰凍 Shader Overlay（藍白冰霜，FishSystem 統一處理）
    And 畫面邊緣顯示冰藍色暈圈特效（全屏 Vignette，2s 後 Fade Out）
    And 技能啟動音效（冰凍音效）觸發

  @client @p0 @visual
  Scenario: 全屏炸彈技能啟動顯示爆炸全屏特效
    Given 全屏炸彈技能處於就緒狀態
    When 玩家點擊全屏炸彈按鈕
    Then 技能按鈕播放激活動畫（橘色光暈爆炸閃光，150ms）
    And 全屏顯示炸彈爆炸特效（EffectPool 全屏粒子系統，橘黃色爆炸，500ms）
    And 所有魚受到傷害（命中特效觸發）並 HUD 金幣計數快速滾動更新
    And 爆炸音效（強烈低頻爆炸 SFX）觸發

  @client @p1 @visual
  Scenario: 自動鎖定技能啟動後炮台自動追蹤並瞄準目標
    Given 自動鎖定技能處於就緒狀態，場景中有多條魚
    When 玩家點擊自動鎖定按鈕
    Then 技能按鈕邊框顯示霓虹青脈衝（color-neon-blue，1s pulse loop）
    And 砲台開始自動旋轉追蹤場景中最高倍率魚
    And 被鎖定目標顯示紅色準心圖示（32×32 px，crosshair 動畫旋轉）
    And HUD 顯示「自動鎖定中」狀態標籤（Fade In，color-neon-blue）

  # ─── 多技能同時冷卻 ──────────────────────────────────────────

  @client @p1 @visual
  Scenario: 三個技能均在冷卻中獨立顯示各自進度
    Given 玩家連續使用三個技能（冰凍 10s / 炸彈 15s / 自動鎖定 8s）
    When 各技能按鈕進入冷卻狀態
    Then 三個按鈕各自獨立顯示冷卻弧動畫
    And 三個冷卻計時器互不影響（SkillSystem 維護獨立計時器）
    And 各按鈕中央顯示對應的剩餘秒數（精度 1 位小數）
    And 最短冷卻（8s）的技能按鈕最先恢復就緒狀態

  @client @p1 @visual
  Scenario: 技能冷卻期間 VFX 特效不影響按鈕可讀性
    Given 全屏炸彈技能剛剛啟動（冷卻中）
    And 場景中有大量粒子特效正在播放
    When 玩家查看技能按鈕區域
    Then 技能按鈕區域的 z-order 高於場景特效層（HUD z=3）
    And 冷卻秒數文字在視覺上清晰可讀（color-white-100，WCAG 4.5:1 以上）
    And 特效不遮擋任何技能按鈕

  # ─── 技能不足 / 未解鎖 ──────────────────────────────────────

  @client @p2 @visual
  Scenario: 未解鎖技能按鈕顯示鎖定狀態
    Given 玩家帳號未解鎖全屏炸彈技能
    When 玩家進入 GameScene
    Then 全屏炸彈按鈕顯示鎖定圖示（金色掛鎖 Sprite 覆蓋按鈕中央）
    And 按鈕底色使用 disabled 狀態（opacity 0.5，color-bg-surface）
    And 點擊鎖定技能按鈕時彈出「前往商城解鎖」Tooltip（text-body-sm，2s）

  # ─── 錯誤路徑 ─────────────────────────────────────────────────

  @client @p1 @interaction
  Scenario: 技能使用事件發送失敗時冷卻弧不啟動（Optimistic 防護）
    Given 冰凍技能處於就緒狀態，WebSocket 連線不穩
    When 玩家點擊技能按鈕，但 skill_use 事件 2 秒內無伺服器確認
    Then 技能按鈕不進入冷卻狀態（冷卻弧不啟動）
    And 顯示 Toast「技能使用失敗，請重試」（color-feedback-error，2s）
    And 技能按鈕恢復就緒狀態（允許再次點擊）
