"""
乐观锁并发压测脚本

模拟 10 个操作员同时将 10 个不同集装箱落到同一目标箱位。
期望结果: 1 个 HTTP 200, 9 个 HTTP 409 (版本冲突)。

依赖: pip install httpx
运行: python test_optimistic_lock.py
"""

import asyncio
import httpx
import time

BASE_URL = "http://localhost:8000"
API_PREFIX = "/api/v1"

# 同一个目标空箱位（确保为 empty 状态）
TARGET_SLOT = "A-01-01"

# 10 个不同的测试集装箱
TEST_CONTAINERS = [f"MSKU000000{i}" for i in range(1, 11)]
# MSKU0000001 ~ MSKU0000010


async def setup_container_master(client: httpx.AsyncClient, container_id: str):
    """确保 containers_master 中存在该箱号"""
    resp = await client.get(f"{API_PREFIX}/containers/{container_id}")
    if resp.status_code == 404:
        await client.post(f"{API_PREFIX}/containers", json={
            "container_id": container_id,
            "container_type": "40HQ",
            "owner_company": "TEST"
        })


async def create_operation(client: httpx.AsyncClient, idx: int) -> str:
    """为每个集装箱创建一条 pending 状态的调箱作业"""
    container_id = TEST_CONTAINERS[idx]
    record_id = f"LOCK-TEST-{idx:03d}"

    original_slot = f"A-01-{idx + 2:02d}"  # 不同的原位置

    # 确保原位置箱位存在（如已存在则跳过）
    slot_check = await client.get(f"{API_PREFIX}/yard-slots/{original_slot}")
    if slot_check.status_code == 404:
        await client.post(f"{API_PREFIX}/yard-slots", json={
            "slot_id": original_slot,
            "zone_id": "A",
            "row_num": 1,
            "col_num": idx + 2,
            "tier_num": 1,
            "slot_status": "empty",
            "max_weight": 30.0,
            "slot_size": "40HQ",
        })

    # 使用唯一 ID 避免重复
    record_id = f"LOCK-TEST-{idx:03d}-{int(time.time() * 1000000) % 1000000}"

    # 创建作业
    resp = await client.post(f"{API_PREFIX}/yard-operations", json={
        "record_id": record_id,
        "operation_type": "shift",
        "container_id": container_id,
        "original_slot_id": original_slot,
        "target_slot_id": TARGET_SLOT,
        "equipment_id": f"YC-{idx + 1:02d}",
        "operator_name": f"操作员{idx + 1:02d}",
        "operation_status": "pending",
        "start_time": "2026-05-30T12:00:00",
    })
    if resp.status_code not in (200, 201):
        print(f"  [WARN] 创建作业失败 {record_id}: {resp.status_code} {resp.text[:100]}")
        record_id = f"LOCK-TEST-{idx:03d}-{int(time.time() * 1000) % 1000000}"
        resp2 = await client.post(f"{API_PREFIX}/yard-operations", json={
            "record_id": record_id,
            "operation_type": "shift",
            "container_id": container_id,
            "original_slot_id": original_slot,
            "target_slot_id": TARGET_SLOT,
            "equipment_id": f"YC-{idx + 1:02d}",
            "operator_name": f"操作员{idx + 1:02d}",
            "operation_status": "pending",
            "start_time": "2026-05-30T12:00:00",
        })
        if resp2.status_code not in (200, 201):
            print(f"  [FAIL] 创建作业最终失败: {resp2.status_code}")

    return record_id


async def reset_target_slot(client: httpx.AsyncClient):
    """将目标箱位重置为 empty 状态，version 归 0"""
    resp = await client.get(f"{API_PREFIX}/yard-slots/{TARGET_SLOT}")
    if resp.status_code == 404:
        await client.post(f"{API_PREFIX}/yard-slots", json={
            "slot_id": TARGET_SLOT,
            "zone_id": "A",
            "row_num": 1,
            "col_num": 1,
            "tier_num": 1,
            "slot_status": "empty",
            "max_weight": 30.0,
            "slot_size": "40HQ",
        })
    else:
        # 直接 SQL 重置（通过后端 API 无法清零 version）—— 用 yard-slots PUT
        await client.put(f"{API_PREFIX}/yard-slots/{TARGET_SLOT}", json={
            "slot_status": "empty",
            "current_container_id": None,
        })


async def attempt_complete(client: httpx.AsyncClient, record_id: str, worker_id: int) -> dict:
    """单个 worker 尝试完成作业——触发乐观锁检查"""
    start = time.perf_counter()
    try:
        resp = await client.put(
            f"{API_PREFIX}/yard-operations/{record_id}/status",
            json={"operation_status": "completed"},
            timeout=10.0,
        )
        elapsed = time.perf_counter() - start
        return {
            "worker": worker_id,
            "record_id": record_id,
            "status": resp.status_code,
            "elapsed": round(elapsed, 4),
            "body": resp.text[:150],
        }
    except Exception as e:
        elapsed = time.perf_counter() - start
        return {
            "worker": worker_id,
            "record_id": record_id,
            "status": -1,
            "elapsed": round(elapsed, 4),
            "body": str(e)[:150],
        }


async def main():
    print("=" * 60)
    print("  乐观锁并发压测 — 10 操作员抢占同一箱位")
    print(f"  目标箱位: {TARGET_SLOT}")
    print("=" * 60)

    limits = httpx.Limits(max_connections=50, max_keepalive_connections=20)
    async with httpx.AsyncClient(base_url=BASE_URL, limits=limits) as client:
        # Phase 0: 健康检查
        print("\n[0] 健康检查...")
        r = await client.get("/health")
        print(f"    后端状态: {r.status_code}")

        # Phase 1: 确保 containers_master 中有 10 个测试箱
        print("\n[1] 创建集装箱主数据...")
        for c in TEST_CONTAINERS:
            await setup_container_master(client, c)
        print(f"    完成 ({len(TEST_CONTAINERS)} 个箱)")

        # Phase 2: 重置目标箱位为 empty
        print("\n[2] 重置目标箱位...")
        await reset_target_slot(client)
        print(f"    {TARGET_SLOT} 已重置为 empty")

        # Phase 3: 创建 10 条 pending 作业
        print("\n[3] 创建 10 条调箱作业 (同时指向目标位)...")
        record_ids = []
        for i in range(10):
            rid = await create_operation(client, i)
            record_ids.append(rid)
        print(f"    完成: {record_ids}")

        # Phase 4: 并发执行——10 个协程同时完成作业
        print("\n[4] 并发抢占目标箱位...")
        print(f"    启动 10 个并发 worker, 目标: {TARGET_SLOT}")
        tasks = [
            attempt_complete(client, record_ids[i], i + 1)
            for i in range(10)
        ]
        results = await asyncio.gather(*tasks)

        # Phase 5: 统计结果
        print("\n" + "=" * 60)
        print("  测试结果")
        print("=" * 60)

        success_count = 0
        conflict_count = 0
        other_count = 0

        for r in sorted(results, key=lambda x: x["worker"]):
            tag = "OK" if r["status"] in (200, 201) else "CONFLICT" if r["status"] == 409 else f"ERR({r['status']})"
            if r["status"] in (200, 201):
                success_count += 1
            elif r["status"] == 409:
                conflict_count += 1
            else:
                other_count += 1
            print(f"  Worker {r['worker']:02d} | {tag:10s} | {r['elapsed']:8.4f}s | {r['record_id']}")

        print(f"\n{'─' * 60}")
        print(f"  成功 (200/201):  {success_count} / 10  (期望 ~1)")
        print(f"  冲突 (409):     {conflict_count} / 10  (期望 ~9)")
        print(f"  其他:            {other_count} / 10")
        print(f"{'─' * 60}")

        # Phase 6: 验证最终状态
        print("\n[5] 验证最终箱位状态...")
        r = await client.get(f"{API_PREFIX}/yard-slots/{TARGET_SLOT}")
        slot = r.json()
        print(f"    {TARGET_SLOT}: status={slot.get('slot_status')}, "
              f"container={slot.get('current_container_id')}, "
              f"version={slot.get('version')}")

        # 检查 move_logs
        r2 = await client.get(f"{API_PREFIX}/containers/{slot.get('current_container_id', '')}/move-logs")
        if r2.status_code == 200:
            logs = r2.json()
            print(f"    move_logs: {logs.get('total', 0)} 条记录")

        result = "PASS" if success_count >= 1 and conflict_count >= 8 else "PARTIAL"
        print(f"\n  >>> 结论: {result} (成功={success_count}, 冲突={conflict_count})")
        print("=" * 60)


if __name__ == "__main__":
    asyncio.run(main())
