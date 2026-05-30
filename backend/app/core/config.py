"""应用配置模块 - 通过 .env 环境变量管理所有配置项"""
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # 数据库配置
    DB_HOST: str = "localhost"
    DB_PORT: int = 3306
    DB_USER: str = "root"
    DB_PASSWORD: str = ""
    DB_NAME: str = "ContainerTerminalDB"

    # 服务配置
    APP_HOST: str = "0.0.0.0"
    APP_PORT: int = 8000
    DEBUG: bool = True
    CORS_ORIGINS: str = "http://localhost:5173"

    # JWT 认证配置
    SECRET_KEY: str = "change-me-in-production-use-a-real-random-string"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 480  # 8 小时

    @property
    def database_url(self) -> str:
        """构建异步MySQL连接URL，使用 aiomysql 驱动（纯Python，无需C编译）"""
        return (
            f"mysql+aiomysql://{self.DB_USER}:{self.DB_PASSWORD}"
            f"@{self.DB_HOST}:{self.DB_PORT}/{self.DB_NAME}"
            f"?charset=utf8mb4"
        )

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


settings = Settings()
