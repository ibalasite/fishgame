# features/client/shooting_interaction.feature
# 來源：PRD US-WPSK-001；PDD §5.4 GameScene 射擊互動；FRONTEND.md §5 ShootingSystem / WeaponSystem
# Client 層面：點擊射擊、自動瞄準、武器 UI、子彈動畫、金幣不足狀態

Feature: 射擊互動
  作為遊戲中的玩家
  我希望透過點擊屏幕發射子彈並得到即時視覺回饋
  以便感受到操作的爽感並有效策略性地捕魚

  Background:
    Given 玩家已登入且在 GameScene 中
    And 遊戲房間狀態為 "PLAYING"
    And 玩家當前金幣餘額為 "500"
    And 玩家裝備基礎砲台（Multiplier=1）

  # ─── 點擊射擊基本流程 ────────────────────────────────────────

  @client @p0 @interaction
  Scenario: 點擊屏幕發射子彈（Happy Path）
    When 玩家點擊屏幕任意位置
    Then BulletPoolManager 從物件池取得子彈節點（BulletPrefab）並在砲台位置 instantiate
    And 子彈以直線動畫飛向點擊坐標（Tween 移動，80ms expo-out）
    And 砲台播放 Fire 動畫（6 幀 / 120ms，炮口橘焰粒子噴射）
    And 射擊音效觸發（AudioManager.playSFX）

  @client @p0 @interaction
  Scenario: 子彈命中魚後顯示命中特效
    Given 場景中有一條普通魚（1x–5x 倍率）
    When 玩家射擊並伺服器回傳 hit=true（fish_hit Colyseus 事件）
    Then EffectPoolManager 在命中坐標 instantiate HitEffect（金色閃爍粒子，80ms）
    And 魚播放受擊閃爍動畫（4 幀 / 80ms）
    And 金幣數字（例如 "+3"）以 scale 0→1.2→1.0 彈出動畫浮現在命中點上方

  @client @p0 @interaction
  Scenario: 子彈飛出邊界後回收至物件池
    When 子彈飛至屏幕邊界（超出 720px 設計寬度）
    Then 子彈節點返回 BulletPoolManager 物件池（active = false）
    And 不觸發任何命中音效或特效

  @client @p1 @interaction
  Scenario: 連續快速點擊射擊（多發子彈並行）
    When 玩家在 500ms 內連續點擊屏幕 5 次
    Then BulletPoolManager 同時維護最多 200 個子彈節點
    And 每次點擊均觸發獨立的子彈 Tween 動畫
    And 砲台每次發射皆播放炮口閃光（不因連擊疊加而跳過）

  # ─── 自動瞄準（Auto-Aim）────────────────────────────────────

  @client @p0 @interaction
  Scenario: 玩家選定魚後自動瞄準高亮
    Given 玩家使用鎖定炮（Lock-on 武器）
    When 玩家長按屏幕上的精英魚
    Then 精英魚外框顯示霓虹青鎖定光圈（2px Outline Shader，color-neon-blue #00D4FF）
    And 砲台自動旋轉朝向目標魚方向（100ms 動畫）
    And HUD 顯示鎖定目標的倍率提示（例如「×20」）

  @client @p0 @interaction
  Scenario: 鎖定目標死亡後自動解除鎖定
    Given 玩家已鎖定一條精英魚
    When 該精英魚因其他玩家射擊而死亡（Colyseus fish_killed 事件）
    Then 鎖定光圈立即消失（Fade Out 150ms）
    And 砲台恢復自由瞄準狀態
    And 若還有其他魚則顯示「目標已被擊殺」Toast（1.5s）

  # ─── 武器選擇視覺反饋 ────────────────────────────────────────

  @client @p0 @visual
  Scenario: 武器切換時 HUD 武器圖示即時更新
    Given 玩家當前裝備基礎砲台
    When 玩家在 CannonSelectScene 選擇雷射炮並確認進入遊戲
    Then GameScene HUD 武器圖示（64×64 px）更新為雷射炮 Sprite
    And 武器倍率標籤更新為「×3」
    And 砲台 Sprite 更換為雷射炮外觀（Aim 動畫同步切換）

  @client @p1 @interaction
  Scenario: 遊戲中升級武器倍率時顯示升級視覺反饋
    Given 玩家裝備基礎砲台（×1）
    When 玩家通過消耗金幣升級砲台至（×2）
    Then HUD 武器倍率標籤以 scale 1.0→1.5→1.0 彈出動畫更新
    And 砲台周圍顯示金色光暈（glow ring，300ms Fade In/Out）
    And 升級音效觸發（升調 SFX）

  # ─── 金幣不足狀態 ────────────────────────────────────────────

  @client @p0 @interaction
  Scenario: 金幣餘額為 0 時射擊按鈕自動禁用
    Given 玩家金幣餘額降為 "0"
    When Colyseus state 同步餘額為 0
    Then HUD 射擊區域以半透明遮罩（opacity 0.5）顯示禁用狀態
    And 顯示「金幣不足」浮動提示（Toast，使用 color-feedback-error #FF4444）
    And 點擊屏幕不觸發任何射擊動畫或音效

  @client @p0 @interaction
  Scenario: 金幣不足時顯示充值引導 CTA
    Given 玩家金幣餘額為 "0"，遊戲仍在進行中
    When 玩家點擊禁用射擊區域
    Then 顯示「金幣不足，立即補充」提示橫幅（底部 Slide Up 動畫，300ms）
    And 橫幅包含「前往商城」Primary Button（color-action-primary #F5C842）
    And 點擊「前往商城」按鈕開啟 ShopDialog（不中斷遊戲背景）

  # ─── 散射炮特效 ───────────────────────────────────────────────

  @client @p1 @visual
  Scenario: 散射炮發射時顯示扇形子彈軌跡
    Given 玩家裝備散射炮（Spread Shot 武器）
    When 玩家點擊屏幕發射
    Then 同時 instantiate 5 顆子彈節點，以扇形（±30° 角度分布）飛出
    And 每顆子彈有獨立的 Tween 軌跡動畫
    And 炮口播放較大的橘焰粒子爆發效果（2× 普通發射粒子量）

  # ─── 技能按鈕啟動快捷操作 ─────────────────────────────────────

  @client @p1 @interaction
  Scenario: 長按技能按鈕顯示技能說明 Tooltip
    Given 玩家進入 GameScene，技能按鈕可見
    When 玩家長按技能按鈕（> 500ms）
    Then 顯示技能說明 Tooltip（技能名稱 + 效果描述，text-body-sm 14px）
    And Tooltip 在 2 秒後自動消失或手指鬆開時消失

  # ─── 錯誤路徑 ─────────────────────────────────────────────────

  @client @p1 @interaction
  Scenario: 射擊指令發送但 WebSocket 連線不穩導致無回應
    Given Colyseus WebSocket 連線狀態為 "reconnecting"
    When 玩家點擊屏幕嘗試射擊
    Then 子彈動畫仍正常播放（Optimistic UI）
    And HUD 顯示網路狀態警示圖示（黃色 WiFi 圖示，pulse 動畫）
    And 若伺服器在 2s 內無回應，子彈節點消失並顯示「射擊未命中，請稍後重試」Toast

  @client @p2 @interaction
  Scenario: 玩家觸控熱區過小時仍能可靠射擊
    # VDD 規範：所有互動觸控熱區 ≥ 44×44 px
    Given GameScene 在小螢幕（320px 寬）裝置上執行
    When 玩家點擊技能按鈕區域
    Then 技能按鈕觸控熱區面積 ≥ 44×44 px（符合 VDD 圖示按鈕規格）
    And 射擊操作不因螢幕尺寸縮放而遺失
