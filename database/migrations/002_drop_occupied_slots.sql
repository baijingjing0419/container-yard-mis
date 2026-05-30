-- ========================================================
-- 迁移 v3: 移除 yard_zones.occupied_slots 反范式冗余字段
-- occupied_slots 改为从 yard_slots 实时 COUNT 计算
-- ========================================================
SET NAMES utf8mb4;

ALTER TABLE yard_zones DROP COLUMN occupied_slots;

SELECT 'Migration 03: dropped yard_zones.occupied_slots' AS result;
