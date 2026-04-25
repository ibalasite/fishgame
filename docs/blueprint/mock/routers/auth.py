"""Auth router – POST /v1/auth/register, login, refresh, DELETE logout."""

from __future__ import annotations

import asyncio
import secrets
import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, Query
from fastapi.responses import JSONResponse

from models.schemas import (
    LoginRequest,
    LogoutResponse,
    RefreshRequest,
    RegisterRequest,
    TokenResponse,
    UserOut,
)

router = APIRouter(prefix="/v1/auth", tags=["auth"])


def _error_guard(error: int) -> JSONResponse | None:
    if error:
        return JSONResponse(
            status_code=422,
            content={"detail": "Simulated error triggered by ?error=1"},
        )
    return None


# ---------------------------------------------------------------------------
# POST /v1/auth/register
# ---------------------------------------------------------------------------

@router.post("/register", response_model=UserOut)
async def register(
    body: RegisterRequest,
    delay: int = Query(0, ge=0, description="Delay in milliseconds"),
    error: int = Query(0, ge=0, le=1, description="Return 422 when 1"),
):
    if delay:
        await asyncio.sleep(delay / 1000)
    if guard := _error_guard(error):
        return guard

    now = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
    user = UserOut(
        id=f"usr_{uuid.uuid4().hex[:10].upper()}",
        email=body.email,
        display_name=body.display_name,
        role="player",
        vip_tier=0,
        vip_expires_at=None,
        gold_balance=500,
        diamond_balance=10,
        age_verified=False,
        status="active",
        created_at=now,
        last_login_at=None,
        updated_at=now,
    )
    return user


# ---------------------------------------------------------------------------
# POST /v1/auth/login
# ---------------------------------------------------------------------------

@router.post("/login", response_model=TokenResponse)
async def login(
    body: LoginRequest,
    delay: int = Query(0, ge=0, description="Delay in milliseconds"),
    error: int = Query(0, ge=0, le=1, description="Return 422 when 1"),
):
    if delay:
        await asyncio.sleep(delay / 1000)
    if guard := _error_guard(error):
        return guard

    return TokenResponse(
        access_token=f"mock_access_{secrets.token_hex(24)}",
        refresh_token=f"mock_refresh_{secrets.token_hex(24)}",
    )


# ---------------------------------------------------------------------------
# POST /v1/auth/refresh
# ---------------------------------------------------------------------------

@router.post("/refresh", response_model=TokenResponse)
async def refresh(
    body: RefreshRequest,
    delay: int = Query(0, ge=0, description="Delay in milliseconds"),
    error: int = Query(0, ge=0, le=1, description="Return 422 when 1"),
):
    if delay:
        await asyncio.sleep(delay / 1000)
    if guard := _error_guard(error):
        return guard

    return TokenResponse(
        access_token=f"mock_access_{secrets.token_hex(24)}",
        refresh_token=f"mock_refresh_{secrets.token_hex(24)}",
    )


# ---------------------------------------------------------------------------
# DELETE /v1/auth/logout
# ---------------------------------------------------------------------------

@router.delete("/logout", response_model=LogoutResponse)
async def logout(
    delay: int = Query(0, ge=0, description="Delay in milliseconds"),
    error: int = Query(0, ge=0, le=1, description="Return 422 when 1"),
):
    if delay:
        await asyncio.sleep(delay / 1000)
    if guard := _error_guard(error):
        return guard

    return LogoutResponse(message="Logged out successfully")
