# features/client/settings_ui.feature
# 來源：PRD US-ACCT-001；PDD §5.10 設定面板（Settings Panel）；
# PDD §3.2 導覽結構（設定面板採分類清單設計）
# FRONTEND.md §6 dialogs/SettingsDialog.ts；StorageUtils.ts（本地偏好儲存）
# Client 層面：音效/音樂設定、語言切換、帳號安全、即時預覽

Feature: 設定 UI
  作為遊戲玩家
  我希望能在設定面板中快速調整音效、語言和帳號設定
  以便自訂最適合我的遊戲體驗

  Background:
    Given 玩家已登入
    And 設定面板（SettingsDialog）尚未開啟

  # ─── 設定面板開啟 / 關閉 ────────────────────────────────────

  @client @p1 @visual
  Scenario: 點擊設定圖示後設定面板開啟
    Given 玩家在大廳或遊戲 HUD 中
    When 玩家點擊設定圖示按鈕（Icon Button，40×40 px，齒輪圖示）
    Then SettingsDialog 以 Slide Down 動畫（Tween translateY：-屏幕高度→0，250ms，ease-out）出現
    And 背景以半透明遮罩覆蓋（color-bg-overlay：rgba(5,20,40,0.85)）
    And 設定面板使用 VDD 標準面板規格（rgba(10,35,64,0.95) 底色，1px 金色邊框，24px 圓角）

  @client @p1 @interaction
  Scenario: 點擊關閉按鈕設定面板關閉並儲存偏好
    Given SettingsDialog 已開啟，玩家修改了音效設定
    When 玩家點擊右上角關閉（×）按鈕
    Then SettingsDialog 以 Slide Up 動畫（Tween translateY：0→-屏幕高度，200ms）消失
    And StorageUtils 持久化儲存最新偏好（音效狀態、音量等）
    And 遊戲繼續，修改後的設定即時生效

  # ─── 音效與音樂設定 ──────────────────────────────────────────

  @client @p1 @interaction
  Scenario: 音效開關切換即時生效
    Given SettingsDialog 已開啟，音效目前為「開啟」
    When 玩家切換「音效」Toggle 為「關閉」
    Then AudioManager.setSFXEnabled(false) 立即呼叫
    And 後續射擊操作不觸發任何 SFX 音效
    And Toggle 視覺狀態切換（從金色「開」狀態→灰色「關」狀態，150ms Tween）

  @client @p1 @interaction
  Scenario: 背景音樂開關切換即時停止或播放 BGM
    Given SettingsDialog 已開啟，BGM 目前為「開啟」
    When 玩家切換「背景音樂」Toggle 為「關閉」
    Then AudioManager.stopBGM() 立即停止當前背景音樂（300ms 淡出）
    And Toggle 視覺狀態切換為灰色「關」狀態
    When 玩家再次切換 Toggle 為「開啟」
    Then AudioManager.playBGM() 重新播放背景音樂（300ms 淡入）

  @client @p1 @interaction
  Scenario: 音量滑桿拖拽調整音效音量即時預覽
    Given SettingsDialog 已開啟，顯示音效音量滑桿（0–100%）
    When 玩家拖拽滑桿從 80% 至 40%
    Then AudioManager.setSFXVolume(0.4) 即時呼叫（每次拖拽事件）
    And 滑桿拖拽期間播放輕微 SFX 預覽音（每 0.2s 一次）
    And 滑桿軌道填充使用 color-gold-400（已選段）和 color-bg-surface（未選段）

  # ─── 語言切換 ─────────────────────────────────────────────────

  @client @p1 @interaction
  Scenario: 語言切換需二次確認 Modal（防誤觸）
    # PDD §5.10：語言切換需確認 Modal
    Given SettingsDialog 已開啟，當前語言為「繁體中文」
    When 玩家點擊語言選項選擇「English」
    Then 顯示確認 Modal「切換語言將重新載入介面，是否繼續？」
    And Modal 提供「確認切換」Primary Button 和「取消」Secondary Button

  @client @p1 @interaction
  Scenario: 確認語言切換後介面文字即時更新
    Given 語言切換確認 Modal 已顯示，當前語言為「繁體中文」
    When 玩家點擊「確認切換」並選擇目標語言「English」
    Then 確認 Modal 關閉
    And StorageUtils 更新儲存語言偏好（"en"）
    And 介面文字切換至英文（i18n 重新渲染，400ms Fade Out/In 過渡）
    And SettingsDialog 自身文字也切換為英文

  @client @p1 @interaction
  Scenario: 取消語言切換後語言設定不變
    Given 語言切換確認 Modal 已顯示
    When 玩家點擊「取消」
    Then 確認 Modal 關閉
    And 當前語言保持「繁體中文」
    And 語言選單視覺仍顯示「繁體中文」為已選取

  # ─── 帳號安全操作 ──────────────────────────────────────────────

  @client @p1 @interaction
  Scenario: 修改密碼需進行二次身份驗證
    # PDD §5.10：帳號安全操作需二次驗證
    Given SettingsDialog 帳號安全分類已展開
    When 玩家點擊「修改密碼」
    Then 顯示二次驗證 Modal（輸入「當前密碼」驗證身份）
    And 輸入欄位使用 VDD 輸入欄位規格（高度 52px，16px 圓角，金色 focus 邊框）
    And 點擊「驗證並繼續」後呼叫 API 驗證當前密碼

  @client @p1 @interaction
  Scenario: 帳號安全二次驗證失敗時顯示 Inline 錯誤
    Given 帳號安全二次驗證 Modal 已顯示
    When 玩家輸入錯誤的當前密碼並提交
    Then 輸入框邊框變為 color-feedback-error（#FF4444，2px）
    And 輸入框下方顯示「密碼不正確，請重試」Inline 錯誤文字（text-body-sm，color-feedback-error）
    And 不跳轉至修改密碼頁面

  @client @p2 @interaction
  Scenario: 登出帳號需確認 Modal 防止誤觸
    Given SettingsDialog 帳號安全分類已展開
    When 玩家點擊「登出」按鈕（Danger Button，#FF4444）
    Then 顯示確認 Modal「確定要登出嗎？」
    And 提供「確定登出」Danger Button 和「取消」Secondary Button
    When 玩家確認登出
    Then 清除本地 JWT Token 和 Session（StorageUtils.clear）
    And 跳轉至 LoginScene（Fade Out→Fade In，300ms）

  # ─── 設定面板分類導覽 ────────────────────────────────────────

  @client @p1 @visual
  Scenario: 設定面板分類清單正確顯示四大分類
    Given SettingsDialog 已開啟
    When 面板完整渲染
    Then 顯示四個設定分類（可折疊清單）：音效、語言、帳號安全、關於
    And 每個分類標題使用 text-h3（20px / font-weight-600）
    And 各分類以折疊/展開互動（Tween 高度動畫，200ms）
    And 預設展開「音效」分類，其他分類收合

  # ─── 錯誤狀態 ─────────────────────────────────────────────────

  @client @p2 @interaction
  Scenario: 設定儲存 API 失敗時顯示重試提示但本地設定仍生效
    Given 玩家修改音效設定，StorageUtils 本地儲存成功但 API 同步失敗
    When API 回傳 503
    Then 音效設定在本地立即生效（StorageUtils 已儲存）
    And 顯示 Toast「設定已在本機儲存，稍後同步至雲端」（color-feedback-warning，2s）
    And 不阻擋玩家繼續操作
