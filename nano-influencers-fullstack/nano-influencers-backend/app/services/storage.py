"""
Private object storage service for Cloudflare R2 (S3-compatible).

Application code deals in opaque storage keys, never arbitrary user-supplied
URLs. Objects are private and are accessed only after the caller has already
authorized the key. Uploaded objects are validated server-side before they can
become proof or identity documents.
"""
import functools
import io
import uuid
from pathlib import PurePosixPath

import imagehash
from PIL import Image

from app.config import settings

ALLOWED_EXTENSIONS = {"jpg", "jpeg", "png", "webp", "pdf", "mp4"}
MAX_FILE_SIZE_BYTES = 50 * 1024 * 1024
CONTENT_TYPES = {
    "jpg": {"image/jpeg"}, "jpeg": {"image/jpeg"}, "png": {"image/png"},
    "webp": {"image/webp"}, "pdf": {"application/pdf"}, "mp4": {"video/mp4"},
}


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


def _validate_key(file_key: str) -> str:
    if not file_key or len(file_key) > 500:
        raise ValueError("Invalid storage key")
    path = PurePosixPath(file_key)
    if path.is_absolute() or ".." in path.parts or "\\" in file_key or "//" in file_key:
        raise ValueError("Invalid storage key")
    ext = path.suffix.lower().lstrip(".")
    if ext not in ALLOWED_EXTENSIONS:
        raise ValueError("Unsupported storage object type")
    return ext


def generate_presigned_upload_url(file_extension: str, folder: str) -> dict:
    """Issue a short-lived private PUT URL under a caller-selected namespace."""
    ext = file_extension.lower().lstrip(".")
    if ext not in ALLOWED_EXTENSIONS:
        raise ValueError(f"File type .{ext} not allowed. Allowed: {sorted(ALLOWED_EXTENSIONS)}")
    if not folder or folder.startswith("/") or ".." in folder.split("/") or "\\" in folder:
        raise ValueError("Invalid upload folder")
    key = f"{folder.rstrip('/')}/{uuid.uuid4()}.{ext}"
    content_type = next(iter(CONTENT_TYPES[ext]))
    url = _s3().generate_presigned_url(
        "put_object",
        Params={
            "Bucket": settings.S3_BUCKET_NAME,
            "Key": key,
            "ContentType": content_type,
        },
        ExpiresIn=300,
    )
    return {
        "upload_url": url,
        "file_key": key,
        "content_type": content_type,
        "expires_in_seconds": 300,
    }


def generate_presigned_download_url(file_key: str, expires_in: int = 300) -> dict:
    """Issue a short-lived signed GET URL for an already-authorized private key."""
    _validate_key(file_key)
    if not 60 <= expires_in <= 900:
        raise ValueError("Download URL expiry must be between 60 and 900 seconds")
    try:
        url = _s3().generate_presigned_url(
            "get_object",
            Params={"Bucket": settings.S3_BUCKET_NAME, "Key": file_key},
            ExpiresIn=expires_in,
        )
    except Exception as exc:
        raise RuntimeError("Unable to create a signed document URL") from exc
    return {"download_url": url, "expires_in_seconds": expires_in}


def store_profile_avatar(file_bytes: bytes, user_id: str, max_bytes: int = 5 * 1024 * 1024) -> str:
    """Validate and store a profile image server-side, avoiding browser bucket CORS."""
    if not file_bytes or len(file_bytes) > max_bytes:
        raise ValueError("Profile photos must be non-empty and 5 MB or smaller")
    try:
        image = Image.open(io.BytesIO(file_bytes))
        image_format = (image.format or "").upper()
        if image.width * image.height > 20_000_000:
            raise ValueError("Profile photo dimensions are too large")
        image.verify()
    except ValueError:
        raise
    except Exception as exc:
        raise ValueError("Choose a valid JPG, PNG, or WebP image") from exc
    extensions = {"JPEG": ("jpg", "image/jpeg"), "PNG": ("png", "image/png"), "WEBP": ("webp", "image/webp")}
    if image_format not in extensions:
        raise ValueError("Profile photos must be JPG, PNG, or WebP images")
    extension, content_type = extensions[image_format]
    key = f"avatars/{user_id}/{uuid.uuid4()}.{extension}"
    _s3().put_object(
        Bucket=settings.S3_BUCKET_NAME,
        Key=key,
        Body=file_bytes,
        ContentType=content_type,
        CacheControl="private, max-age=300",
    )
    return key


def validate_uploaded_image(file_key: str, required_prefix: str, max_bytes: int = 5 * 1024 * 1024) -> dict:
    """Validate an uploaded avatar's ownership, size, metadata and actual image data."""
    details = validate_uploaded_object(file_key, required_prefix)
    if details["extension"] not in {"jpg", "jpeg", "png", "webp"}:
        raise ValueError("Profile photos must be JPG, PNG, or WebP images")
    if details["size"] > max_bytes:
        raise ValueError("Profile photos must be 5 MB or smaller")
    try:
        obj = _s3().get_object(Bucket=settings.S3_BUCKET_NAME, Key=file_key)
        body = obj["Body"].read(max_bytes + 1)
        if len(body) > max_bytes:
            raise ValueError("Profile photos must be 5 MB or smaller")
        image = Image.open(io.BytesIO(body))
        image.verify()
    except ValueError:
        raise
    except Exception as exc:
        raise ValueError("The uploaded file is not a valid image") from exc
    return details


def delete_storage_object(file_key: str) -> None:
    """Delete an object using a validated opaque storage key."""
    _validate_key(file_key)
    _s3().delete_object(Bucket=settings.S3_BUCKET_NAME, Key=file_key)


def validate_uploaded_object(file_key: str, required_prefix: str) -> dict:
    """Verify existence, caller namespace, size and content type server-side."""
    ext = _validate_key(file_key)
    if not required_prefix or not file_key.startswith(required_prefix.rstrip("/") + "/"):
        raise ValueError("Storage object does not belong to this account")
    try:
        metadata = _s3().head_object(Bucket=settings.S3_BUCKET_NAME, Key=file_key)
    except Exception as exc:
        raise ValueError("Uploaded object was not found") from exc
    size = int(metadata.get("ContentLength", -1))
    if size < 1 or size > MAX_FILE_SIZE_BYTES:
        raise ValueError("Uploaded file is empty or exceeds the 50 MB limit")
    content_type = (metadata.get("ContentType") or "").split(";")[0].strip().lower()
    if content_type not in CONTENT_TYPES[ext]:
        raise ValueError("Uploaded file type does not match its extension")
    try:
        sample_obj = _s3().get_object(Bucket=settings.S3_BUCKET_NAME, Key=file_key, Range="bytes=0-15")
        signature = sample_obj["Body"].read(16)
    except Exception as exc:
        raise ValueError("Unable to inspect uploaded file content") from exc
    signatures = {
        "jpg": signature.startswith(b"\xff\xd8\xff"),
        "jpeg": signature.startswith(b"\xff\xd8\xff"),
        "png": signature.startswith(b"\x89PNG\r\n\x1a\n"),
        "webp": len(signature) >= 12 and signature[:4] == b"RIFF" and signature[8:12] == b"WEBP",
        "pdf": signature.startswith(b"%PDF-"),
        "mp4": len(signature) >= 8 and signature[4:8] == b"ftyp",
    }
    if not signatures.get(ext, False):
        raise ValueError("Uploaded file content does not match its declared file type")
    if ext in {"jpg", "jpeg", "png", "webp"}:
        try:
            obj = _s3().get_object(Bucket=settings.S3_BUCKET_NAME, Key=file_key)
            image_bytes = obj["Body"].read(MAX_FILE_SIZE_BYTES + 1)
            if len(image_bytes) > MAX_FILE_SIZE_BYTES:
                raise ValueError("Uploaded image exceeds the maximum file size")
            image = Image.open(io.BytesIO(image_bytes))
            image.verify()
        except ValueError:
            raise
        except Exception as exc:
            raise ValueError("Uploaded image is not a valid image file") from exc
    return {
        "file_key": file_key,
        "size": size,
        "content_type": content_type,
        "extension": ext,
    }


async def compute_image_hash(file_key: str) -> str | None:
    """Hash a private R2 image by key; arbitrary HTTP URLs are never accepted."""
    ext = _validate_key(file_key)
    if ext in {"mp4", "pdf"}:
        return None
    try:
        obj = _s3().get_object(Bucket=settings.S3_BUCKET_NAME, Key=file_key)
        body = obj["Body"].read(MAX_FILE_SIZE_BYTES + 1)
        if len(body) > MAX_FILE_SIZE_BYTES:
            return None
        img = Image.open(io.BytesIO(body))
        img.verify()
        img = Image.open(io.BytesIO(body))
        return str(imagehash.phash(img))
    except Exception:
        return None


def hashes_are_duplicate(hash_a: str, hash_b: str, threshold: int = 8) -> bool:
    try:
        return (imagehash.hex_to_hash(hash_a) - imagehash.hex_to_hash(hash_b)) <= threshold
    except Exception:
        return False
