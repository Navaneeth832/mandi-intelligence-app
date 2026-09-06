from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import decode_access_token
from app.models.user import User

security = HTTPBearer()
security_optional = HTTPBearer(auto_error=False)


import uuid

def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db),
):
    token = credentials.credentials

    payload = decode_access_token(token)

    if payload is None or "sub" not in payload:
        raise HTTPException(
            status_code=401,
            detail="Invalid token"
        )

    user_id = payload["sub"]
    if isinstance(user_id, str):
        try:
            user_id = uuid.UUID(user_id)
        except ValueError:
            pass

    user = db.get(User, user_id)

    if user is None:
        raise HTTPException(
            status_code=401,
            detail="User not found"
        )

    return user


def get_current_user_optional(
    credentials: HTTPAuthorizationCredentials | None = Depends(security_optional),
    db: Session = Depends(get_db),
) -> User | None:
    if not credentials:
        return None

    token = credentials.credentials
    payload = decode_access_token(token)

    if payload is None or "sub" not in payload:
        return None

    user_id = payload["sub"]
    if isinstance(user_id, str):
        try:
            user_id = uuid.UUID(user_id)
        except ValueError:
            pass

    user = db.get(User, user_id)
    return user