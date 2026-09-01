from pydantic import BaseModel, Field


class KycSubmitRequest(BaseModel):
    """Mirrors app.models.user.KycProfile's optional fields. Replaces the
    previous raw `dict` body, which had zero validation and filtered
    incoming keys with `hasattr(KycProfile, k)` — a fragile check that
    happily matches inherited SQLAlchemy internals (e.g. 'metadata') as
    well as real columns, and enforced no types, lengths, or allowed
    values at all. Every field mirrors an existing column 1:1; none of
    this changes the data model."""

    # Pillar 1: Demographics
    gender: str | None = None
    age_bracket: str | None = None
    marital_status: str | None = None

    # Pillar 2: Social / Cultural
    religion: str | None = None
    ethnicity_tribe: str | None = None
    race: str | None = None
    languages_spoken: list[str] = Field(default_factory=list)

    # Pillar 3: Geographic
    primary_city: str | None = None
    primary_state: str | None = None
    primary_country: str | None = "Nigeria"
    secondary_locations: list[str] = Field(default_factory=list)
    occupation_location: str | None = None
    state_of_origin: str | None = None
    town_of_origin: str | None = None

    # Pillar 4: Economic
    monthly_income_range: str | None = None
    primary_income_source: str | None = None
    secondary_income_source: str | None = None

    # Pillar 5: Occupation
    occupation_industry: str | None = None
    is_self_employed: bool = False
    self_employed_industry: str | None = None
    skills: list[str] = Field(default_factory=list)
    school_name: str | None = None
    department_of_study: str | None = None
    study_location: str | None = None
    trade_school_niche: str | None = None

    # Pillar 6: Interests
    interests_hobbies: list[str] = Field(default_factory=list)
    music_genres: list[str] = Field(default_factory=list)

    # Pillar 7: Behavior
    content_niches_posted: list[str] = Field(default_factory=list)
    content_types_interacted: list[str] = Field(default_factory=list)
    account_types_followed: list[str] = Field(default_factory=list)

    # Reach metrics
    follower_count: int = Field(0, ge=0)
    following_count: int = Field(0, ge=0)
    avg_story_views: int = Field(0, ge=0)
    avg_engagement_rate: float | None = Field(None, ge=0, le=100)
    posting_frequency: str | None = None
    majority_follower_location: str | None = None
    follower_categories: list[str] = Field(default_factory=list)
    follower_industries: list[str] = Field(default_factory=list)
    follower_care_about: list[str] = Field(default_factory=list)

    # Authority & Trust
    account_age_years: float | None = Field(None, ge=0)
    is_verified_on_platform: bool = False
    uses_real_name: bool = False
    uses_real_photo: bool = False

    # Community / Group access
    group_types: list[str] = Field(default_factory=list)
    group_industries: list[str] = Field(default_factory=list)
    group_descriptions: list[str] = Field(default_factory=list)
    gender_group_membership: str | None = None
    marital_group_keywords: list[str] = Field(default_factory=list)

    # Social handles
    instagram_handle: str | None = None
    tiktok_handle: str | None = None
    twitter_handle: str | None = None
    facebook_handle: str | None = None
    youtube_handle: str | None = None
    whatsapp_number: str | None = None

    # Identity documents
    document_type: str | None = None
    document_url: str | None = None


class KycStatusResponse(BaseModel):
    status: str  # not_submitted | pending | approved | rejected
