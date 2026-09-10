"""
Storage service — Cloudflare R2 (S3-compatible).

KYC and proof objects are stored privately. Uploads use short-lived presigned
PUT URLs and consumers receive short-lived presigned GET URLs rather than
public object URLs.
"""
import uuid
import io
import functools
import httpx
import imagehash
from PIL import Image
from app.config import settings

ALLOWED_EXTENSIONS = {"jpg", "jpeg", "png", "webp", "pdf", "mp4"}
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
        raise ValueError(f"File type .{ext} not allowed. Allowed: {sorted(ALLOWED_EXTENSIONS)}")
    key = f"{folder}/{uuid.uuid4()}.{ext}"
    url = _s3().generate_presigned_url(
        "put_object",
        Params={"Bucket": settings.S3_BUCKET_NAME, "Key": key},
        ExpiresIn=300,
    )
    return {
        "upload_url": url,
        "file_key": key,
        # Kept for backward compatibility with non-sensitive proof callers.
        # KYC callers deliberately do not return this value.
        "public_url": get_public_url(key),
        "expires_in_seconds": 300,
    }


def generate_presigned_download_url(file_key: str, expires_in: int = 300) -> dict:
    """Create a short-lived private GET URL for an existing object.

    The caller must authorize access before invoking this function. Storage
    itself has no knowledge of application users or roles.
    """
    if not file_key or file_key.startswith("/") or ".." in file_key.split("/") or "\\" in file_key:
        raise ValueError("Invalid storage key")
    if not 1 <= expires_in <= 900:
        raise ValueError("Download URL expiry must be between 1 and 900 seconds")

    url = _s3().generate_presigned_url(
        "get_object",
        Params={"Bucket": settings.S3_BUCKET_NAME, "Key": file_key},
        ExpiresIn=expires_in,
    )
    return {"download_url": url, "expires_in_seconds": expires_in}


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
