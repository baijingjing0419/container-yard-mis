-- ========================================================
-- 清除所有测试数据（保留基础参考数据：ships / yard_zones / yard_slots / users）
-- ========================================================
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE container_move_logs;
TRUNCATE TABLE yard_operation_records;
TRUNCATE TABLE dispatch_orders;
TRUNCATE TABLE yard_container_inventory;
TRUNCATE TABLE gate_io_records;
TRUNCATE TABLE system_logs;
TRUNCATE TABLE alerts;
TRUNCATE TABLE sea_inbound_containers;
TRUNCATE TABLE sea_outbound_containers;
TRUNCATE TABLE sea_terminal_io;
TRUNCATE TABLE land_inbound_containers;
TRUNCATE TABLE land_outbound_containers;
TRUNCATE TABLE sea_operation_plans;
TRUNCATE TABLE land_operation_plans;
TRUNCATE TABLE containers_master;

-- 重置 yard_slots 为全空闲状态
UPDATE yard_slots SET slot_status = 'empty', current_container_id = NULL, version = 0;

SET FOREIGN_KEY_CHECKS = 1;

SELECT 'All test data cleared. Base data (ships, yard_zones, yard_slots, users) preserved.' AS result;
