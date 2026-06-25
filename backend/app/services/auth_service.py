from uuid import uuid4

from sqlalchemy.orm import Session

from app.models.user import User
from app.schemas.user import UserRegister, UserLogin
from app.core.security import (
    hash_password,
    verify_password,
    create_access_token,
)


class AuthService:

    @staticmethod
    def register(db: Session, user_data: UserRegister):

        # Check if email already exists
        existing_user = (
            db.query(User)
            .filter(User.email == user_data.email)
            .first()
        )

        if existing_user:
            raise ValueError("Email already registered")

        user = User(
            id=uuid4(),
            name=user_data.name,
            email=user_data.email,
            password_hash=hash_password(user_data.password),
        )

        db.add(user)
        db.commit()
        db.refresh(user)

        return user

    @staticmethod
    def login(db: Session, user_data: UserLogin):

        user = (
            db.query(User)
            .filter(User.email == user_data.email)
            .first()
        )

        if not user:
            raise ValueError("Invalid email or password")

        if not verify_password(
            user_data.password,
            user.password_hash,
        ):
            raise ValueError("Invalid email or password")

        token = create_access_token(
            {
                "sub": str(user.id)
            }
        )

        return {
            "access_token": token,
            "token_type": "bearer",
            "user": user,
        }