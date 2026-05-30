-- ========================================================
-- 集装箱码头堆场管理MIS系统 - 数据库架构优化迁移脚本 v2.0
-- 包含: 主数据表解耦 / 轨迹流水 / 乐观锁 / 表分区
-- ========================================================
SET NAMES utf8mb4;

-- ========================================================
-- 1. 核心实体抽象：新建 containers_master 集装箱主数据表
-- ========================================================
CREATE TABLE IF NOT EXISTS containers_master (
    container_id    VARCHAR(20)  NOT NULL COMMENT '箱号（主键），如 MSKU7892345',
    container_type  VARCHAR(10)  NOT NULL COMMENT '箱型：20GP/40GP/40HQ/45HQ',
    tare_weight     DECIMAL(10,2)         COMMENT '皮重(kg)',
    owner_company   VARCHAR(100)          COMMENT '所属船公司/箱公司',
    size_code       VARCHAR(10)           COMMENT '尺寸代码，如 22G1/42G1',
    manufacture_date DATE                 COMMENT '制造日期',
    created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (container_id),
    INDEX idx_owner (owner_company),
    INDEX idx_type  (container_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='集装箱主数据表 - 只记录固有物理属性';

-- 将现有集装箱数据从各业务表迁移到 containers_master（按箱号去重）
INSERT INTO containers_master (container_id, container_type)
SELECT container_id, MAX(container_type)
FROM (
    SELECT container_id, container_type FROM sea_inbound_containers
    UNION
    SELECT container_id, container_type FROM land_inbound_containers
    UNION
    SELECT container_id, container_type FROM yard_container_inventory
    UNION
    SELECT container_id, container_type FROM gate_io_records WHERE container_id IS NOT NULL
    UNION
    SELECT container_id, container_type FROM dispatch_orders WHERE container_id IS NOT NULL
    UNION
    SELECT container_id, container_type FROM yard_operation_records
    UNION
    SELECT container_id, container_type FROM sea_outbound_containers
    UNION
    SELECT container_id, container_type FROM land_outbound_containers
) AS all_containers
WHERE container_id IS NOT NULL AND container_id != ''
GROUP BY container_id;

-- step 1: 修改 sea_inbound_containers - 添加 FK 到 containers_master, 移除 container_type
ALTER TABLE sea_inbound_containers
    ADD CONSTRAINT fk_sea_in_cont FOREIGN KEY (container_id) REFERENCES containers_master(container_id);
ALTER TABLE sea_inbound_containers DROP COLUMN container_type;

-- step 2: 修改 land_inbound_containers
ALTER TABLE land_inbound_containers
    ADD CONSTRAINT fk_land_in_cont FOREIGN KEY (container_id) REFERENCES containers_master(container_id);
ALTER TABLE land_inbound_containers DROP COLUMN container_type;

-- step 3: 修改 yard_container_inventory - 外键指向 containers_master
ALTER TABLE yard_container_inventory
    DROP FOREIGN KEY yard_container_inventory_ibfk_1;
ALTER TABLE yard_container_inventory
    ADD CONSTRAINT fk_yard_inv_cont FOREIGN KEY (container_id) REFERENCES containers_master(container_id);
ALTER TABLE yard_container_inventory DROP COLUMN container_type;

-- step 4: 修改 yard_operation_records
ALTER TABLE yard_operation_records
    DROP FOREIGN KEY yard_operation_records_ibfk_1;
ALTER TABLE yard_operation_records
    ADD CONSTRAINT fk_yard_op_cont FOREIGN KEY (container_id) REFERENCES containers_master(container_id);
ALTER TABLE yard_operation_records DROP COLUMN container_type;

-- step 5: 修改 dispatch_orders
ALTER TABLE dispatch_orders
    DROP FOREIGN KEY dispatch_orders_ibfk_1;
ALTER TABLE dispatch_orders
    ADD CONSTRAINT fk_dispatch_cont FOREIGN KEY (container_id) REFERENCES containers_master(container_id);
ALTER TABLE dispatch_orders DROP COLUMN container_type;

-- step 6: 修改 gate_io_records (保留 container_type 作为快照字段)
ALTER TABLE gate_io_records
    ADD CONSTRAINT fk_gate_cont FOREIGN KEY (container_id) REFERENCES containers_master(container_id);

-- step 7: 修改 sea_outbound_containers & land_outbound_containers
ALTER TABLE sea_outbound_containers
    ADD CONSTRAINT fk_sea_out_cont FOREIGN KEY (container_id) REFERENCES containers_master(container_id);
ALTER TABLE sea_outbound_containers DROP COLUMN container_type;

ALTER TABLE land_outbound_containers
    ADD CONSTRAINT fk_land_out_cont FOREIGN KEY (container_id) REFERENCES containers_master(container_id);
ALTER TABLE land_outbound_containers DROP COLUMN container_type;

-- ========================================================
-- 2. 轨迹流水规范化：新建 container_move_logs
-- ========================================================
CREATE TABLE IF NOT EXISTS container_move_logs (
    log_id          INT          NOT NULL AUTO_INCREMENT COMMENT '日志ID',
    container_id    VARCHAR(20)  NOT NULL COMMENT '箱号',
    from_slot_id    VARCHAR(20)           COMMENT '原位置',
    to_slot_id      VARCHAR(20)  NOT NULL COMMENT '新位置',
    move_time       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '移动时间',
    operator_name   VARCHAR(50)           COMMENT '操作人员',
    operation_id    VARCHAR(30)           COMMENT '关联作业记录号',
    equipment_id    VARCHAR(20)           COMMENT '作业机械编号',
    remark          VARCHAR(200)          COMMENT '备注',
    created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (log_id, move_time),
    INDEX idx_container (container_id),
    INDEX idx_move_time (move_time),
    CONSTRAINT fk_move_cont FOREIGN KEY (container_id) REFERENCES containers_master(container_id),
    CONSTRAINT fk_move_from FOREIGN KEY (from_slot_id) REFERENCES yard_slots(slot_id),
    CONSTRAINT fk_move_to   FOREIGN KEY (to_slot_id)   REFERENCES yard_slots(slot_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='箱位移动流水表 - 每一次位置变更均记录'
PARTITION BY RANGE (TO_DAYS(move_time)) (
    PARTITION p202401 VALUES LESS THAN (TO_DAYS('2024-02-01')),
    PARTITION p202402 VALUES LESS THAN (TO_DAYS('2024-03-01')),
    PARTITION p202403 VALUES LESS THAN (TO_DAYS('2024-04-01')),
    PARTITION p202404 VALUES LESS THAN (TO_DAYS('2024-05-01')),
    PARTITION p202405 VALUES LESS THAN (TO_DAYS('2024-06-01')),
    PARTITION p202406 VALUES LESS THAN (TO_DAYS('2024-07-01')),
    PARTITION p202407 VALUES LESS THAN (TO_DAYS('2024-08-01')),
    PARTITION p202408 VALUES LESS THAN (TO_DAYS('2024-09-01')),
    PARTITION p202409 VALUES LESS THAN (TO_DAYS('2024-10-01')),
    PARTITION p202410 VALUES LESS THAN (TO_DAYS('2024-11-01')),
    PARTITION p202411 VALUES LESS THAN (TO_DAYS('2024-12-01')),
    PARTITION p202412 VALUES LESS THAN (TO_DAYS('2025-01-01')),
    PARTITION p202501 VALUES LESS THAN (TO_DAYS('2025-02-01')),
    PARTITION p202502 VALUES LESS THAN (TO_DAYS('2025-03-01')),
    PARTITION p202503 VALUES LESS THAN (TO_DAYS('2025-04-01')),
    PARTITION p202504 VALUES LESS THAN (TO_DAYS('2025-05-01')),
    PARTITION p202505 VALUES LESS THAN (TO_DAYS('2025-06-01')),
    PARTITION p202506 VALUES LESS THAN (TO_DAYS('2025-07-01')),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- 移除 yard_container_inventory 的 JSON 历史字段
ALTER TABLE yard_container_inventory DROP COLUMN position_history;

-- ========================================================
-- 3. 乐观锁：yard_slots 增加 version 字段
-- ========================================================
ALTER TABLE yard_slots ADD COLUMN version INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号';

-- ========================================================
-- 4. 冷热数据分离：日志/流水表按月分区
-- ========================================================

-- 4a. system_logs 按月分区
ALTER TABLE system_logs
    PARTITION BY RANGE (TO_DAYS(created_at)) (
        PARTITION p202401 VALUES LESS THAN (TO_DAYS('2024-02-01')),
        PARTITION p202402 VALUES LESS THAN (TO_DAYS('2024-03-01')),
        PARTITION p202403 VALUES LESS THAN (TO_DAYS('2024-04-01')),
        PARTITION p202404 VALUES LESS THAN (TO_DAYS('2024-05-01')),
        PARTITION p202405 VALUES LESS THAN (TO_DAYS('2024-06-01')),
        PARTITION p202406 VALUES LESS THAN (TO_DAYS('2024-07-01')),
        PARTITION p202407 VALUES LESS THAN (TO_DAYS('2024-08-01')),
        PARTITION p202408 VALUES LESS THAN (TO_DAYS('2024-09-01')),
        PARTITION p202409 VALUES LESS THAN (TO_DAYS('2024-10-01')),
        PARTITION p202410 VALUES LESS THAN (TO_DAYS('2024-11-01')),
        PARTITION p202411 VALUES LESS THAN (TO_DAYS('2024-12-01')),
        PARTITION p202412 VALUES LESS THAN (TO_DAYS('2025-01-01')),
        PARTITION p202501 VALUES LESS THAN (TO_DAYS('2025-02-01')),
        PARTITION p202502 VALUES LESS THAN (TO_DAYS('2025-03-01')),
        PARTITION p202503 VALUES LESS THAN (TO_DAYS('2025-04-01')),
        PARTITION p202504 VALUES LESS THAN (TO_DAYS('2025-05-01')),
        PARTITION p202505 VALUES LESS THAN (TO_DAYS('2025-06-01')),
        PARTITION p202506 VALUES LESS THAN (TO_DAYS('2025-07-01')),
        PARTITION p_future VALUES LESS THAN MAXVALUE
    );

-- 4b. gate_io_records 按月分区
ALTER TABLE gate_io_records
    PARTITION BY RANGE (TO_DAYS(created_at)) (
        PARTITION p202401 VALUES LESS THAN (TO_DAYS('2024-02-01')),
        PARTITION p202402 VALUES LESS THAN (TO_DAYS('2024-03-01')),
        PARTITION p202403 VALUES LESS THAN (TO_DAYS('2024-04-01')),
        PARTITION p202404 VALUES LESS THAN (TO_DAYS('2024-05-01')),
        PARTITION p202405 VALUES LESS THAN (TO_DAYS('2024-06-01')),
        PARTITION p202406 VALUES LESS THAN (TO_DAYS('2024-07-01')),
        PARTITION p202407 VALUES LESS THAN (TO_DAYS('2024-08-01')),
        PARTITION p202408 VALUES LESS THAN (TO_DAYS('2024-09-01')),
        PARTITION p202409 VALUES LESS THAN (TO_DAYS('2024-10-01')),
        PARTITION p202410 VALUES LESS THAN (TO_DAYS('2024-11-01')),
        PARTITION p202411 VALUES LESS THAN (TO_DAYS('2024-12-01')),
        PARTITION p202412 VALUES LESS THAN (TO_DAYS('2025-01-01')),
        PARTITION p202501 VALUES LESS THAN (TO_DAYS('2025-02-01')),
        PARTITION p202502 VALUES LESS THAN (TO_DAYS('2025-03-01')),
        PARTITION p202503 VALUES LESS THAN (TO_DAYS('2025-04-01')),
        PARTITION p202504 VALUES LESS THAN (TO_DAYS('2025-05-01')),
        PARTITION p202505 VALUES LESS THAN (TO_DAYS('2025-06-01')),
        PARTITION p202506 VALUES LESS THAN (TO_DAYS('2025-07-01')),
        PARTITION p_future VALUES LESS THAN MAXVALUE
    );

-- 4c. yard_operation_records 按月分区
ALTER TABLE yard_operation_records
    PARTITION BY RANGE (TO_DAYS(created_at)) (
        PARTITION p202401 VALUES LESS THAN (TO_DAYS('2024-02-01')),
        PARTITION p202402 VALUES LESS THAN (TO_DAYS('2024-03-01')),
        PARTITION p202403 VALUES LESS THAN (TO_DAYS('2024-04-01')),
        PARTITION p202404 VALUES LESS THAN (TO_DAYS('2024-05-01')),
        PARTITION p202405 VALUES LESS THAN (TO_DAYS('2024-06-01')),
        PARTITION p202406 VALUES LESS THAN (TO_DAYS('2024-07-01')),
        PARTITION p202407 VALUES LESS THAN (TO_DAYS('2024-08-01')),
        PARTITION p202408 VALUES LESS THAN (TO_DAYS('2024-09-01')),
        PARTITION p202409 VALUES LESS THAN (TO_DAYS('2024-10-01')),
        PARTITION p202410 VALUES LESS THAN (TO_DAYS('2024-11-01')),
        PARTITION p202411 VALUES LESS THAN (TO_DAYS('2024-12-01')),
        PARTITION p202412 VALUES LESS THAN (TO_DAYS('2025-01-01')),
        PARTITION p202501 VALUES LESS THAN (TO_DAYS('2025-02-01')),
        PARTITION p202502 VALUES LESS THAN (TO_DAYS('2025-03-01')),
        PARTITION p202503 VALUES LESS THAN (TO_DAYS('2025-04-01')),
        PARTITION p202504 VALUES LESS THAN (TO_DAYS('2025-05-01')),
        PARTITION p202505 VALUES LESS THAN (TO_DAYS('2025-06-01')),
        PARTITION p202506 VALUES LESS THAN (TO_DAYS('2025-07-01')),
        PARTITION p_future VALUES LESS THAN MAXVALUE
    );
