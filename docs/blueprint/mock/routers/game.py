"""Game router – rooms, leaderboard, history."""

from __future__ import annotations

import asyncio
import json
import uuid
from datetime import datetime, timezone
from pathlib import Path
from typing import List, Optional

from fastapi import APIRouter, Header, HTTPException, Query
from fastapi.responses import JSONResponse

from models.schemas import (
    CreateRoomRequest,
    CreateRoomResponse,
    GameHistoryEntry,
    LeaderboardEntry,
    ListResponse,
    RoomOut,
)

router = APIRouter(prefix="/v1/game", tags=["game"])

DATA_DIR = Path(__file__).parent.parent / "data"


def _load_json(filename: str) -> list | dict:
    with open(DATA_DIR / filename, encoding="utf-8") as f:
        return json.load(f)


def _auth_guard(authorization: Optional[str]) -> None:
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header required")


def _error_guard(error: int) -> JSONResponse | None:
    if error:
        return JSONResponse(
            status_code=422,
            content={"detail": "Simulated error triggered by ?error=1"},
        )
    return None


# ---------------------------------------------------------------------------
# GET /v1/game/rooms
# ---------------------------------------------------------------------------

@router.get("/rooms", response_model=ListResponse)
async def list_rooms(
    status: Optional[str] = Query(None, description="Filter by status"),
    delay: int = Query(0, ge=0),
    error: int = Query(0, ge=0, le=1),
    authorization: Optional[str] = Header(None),
):
    _auth_guard(authorization)
    if delay:
        await asyncio.sleep(delay / 1000)
    if guard := _error_guard(error):
        return guard

    rooms: list = _load_json("game_rooms.json")
    if status:
        rooms = [r for r in rooms if r.get("status") == status]
    return ListResponse(data=rooms, total=len(rooms))


# ---------------------------------------------------------------------------
# POST /v1/game/rooms
# ---------------------------------------------------------------------------

@router.post("/rooms", response_model=CreateRoomResponse, status_code=201)
async def create_room(
    body: CreateRoomRequest,
    delay: int = Query(0, ge=0),
    error: int = Query(0, ge=0, le=1),
    authorization: Optional[str] = Header(None),
):
    _auth_guard(authorization)
    if delay:
        await asyncio.sleep(delay / 1000)
    if guard := _error_guard(error):
        return guard

    now = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
    room = CreateRoomResponse(
        room_id=f"room_{uuid.uuid4().hex[:10].upper()}",
        room_name=body.room_name,
        status="waiting",
        current_players=1,
        max_players=body.max_players,
        jackpot_pool=0,
        min_bet=body.min_bet,
        max_bet=body.max_bet,
        created_at=now,
    )
    return room


# ---------------------------------------------------------------------------
# GET /v1/game/rooms/{room_id}
# ---------------------------------------------------------------------------

@router.get("/rooms/{room_id}", response_model=RoomOut)
async def get_room(
    room_id: str,
    delay: int = Query(0, ge=0),
    error: int = Query(0, ge=0, le=1),
    authorization: Optional[str] = Header(None),
):
    _auth_guard(authorization)
    if delay:
        await asyncio.sleep(delay / 1000)
    if guard := _error_guard(error):
        return guard

    rooms: list = _load_json("game_rooms.json")
    for room in rooms:
        if room["room_id"] == room_id:
            return room
    raise HTTPException(status_code=404, detail=f"Room '{room_id}' not found")


# ---------------------------------------------------------------------------
# GET /v1/game/leaderboard
# ---------------------------------------------------------------------------

@router.get("/leaderboard", response_model=ListResponse)
async def leaderboard(
    limit: int = Query(10, ge=1, le=100),
    delay: int = Query(0, ge=0),
    error: int = Query(0, ge=0, le=1),
    authorization: Optional[str] = Header(None),
):
    _auth_guard(authorization)
    if delay:
        await asyncio.sleep(delay / 1000)
    if guard := _error_guard(error):
        return guard

    entries: list = _load_json("leaderboard.json")
    entries = entries[:limit]
    return ListResponse(data=entries, total=len(entries))


# ---------------------------------------------------------------------------
# GET /v1/game/history
# ---------------------------------------------------------------------------

@router.get("/history", response_model=ListResponse)
async def game_history(
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    delay: int = Query(0, ge=0),
    error: int = Query(0, ge=0, le=1),
    authorization: Optional[str] = Header(None),
):
    _auth_guard(authorization)
    if delay:
        await asyncio.sleep(delay / 1000)
    if guard := _error_guard(error):
        return guard

    entries: list = _load_json("game_history.json")
    page = entries[offset : offset + limit]
    return ListResponse(data=page, total=len(entries))
