from pydantic import BaseModel


class CommodityTranslationSchema(BaseModel):
    id: int
    commodity_id: int
    language_code: str
    translated_name: str

    class Config:
        from_attributes = True


class CommoditySchema(BaseModel):
    id: int
    name: str
    commodity_image_url: str | None = None
    translations: list[CommodityTranslationSchema] | None = None

    class Config:
        from_attributes = True
