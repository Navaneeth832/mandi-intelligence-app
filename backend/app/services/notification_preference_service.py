from uuid import UUID
from sqlalchemy.orm import Session

from app.models.notification_preference import NotificationPreference
from app.schemas.notification_preference import (
    NotificationPreferenceUpdate,
    NotificationFrequency,
)


class NotificationPreferenceService:
    """Service layer managing user notification preferences."""

    @staticmethod
    def get_preferences(db: Session, user_id: UUID) -> NotificationPreference:
        """
        Fetch user notification preferences.
        If none exist, automatically creates and returns default preferences:
          - price_increase = True
          - price_drop = True
          - better_market = True
          - market_glut = True
          - ai_recommendation = True
          - delivery_in_app = True
          - delivery_sms = False
          - delivery_push = False
          - frequency = 'instant'
        """
        preferences = (
            db.query(NotificationPreference)
            .filter(NotificationPreference.user_id == user_id)
            .first()
        )

        if preferences is None:
            preferences = NotificationPreference(
                user_id=user_id,
                price_increase=True,
                price_drop=True,
                better_market=True,
                market_glut=True,
                ai_recommendation=True,
                delivery_in_app=True,
                delivery_sms=False,
                delivery_push=False,
                frequency=NotificationFrequency.INSTANT.value,
            )
            db.add(preferences)
            db.commit()
            db.refresh(preferences)

        return preferences

    @staticmethod
    def update_preferences(
        db: Session,
        user_id: UUID,
        preference_data: NotificationPreferenceUpdate,
    ) -> NotificationPreference:
        """
        Update user notification preferences.
        If preferences record does not exist yet, creates one with the provided updates.
        """
        preferences = (
            db.query(NotificationPreference)
            .filter(NotificationPreference.user_id == user_id)
            .first()
        )

        if preferences is None:
            preferences = NotificationPreference(user_id=user_id)
            db.add(preferences)

        preferences.price_increase = preference_data.price_increase
        preferences.price_drop = preference_data.price_drop
        preferences.better_market = preference_data.better_market
        preferences.market_glut = preference_data.market_glut
        preferences.ai_recommendation = preference_data.ai_recommendation
        preferences.delivery_in_app = preference_data.delivery_in_app
        preferences.delivery_sms = preference_data.delivery_sms
        preferences.delivery_push = preference_data.delivery_push

        frequency_val = (
            preference_data.frequency.value
            if hasattr(preference_data.frequency, "value")
            else str(preference_data.frequency)
        )
        preferences.frequency = frequency_val

        db.commit()
        db.refresh(preferences)

        return preferences


def get_notification_preferences(
    db: Session,
    user_id: UUID,
) -> NotificationPreference:
    return NotificationPreferenceService.get_preferences(db, user_id)


def update_notification_preferences(
    db: Session,
    user_id: UUID,
    preference_data: NotificationPreferenceUpdate,
) -> NotificationPreference:
    return NotificationPreferenceService.update_preferences(
        db, user_id, preference_data
    )
