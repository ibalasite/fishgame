---
diagram: activity-gameplay
uml-type: 活動圖（主遊戲流程）
source: PRD.md §4.1; EDD.md §3.1; ARCH.md §3.4
generated: 2026-04-25T00:00:00Z
---

# Activity Diagram — Main Gameplay Loop（主遊戲流程）

> 來源：PRD.md §4.1 In Scope；EDD.md §3.1 分層架構；ARCH.md §3.4 Data Flow Diagram

```mermaid
%%{init: {"theme": "dark"}}%%
flowchart TD
    subgraph Player["👤 Player"]
        P_Start([Start])
        P_OpenApp[開啟遊戲 App]
        P_SelectRoom[選擇房間類型\n競技/休閒/VIP]
        P_WaitMatch[等待配對中\n顯示 Loading UI]
        P_ChooseWeapon[選擇武器與技能\n初始化砲台]
        P_Observe[觀察魚群移動\n選擇目標]
        P_Shoot[點擊射擊\nSHOOT 事件送出]
        P_WaitResult[等待命中結果\n顯示彈道動畫]
        P_ViewHit[顯示命中動畫\n金幣 +N 特效]
        P_ViewMiss[顯示未命中\n彈幕消失]
        P_UseSkill[使用技能\n冰凍/炸彈/鎖定]
        P_ViewResults[查看對局結果\nMVP 獎勵動畫]
        P_Continue{繼續遊玩?}
        P_End([End])
    end

    subgraph GameServer["⚙️ GameServer (Colyseus + Node.js)"]
        GS_Auth[驗證 JWT Token\nonAuth()]
        GS_FindRoom[查詢可用房間\nFindOrCreate]
        GS_WaitPlayers{玩家數 >= 4?}
        GS_AddBot[補 Bot\naddBot()]
        GS_StartSession[建立 GameSession\nstartSession()]
        GS_SpawnFish[生成魚群波次\nFishSpawner.scheduleWave()]
        GS_ValidateShoot[驗證射擊請求\n玩家/魚/武器 合法性]
        GS_RTPCalc[RTP 引擎計算命中\nServer-Authoritative]
        GS_ContributeJP[Jackpot 貢獻\nREDIS INCR +5]
        GS_HitFish[魚扣血\nfish.applyDamage()]
        GS_CheckDead{fish.hp <= 0?}
        GS_KillFish[標記 DEAD\n發布 FishKilled]
        GS_BroadcastHit[廣播命中結果\n STATE_UPDATE delta]
        GS_BroadcastMiss[廣播未命中\nMISS to shooter]
        GS_CheckSession{對局時間 >= 10min?}
        GS_SettleSession[結算 SessionSettleUseCase\n計算 MVP]
        GS_BroadcastResults[廣播對局結果\n RESULTS to all]
    end

    subgraph Database["💾 Database (MySQL + Redis)"]
        DB_Session[INSERT game_sessions]
        DB_Kill[INSERT fish_kills\nrtp_snapshot]
        DB_Balance[UPDATE gold_balance\n async via EventBus]
        DB_SessionEnd[UPDATE game_sessions.status=ENDED]
    end

    P_Start --> P_OpenApp --> P_SelectRoom
    P_SelectRoom --> P_WaitMatch
    P_WaitMatch --> GS_Auth
    GS_Auth --> GS_FindRoom
    GS_FindRoom --> GS_WaitPlayers
    GS_WaitPlayers -->|是| GS_StartSession
    GS_WaitPlayers -->|30s 超時| GS_AddBot --> GS_StartSession
    GS_StartSession --> DB_Session
    DB_Session --> GS_SpawnFish
    GS_SpawnFish --> P_ChooseWeapon

    P_ChooseWeapon --> P_Observe
    P_Observe --> P_Shoot
    P_Observe --> P_UseSkill
    P_UseSkill --> P_Observe

    P_Shoot --> GS_ValidateShoot
    GS_ValidateShoot -->|驗證失敗| P_ViewMiss
    GS_ValidateShoot -->|驗證通過| GS_RTPCalc
    GS_RTPCalc -->|命中| GS_ContributeJP --> GS_HitFish
    GS_RTPCalc -->|未命中| GS_BroadcastMiss --> P_ViewMiss
    GS_HitFish --> GS_CheckDead
    GS_CheckDead -->|存活| GS_BroadcastHit
    GS_CheckDead -->|死亡| GS_KillFish --> DB_Kill --> DB_Balance
    GS_KillFish --> GS_BroadcastHit

    GS_BroadcastHit --> P_WaitResult --> P_ViewHit
    P_ViewMiss --> P_Observe
    P_ViewHit --> P_Observe

    P_Observe --> GS_CheckSession
    GS_CheckSession -->|繼續| GS_SpawnFish
    GS_CheckSession -->|結束| GS_SettleSession --> DB_SessionEnd
    GS_SettleSession --> GS_BroadcastResults --> P_ViewResults

    P_ViewResults --> P_Continue
    P_Continue -->|是| P_SelectRoom
    P_Continue -->|否| P_End
```
