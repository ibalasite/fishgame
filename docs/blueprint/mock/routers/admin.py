"""Admin router – stats, game-config, users."""

from __future__ import annotations

import asyncio
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional

from fastapi import APIRouter, Header, HTTPException, Query
from fastapi.responses import JSONResponse

from models.schemas import (
    GameConfig,
    KpiStats,
    ListResponse,
    PatchGameConfigRequest,
    UserOut,
)

router = APIRouter(prefix="/v1/admin", tags=["admin"])

DATA_DIR = Path(__file__).parent.parent / "data"

# In-memory mutable copy of game config so PATCH changes persist per session
_game_config_cache: dict | None = None


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
# GET /v1/admin/stats
# ---------------------------------------------------------------------------

@router.get("/stats", response_model=KpiStats)
async def get_stats(
    delay: int = Query(0, ge=0),
    error: int = Query(0, ge=0, le=1),
    authorization: Optional[str] = Header(None),
):
    _auth_guard(authorization)
    if delay:
        await asyncio.sleep(delay / 1000)
    if guard := _error_guard(error):
        return guard

    stats = _load_json("kpi_stats.json")
    return stats


# ---------------------------------------------------------------------------
# PATCH /v1/admin/game-config
# ---------------------------------------------------------------------------

@router.patch("/game-config", response_model=GameConfig)
async def patch_game_config(
    body: PatchGameConfigRequest,
    delay: int = Query(0, ge=0),
    error: int = Query(0, ge=0, le=1),
    authorization: Optional[str] = Header(None),
):
    _auth_guard(authorization)
    if delay:
        await asyncio.sleep(delay / 1000)
    if guard := _error_guard(error):
        return guard

    global _game_config_cache
    if _game_config_cache is None:
        _game_config_cache = dict(_load_json("game_config.json"))

    updates = body.model_dump(exclude_none=True)
    _game_config_cache.update(updates)
    _game_config_cache["updated_at"] = (
        datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
    )
    return _game_config_cache


# ---------------------------------------------------------------------------
# GET /v1/admin/users
# ---------------------------------------------------------------------------

@router.get("/users", response_model=ListResponse)
async def list_users(
    status: Optional[str] = Query(None, description="Filter by status"),
    role: Optional[str] = Query(None, description="Filter by role"),
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

    users: list = _load_json("users.json")
    if status:
        users = [u for u in users if u.get("status") == status]
    if role:
        users = [u for u in users if u.get("role") == role]
    page = users[offset : offset + limit]
    return ListResponse(data=page, total=len(users))
