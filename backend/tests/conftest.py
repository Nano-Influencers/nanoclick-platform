import os

import pytest_asyncio
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker

os.environ.setdefault(
    "DATABASE_URL",
    "postgresql+asyncpg://ci:ci@localhost:5432/nanoclick",
)
os.environ.setdefault("SECRET_KEY", "test-secret-key-at-least-32-characters-long")

from app.database import Base
from app.models import *  # noqa: F401,F403


@pytest_asyncio.fixture
async def test_engine():
    from app.database import engine

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield engine
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
    await engine.dispose()


@pytest_asyncio.fixture
async def db(test_engine):
    maker = async_sessionmaker(test_engine, class_=AsyncSession, expire_on_commit=False)
    async with maker() as session:
        yield session
        await session.rollback()


@pytest_asyncio.fixture
async def db_factory(test_engine):
    yield async_sessionmaker(test_engine, class_=AsyncSession, expire_on_commit=False)
