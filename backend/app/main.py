"""FastAPI 应用入口 - 集装箱码头堆场管理MIS系统后端服务"""
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import select

from app.core.config import settings
from app.core.database import async_session_factory
from app.core.security import hash_password
from app.models.users import User
from app.api.v1.router import api_router

# 五个内置用户
_SEED_USERS = [
    {"user_id": "1", "username": "张瀚", "real_name": "张瀚", "role": "admin",      "department": "信息中心"},
    {"user_id": "2", "username": "李策", "real_name": "李策", "role": "dispatcher", "department": "调度中心"},
    {"user_id": "3", "username": "王卫", "real_name": "王卫", "role": "gate_clerk",  "department": "闸口管理"},
    {"user_id": "4", "username": "赵起", "real_name": "赵起", "role": "qc_op",      "department": "岸桥班组"},
    {"user_id": "5", "username": "陈桥", "real_name": "陈桥", "role": "yc_op",      "department": "场桥班组"},
]


async def _seed_users():
    """启动时确保五个内置用户存在（upsert）"""
    async with async_session_factory() as session:
        for u in _SEED_USERS:
            await session.merge(User(
                user_id=u["user_id"],
                username=u["username"],
                real_name=u["real_name"],
                role=u["role"],
                department=u["department"],
                password_hash=hash_password("123"),
                status="active",
            ))
        await session.commit()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """应用生命周期管理：启动时初始化数据，关闭时清理资源"""
    print(f"[启动] 数据库: {settings.DB_HOST}:{settings.DB_PORT}/{settings.DB_NAME}")
    try:
        await _seed_users()
        print("[启动] 用户数据已就绪")
    except Exception as e:
        print(f"[启动] 用户初始化失败（数据库可能尚未就绪）: {e}")
    print(f"[启动] API文档: http://{settings.APP_HOST}:{settings.APP_PORT}/docs")
    yield
    print("[关闭] 服务已停止")


app = FastAPI(
    title="集装箱码头堆场管理MIS系统",
    description="Container Terminal Yard Management Information System API",
    version="0.1.0",
    lifespan=lifespan,
)

# 跨域配置 - 开发环境允许配置中指定的来源，生产环境通过反向代理同源部署
ALLOWED_ORIGINS = settings.CORS_ORIGINS.split(",") if settings.CORS_ORIGINS else []
if ALLOWED_ORIGINS:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=ALLOWED_ORIGINS,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

# 注册 API 路由
app.include_router(api_router)


@app.get("/", tags=["系统"])
async def root():
    """根路径 - 返回系统基本信息"""
    return {
        "name": "集装箱码头堆场管理MIS系统",
        "version": "0.1.0",
        "docs": "/docs",
    }


@app.get("/health", tags=["系统"])
async def health_check():
    """健康检查端点"""
    return {"status": "ok"}
