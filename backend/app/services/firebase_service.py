import os
import logging
from typing import List, Optional
from app.core.config import settings

logger = logging.getLogger(__name__)

_firebase_initialized = False

def init_firebase():
    global _firebase_initialized
    if _firebase_initialized:
        return True
    
    cred_json = getattr(settings, "FIREBASE_CREDENTIALS_JSON", None)
    cred_path = getattr(settings, "FIREBASE_CREDENTIALS_PATH", None)

    try:
        import json
        import firebase_admin
        from firebase_admin import credentials
        
        if not firebase_admin._apps:
            if cred_json and cred_json.strip():
                # Parse raw JSON string from environment variable
                try:
                    cert_dict = json.loads(cred_json)
                    cred = credentials.Certificate(cert_dict)
                except Exception as json_err:
                    logger.error(f"Invalid FIREBASE_CREDENTIALS_JSON string: {json_err}")
                    return False
            else:
                target_path = None
                if cred_path:
                    candidates = [
                        cred_path,
                        os.path.basename(cred_path),
                        os.path.join(os.path.dirname(__file__), "..", "..", cred_path),
                        os.path.join(os.path.dirname(__file__), "..", "..", os.path.basename(cred_path)),
                    ]
                    for candidate in candidates:
                        if candidate and os.path.exists(candidate):
                            target_path = candidate
                            break

                if target_path:
                    cred = credentials.Certificate(target_path)
                else:
                    logger.warning("Neither FIREBASE_CREDENTIALS_JSON nor valid FIREBASE_CREDENTIALS_PATH found. Push notifications disabled.")
                    return False


            firebase_admin.initialize_app(cred)

        _firebase_initialized = True
        logger.info("Firebase Admin SDK initialized successfully.")
        return True
    except Exception as e:
        logger.error(f"Failed to initialize Firebase Admin SDK: {e}")
        return False



def send_fcm_notification(
    tokens: List[str],
    title: str,
    body: str,
    data: Optional[dict] = None
) -> int:
    """
    Sends FCM Push Notification to a list of device tokens.
    Returns the count of successfully delivered messages.
    """
    if not tokens:
        return 0

    if not init_firebase():
        logger.info("Skipping FCM send: Firebase not initialized.")
        return 0

    try:
        import firebase_admin
        from firebase_admin import messaging

        # Prepare string data map
        payload_data = {k: str(v) for k, v in (data or {}).items()}

        message = messaging.MulticastMessage(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            data=payload_data,
            tokens=tokens,
        )

        response = messaging.send_each_for_multicast(message)
        logger.info(f"FCM Multicast sent: {response.success_count} success, {response.failure_count} failure out of {len(tokens)} tokens.")
        return response.success_count
    except Exception as e:
        logger.error(f"Error sending FCM notification: {e}")
        return 0
