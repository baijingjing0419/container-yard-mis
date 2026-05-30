-- ========================================================
-- V2 架构专属测试数据脚本
-- 适配 containers_master + container_move_logs + 乐观锁 version
-- 可重复执行（使用 SET FOREIGN_KEY_CHECKS + REPLACE INTO）
-- ========================================================
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ========================================================
-- 1. 基础支撑数据
-- ========================================================
REPLACE INTO ships (ship_id, ship_name, ship_type, ship_company, ship_length, ship_capacity, status) VALUES
('COSCO-2405', '中远海运白羊座', '集装箱船', '中远海运', 399.99, 20000, 'active'),
('EVER-1803', '长荣海运', '集装箱船', '长荣海运', 368.00, 15000, 'active'),
('MAERSK-8821', '马士基浩南', '集装箱船', '马士基', 399.00, 18000, 'active'),
('MSC-0921', '地中海航运', '集装箱船', 'MSC', 350.00, 14000, 'active');

REPLACE INTO yard_zones (zone_id, zone_name, zone_type, total_slots, occupied_slots, max_tier, status) VALUES
('A', 'A区-进口箱区', 'import', 576, 0, 5, 'active'),
('B', 'B区-出口箱区', 'export', 576, 0, 5, 'active'),
('C', 'C区-中转箱区', 'transfer', 576, 0, 5, 'active');

-- 预置足够箱位用于测试（包括目标位 A-01-01）
REPLACE INTO yard_slots (slot_id, zone_id, row_num, col_num, tier_num, slot_status, current_container_id, max_weight, slot_size, version) VALUES
('A-01-01', 'A', 1, 1, 1, 'empty', NULL, 30.0, '40GP', 0),
('A-01-02', 'A', 1, 2, 1, 'empty', NULL, 30.0, '40GP', 0),
('A-01-03', 'A', 1, 3, 1, 'empty', NULL, 30.0, '40GP', 0),
('A-01-04', 'A', 1, 4, 1, 'empty', NULL, 30.0, '40GP', 0),
('A-02-01', 'A', 2, 1, 1, 'empty', NULL, 30.0, '40GP', 0),
('A-02-02', 'A', 2, 2, 1, 'empty', NULL, 30.0, '40GP', 0),
('B-01-01', 'B', 1, 1, 1, 'empty', NULL, 30.0, '40GP', 0),
('B-01-02', 'B', 1, 2, 1, 'empty', NULL, 30.0, '40GP', 0),
('B-01-03', 'B', 1, 3, 1, 'empty', NULL, 30.0, '40GP', 0),
('B-01-04', 'B', 1, 4, 1, 'empty', NULL, 30.0, '40GP', 0),
('B-02-01', 'B', 2, 1, 1, 'empty', NULL, 30.0, '40GP', 0),
('B-02-02', 'B', 2, 2, 1, 'empty', NULL, 30.0, '40GP', 0),
('A-10-05', 'A', 10, 5, 1, 'empty', NULL, 30.0, '40GP', 0),
('A-15-06', 'A', 15, 6, 1, 'empty', NULL, 30.0, '40GP', 0),
('B-10-01', 'B', 10, 1, 1, 'empty', NULL, 30.0, '40GP', 0),
('B-10-05', 'B', 10, 5, 1, 'empty', NULL, 30.0, '40GP', 0);

-- ========================================================
-- 2. containers_master 主数据（V2 核心：必须先于业务表插入）
-- ========================================================
REPLACE INTO containers_master (container_id, container_type, tare_weight, owner_company, size_code) VALUES
('MSKU7892345', '40HQ', 3850.00, 'COSCO', '45G1'),
('TEST-8888999', '40HQ', 3920.00, 'MAERSK', '45G1'),
('TEST-FORM001', '20GP', 2250.00, 'MSC', '22G1'),
('MSKU0000001', '40GP', 3780.00, 'COSCO', '42G1'),
('MSKU0000002', '40HQ', 3900.00, 'COSCO', '45G1'),
('MSKU0000003', '20GP', 2210.00, 'EVERGREEN', '22G1'),
('MSKU0000004', '40HQ', 3950.00, 'MAERSK', '45G1'),
('MSKU0000005', '40GP', 3760.00, 'MAERSK', '42G1'),
('MSKU0000006', '20GP', 2280.00, 'MSC', '22G1'),
('MSKU0000007', '40HQ', 3880.00, 'EVERGREEN', '45G1'),
('MSKU0000008', '40GP', 3810.00, 'MSC', '42G1'),
('MSKU0000009', '20GP', 2240.00, 'COSCO', '22G1'),
('MSKU0000010', '40HQ', 3910.00, 'MAERSK', '45G1'),
('MSKU0000011', '40GP', 3790.00, 'EVERGREEN', '42G1'),
('MSKU0000012', '20GP', 2220.00, 'MSC', '22G1');

-- ========================================================
-- 3. 业务表数据（不再含 container_type）
-- ========================================================

-- 3a. 海侧进箱 (D1) — 只有业务流程字段
REPLACE INTO sea_inbound_containers (container_id, container_status, ship_id, voyage_no, manifest_info, damage_status, target_slot_id, actual_slot_id, operation_id, plan_id, discharge_crane, transfer_truck, yard_crane, process_status) VALUES
('MSKU7892345', 'intact', 'COSCO-2405', 'V2405', 'BL-COSCO-20260528-001', '完好', 'A-15-06', 'A-15-06', NULL, 'SP-20260528-TEST01', 'QC-01', 'IT-01', 'YC-03', 'landed'),
('TEST-8888999', 'intact', 'COSCO-2405', 'V2405', 'BL-COSCO-20260528-002', '完好', 'B-10-05', 'B-10-05', NULL, 'SP-20260528-TEST01', 'QC-02', 'IT-02', 'YC-02', 'landed'),
('TEST-FORM001', 'intact', 'COSCO-2405', 'V2405', 'BL-COSCO-20260528-003', '完好', 'A-12-04', NULL, NULL, 'SP-20260528-TEST01', 'QC-03', 'IT-03', 'YC-01', 'transiting');

-- 3b. 陆侧进箱 (D4)
REPLACE INTO land_inbound_containers (container_id, container_status, truck_plate, driver_name, document_no, ship_id, target_slot_id, actual_slot_id, damage_check, process_status) VALUES
('MSKU0000011', 'intact', 'HUA B8821', 'Zhang Wei', 'DOC001', 'COSCO-2405', 'B-02-01', 'B-02-01', '完好', 'landed'),
('MSKU0000012', 'intact', 'HUA C1234', 'Li Ming', 'DOC002', 'EVER-1803', 'B-02-02', 'B-02-02', '完好', 'landed');

-- 3c. 海侧出场 (D2)
REPLACE INTO sea_outbound_containers (container_id, container_status, ship_id, voyage_no, stowage_position, original_slot_id, process_status) VALUES
('MSKU0000001', 'loaded', 'MAERSK-8821', 'V8821', 'BAY-12', 'B-01-01', 'loaded'),
('MSKU0000002', 'loaded', 'MAERSK-8821', 'V8821', 'BAY-13', 'B-01-02', 'loaded');

-- 3d. 陆侧出场 (D5)
REPLACE INTO land_outbound_containers (container_id, container_status, truck_plate, driver_name, pickup_document_no, ship_id, original_slot_id, process_status) VALUES
('MSKU0000005', 'ready', 'HUA D5678', 'Wang Fang', 'DOC003', NULL, 'B-01-03', 'planned');

-- ========================================================
-- 4. 场内台账 (D7) — 不再含 container_type / position_history
-- ========================================================
REPLACE INTO yard_container_inventory (container_id, container_status, current_slot_id, previous_slot_id, entry_time, expected_exit_time, dwell_time_hours, ship_id, voyage_no, is_overdue, overdue_days, alert_level, source_type, source_record_id) VALUES
('MSKU7892345', 'in_yard', 'A-15-06', NULL, '2026-05-28 08:30:00', NULL, 0, 'COSCO-2405', 'V2405', FALSE, 0, 'normal', 'sea_inbound', 'MSKU7892345'),
('TEST-8888999', 'in_yard', 'B-10-05', NULL, '2026-05-28 09:15:00', NULL, 0, 'COSCO-2405', 'V2405', FALSE, 0, 'normal', 'sea_inbound', 'TEST-8888999'),
('MSKU0000011', 'in_yard', 'B-02-01', NULL, '2026-05-29 14:00:00', NULL, 0, 'COSCO-2405', 'V2405', FALSE, 0, 'normal', 'land_inbound', 'MSKU0000011'),
('MSKU0000012', 'in_yard', 'B-02-02', NULL, '2026-05-29 15:30:00', NULL, 0, 'EVER-1803', 'V1803', FALSE, 0, 'normal', 'land_inbound', 'MSKU0000012');

-- ========================================================
-- 5. 箱位移动流水 (M1) — 结构化轨迹数据
-- ========================================================
REPLACE INTO container_move_logs (container_id, from_slot_id, to_slot_id, move_time, operator_name, operation_id, equipment_id, remark) VALUES
-- MSKU7892345 的完整轨迹
('MSKU7892345', NULL, 'A-10-05', '2026-05-28 08:30:00', '张明', 'YM-20260528-001', 'YC-03', '卸船落箱'),
('MSKU7892345', 'A-10-05', 'A-15-06', '2026-05-28 10:15:00', '李强', 'YM-20260528-010', 'YC-03', '场内归位'),
-- TEST-8888999 的完整轨迹
('TEST-8888999', NULL, 'B-10-01', '2026-05-28 09:15:00', '王磊', 'YM-20260528-002', 'YC-02', '卸船落箱'),
('TEST-8888999', 'B-10-01', 'B-10-05', '2026-05-28 11:00:00', '赵刚', 'YM-20260528-011', 'YC-02', '场内归位'),
-- MSKU0000011 的陆侧入场轨迹
('MSKU0000011', NULL, 'B-02-01', '2026-05-29 14:00:00', '孙伟', 'YM-20260529-003', 'YC-01', '闸口入场落箱');

-- ========================================================
-- 6. 调度指令 (D9)
-- ========================================================
REPLACE INTO dispatch_orders (order_id, order_type, issue_time, issue_dept, execute_dept, container_id, original_position, target_position, operation_requirement, priority_level, execution_status, related_ship_id) VALUES
('DI-20260528-001', 'sea_inbound',  '2026-05-28 08:00:00', '中控调度', '岸桥班组', 'MSKU7892345', NULL, 'A-10-05', '卸船落箱至进口箱区', 'normal', 'completed', 'COSCO-2405'),
('DI-20260528-002', 'sea_inbound',  '2026-05-28 09:00:00', '中控调度', '岸桥班组', 'TEST-8888999', NULL, 'B-10-01', '卸船落箱至出口箱区', 'normal', 'completed', 'COSCO-2405'),
('DI-20260528-003', 'yard_shift',   '2026-05-28 10:00:00', '中控调度', '场桥班组', 'MSKU7892345', 'A-10-05', 'A-15-06', '调箱至目标箱位',      'high',   'completed', 'COSCO-2405'),
('DI-20260528-004', 'yard_shift',   '2026-05-28 10:50:00', '中控调度', '场桥班组', 'TEST-8888999', 'B-10-01', 'B-10-05', '调箱至目标箱位',      'high',   'completed', 'COSCO-2405'),
('DI-20260528-010', 'land_inbound', '2026-05-29 13:50:00', '中控调度', '闸口班组', 'MSKU0000011',   NULL, 'B-02-01', '陆侧入场落箱',          'normal', 'completed', 'COSCO-2405');

-- ========================================================
-- 7. 预置用户（复用原有数据）
-- ========================================================
REPLACE INTO users (user_id, username, password_hash, real_name, role, department, phone, email, status) VALUES
('U001', 'dispatcher',  'pbkdf2:sha256:100000$aba8b12b6f9b3b1b9626911accbd68df$e92ac4bc2fba122f22e91e0c96f5056f4460c068a64ce3bc519522259e763801', '李明',  'dispatcher', '调度中心', '13800000001', 'dispatcher@yard.local',  'active'),
('U002', 'gate_clerk',  'pbkdf2:sha256:100000$1d6d6928c68b34c510853e1c4ff16d7c$e66dbd0510672d748c39e1275782ddc79842bd461444c1a436032abab58367c5', '王芳',  'gate_clerk',  '闸口管理', '13800000002', 'gate@yard.local',       'active'),
('U003A', 'qc_op',      'pbkdf2:sha256:100000$1ba9298243dceb57bdc60618f092c8bb$08f95b19fd587d375bac4a680bc03270417925a70d32825aaf2af349d7cc1fc1', '赵岸',  'qc_op',       '岸桥班组', '13800000003', 'qc_op@yard.local',      'active'),
('U003B', 'yc_op',      'pbkdf2:sha256:100000$7c2feab5124f2b873ab51f71696078af$c6aee2de8c9b6a011b96c5fecf3b3a4f838eff4e9b31e3b1ca35a603962028c3', '钱场',  'yc_op',       '场桥班组', '13800000005', 'yc_op@yard.local',      'active'),
('admin', 'admin',       'pbkdf2:sha256:100000$6af7b7c107875685df0496dea0c92c58$b228b0c6ec0a209d38357550af0dfaf4957925f954979b7f9c86f9411076b30e', '管理员','admin',       '信息中心', '13800000004', 'admin@yard.local',      'active');

SET FOREIGN_KEY_CHECKS = 1;
