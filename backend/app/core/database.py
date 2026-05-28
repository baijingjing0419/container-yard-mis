"""数据库连接模块 - SQLAlchemy 异步引擎与会话管理"""
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker
from sqlalchemy.orm import DeclarativeBase

from app.core.config import settings

# 创建异步数据库引擎
engine = create_async_engine(
    settings.database_url,
    echo=settings.DEBUG,       # 开发环境打印 SQL 日志
    pool_size=10,              # 连接池大小
    max_overflow=20,           # 超出 pool_size 后最多创建的连接数
    pool_pre_ping=True,        # 每次从池中取连接时先 ping 检测可用性
)

# 创建异步会话工厂
async_session_factory = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,    # 提交后不使对象过期，便于在事务外访问属性
)


# SQLAlchemy 2.0 声明式基类
class Base(DeclarativeBase):
    pass


async def get_db() -> AsyncSession:
    """FastAPI 依赖注入：为每个请求提供一个异步数据库会话"""
    async with async_session_factory() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()
