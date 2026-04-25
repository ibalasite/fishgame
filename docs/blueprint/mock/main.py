"""FastAPI mock server for FishGame API.

Features
--------
- CORS open for all origins (dev mode)
- ?delay=N  – sleep N milliseconds before responding
- ?error=1  – return HTTP 422 to simulate error handling
- Authorization: Bearer header check (presence only, token not validated)
- WebSocket /ws/game/{room_id} – echo + fish-event broadcast every 2 s
"""

from __future__ import annotations

import asyncio
import json
import random
from datetime import datetime, timezone

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware

from routers import admin, auth, game, shop

app = FastAPI(
    title="FishGame Mock API",
    description="開發用假資料伺服器，支援 delay / error 查詢參數與 WebSocket 魚群事件",
    version="0.1.0",
)

# ---------------------------------------------------------------------------
# CORS – allow everything for local development
# ---------------------------------------------------------------------------

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------------------------
# Routers
# ---------------------------------------------------------------------------

app.include_router(auth.router)
app.include_router(game.router)
app.include_router(shop.router)
app.include_router(admin.router)

# ---------------------------------------------------------------------------
# Health check
# ---------------------------------------------------------------------------

@app.get("/health", tags=["health"])
async def health():
    return {"status": "ok", "timestamp": datetime.now(timezone.utc).isoformat()}


# ---------------------------------------------------------------------------
# WebSocket – /ws/game/{room_id}
# ---------------------------------------------------------------------------

_FISH_TYPES = ["鯊魚", "旗魚", "金槍魚", "章魚", "龍蝦", "河豚", "鰻魚"]
_EVENTS = ["spawn", "boss_spawn", "jackpot_trigger"]


async def _broadcast_fish_events(websocket: WebSocket, room_id: str) -> None:
    """Emit a fake fish event to the connected client every 2 seconds."""
    while True:
        await asyncio.sleep(2)
        event = {
            "type": random.choice(_EVENTS),
            "room_id": room_id,
            "fish": random.choice(_FISH_TYPES),
            "x": round(random.uniform(0, 1920), 1),
            "y": round(random.uniform(0, 1080), 1),
            "reward": random.randint(10, 5000),
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }
        await websocket.send_text(json.dumps(event, ensure_ascii=False))


@app.websocket("/ws/game/{room_id}")
async def websocket_game(websocket: WebSocket, room_id: str):
    await websocket.accept()
    broadcast_task = asyncio.create_task(
        _broadcast_fish_events(websocket, room_id)
    )
    try:
        while True:
            # Echo any message the client sends back with a wrapper
            data = await websocket.receive_text()
            echo = {
                "type": "echo",
                "room_id": room_id,
                "data": data,
                "timestamp": datetime.now(timezone.utc).isoformat(),
            }
            await websocket.send_text(json.dumps(echo, ensure_ascii=False))
    except WebSocketDisconnect:
        pass
    finally:
        broadcast_task.cancel()
