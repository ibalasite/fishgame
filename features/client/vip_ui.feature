# features/client/vip_ui.feature
# 來源：PRD US-VIP-001；PDD §5.7 VIP 光環設計；VDD §3.4 VIP 等級色系；
# PDD §4.4 VIP 訂閱流程；FRONTEND.md §6 ui/common/VIPBadge.ts
# Client 層面：VIP 徽章、房間內光環、訂閱 UI、等級進度顯示

Feature: VIP UI 顯示
  作為高付費的 VIP 玩家
  我希望在遊戲中清楚展示我的 VIP 等級光環
  以便讓其他玩家「看見」我的地位，並強化 VIP 特權的價值感

  Background:
    Given 玩家已登入
    And VIPBadge 元件已初始化

  # ─── VIP 徽章顯示 ─────────────────────────────────────────────

  @client @p0 @visual
  Scenario: VIP 1–2 等（銀牌）玩家徽章顯示靜態銀光環
    Given 玩家 VIP 等級為 "2"（銀牌）
    When 玩家進入 GameScene 或 LobbyScene
    Then VIPBadge 顯示銀牌圖示（主色 #C0C0C0，次色 #E8E8E8）
    And 光環為靜態銀光環（無動畫 loop）
    And VIPBadge 尺寸符合規格（適配 HUD 顯示）
    And 其他玩家砲台位置顯示對應的 VIPBadge（依各自等級）

  @client @p0 @visual
  Scenario: VIP 3–4 等（金牌）玩家徽章顯示緩慢旋轉金光環
    # VDD §3.4：金牌 VIP 光環 6s loop 緩慢旋轉
    Given 玩家 VIP 等級為 "4"（金牌）
    When 玩家進入遊戲房間
    Then VIPBadge 顯示金牌圖示（主色 #FFD700，次色 #FFF176）
    And 光暈以 6 秒為週期緩慢旋轉 loop 動畫（Tween 或 Shader rotation）
    And 金色光暈在深色背景上清晰可見

  @client @p1 @visual
  Scenario: VIP 7–8 等（紅鑽）玩家光環顯示紅色脈衝效果
    # VDD §3.4：紅鑽 2s pulse 脈衝光暈
    Given 玩家 VIP 等級為 "8"（紅鑽）
    When 玩家在房間中可見
    Then VIPBadge 顯示紅鑽圖示（主色 #FF1744，次色 #FF6B6B）
    And 光暈以 2 秒週期做脈衝動畫（opacity 0.6→1.0→0.6，easing sine）
    And 脈衝光暈範圍比金牌等級更大（視覺上更顯著）

  @client @p1 @visual
  Scenario: VIP 10 等（彩虹）玩家顯示彩虹流動光環與全屏小特效進場
    # VDD §3.4：彩虹 3s loop + 進場爆炸
    Given 玩家 VIP 等級為 "10"（彩虹）
    When 玩家進入遊戲房間
    Then VIPBadge 顯示彩虹流動漸層光環（#FF0080→#00D4FF→#00FF88，3s loop）
    And 玩家進入房間時觸發小型全屏特效（彩虹粒子爆炸，1s，只觸發一次）
    And 其他玩家看到「VIP LV.10 [玩家名稱] 加入了房間」系統提示

  # ─── 房間內 VIP 光環可見性 ────────────────────────────────────

  @client @p0 @visual
  Scenario: 遊戲房間中所有玩家 VIP 光環同時可見
    # PDD §5.7：VIP 光環在房間中顯眼可見（Persona B 核心需求）
    Given 房間中有 4 名玩家，VIP 等級分別為：0 / 2（銀）/ 4（金）/ 8（紅鑽）
    When 所有玩家進入 GameScene
    Then 每個玩家砲台旁顯示對應的 VIPBadge（非 VIP 玩家不顯示徽章）
    And VIP 光環不遮擋遊戲主要視野（z-order 管理，低於魚群場景層）
    And VIP 等級越高的光環視覺越顯眼（符合 VDD §3.4 等級差異化規格）

  @client @p0 @visual
  Scenario: 非 VIP 玩家不顯示 VIP 徽章
    Given 玩家 VIP 等級為 "0"（非 VIP）
    When 玩家進入遊戲房間
    Then 玩家砲台旁不顯示任何 VIPBadge
    And 不顯示任何光暈特效

  # ─── VIP 訂閱 UI 流程 ─────────────────────────────────────────

  @client @p0 @interaction
  Scenario: 商城中點擊 VIP 訂閱顯示 VIP 特權對比介紹
    # PDD §4.4 VIP 訂閱流程
    Given 玩家在 ShopDialog 或 ProfileScene 中
    When 玩家點擊「VIP 訂閱」入口
    Then 顯示 VIP 訂閱介紹頁面（Slide Up 或 Modal）
    And 頁面顯示 VIP 等級 1–10 的特權對比表格（每日鑽石補貼 / 加成 / 光環等）
    And 「訂閱 VIP 月費 USD 9.99」Primary Button 清晰可見（56px 高，金色）
    And 頁面滾動展示各等級光環動畫預覽

  @client @p0 @interaction
  Scenario: VIP 訂閱確認後啟用動畫即時顯示光環
    # PDD §4.4：訂閱成功 → VIP 等級啟用動畫 + 光環即時顯示
    Given 玩家確認 VIP 訂閱並支付成功
    When 後端 VIP 等級更新同步至客戶端（API 回應或 Colyseus 事件）
    Then 顯示 VIP 啟用動畫（全屏金色光暈爆發，1s）
    And VIPBadge 以動畫形式出現在玩家砲台旁（scale 0→1.0，500ms 彈入）
    And Toast 顯示「VIP 已啟用！享受每日鑽石補貼」（color-feedback-success，3s）
    And 大廳中玩家名稱旁即時顯示 VIP 等級標籤

  @client @p1 @visual
  Scenario: VIP 訂閱到期前 3 天顯示續費提醒
    Given 玩家 VIP 訂閱剩餘 3 天到期
    When 玩家進入 LobbyScene 或 ProfileScene
    Then 顯示 VIP 到期提醒 Banner（橘色，頂部 Slide Down，4s 後自動收起）
    And Banner 文字「VIP 將於 3 天後到期，立即續費保持特權」
    And Banner 包含「立即續費」Secondary Button

  # ─── VIP 等級進度顯示 ──────────────────────────────────────────

  @client @p1 @visual
  Scenario: ProfileScene 顯示 VIP 等級進度條
    Given 玩家 VIP 等級為 "3"（金牌），累積點數為 350/500
    When 玩家進入 ProfileScene（個人中心）
    Then VIP 等級進度條顯示（當前 350/500 點，70% 進度）
    And 進度條使用金色漸層填充（color-gold-400→color-gold-600）
    And 顯示「距下一等級還差 150 點」文字（text-body-sm，color-text-secondary）
    And VIP 等級圖示（金牌）在進度條左端顯示（與下一等級圖示對比）

  # ─── 錯誤路徑 ─────────────────────────────────────────────────

  @client @p1 @interaction
  Scenario: VIP 訂閱支付失敗時顯示友好錯誤訊息
    Given 玩家確認 VIP 訂閱，但 IAP 支付失敗
    When 支付失敗事件到達客戶端
    Then 顯示錯誤 Modal「訂閱遇到問題，請稍後重試」
    And 不啟用 VIP 等級（不更新 VIPBadge）
    And 提供「重試」Primary Button 和「聯絡客服」連結

  @client @p2 @visual
  Scenario: VIP Shader 資源載入失敗時光環降級顯示
    Given VIP Shader（旋轉光環）資源載入失敗
    When VIPBadge 嘗試渲染光暈效果
    Then VIPBadge 以靜態金色邊框（fallback，2px solid #FFD700）顯示
    And 不顯示動態光暈 Shader 效果
    And Console 輸出 warn 日誌：「VIP shader load failed, using fallback border」
    And 遊戲功能不受影響
