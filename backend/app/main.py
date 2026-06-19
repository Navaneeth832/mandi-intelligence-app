import sys
import os
import asyncio
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.routes import states
from app.api.routes import commodities
from app.api.routes import markets
from app.api.routes import mandi_prices
from app.api.routes import price_history
from app.api.routes import districts
from app.api.routes import market_directory


async def fetch_prices_task():
    """Periodic task to fetch live mandi prices every 1 hour."""
    while True:
        try:
            print("[Scheduler] Starting Task 1: Fetching live mandi prices...")
            from price_fetcher import run_fetching_pipeline
            await asyncio.to_thread(run_fetching_pipeline)
            print("[Scheduler] Task 1 completed successfully.")
        except Exception as e:
            print(f"[Scheduler Error] Task 1 price_fetcher encountered an error: {e}. Retrying in 1 hour.")
        await asyncio.sleep(3600)


async def generate_mapping_task():
    """Periodic task to generate mappings every 12 hours."""
    await asyncio.sleep(50)
    while True:
        try:
            print("[Scheduler] Starting Task 2: Generating mapping...")
            from generate_mapping import create_mapping
            await asyncio.to_thread(create_mapping)
            print("[Scheduler] Task 2 completed successfully.")
        except Exception as e:
            print(f"[Scheduler Error] Task 2 generate_mapping encountered an error: {e}. Retrying in 12 hours.")
        await asyncio.sleep(12 * 3600)


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Start tasks in background
    price_task = asyncio.create_task(fetch_prices_task())
    mapping_task = asyncio.create_task(generate_mapping_task())
    yield
    # Cleanup tasks on shutdown
    price_task.cancel()
    mapping_task.cancel()
    await asyncio.gather(price_task, mapping_task, return_exceptions=True)


app = FastAPI(lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def root():
    return {"message": "Mandi Intelligence API"}


@app.get("/health")
def health():
    return {"status": "healthy"}


app.include_router(
    states.router,
    prefix="/states",
    tags=["States"]
)

app.include_router(
    commodities.router,
    prefix="/commodities",
    tags=["Commodities"]
)

app.include_router(
    markets.router,
    prefix="/markets",
    tags=["Markets"]
)

app.include_router(
    mandi_prices.router,
    prefix="/mandi-prices",
    tags=["Mandi Prices"]
)

app.include_router(
    price_history.router,
    prefix="/price-history",
    tags=["Price history"]
)

app.include_router(
    districts.router,
    prefix="/districts",
    tags=["Districts"]
)

app.include_router(
    market_directory.router,
    prefix="/market-directory",
    tags=["Market Directory"]
)
