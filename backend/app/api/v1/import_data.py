"""CSV 数据导入 API"""
import csv
import io
from typing import Any

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.exc import IntegrityError

from app.core.database import get_db
from app.models.users import User
from app.models.ships import Ship
from app.models.containers_master import ContainerMaster
from app.api.deps import RoleChecker

router = APIRouter(prefix="/import", tags=["数据导入"])

# 三张表的字段名 → 中文表头映射
TABLE_COLUMNS: dict[str, dict[str, str]] = {
    "users": {
        "user_id": "工号",
        "username": "用户名",
        "real_name": "姓名",
        "role": "角色",
        "department": "部门",
        "phone": "电话",
        "email": "邮箱",
        "status": "状态",
    },
    "ships": {
        "ship_id": "船舶编号",
        "ship_name": "船舶名称",
        "ship_type": "船舶类型",
        "ship_company": "船公司",
        "ship_length": "船长(米)",
        "ship_capacity": "载箱量(TEU)",
        "status": "状态",
    },
    "containers_master": {
        "container_id": "箱号",
        "container_type": "箱型",
        "tare_weight": "皮重(kg)",
        "owner_company": "所属公司",
        "size_code": "尺寸代码",
        "manufacture_date": "制造日期",
    },
}

MODEL_MAP: dict[str, type] = {
    "users": User,
    "ships": Ship,
    "containers_master": ContainerMaster,
}

# 中文表头 → 数据库字段名 的反向映射
HEADER_TO_COL: dict[str, dict[str, str]] = {
    table: {cn: col for col, cn in cols.items()}
    for table, cols in TABLE_COLUMNS.items()
}


@router.get("/templates/{table}", summary="下载 CSV 模板")
async def download_template(table: str):
    """返回带中文表头的空 CSV 模板"""
    if table not in TABLE_COLUMNS:
        raise HTTPException(status_code=404, detail=f"不支持的表: {table}")

    cols = TABLE_COLUMNS[table]
    headers = list(cols.values())

    from fastapi.responses import PlainTextResponse
    return PlainTextResponse(
        content=",".join(headers) + "\n",
        media_type="text/csv",
        headers={"Content-Disposition": f"attachment; filename={table}_template.csv"},
    )


@router.post("/csv", summary="上传 CSV 导入数据")
async def upload_csv(
    file: UploadFile = File(...),
    table: str = Form(...),
    db: AsyncSession = Depends(get_db),
    _current_user = Depends(RoleChecker(["admin"])),
):
    """上传 CSV 文件，解析后批量导入指定表"""
    if table not in TABLE_COLUMNS:
        raise HTTPException(status_code=400, detail=f"不支持的表: {table}")

    if not file.filename or not file.filename.endswith(".csv"):
        raise HTTPException(status_code=400, detail="仅支持 .csv 文件")

    content = await file.read()
    try:
        text = content.decode("utf-8-sig")
    except UnicodeDecodeError:
        raise HTTPException(status_code=400, detail="文件编码错误，请使用 UTF-8")

    reader = csv.DictReader(io.StringIO(text))
    if not reader.fieldnames:
        raise HTTPException(status_code=400, detail="CSV 文件为空")

    header_map = HEADER_TO_COL[table]
    model_cls: Any = MODEL_MAP[table]
    imported = 0
    errors: list[dict[str, Any]] = []

    for row_num, row in enumerate(reader, start=2):  # row 2 = 第一行数据
        try:
            record: dict[str, Any] = {}
            for cn_header, db_col in header_map.items():
                value = row.get(cn_header, "").strip()
                if value == "":
                    value = None
                elif db_col in ("ship_length", "ship_capacity", "tare_weight"):
                    if value is not None:
                        try:
                            value = float(value) if db_col in ("ship_length", "tare_weight") else int(value)
                        except ValueError:
                            errors.append({"row": row_num, "reason": f"{cn_header} 格式错误"})
                            break
                elif db_col == "manufacture_date" and value:
                    from datetime import date
                    try:
                        value = date.fromisoformat(value)
                    except ValueError:
                        errors.append({"row": row_num, "reason": f"{cn_header} 日期格式错误(应为 YYYY-MM-DD)"})
                        break
                record[db_col] = value
            else:
                instance = model_cls(**record)
                db.add(instance)
                imported += 1
        except IntegrityError:
            await db.rollback()
            errors.append({"row": row_num, "reason": "数据重复或违反唯一性约束"})

    await db.flush()
    return {"imported": imported, "errors": errors, "total": imported + len(errors)}
