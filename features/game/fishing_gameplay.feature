# features/game/fishing_gameplay.feature
# 來源：PRD US-FISH-001/AC-1,AC-2,AC-3,AC-4,AC-5,AC-6；US-ROOM-001/AC-5,AC-6
# Risk Level：High（核心遊戲玩法與金幣獎勵，Scenario 數量加倍）

Feature: 捕魚遊戲核心玩法與結算
  作為 競技房間中的玩家
  我希望 射擊不同魚種並獲得相應金幣獎勵
  以便 在計時結束後以最高積分獲得 MVP 獎勵

  Background:
    Given 資料庫已初始化（clean state）
    And 競技房間 "fishingRoom-001" 正在進行中，有 4 位玩家
    And 玩家 "player-001@example.com" 已登入，初始金幣餘額 500

  # ─── 正常路徑 ───────────────────────────────────────────

  @p0 @smoke @regression @api @contract @TC-INT-FISH-001-S
  Scenario: 射擊命中後金幣獎勵立即到帳（普通魚種 × 3 倍）
    Given 房間中出現 HP=1 的普通魚種（倍率 3x）
    And 玩家使用基本武器（Multiplier=1）發送 fire 事件
    When 服務端判定命中（hit=true）
    Then 玩家收到 fish_kill 事件，含 reward=3 金幣
    And GET /v1/users/:id/balance 回應顯示餘額增加 3
    And 資料庫 users.coin_balance 已更新為 503

  @p0 @smoke @regression @api @TC-INT-FISH-002-S
  Scenario: 射擊未命中消耗彈藥但金幣不減少
    Given 玩家初始金幣餘額 500，彈藥充足
    And 服務端判定本次射擊 hit=false
    When 玩家發送 fire 事件
    Then 玩家未收到 fish_kill 事件
    And GET /v1/users/:id/balance 回應餘額仍為 500
    And 彈藥數量減少 1

  @p0 @regression @api @TC-INT-FISH-003-S
  Scenario: 不同魚種倍率計算正確
    Given 房間中存在 4 種魚種（倍率 3x/5x/10x/20x），各 HP=1
    When 玩家使用基本武器（Multiplier=1）各命中一條
    Then 分別獲得 3、5、10、20 金幣獎勵
    And 最終餘額為 500 + 3 + 5 + 10 + 20 = 538

  @p0 @regression @api @TC-INT-FISH-004-S
  Scenario: 武器倍率疊加魚種倍率計算正確（雷射炮 × 高倍魚）
    Given 玩家裝備雷射炮（Multiplier=3），房間有 20x 魚種（HP=1）
    When 玩家命中該 20x 魚
    Then 玩家獲得 60 金幣獎勵（3 × 20）
    And 金幣餘額更新為 560

  @p0 @regression @api @TC-INT-FISH-005-S
  Scenario: 單局最少保底 10 金幣（即使全程未命中）
    Given 玩家在整局遊戲中所有射擊均未命中
    When 遊戲結算時間到
    Then 玩家獲得保底獎勵 10 金幣
    And 金幣餘額更新為 510

  @p0 @regression @api @TC-E2E-ROOM-005-S @websocket
  Scenario: 遊戲結束後顯示積分排名，最高分獲得 MVP 標記
    Given 房間 4 位玩家遊戲結束，各自積分為 200、150、180、90
    When 服務端發送 game_ended 事件
    Then 所有玩家均收到 onMessage "game_result" 含 Top3 排名
    And 積分 200 的玩家被標記為 MVP（is_mvp=true）
    And 排名第 1 位積分顯示為 200，第 2 位為 180，第 3 位為 150

  # ─── 錯誤路徑 ───────────────────────────────────────────

  @p0 @regression @api @contract @TC-INT-FISH-006-B @websocket
  Scenario: 遊戲未開始時發送射擊事件被忽略
    Given 房間狀態為 "waiting"（遊戲未開始）
    When 玩家發送 fire WebSocket 事件
    Then 服務端回傳 onMessage "error"，訊息為 "GAME_NOT_STARTED"
    And 金幣餘額不變

  @p0 @regression @api @contract @TC-INT-FISH-007-E @websocket
  Scenario: 射擊目標魚已被其他玩家擊殺時返回魚種不存在
    Given 房間中某條魚 fish_id="fish-001" 已被玩家 B 擊殺
    When 玩家 A 發送 fire 事件，目標 target_id="fish-001"
    Then 服務端回傳 onMessage "error"，訊息為 "TARGET_NOT_FOUND"
    And 玩家 A 金幣餘額不變

  # ─── 邊界條件 ───────────────────────────────────────────

  @p0 @regression @api @TC-INT-FISH-008-B
  Scenario Outline: 不同魚種倍率邊界條件驗證
    Given 房間中出現 <fish_type>（倍率 <multiplier>x）
    And 玩家使用 <weapon>（Weapon Multiplier=<weapon_mult>）命中
    When 服務端判定命中並計算獎勵
    Then 玩家獲得 <expected_reward> 金幣

    Examples:
      | fish_type    | multiplier | weapon       | weapon_mult | expected_reward |
      | 普通魚種     | 3          | 基本武器     | 1           | 3               |
      | 中型魚種     | 5          | 散彈武器     | 2           | 10              |
      | 大型魚種     | 10         | 雷射炮       | 3           | 30              |
      | BOSS 魚種   | 20         | 等離子炮     | 5           | 100             |
