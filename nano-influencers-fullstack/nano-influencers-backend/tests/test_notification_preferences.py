from app.services.notification_service import notification_is_enabled, notification_preference_keys


def test_notifications_are_disabled_by_default():
    assert notification_is_enabled("deposit_success", {}) is False
    assert notification_is_enabled("campaign_approved", None) is False
    assert notification_is_enabled("unknown_event", {"emailCampaign": True, "pushWallet": True}) is False


def test_wallet_notifications_follow_wallet_toggles():
    assert notification_is_enabled("deposit_success", {"emailWallet": True}) is True
    assert notification_is_enabled("withdrawal_processed", {"pushWallet": True}) is True
    assert notification_is_enabled("deposit_success", {"emailCampaign": True}) is False


def test_campaign_notifications_follow_campaign_toggles():
    assert notification_is_enabled("campaign_paused", {"pushCampaign": True}) is True
    assert notification_is_enabled("campaign_completed", {"emailCampaign": True}) is True
    assert notification_is_enabled("campaign_completed", {"emailWallet": True}) is False


def test_message_and_marketing_notifications_use_their_own_toggles():
    assert notification_is_enabled("direct_message", {"pushMessages": True}) is True
    assert notification_is_enabled("marketing_promotion", {"emailMarketing": True}) is True
    assert notification_is_enabled("direct_message", {"emailCampaign": True}) is False


def test_unknown_notification_types_are_never_shown():
    assert notification_preference_keys("something_new") == ()
    assert notification_is_enabled("something_new", {"emailCampaign": True, "pushWallet": True}) is False
