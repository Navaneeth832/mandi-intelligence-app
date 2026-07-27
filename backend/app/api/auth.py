from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.schemas.user import (
    SendOTPRequest,
    UserRegister,
    UserLogin,
    UserResponse,
    VerifyOTPRequest,
    ResetPasswordRequest,
)
from app.services.auth_service import AuthService
from app.core.database import get_db

from app.core.dependencies import get_current_user
from app.models.user import User

router = APIRouter(
    prefix="/auth",
    tags=["Authentication"]
)


@router.post("/send-otp")
def send_otp(
    request: SendOTPRequest,
    db: Session = Depends(get_db)
):
    try:
        return AuthService.send_otp(db, request)

    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=str(e)
        )


@router.post("/verify-otp")
def verify_otp(
    request: VerifyOTPRequest,
    db: Session = Depends(get_db)
):
    try:
        return AuthService.verify_otp(db, request)

    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=str(e)
        )


@router.post("/forgot-password/send-otp")
def send_forgot_password_otp(
    request: SendOTPRequest,
    db: Session = Depends(get_db)
):
    try:
        return AuthService.send_forgot_password_otp(db, request)

    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=str(e)
        )


@router.post("/forgot-password/verify-otp")
def verify_forgot_password_otp(
    request: VerifyOTPRequest,
    db: Session = Depends(get_db)
):
    try:
        return AuthService.verify_forgot_password_otp(db, request)

    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=str(e)
        )


@router.post("/forgot-password/reset-password")
def reset_password(
    request: ResetPasswordRequest,
    db: Session = Depends(get_db)
):
    try:
        return AuthService.reset_password(db, request)

    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=str(e)
        )


@router.post("/register", response_model=UserResponse)
def register(
    user: UserRegister,
    db: Session = Depends(get_db)
):
    try:
        return AuthService.register(db, user)

    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=str(e)
        )


@router.post("/login")
def login(
    user: UserLogin,
    db: Session = Depends(get_db)
):
    try:
        return AuthService.login(db, user)

    except ValueError as e:
        raise HTTPException(
            status_code=401,
            detail=str(e)
        )
        
@router.get("/me", response_model=UserResponse)
def get_profile(
    current_user: User = Depends(get_current_user)
):
    return current_user

