-- ========================================================
-- 分区维护存储过程 — 按月自动扩展分区
-- 适用表: container_move_logs / system_logs / gate_io_records / yard_operation_records
-- 建议通过 MySQL EVENT 每月 1 号自动执行
-- ========================================================

DELIMITER //

CREATE PROCEDURE IF NOT EXISTS sp_maintain_partitions()
BEGIN
    DECLARE v_target_date DATE;
    DECLARE v_part_name VARCHAR(20);
    DECLARE v_part_date VARCHAR(10);
    DECLARE i INT DEFAULT 0;

    -- 从下个月开始，预创建未来 12 个月的分区
    WHILE i < 12 DO
        SET v_target_date = DATE_ADD(DATE_FORMAT(CURDATE(), '%Y-%m-01'), INTERVAL (i + 1) MONTH);
        SET v_part_name = CONCAT('p', DATE_FORMAT(v_target_date, '%Y%m'));
        SET v_part_date = DATE_FORMAT(DATE_ADD(v_target_date, INTERVAL 1 MONTH), '%Y-%m-01');

        -- container_move_logs
        SET @sql = CONCAT(
            'ALTER TABLE container_move_logs REORGANIZE PARTITION p_future INTO (',
            'PARTITION ', v_part_name, ' VALUES LESS THAN (TO_DAYS(''', v_part_date, ''')),',
            'PARTITION p_future VALUES LESS THAN MAXVALUE)'
        );
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- system_logs
        SET @sql = CONCAT(
            'ALTER TABLE system_logs REORGANIZE PARTITION p_future INTO (',
            'PARTITION ', v_part_name, ' VALUES LESS THAN (TO_DAYS(''', v_part_date, ''')),',
            'PARTITION p_future VALUES LESS THAN MAXVALUE)'
        );
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- gate_io_records
        SET @sql = CONCAT(
            'ALTER TABLE gate_io_records REORGANIZE PARTITION p_future INTO (',
            'PARTITION ', v_part_name, ' VALUES LESS THAN (TO_DAYS(''', v_part_date, ''')),',
            'PARTITION p_future VALUES LESS THAN MAXVALUE)'
        );
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- yard_operation_records
        SET @sql = CONCAT(
            'ALTER TABLE yard_operation_records REORGANIZE PARTITION p_future INTO (',
            'PARTITION ', v_part_name, ' VALUES LESS THAN (TO_DAYS(''', v_part_date, ''')),',
            'PARTITION p_future VALUES LESS THAN MAXVALUE)'
        );
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET i = i + 1;
    END WHILE;
END //

DELIMITER ;

-- 创建每月自动执行的事件（每月 1 号凌晨 2:00）
CREATE EVENT IF NOT EXISTS evt_monthly_partition_maintenance
ON SCHEDULE EVERY 1 MONTH
STARTS DATE_FORMAT(DATE_ADD(CURDATE(), INTERVAL 1 MONTH), '%Y-%m-01 02:00:00')
DO CALL sp_maintain_partitions();

SELECT 'Partition maintenance procedure & event created.' AS result;
