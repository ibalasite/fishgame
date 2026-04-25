# features/client/fish_animation.feature
# 來源：PRD US-FISH-001；PDD §5.4 GameScene 魚群；VDD §4.2 NPC 魚類設計；FRONTEND.md §5 FishSystem / FishPoolManager
# Client 層面：魚入場動畫、Idle 循環、命中特效、死亡動畫、Boss 進場、冰凍狀態

Feature: 魚類動畫與視覺狀態
  作為遊戲中的玩家
  我希望看到流暢的魚類動畫和視覺效果
  以便感受到遊戲世界的生動感與每次擊殺的多巴胺爽感

  Background:
    Given 玩家已進入 GameScene
    And FishPoolManager 已初始化（100 個魚節點物件池）
    And EffectPoolManager 已初始化（HitEffect×50、CoinEffect×100）

  # ─── 魚入場動畫 ──────────────────────────────────────────────

  @client @p0 @visual
  Scenario: 普通魚從屏幕邊緣游入（入場動畫）
    When FishSystem 生成一條普通魚（School Fish，64×48 px）
    Then 魚節點從屏幕任意邊緣（左/右/上）外側出現
    And 魚以設定路徑游入（Tween 移動，500ms ease-in-out）
    And 魚在游入過程中播放 8 幀擺尾 loop 動畫
    And 魚入場時使用淡入效果（opacity 0→1，200ms）

  @client @p0 @visual
  Scenario: 精英魚入場有輪廓光效果
    When FishSystem 生成一條精英魚（Elite Fish，128×96 px）
    Then 精英魚從屏幕邊緣游入（Tween 動畫，600ms）
    And 精英魚外框顯示 2px Outline Shader（顏色對應魚主色，例如 #E91E63）
    And 精英魚同時顯示 HP 血條（顏色初始為 color-neon-green #00FF88）
    And 入場動畫播放 12 幀（含鰭動）

  @client @p0 @visual
  Scenario: Boss 魚進場顯示史詩進場動畫序列
    # VDD §4.2 NPC-03 Boss Fish：16 幀，全屏震動 + 海浪裂開 + 主題音效，1200ms
    When FishSystem 生成一條 Boss 魚（320×240 px）
    Then 畫面執行全屏震動效果（Tween shake，2s，振幅 8px）
    And Boss 魚以 16 幀進場動畫從底部衝入屏幕中央
    And 進場音效（Boss 主題 BGM 段落）觸發（AudioManager.playBGM）
    And 進場動畫總時長 ≤ 1200ms
    And Boss 大型 HP 血條置頂顯示（金框，Tween 300ms 緩衝入場）
    And Boss 名稱標題（text-h1 32px）以 Fade In（300ms）顯示於血條下方

  # ─── 魚 Idle 動畫循環 ─────────────────────────────────────────

  @client @p0 @visual
  Scenario: 普通魚在場景中保持游泳 Idle 動畫
    Given 一條普通魚已進入屏幕並在游動路徑上
    When 魚未被射擊
    Then 魚持續播放 8 幀擺尾 loop 動畫（800ms/loop）
    And 魚依預設路徑緩慢移動（路徑 Tween，方向感自然）

  @client @p0 @visual
  Scenario: 精英魚在場景中的 Idle 動畫含輪廓光閃爍
    Given 一條精英魚已進入屏幕
    When 精英魚未被射擊（Idle 狀態）
    Then 精英魚播放 12 幀 loop 動畫（含鰭動）
    And Outline Shader 以輕微脈衝（opacity 0.7→1.0，1s loop）呈現存在感

  # ─── 命中特效（Hit Effect）──────────────────────────────────

  @client @p0 @visual
  Scenario: 子彈命中普通魚顯示受擊閃爍
    Given 場景中有一條存活的普通魚
    When 伺服器回傳命中事件（hit=true）
    Then 魚播放受擊閃爍動畫（4 幀 / 80ms，白色閃光 Sprite Overlay）
    And EffectPoolManager 在命中坐標生成小金幣粒子（3 枚，飛出 Tween 300ms）
    And 命中音效觸發（短促金屬音）

  @client @p0 @visual
  Scenario: 精英魚多次被命中但未死亡時血條持續減少
    Given 精英魚 HP = 10，當前血量 = 10（血條全滿 100%）
    When 玩家射擊命中 3 次（每次 -1 HP）
    Then 精英魚 HP 血條以 Tween（300ms）動畫從 100% 縮短至 70%
    And 血條顏色保持 color-neon-green（HP > 30%）
    And 每次命中皆觸發受擊閃爍動畫（80ms）

  @client @p1 @visual
  Scenario: 精英魚血量低於 30% 時血條變紅警示
    Given 精英魚 HP 血條顯示，血量剩餘 25%
    When FishSystem 同步血量更新（Colyseus state patch）
    Then 血條顏色從 color-neon-green（#00FF88）Tween 至 color-red-500（#FF4444）
    And 血條邊框閃爍（1s pulse，color-red-500）
    And Boss 魚血量低於 30% 時進一步觸發全場暗度降低至 60%（Boss 高亮效果）

  # ─── 死亡動畫 ─────────────────────────────────────────────────

  @client @p0 @visual
  Scenario: 普通魚死亡後顯示爆炸特效與金幣飛濺
    # VDD §4.2 NPC-01：小爆炸，金幣 ×1–5 飛出，持續 300ms
    Given 一條普通魚 HP 被打至 0（fish_killed Colyseus 事件）
    When FishSystem 接收到死亡事件
    Then 魚節點播放小爆炸特效（EffectPool 粒子，金色，300ms）
    And CoinEffect 生成 1–5 枚金幣粒子從魚位置飛散（Tween 弧線，300ms）
    And 魚節點在特效結束後返回 FishPoolManager 物件池（active = false）
    And 金幣獎勵數字（例如 "+5"）以彈出動畫（scale 0→1.2→1.0，200ms）浮現

  @client @p0 @visual
  Scenario: 精英魚死亡後顯示大爆炸與金幣瀑布
    # VDD §4.2 NPC-02：大爆炸，金幣瀑布（30–50 枚），持續 500ms
    Given 一條精英魚 HP 被打至 0
    When FishSystem 接收到精英魚死亡事件
    Then 播放大爆炸特效（粒子系統，白色閃光 + 金色噴射，500ms）
    And CoinEffect 生成 30–50 枚金幣粒子（弧線飛散，Tween 500ms）
    And 精英魚 HP 血條以 Fade Out（200ms）消失
    And 精英魚 Outline Shader 在死亡時放大（scale 1.0→2.0）後消失

  @client @p0 @visual
  Scenario: Boss 魚死亡觸發全屏金色爆炸與倍率爆字
    # VDD §4.2 NPC-03：32 幀，全屏金色爆炸 + 倍率數字衝屏，持續 ≥ 3000ms
    Given Boss 魚 HP 被打至 0（fish_killed，isBoss=true）
    When FishSystem 接收到 Boss 死亡事件
    Then 播放 32 幀全屏金色爆炸動畫（3000ms）
    And 倍率數字爆字（例如 "×1000"）以 scale 0.5→3.0 衝屏並 Fade Out（1s）
    And 爆字使用 VDD "text-multiplier"（56px / font-weight-900 / font-family-display）
    And 爆字顏色為 color-gold-400（#F5C842）+ shadow-glow-neon（霓虹發光效果）
    And Boss 死亡音效（史詩主題 SFX）觸發
    And 所有玩家 HUD 短暫閃爍金光（200ms 全屏 Overlay）

  # ─── 冰凍狀態（Frozen Fish）──────────────────────────────────

  @client @p1 @visual
  Scenario: 魚被冰凍技能凍結後顯示冰霜視覺效果
    # PDD §5.4：冰凍技能（控場）讓魚暫時靜止
    Given 玩家或隊友使用冰凍技能（FreezeSkill 觸發，Colyseus fish_frozen 事件）
    When 場景中的魚收到 frozen=true 狀態
    Then 魚身覆蓋冰霜 Shader Overlay（半透明藍白色，opacity 0.7）
    And 魚停止游泳動畫（暫停在當前幀）
    And 魚停止移動路徑 Tween
    And 冰凍特效粒子（藍色冰晶粒子，1s loop）在魚周圍持續顯示

  @client @p1 @visual
  Scenario: 冰凍效果結束後魚恢復正常動畫
    Given 一條魚處於冰凍狀態（frozen=true）
    When 冰凍持續時間到期（Colyseus fish_unfrozen 事件）
    Then 冰霜 Shader 以 Fade Out（300ms）消失
    And 魚恢復游泳 Idle 動畫（繼續從當前幀播放）
    And 魚繼續沿路徑移動 Tween
    And 冰晶粒子停止生成並 Fade Out

  # ─── 錯誤狀態（資源未載入）──────────────────────────────────

  @client @p2 @visual
  Scenario: 魚 Prefab 資源載入失敗時顯示佔位圖
    Given FishPoolManager 初始化時 NormalFish.prefab 載入失敗（資源缺失）
    When FishSystem 嘗試生成普通魚
    Then 使用 fallback 佔位 Sprite（純色矩形，64×48 px，灰色）替代魚外觀
    And Console 輸出 warn 日誌（LogUtils.warn）：「NormalFish prefab missing, using fallback」
    And 遊戲邏輯不中斷，射擊命中判定仍正常運作
