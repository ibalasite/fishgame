---
diagram: frontend-activity-ui
uml-type: 大廳→遊戲 UI 流程活動圖
source: FRONTEND.md + PDD.md + VDD.md
generated: 2026-04-25T00:00:00Z
engine: Cocos Creator 3.8
---

# 大廳→遊戲 UI 流程活動圖（泳道）

> 來源：FRONTEND.md §ui/lobby / §MatchmakingScene / §CannonSelectScene

```mermaid
flowchart TD
    subgraph Player["👤 Player（玩家）"]
        A1([進入大廳 LobbyScene])
        A2{選擇配對方式？}
        A3[選擇特定房間]
        A4[點擊快速配對]
        A9[選擇砲台卡片]
        A10{餘額不足選武器？}
        A11[顯示充值提示]
        A12[確認武器 + 技能]
        A17([進入 GameScene 遊戲])
    end

    subgraph LobbyClient["🏠 LobbyUI（Cocos Client）"]
        B1[加載房間列表\nHttpClient.GET /api/v1/rooms]
        B2[渲染 RoomListItem 卡片]
        B3{房間是否有空位？}
        B4[顯示房間已滿提示]
        B5[SceneManager.loadScene CANNON_SELECT]
        B6[MatchmakingScene.startMatchmaking]
    end

    subgraph MatchScene["⏳ MatchmakingScene"]
        C1[MatchmakingUI.startMatchmaking(30s)]
        C2[輪詢配對狀態\nHttpClient.POST /api/v1/match/join]
        C3{配對超時 30s？}
        C4[Bot 補位入場]
        C5{配對成功？}
        C6[SceneManager.loadScene GAME]
    end

    subgraph GameServer["☁️ Game Server（HTTP）"]
        D1[POST /api/v1/match/join\n返回 matchToken]
        D2{找到真人玩家？}
        D3[回傳 roomId + players]
        D4[Bot 填補空位\n回傳 roomId + botPlayers]
    end

    A1 --> B1
    B1 --> B2
    B2 --> A2
    A2 -- 選房間 --> A3
    A2 -- 快速配對 --> A4
    A3 --> B3
    B3 -- 已滿 --> B4
    B4 --> A1
    B3 -- 有空位 --> B5
    A4 --> B6
    B6 --> C1
    C1 --> D1
    D1 --> C2
    C2 --> D2
    D2 -- 是 --> D3
    D2 -- 否，等待中... --> C3
    C3 -- 超時 --> C4
    C4 --> D4
    D4 --> C5
    D3 --> C5
    C5 -- 成功 --> C6
    C6 --> B5
    B5 --> A9
    A9 --> A10
    A10 -- 是 --> A11
    A11 --> A9
    A10 -- 否 --> A12
    A12 --> C1
    C1 --> C5
    C5 -- 成功 --> A17
```
