from pydantic import BaseModel


class StateTranslationSchema(BaseModel):
    id: int
    state_id: int
    language_code: str
    translated_name: str

    class Config:
        from_attributes = True


class StateSchema(BaseModel):
    id: int
    name: str
    translations: list[StateTranslationSchema] | None = None

    class Config:
        from_attributes = True


class DistrictTranslationSchema(BaseModel):
    id: int
    district_id: int
    language_code: str
    translated_name: str

    class Config:
        from_attributes = True


class DistrictSchema(BaseModel):
    id: int
    name: str
    state_id: int
    translations: list[DistrictTranslationSchema] | None = None

    class Config:
        from_attributes = True


class MarketTranslationSchema(BaseModel):
    id: int
    market_id: int
    language_code: str
    translated_name: str

    class Config:
        from_attributes = True


class MarketSchema(BaseModel):
    id: int
    name: str
    district_id: int
    translations: list[MarketTranslationSchema] | None = None

    class Config:
        from_attributes = True
