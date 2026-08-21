from pydantic import BaseModel, EmailStr
from uuid import UUID
from typing import List


class SendOTPRequest(BaseModel):
    identifier: str


class VerifyOTPRequest(BaseModel):
    identifier: str
    otp: str


class UserRegister(BaseModel):
    name: str
    identifier: str
    password: str
    verification_token: str
    state_id: int | None = None
    district_id: int | None = None
    preferred_market_id: int | None = None
    preferred_language: str = "en"


class UserLogin(BaseModel):
    identifier: str
    password: str


class ResetPasswordRequest(BaseModel):
    identifier: str
    verification_token: str
    new_password: str



class UserProfileUpdate(BaseModel):
    name: str
    state_id: int | None = None
    district_id: int | None = None
    preferred_market_id: int | None = None
    preferred_language: str


class UserResponse(BaseModel):
    id: UUID
    name: str
    email: EmailStr | None = None
    phone_number: str | None = None
    registration_method: str
    is_verified: bool

    state_id: int | None = None
    district_id: int | None = None
    preferred_market_id: int | None = None

    state_name: str | None = None
    district_name: str | None = None
    preferred_market_name: str | None = None

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
