"""FastAPI 应用入口 - 集装箱码头堆场管理MIS系统后端服务"""
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.api.v1.router import api_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    """应用生命周期管理：启动时打印配置信息，关闭时清理资源"""
    print(f"[启动] 数据库: {settings.DB_HOST}:{settings.DB_PORT}/{settings.DB_NAME}")
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
