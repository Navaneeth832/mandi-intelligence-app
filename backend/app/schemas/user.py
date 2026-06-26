from pydantic import BaseModel, EmailStr
from uuid import UUID
from typing import List


class UserRegister(BaseModel):
    name: str
    email: EmailStr
    password: str


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserProfileUpdate(BaseModel):
    name: str
    state_id: int | None = None
    district_id: int | None = None
    preferred_language: str


class UserResponse(BaseModel):
    id: UUID
    name: str
    email: EmailStr
    state_id: int | None
    district_id: int | None
    preferred_language: str

    class Config:
        from_attributes = True


class CropPreferenceUpdate(BaseModel):
    commodity_ids: List[int]
    
class CropPreferenceResponse(BaseModel):
    commodity_id: int
    commodity_name: str


class CropPreferenceListResponse(BaseModel):
    preferences: List[CropPreferenceResponse]