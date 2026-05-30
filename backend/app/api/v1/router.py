"""API v1 路由聚合 - 全部 17 个子模块"""
from fastapi import APIRouter
from app.api.v1.ships import router as ships_router
from app.api.v1.yard_zones import router as yard_zones_router
from app.api.v1.yard_slots import router as yard_slots_router
from app.api.v1.sea_inbound_containers import router as sea_inbound_router
from app.api.v1.sea_outbound_containers import router as sea_outbound_router
from app.api.v1.sea_terminal_io import router as terminal_io_router
from app.api.v1.land_inbound_containers import router as land_inbound_router
from app.api.v1.land_outbound_containers import router as land_outbound_router
from app.api.v1.gate_io_records import router as gate_router
from app.api.v1.yard_container_inventory import router as inventory_router
from app.api.v1.yard_operation_records import router as operations_router
from app.api.v1.dispatch_orders import router as dispatch_router
from app.api.v1.sea_operation_plans import router as sea_plans_router
from app.api.v1.land_operation_plans import router as land_plans_router
from app.api.v1.users import router as users_router
from app.api.v1.system_logs import router as logs_router
from app.api.v1.alerts import router as alerts_router
from app.api.v1.containers import router as containers_router
from app.api.v1.auth import router as auth_router
from app.api.v1.system import router as system_router
from app.api.v1.import_data import router as import_router

api_router = APIRouter(prefix="/api/v1")
api_router.include_router(system_router)
api_router.include_router(import_router)
api_router.include_router(ships_router)
api_router.include_router(yard_zones_router)
api_router.include_router(yard_slots_router)
api_router.include_router(sea_inbound_router)
api_router.include_router(sea_outbound_router)
api_router.include_router(terminal_io_router)
api_router.include_router(land_inbound_router)
api_router.include_router(land_outbound_router)
api_router.include_router(gate_router)
api_router.include_router(inventory_router)
api_router.include_router(operations_router)
api_router.include_router(dispatch_router)
api_router.include_router(sea_plans_router)
api_router.include_router(land_plans_router)
api_router.include_router(users_router)
api_router.include_router(logs_router)
api_router.include_router(alerts_router)
api_router.include_router(containers_router)
api_router.include_router(auth_router)
