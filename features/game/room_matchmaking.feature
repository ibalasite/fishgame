# features/game/room_matchmaking.feature
# 來源：PRD US-ROOM-001/AC-1,AC-2,AC-3,AC-4,AC-6
# 注意：AC-7（金幣限制）無對應 Scenario，見 RTM TC-UNIT-ROOM-007-E
# Risk Level：High（WebSocket 多人連線是核心體驗，Scenario 數量加倍）

Feature: 多人競技房間快速匹配
  作為 登入的遊戲玩家
  我希望 透過快速匹配機制進入 4-6 人競技房間
  以便 與其他玩家即時對戰捕魚

  Background:
    Given 資料庫已初始化（clean state）
    And Colyseus Game Server 運行於 :2567
    And 4 位測試玩家均已登入並持有有效 JWT

  # ─── 正常路徑 ───────────────────────────────────────────

  @p0 @smoke @regression @api @contract @TC-E2E-ROOM-001-S @websocket
  Scenario: 4 位玩家在 30 秒內完成快速匹配並進入競技房間
    Given 4 位玩家均呼叫 Colyseus matchmake joinOrCreate "fishingRoom"
    When 所有玩家的 WebSocket 握手完成
    Then 4 位玩家均收到 onJoin 事件，持有相同的 room_id
    And 匹配完成時間 ≤ 30 秒
    And 房間狀態為 "waiting"（等待更多玩家）或 "game_started"

  @p0 @smoke @regression @api @TC-INT-ROOM-002-S @websocket
  Scenario: 4-6 人連線就緒後房間狀態切換為 game_started
    Given 房間 "fishingRoom-001" 中已有 4 位玩家連線且均 ready
    When 房間中最後一位玩家發送 ready 訊息
    Then 所有玩家均收到 onMessage "game_started" 廣播
    And 房間 state.status 變更為 "game_started"
    And 服務端開始計算魚群刷新週期

  @p0 @smoke @regression @api @TC-E2E-ROOM-003-S @websocket
  Scenario: Bot 補位 E2E — 匹配逾時後補入機器人並成功開局
    Given 只有 1 位玩家呼叫 joinOrCreate "fishingRoom"
    When 等待 30 秒後仍無其他玩家加入
    Then 系統補入 3 個機器人至 4 人（is_bot=true）並啟動房間
    And 玩家收到 onMessage "game_started"，房間狀態為 "game_started"
    And 機器人以基礎射擊頻率持續參與，不影響玩家正常遊戲
    And 玩家可正常發送 fire 事件並獲得金幣獎勵

  @p0 @regression @api @TC-INT-ROOM-003-S @websocket
  Scenario: 玩家斷線後 10 秒內補入機器人維持遊戲進行
    Given 房間 "fishingRoom-001" 有 4 位真實玩家，遊戲進行中
    When 其中 1 位玩家 WebSocket 連線中斷
    Then 10 秒內房間補入 1 個機器人玩家（is_bot=true）
    And 剩餘真實玩家的遊戲未中斷，可繼續發送射擊指令
    And 機器人玩家會以基礎射擊頻率持續參與

  @p0 @regression @api @TC-INT-ROOM-004-S @websocket
  Scenario: WebSocket 事件往返延遲 P99 < 100ms
    Given 房間中有 6 位玩家，遊戲進行中（正常負載）
    When 玩家發送射擊事件並等待服務端廣播確認
    Then 同一 AZ 內事件往返延遲 P99 ≤ 100ms（連續 100 次量測）

  # ─── 錯誤路徑 ───────────────────────────────────────────

  @p0 @regression @api @TC-INT-ROOM-004-E @websocket
  Scenario: WS 斷線後 5 秒內未重連，機器人永久接管席位
    Given 房間 "fishingRoom-001" 有 4 位真實玩家，遊戲進行中
    And 玩家 "player-001@example.com" WebSocket 連線中斷
    When 5 秒重連視窗關閉，玩家未嘗試重新連線
    Then 系統補入機器人永久接管該席位（is_bot=true）
    And 玩家無法再以舊 session_id 重連回該房間（返回 "RECONNECT_WINDOW_EXPIRED"）
    And 剩餘 3 位真實玩家遊戲不中斷

  @p0 @regression @api @contract @TC-INT-ROOM-005-E @websocket
  Scenario: 房間已滿 6 人時新玩家加入返回房間已滿錯誤
    Given 房間 "fishingRoom-001" 已有 6 位玩家（滿員）
    When 第 7 位玩家嘗試 joinOrCreate "fishingRoom-001"
    Then API 回應業務錯誤 "ROOM_FULL"（對應 HTTP 422）
    And 第 7 位玩家未被加入房間

  @p0 @regression @api @contract @TC-INT-ROOM-006-E @websocket
  Scenario: Colyseus 匹配服務 Circuit Breaker 觸發後返回服務不可用
    Given Colyseus Game Server 連續故障次數超過 Circuit Breaker 閾值
    When 玩家發送 POST /v1/rooms/matchmake（joinOrCreate 請求）
    Then API 回應狀態碼 503
    And 回應錯誤碼為 "MATCHMAKING_SERVICE_UNAVAILABLE"
    And 回應包含 retry_after（秒）

  @p0 @regression @api @contract @TC-INT-ROOM-012-E @websocket
  Scenario: 玩家嘗試加入不存在的房間返回資源不存在
    Given 房間 ID "non-existent-room-999" 不存在於系統
    When 玩家嘗試 joinById "non-existent-room-999"
    Then API 回應狀態碼 404
    And 回應錯誤碼為 "ROOM_NOT_FOUND"

  @p0 @regression @api @contract @TC-INT-ROOM-007-E @websocket
  Scenario: 不帶 JWT Token 嘗試 WebSocket 連線被拒
    Given 使用者未攜帶有效 JWT Token
    When 使用者嘗試建立 WebSocket 連線至 Colyseus matchmake
    Then WebSocket 握手階段返回 HTTP 401
    And 連線未建立

  @p0 @regression @api @contract @TC-INT-ROOM-008-E @websocket
  Scenario: 帶無效 JWT Token 嘗試 WebSocket 連線被拒
    Given 使用者攜帶已過期或偽造的 JWT Token
    When 使用者嘗試建立 WebSocket 連線至 Colyseus matchmake
    Then WebSocket 握手階段返回 HTTP 401
    And 回應錯誤碼為 "INVALID_TOKEN"

  # ─── 邊界條件 ───────────────────────────────────────────

  @p0 @regression @api @TC-INT-ROOM-009-B
  Scenario Outline: 房間人數邊界條件對遊戲狀態的影響
    Given 房間中有 <player_count> 位玩家已連線
    When 所有玩家發送 ready 訊息
    Then 房間狀態為 <expected_state>

    Examples:
      | player_count | expected_state |
      | 3            | waiting        |
      | 4            | game_started   |
      | 6            | game_started   |

  @p0 @regression @api @TC-INT-ROOM-010-S @websocket
  Scenario: 30 秒快速匹配超時後單人也能進入房間（等候中機制）
    Given 只有 1 位玩家呼叫 joinOrCreate "fishingRoom"
    When 等待 30 秒後仍無其他玩家加入
    Then 系統補入機器人至 4 人並啟動遊戲
    And 玩家收到 onMessage "game_started"
