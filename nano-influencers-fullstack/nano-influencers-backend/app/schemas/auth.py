import re
import uuid
from pydantic import BaseModel, EmailStr, Field, field_validator


class RegisterRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8, max_length=72)
    full_name: str = Field(min_length=2, max_length=255)
    role: str
    referral_code: str | None = None

    @field_validator("full_name")
    @classmethod
    def validate_full_name(cls, value: str) -> str:
        value = " ".join(value.split())
        if len(value) < 2:
            raise ValueError("Please enter your full name")
        return value

    @field_validator("role")
    @classmethod
    def validate_role(cls, value: str) -> str:
        if value not in {"advertiser", "worker"}:
            raise ValueError("role must be advertiser or worker")
        return value


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str | None = None
    token_type: str = "bearer"


class RefreshRequest(BaseModel):
    refresh_token: str | None = None


class UserResponse(BaseModel):
    id: uuid.UUID
    email: str
    full_name: str
    role: str
    referral_code: str
    kyc_verified: bool
    email_verified: bool = False
    phone_number: str | None = None
    avatar_url: str | None = None
    notification_preferences: dict[str, bool] = Field(default_factory=dict)
    regional_preferences: dict[str, object] = Field(default_factory=dict)
    model_config = {"from_attributes": True}


class AccountSettingsRequest(BaseModel):
    notification_preferences: dict[str, bool] | None = None
    regional_preferences: dict[str, object] | None = None


class AvatarUploadRequest(BaseModel):
    file_extension: str = Field(min_length=3, max_length=5)


class AvatarConfirmRequest(BaseModel):
    file_key: str = Field(min_length=1, max_length=500)


class UpdateProfileRequest(BaseModel):
    full_name: str | None = Field(default=None, min_length=2, max_length=255)
    phone_number: str | None = Field(default=None, max_length=32)

    @field_validator("full_name")
    @classmethod
    def validate_profile_name(cls, value: str | None) -> str | None:
        if value is None:
            raise ValueError("Name cannot be empty")
        value = " ".join(value.split())
        if len(value) < 2:
            raise ValueError("Name must contain at least 2 characters")
        return value

    @field_validator("phone_number")
    @classmethod
    def validate_phone_number(cls, value: str | None) -> str | None:
        if value is None or not value.strip():
            return None
        normalized = re.sub(r"[\s()-]", "", value)
        if not re.fullmatch(r"\+?\d{7,15}", normalized):
            raise ValueError("Enter a valid phone number with 7 to 15 digits")
        return normalized


class ChangePasswordRequest(BaseModel):
    current_password: str
    new_password: str


class ForgotPasswordRequest(BaseModel):
    email: EmailStr


class ResetPasswordRequest(BaseModel):
    token: str
    new_password: str


class SendOTPRequest(BaseModel):
    email: EmailStr


class VerifyOTPRequest(BaseModel):
    email: EmailStr
    code: str