from pydantic import BaseModel

class RewardProgressResponse(BaseModel):
    grit_level: int
    grit_difficult_tasks_approved: int
    grit_tasks_to_next_level: int
    grit_level10_reached: bool
    grit_level10_pool_claimed: bool
    gratis_level: int
    gratis_unpaid_tasks_approved: int
    gratis_tasks_to_next_level: int
    gratis_level10_reached: bool
    gratis_level10_pool_claimed: bool
