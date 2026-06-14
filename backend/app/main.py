from fastapi import FastAPI

from app.api.routes import states
from app.api.routes import commodities
from app.api.routes import markets
from app.api.routes import mandi_prices
from app.api.routes import price_history

from fastapi.middleware.cors import CORSMiddleware


app = FastAPI()

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