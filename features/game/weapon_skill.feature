# features/game/weapon_skill.feature
# 來源：PRD US-WPSK-001/AC-1,AC-2,AC-3,AC-4
# Risk Level：Medium

Feature: 武器選擇與技能系統
  作為 競技房間中的玩家
  我希望 選擇不同武器並使用特殊技能
  以便 提高命中率和金幣收益

  Background:
    Given 資料庫已初始化（clean state）
    And 玩家 "player-weapon@example.com" 已登入，持有有效 JWT
    And 競技房間 "fishingRoom-weapon" 遊戲進行中
    And 玩家初始鑽石餘額 100，金幣餘額 1000

  # ─── 正常路徑 ───────────────────────────────────────────

  @p0 @smoke @regression @api @contract @TC-E2E-WPSK-001-S @websocket
  Scenario: 玩家選擇雷射炮後消費對應費用並生效
    Given 房間提供 4 種武器：散彈炮（費用 10）、雷射炮（費用 30）、導彈炮（費用 50）、等離子炮（費用 100）
    When 玩家透過 WebSocket 發送 weapon_select，weapon_id="laser_cannon"
    Then 玩家金幣餘額扣除 30，餘額更新為 970
    And 服務端廣播玩家武器狀態更新 weapon="laser_cannon"
    And 玩家後續射擊倍率為 3x

  @p0 @regression @api @TC-INT-WPSK-002-S @websocket
  Scenario: 技能冷卻期間無法重複使用同一技能
    Given 玩家已使用冰凍技能（cooldown=3 秒）
    When 玩家在 2 秒後再次嘗試使用冰凍技能
    Then 服務端回傳 onMessage "error"，訊息為 "SKILL_COOLING_DOWN"
    And 回應包含剩餘冷卻時間（remaining_cooldown=1）
    And 技能未生效，金幣不扣除

  @p0 @regression @api @TC-INT-WPSK-003-S
  Scenario: 冷卻期結束後可重新使用技能
    Given 玩家已使用冰凍技能，冷卻 3 秒
    When 3 秒後玩家再次使用冰凍技能
    Then 服務端接受技能請求並廣播 skill_activated 事件
    And 房間內所有魚速度降低（frozen_duration=3 秒）

  @p0 @regression @api @TC-INT-WPSK-005-S
  Scenario: 全屏炸彈技能命中所有存活魚並結算獎勵
    Given 房間中有 10 條存活魚，玩家使用全屏炸彈技能（cooldown=5 秒）
    When 玩家發送 skill_activate，skill_id="aoe_bomb"
    Then 服務端廣播 skill_activated，影響所有 10 條魚
    And 所有命中的魚均觸發 fish_kill 事件（各自倍率計算）
    And 玩家技能冷卻計時器設為 5 秒

  # ─── 錯誤路徑 ───────────────────────────────────────────

  @p0 @regression @api @contract @TC-UNIT-WPSK-004-E @websocket
  Scenario: 金幣不足時選擇高費用武器被拒絕
    Given 玩家金幣餘額僅剩 20
    When 玩家嘗試選擇費用為 50 的導彈炮
    Then 服務端回傳 onMessage "error"，訊息為 "INSUFFICIENT_COINS"
    And 玩家武器保持原有設定，金幣不扣除

  @p0 @regression @api @contract @TC-INT-WPSK-006-E @websocket
  Scenario: 非 VIP 玩家嘗試使用 VIP 專屬武器升級被拒絕（US-WPSK-001/AC-4）
    Given 玩家 vip_tier=0（非 VIP）
    When 玩家嘗試裝備 VIP 專屬強化版武器 "laser_cannon_vip"
    Then 服務端回傳 onMessage "error"，訊息為 "VIP_REQUIRED"
    And 武器未升級

  @p0 @regression @api @contract @TC-INT-WPSK-007-S
  Scenario: VIP 玩家可成功裝備 VIP 專屬強化武器（US-WPSK-001/AC-4）
    Given 玩家 vip_tier=1（VIP 月費訂閱有效）
    When 玩家發送 weapon_select，weapon_id="laser_cannon_vip"
    Then 服務端廣播武器升級成功
    And 玩家後續射擊倍率為 5x（VIP 強化）

  @p0 @regression @api @TC-INT-WPSK-008-E
  Scenario: 遊戲未開始時選擇武器被拒絕
    Given 房間狀態為 "waiting"（遊戲未開始）
    When 玩家發送 weapon_select 事件
    Then 服務端回傳 "error"，訊息為 "GAME_NOT_STARTED"

  # ─── 邊界條件 ───────────────────────────────────────────

  @p0 @regression @api @TC-INT-WPSK-009-B
  Scenario Outline: 技能冷卻邊界條件
    Given 玩家已使用 <skill>，冷卻時間為 <cooldown> 秒
    When 玩家在 <elapsed> 秒後嘗試再次使用
    Then 技能操作結果為 <result>

    Examples:
      | skill         | cooldown | elapsed | result       |
      | 冰凍技能      | 3        | 2       | COOLING_DOWN |
      | 冰凍技能      | 3        | 3       | SUCCESS      |
      | 全屏炸彈      | 5        | 4       | COOLING_DOWN |
      | 全屏炸彈      | 5        | 5       | SUCCESS      |
