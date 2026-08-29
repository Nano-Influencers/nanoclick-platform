import uuid
from datetime import datetime
from sqlalchemy import String, Boolean, DateTime, ForeignKey, Integer
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID, ARRAY
from sqlalchemy import String as SAString
from app.database import Base


class User(Base):
    __tablename__ = "users"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False, index=True)
    password_hash: Mapped[str | None] = mapped_column(String(255), nullable=True)  # null for OAuth users
    full_name: Mapped[str] = mapped_column(String(255), nullable=False)
    role: Mapped[str] = mapped_column(String(20), nullable=False)           # advertiser | worker | admin
    referral_code: Mapped[str] = mapped_column(String(20), unique=True, nullable=False, index=True)
    referred_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    kyc_verified: Mapped[bool] = mapped_column(Boolean, default=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    oauth_provider: Mapped[str | None] = mapped_column(String(20), nullable=True)      # google | facebook
    oauth_provider_id: Mapped[str | None] = mapped_column(String(100), nullable=True, index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    wallet: Mapped["Wallet"] = relationship("Wallet", back_populates="user", uselist=False)
    campaigns: Mapped[list["Campaign"]] = relationship("Campaign", back_populates="owner")
    submissions: Mapped[list["Submission"]] = relationship("Submission", back_populates="worker")
    kyc_profile: Mapped["KycProfile"] = relationship("KycProfile", back_populates="user", uselist=False)
    task_acceptances: Mapped[list["TaskAcceptance"]] = relationship("TaskAcceptance", back_populates="worker")


class KycProfile(Base):
    __tablename__ = "kyc_profiles"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), unique=True, nullable=False)

    # Pillar 1: Demographics
    gender: Mapped[str | None] = mapped_column(String(20), nullable=True)
    age_bracket: Mapped[str | None] = mapped_column(String(20), nullable=True)
    marital_status: Mapped[str | None] = mapped_column(String(20), nullable=True)

    # Pillar 2: Social / Cultural
    religion: Mapped[str | None] = mapped_column(String(50), nullable=True)
    ethnicity_tribe: Mapped[str | None] = mapped_column(String(100), nullable=True)
    race: Mapped[str | None] = mapped_column(String(50), nullable=True)
    languages_spoken: Mapped[list[str]] = mapped_column(ARRAY(SAString), default=list)

    # Pillar 3: Geographic
    primary_city: Mapped[str | None] = mapped_column(String(100), nullable=True)
    primary_state: Mapped[str | None] = mapped_column(String(100), nullable=True)
    primary_country: Mapped[str | None] = mapped_column(String(100), nullable=True, default="Nigeria")
    secondary_locations: Mapped[list[str]] = mapped_column(ARRAY(SAString), default=list)
    occupation_location: Mapped[str | None] = mapped_column(String(100), nullable=True)
    state_of_origin: Mapped[str | None] = mapped_column(String(100), nullable=True)
    town_of_origin: Mapped[str | None] = mapped_column(String(100), nullable=True)

    # Pillar 4: Economic
    monthly_income_range: Mapped[str | None] = mapped_column(String(50), nullable=True)
    primary_income_source: Mapped[str | None] = mapped_column(String(100), nullable=True)
    secondary_income_source: Mapped[str | None] = mapped_column(String(100), nullable=True)

    # Pillar 5: Occupation
    occupation_industry: Mapped[str | None] = mapped_column(String(100), nullable=True)
    is_self_employed: Mapped[bool] = mapped_column(Boolean, default=False)
    self_employed_industry: Mapped[str | None] = mapped_column(String(100), nullable=True)
    skills: Mapped[list[str]] = mapped_column(ARRAY(SAString), default=list)
    school_name: Mapped[str | None] = mapped_column(String(200), nullable=True)
    department_of_study: Mapped[str | None] = mapped_column(String(100), nullable=True)
    study_location: Mapped[str | None] = mapped_column(String(100), nullable=True)
    trade_school_niche: Mapped[str | None] = mapped_column(String(100), nullable=True)

    # Pillar 6: Interests
    interests_hobbies: Mapped[list[str]] = mapped_column(ARRAY(SAString), default=list)
    music_genres: Mapped[list[str]] = mapped_column(ARRAY(SAString), default=list)

    # Pillar 7: Behavior
    content_niches_posted: Mapped[list[str]] = mapped_column(ARRAY(SAString), default=list)
    content_types_interacted: Mapped[list[str]] = mapped_column(ARRAY(SAString), default=list)
    account_types_followed: Mapped[list[str]] = mapped_column(ARRAY(SAString), default=list)

    # Reach metrics
    follower_count: Mapped[int] = mapped_column(Integer, default=0)
    following_count: Mapped[int] = mapped_column(Integer, default=0)
    avg_story_views: Mapped[int] = mapped_column(Integer, default=0)
    avg_engagement_rate: Mapped[float | None] = mapped_column(nullable=True)
    posting_frequency: Mapped[str | None] = mapped_column(String(50), nullable=True)
    majority_follower_location: Mapped[str | None] = mapped_column(String(100), nullable=True)
    follower_categories: Mapped[list[str]] = mapped_column(ARRAY(SAString), default=list)
    follower_industries: Mapped[list[str]] = mapped_column(ARRAY(SAString), default=list)
    follower_care_about: Mapped[list[str]] = mapped_column(ARRAY(SAString), default=list)

    # Authority & Trust
    account_age_years: Mapped[float | None] = mapped_column(nullable=True)
    is_verified_on_platform: Mapped[bool] = mapped_column(Boolean, default=False)
    uses_real_name: Mapped[bool] = mapped_column(Boolean, default=False)
    uses_real_photo: Mapped[bool] = mapped_column(Boolean, default=False)

    # Community / Group access (for Gender + Marital Status Tier-2 targeting)
    group_types: Mapped[list[str]] = mapped_column(ARRAY(SAString), default=list)
    group_industries: Mapped[list[str]] = mapped_column(ARRAY(SAString), default=list)
    group_descriptions: Mapped[list[str]] = mapped_column(ARRAY(SAString), default=list)
    gender_group_membership: Mapped[str | None] = mapped_column(String(30), nullable=True)  # male_group | female_group | mixed
    marital_group_keywords: Mapped[list[str]] = mapped_column(ARRAY(SAString), default=list)

    # Social handles
    instagram_handle: Mapped[str | None] = mapped_column(String(100), nullable=True)
    tiktok_handle: Mapped[str | None] = mapped_column(String(100), nullable=True)
    twitter_handle: Mapped[str | None] = mapped_column(String(100), nullable=True)
    facebook_handle: Mapped[str | None] = mapped_column(String(100), nullable=True)
    youtube_handle: Mapped[str | None] = mapped_column(String(100), nullable=True)
    whatsapp_number: Mapped[str | None] = mapped_column(String(20), nullable=True)

    # Identity documents
    document_type: Mapped[str | None] = mapped_column(String(30), nullable=True)   # NIN | BVN | drivers_license
    document_url: Mapped[str | None] = mapped_column(String(500), nullable=True)

    # status: pending | approved | rejected
    status: Mapped[str] = mapped_column(String(20), default="pending", nullable=False)
    submitted_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    reviewed_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)

    user: Mapped["User"] = relationship("User", back_populates="kyc_profile")
