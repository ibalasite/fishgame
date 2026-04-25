"""Pydantic models matching the data/*.json structures."""

from __future__ import annotations

from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel


# ---------------------------------------------------------------------------
# Auth
# ---------------------------------------------------------------------------

class RegisterRequest(BaseModel):
    email: str
    password: str
    display_name: str


class LoginRequest(BaseModel):
    email: str
    password: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int = 3600


class RefreshRequest(BaseModel):
    refresh_token: str


class LogoutResponse(BaseModel):
    message: str


# ---------------------------------------------------------------------------
# User
# ---------------------------------------------------------------------------

class UserOut(BaseModel):
    id: str
    email: str
    display_name: str
    role: str
    vip_tier: int
    vip_expires_at: Optional[datetime]
    gold_balance: int
    diamond_balance: int
    age_verified: bool
    status: str
    created_at: datetime
    last_login_at: Optional[datetime]
    updated_at: datetime


# ---------------------------------------------------------------------------
# Game rooms
# ---------------------------------------------------------------------------

class RoomOut(BaseModel):
    room_id: str
    room_name: str
    status: str
    current_players: int
    max_players: int
    jackpot_pool: int
    min_bet: int
    max_bet: int
    created_at: datetime


class CreateRoomRequest(BaseModel):
    room_name: str
    max_players: int = 6
    min_bet: int = 10
    max_bet: int = 500


class CreateRoomResponse(BaseModel):
    room_id: str
    room_name: str
    status: str
    current_players: int
    max_players: int
    jackpot_pool: int
    min_bet: int
    max_bet: int
    created_at: str


# ---------------------------------------------------------------------------
# Leaderboard
# ---------------------------------------------------------------------------

class LeaderboardEntry(BaseModel):
    rank: int
    user_id: str
    display_name: str
    vip_tier: int
    gold_earned: int
    fish_killed: int
    jackpot_count: int


# ---------------------------------------------------------------------------
# Game history
# ---------------------------------------------------------------------------

class GameHistoryEntry(BaseModel):
    session_id: str
    room_name: str
    started_at: datetime
    ended_at: datetime
    duration_seconds: int
    gold_earned: int
    gold_spent: int
    fish_killed: int
    jackpot_won: bool
    jackpot_amount: int


# ---------------------------------------------------------------------------
# Shop products
# ---------------------------------------------------------------------------

class ShopProduct(BaseModel):
    product_id: str
    name: str
    description: str
    diamond_amount: int
    bonus_diamonds: int
    price_usd: str
    price_twd: int
    platform: str
    is_active: bool
    sort_order: int
    created_at: datetime


# ---------------------------------------------------------------------------
# Orders
# ---------------------------------------------------------------------------

class PurchaseRequest(BaseModel):
    product_id: str
    platform: str
    iap_receipt: str
    idempotency_key: str


class OrderOut(BaseModel):
    order_id: str
    user_id: str
    product_id: str
    product_name: str
    diamond_amount: int
    price_usd: str
    platform: str
    iap_receipt: str
    status: str
    idempotency_key: str
    created_at: datetime
    completed_at: Optional[datetime]


# ---------------------------------------------------------------------------
# Admin – KPI stats
# ---------------------------------------------------------------------------

class KpiStats(BaseModel):
    period: str
    date: str
    dau: int
    mau: int
    new_users_today: int
    active_rooms_peak: int
    total_gold_circulated: int
    total_jackpot_paid: int
    iap_revenue_usd: str
    iap_orders_count: int
    vip_subscribers_active: int
    avg_session_duration_minutes: float
    retention_d1: float
    retention_d7: float
    retention_d30: float


# ---------------------------------------------------------------------------
# Admin – game config
# ---------------------------------------------------------------------------

class GameConfig(BaseModel):
    rtp_target: float
    jackpot_trigger_probability: float
    jackpot_seed_amount: int
    jackpot_contribution_rate: float
    max_concurrent_rooms: int
    default_room_max_players: int
    fish_spawn_interval_ms: int
    boss_spawn_interval_minutes: int
    updated_at: datetime
    updated_by: str


class PatchGameConfigRequest(BaseModel):
    rtp_target: Optional[float] = None
    jackpot_trigger_probability: Optional[float] = None
    jackpot_seed_amount: Optional[int] = None
    jackpot_contribution_rate: Optional[float] = None
    max_concurrent_rooms: Optional[int] = None
    default_room_max_players: Optional[int] = None
    fish_spawn_interval_ms: Optional[int] = None
    boss_spawn_interval_minutes: Optional[int] = None


# ---------------------------------------------------------------------------
# Generic wrappers
# ---------------------------------------------------------------------------

class ListResponse(BaseModel):
    data: list
    total: int


class ErrorResponse(BaseModel):
    detail: str
