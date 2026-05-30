-- ========================================================
-- 堆场物理布局初始化数据
-- 新系统部署后执行: docker exec -i yard-mysql mysql -u root -proot ContainerTerminalDB < database/seeds/yard_setup.sql
-- ========================================================
SET NAMES utf8mb4;

-- 堆场区域（3个区，各576箱位，5层堆叠）
INSERT INTO yard_zones (zone_id, zone_name, zone_type, total_slots, max_tier, status) VALUES
('A', 'A区-进口箱区', 'import', 576, 5, 'active'),
('B', 'B区-出口箱区', 'export', 576, 5, 'active'),
('C', 'C区-中转箱区', 'transfer', 576, 5, 'active')
ON DUPLICATE KEY UPDATE zone_name=VALUES(zone_name);

-- 预置常用箱位
INSERT INTO yard_slots (slot_id, zone_id, row_num, col_num, tier_num, slot_status, max_weight, slot_size, version) VALUES
('A-01-01', 'A', 1, 1, 1, 'empty', 30.0, '40GP', 0),
('A-01-02', 'A', 1, 2, 1, 'empty', 30.0, '40GP', 0),
('A-01-03', 'A', 1, 3, 1, 'empty', 30.0, '40GP', 0),
('A-01-04', 'A', 1, 4, 1, 'empty', 30.0, '40GP', 0),
('A-02-01', 'A', 2, 1, 1, 'empty', 30.0, '40GP', 0),
('A-02-02', 'A', 2, 2, 1, 'empty', 30.0, '40GP', 0),
('B-01-01', 'B', 1, 1, 1, 'empty', 30.0, '40GP', 0),
('B-01-02', 'B', 1, 2, 1, 'empty', 30.0, '40GP', 0),
('B-01-03', 'B', 1, 3, 1, 'empty', 30.0, '40GP', 0),
('B-01-04', 'B', 1, 4, 1, 'empty', 30.0, '40GP', 0),
('B-02-01', 'B', 2, 1, 1, 'empty', 30.0, '40GP', 0),
('B-02-02', 'B', 2, 2, 1, 'empty', 30.0, '40GP', 0),
('A-10-05', 'A', 10, 5, 1, 'empty', 30.0, '40GP', 0),
('A-15-06', 'A', 15, 6, 1, 'empty', 30.0, '40GP', 0),
('B-10-01', 'B', 10, 1, 1, 'empty', 30.0, '40GP', 0),
('B-10-05', 'B', 10, 5, 1, 'empty', 30.0, '40GP', 0)
ON DUPLICATE KEY UPDATE slot_status=VALUES(slot_status);

SELECT 'Yard setup data imported.' AS result;
