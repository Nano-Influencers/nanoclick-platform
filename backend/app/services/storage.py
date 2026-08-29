"""
Storage service — Cloudflare R2 (S3-compatible).
Bug 7 fix: S3 client is lazy-initialised so the module imports cleanly
even when S3 credentials are not yet configured.
"""
import uuid
import io
import functools
import httpx
import imagehash
from PIL import Image
from app.config import settings

ALLOWED_EXTENSIONS = {"jpg", "jpeg", "png", "mp4"}
MAX_FILE_SIZE_BYTES = 50 * 1024 * 1024  # 50 MB


@functools.lru_cache(maxsize=1)
def _s3():
    import boto3
    if not settings.S3_ENDPOINT_URL:
        raise RuntimeError("S3_ENDPOINT_URL is not configured. Set it in .env before using file uploads.")
    return boto3.client(
        "s3",
        endpoint_url=settings.S3_ENDPOINT_URL,
        aws_access_key_id=settings.S3_ACCESS_KEY_ID,
        aws_secret_access_key=settings.S3_SECRET_ACCESS_KEY,
    )


def generate_presigned_upload_url(file_extension: str, folder: str = "proofs") -> dict:
    ext = file_extension.lower().lstrip(".")
    if ext not in ALLOWED_EXTENSIONS:
        raise ValueError(f"File type .{ext} not allowed. Allowed: {ALLOWED_EXTENSIONS}")
    key = f"{folder}/{uuid.uuid4()}.{ext}"
    url = _s3().generate_presigned_url(
        "put_object",
        Params={"Bucket": settings.S3_BUCKET_NAME, "Key": key},
        ExpiresIn=300,
    )
    return {"upload_url": url, "file_key": key,
            "public_url": get_public_url(key), "expires_in_seconds": 300}


def get_public_url(file_key: str) -> str:
    return f"{settings.S3_ENDPOINT_URL}/{settings.S3_BUCKET_NAME}/{file_key}"


async def compute_image_hash(image_url: str) -> str | None:
    if image_url.lower().endswith(".mp4"):
        return None
    try:
        async with httpx.AsyncClient(timeout=10) as client:
            resp = await client.get(image_url)
            resp.raise_for_status()
        img = Image.open(io.BytesIO(resp.content))
        return str(imagehash.phash(img))
    except Exception:
        return None


def hashes_are_duplicate(hash_a: str, hash_b: str, threshold: int = 8) -> bool:
    try:
        return (imagehash.hex_to_hash(hash_a) - imagehash.hex_to_hash(hash_b)) <= threshold
    except Exception:
        return False
