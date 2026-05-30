"""安全工具 — 密码哈希 / 验证（PBKDF2-HMAC-SHA256）"""
import hashlib
import secrets


def hash_password(password: str) -> str:
    """对明文密码生成 PBKDF2 哈希，格式：pbkdf2:sha256:100000$<salt>$<hash>"""
    salt = secrets.token_hex(16)
    h = hashlib.pbkdf2_hmac("sha256", password.encode(), salt.encode(), 100000)
    return f"pbkdf2:sha256:100000${salt}${h.hex()}"


def verify_password(password: str, stored_hash: str) -> bool:
    """校验密码是否匹配存储的 PBKDF2 哈希"""
    try:
        _, salt, h = stored_hash.split("$")
    except ValueError:
        return False
    new_h = hashlib.pbkdf2_hmac("sha256", password.encode(), salt.encode(), 100000)
    return secrets.compare_digest(new_h.hex(), h)
