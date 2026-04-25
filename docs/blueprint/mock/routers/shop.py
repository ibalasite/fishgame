"""Shop router – products, purchase, orders."""

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
    ListResponse,
    OrderOut,
    PurchaseRequest,
    ShopProduct,
)

router = APIRouter(prefix="/v1/shop", tags=["shop"])

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
# GET /v1/shop/products
# ---------------------------------------------------------------------------

@router.get("/products", response_model=ListResponse)
async def list_products(
    delay: int = Query(0, ge=0),
    error: int = Query(0, ge=0, le=1),
    authorization: Optional[str] = Header(None),
):
    _auth_guard(authorization)
    if delay:
        await asyncio.sleep(delay / 1000)
    if guard := _error_guard(error):
        return guard

    products: list = _load_json("shop_products.json")
    active = [p for p in products if p.get("is_active")]
    return ListResponse(data=active, total=len(active))


# ---------------------------------------------------------------------------
# POST /v1/shop/purchase
# ---------------------------------------------------------------------------

@router.post("/purchase", response_model=OrderOut, status_code=201)
async def purchase(
    body: PurchaseRequest,
    delay: int = Query(0, ge=0),
    error: int = Query(0, ge=0, le=1),
    authorization: Optional[str] = Header(None),
):
    _auth_guard(authorization)
    if delay:
        await asyncio.sleep(delay / 1000)
    if guard := _error_guard(error):
        return guard

    products: list = _load_json("shop_products.json")
    product = next((p for p in products if p["product_id"] == body.product_id), None)
    if not product:
        raise HTTPException(status_code=404, detail=f"Product '{body.product_id}' not found")

    now = datetime.now(timezone.utc)
    order = OrderOut(
        order_id=str(uuid.uuid4()),
        user_id="usr_01HX7ABCD1",  # mock: always the first demo user
        product_id=body.product_id,
        product_name=product["name"],
        diamond_amount=product["diamond_amount"] + product["bonus_diamonds"],
        price_usd=product["price_usd"],
        platform=body.platform,
        iap_receipt=body.iap_receipt,
        status="completed",
        idempotency_key=body.idempotency_key,
        created_at=now,
        completed_at=now,
    )
    return order


# ---------------------------------------------------------------------------
# GET /v1/shop/orders
# ---------------------------------------------------------------------------

@router.get("/orders", response_model=ListResponse)
async def list_orders(
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

    orders: list = _load_json("orders.json")
    page = orders[offset : offset + limit]
    return ListResponse(data=page, total=len(orders))
