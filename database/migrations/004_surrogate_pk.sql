-- ========================================================
-- 迁移 004: INT 代理键 + 位置字段 FK 约束
--   - dispatch_orders / yard_operation_records 添加 id INT AUTO_INCREMENT UNIQUE
--   - 原 varchar 业务键保留为 PRIMARY KEY，兼容现有 API
--   - dispatch_orders 位置字段添加 FK → yard_slots
-- ========================================================
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 1. dispatch_orders: 添加代理键
ALTER TABLE dispatch_orders
    ADD COLUMN id INT AUTO_INCREMENT UNIQUE NOT NULL
    COMMENT '代理键(高效join)',
    ALGORITHM=INPLACE, LOCK=NONE;

-- 2. dispatch_orders: 位置字段添加 FK 约束
ALTER TABLE dispatch_orders
    ADD CONSTRAINT fk_dispatch_orig_pos
        FOREIGN KEY (original_position) REFERENCES yard_slots(slot_id)
        ON DELETE SET NULL,
    ADD CONSTRAINT fk_dispatch_target_pos
        FOREIGN KEY (target_position) REFERENCES yard_slots(slot_id)
        ON DELETE SET NULL;

-- 3. yard_operation_records: 添加代理键
ALTER TABLE yard_operation_records
    ADD COLUMN id INT AUTO_INCREMENT UNIQUE NOT NULL
    COMMENT '代理键(高效join)',
    ALGORITHM=INPLACE, LOCK=NONE;

SET FOREIGN_KEY_CHECKS = 1;

SELECT 'Migration 004: surrogate keys + position FKs applied.' AS result;
