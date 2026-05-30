SET NAMES utf8mb4;

-- ========================================================
-- 集装箱码头堆场管理信息MIS系统 - 数据库设计
-- Container Terminal Yard Management System Database
-- 基于9大核心数据类设计
-- ========================================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS ContainerTerminalDB 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE ContainerTerminalDB;

-- ========================================================
-- 1. 基础数据表 - 船舶信息 (支撑海侧作业)
-- ========================================================
CREATE TABLE ships (
    ship_id             VARCHAR(20) PRIMARY KEY COMMENT '船舶编号',
    ship_name           VARCHAR(100) NOT NULL COMMENT '船舶名称',
    ship_type           VARCHAR(20) COMMENT '船舶类型(集装箱船/散货船等)',
    ship_company        VARCHAR(100) COMMENT '船公司',
    ship_length         DECIMAL(8,2) COMMENT '船长(米)',
    ship_capacity       INT COMMENT '载箱量(TEU)',
    status              VARCHAR(20) DEFAULT 'active' COMMENT '状态(active/retired)',
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='船舶基础信息表';

-- ========================================================
-- 2. 基础数据表 - 堆场区域与箱位信息
-- ========================================================
CREATE TABLE yard_zones (
    zone_id             VARCHAR(10) PRIMARY KEY COMMENT '区域编号(A/B/C)',
    zone_name           VARCHAR(50) NOT NULL COMMENT '区域名称',
    zone_type           VARCHAR(20) NOT NULL COMMENT '区域类型(import/export/transit)',
    total_slots         INT NOT NULL COMMENT '总箱位数',
    max_tier            INT DEFAULT 5 COMMENT '最大堆叠层数',
    status              VARCHAR(20) DEFAULT 'active' COMMENT '状态',
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='堆场区域定义表';

CREATE TABLE yard_slots (
    slot_id             VARCHAR(20) PRIMARY KEY COMMENT '箱位编号(如:A-12-04)',
    zone_id             VARCHAR(10) NOT NULL COMMENT '所属区域',
    row_num             INT NOT NULL COMMENT '排号',
    col_num             INT NOT NULL COMMENT '列号',
    tier_num            INT DEFAULT 1 COMMENT '层号',
    slot_status         VARCHAR(20) DEFAULT 'empty' COMMENT '状态(empty/occupied/reserved/maintenance)',
    current_container_id VARCHAR(20) COMMENT '当前存放集装箱号',
    max_weight          DECIMAL(10,2) COMMENT '最大承重(吨)',
    slot_size           VARCHAR(10) COMMENT '适用箱型(20GP/40GP/40HQ/all)',
    FOREIGN KEY (zone_id) REFERENCES yard_zones(zone_id)
) ENGINE=InnoDB COMMENT='堆场箱位明细表';

-- ========================================================
-- 3. 核心数据类 D1: 海侧入场集装箱信息
-- 关联过程: 海侧进箱作业(C)、海侧作业计划(U)
-- ========================================================
CREATE TABLE sea_inbound_containers (
    container_id        VARCHAR(20) PRIMARY KEY COMMENT '箱号',
    container_type      VARCHAR(10) NOT NULL COMMENT '箱型(20GP/40GP/40HQ/45HQ)',
    container_status    VARCHAR(20) DEFAULT 'intact' COMMENT '箱状态(intact/damaged/empty)',
    ship_id             VARCHAR(20) NOT NULL COMMENT '船名航次',
    voyage_no           VARCHAR(20) NOT NULL COMMENT '航次号',
    manifest_info       VARCHAR(100) COMMENT '舱单信息(舱位编号)',
    damage_status       VARCHAR(50) DEFAULT '完好' COMMENT '残损情况',
    entry_time          DATETIME COMMENT '入场时间(场桥落箱完成时间)',
    target_slot_id      VARCHAR(20) COMMENT '目标堆场位置',
    actual_slot_id      VARCHAR(20) COMMENT '实际落箱位置',

    -- 作业关联
    operation_id        VARCHAR(30) COMMENT '关联作业记录号',
    plan_id             VARCHAR(30) COMMENT '关联海侧作业计划号',

    -- 来源信息
    discharge_crane     VARCHAR(20) COMMENT '卸船岸桥编号',
    transfer_truck      VARCHAR(20) COMMENT '转运内集卡编号',
    yard_crane          VARCHAR(20) COMMENT '落箱场桥编号',

    -- 状态跟踪
    process_status      VARCHAR(20) DEFAULT 'pending' COMMENT '作业状态(pending/transiting/landed/completed)',
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (ship_id) REFERENCES ships(ship_id),
    FOREIGN KEY (target_slot_id) REFERENCES yard_slots(slot_id),
    FOREIGN KEY (actual_slot_id) REFERENCES yard_slots(slot_id)
) ENGINE=InnoDB COMMENT='海侧入场集装箱信息表(D1)';

-- ========================================================
-- 4. 核心数据类 D2: 海侧出场集装箱信息
-- 关联过程: 海侧出场作业(C)、海侧作业计划(U)
-- ========================================================
CREATE TABLE sea_outbound_containers (
    container_id        VARCHAR(20) PRIMARY KEY COMMENT '箱号',
    container_type      VARCHAR(10) NOT NULL COMMENT '箱型',
    container_status    VARCHAR(20) DEFAULT 'loaded' COMMENT '箱状态',
    ship_id             VARCHAR(20) NOT NULL COMMENT '目标船名航次',
    voyage_no           VARCHAR(20) NOT NULL COMMENT '航次号',
    stowage_position    VARCHAR(20) COMMENT '配载舱位',

    exit_time           DATETIME COMMENT '出场时间(场桥提箱时间)',
    original_slot_id    VARCHAR(20) COMMENT '原堆场位置',
    load_complete_time  DATETIME COMMENT '装船完成时间',

    -- 单证信息
    document_info       TEXT COMMENT '单证信息(出口舱单、装箱单等)',
    customs_status      VARCHAR(20) DEFAULT 'cleared' COMMENT '海关放行状态',

    -- 作业关联
    operation_id        VARCHAR(30) COMMENT '关联出场作业记录号',
    plan_id             VARCHAR(30) COMMENT '关联海侧作业计划号',

    -- 设备信息
    yard_crane          VARCHAR(20) COMMENT '提箱场桥编号',
    transfer_truck      VARCHAR(20) COMMENT '转运内集卡编号',
    load_crane          VARCHAR(20) COMMENT '装船岸桥编号',

    process_status      VARCHAR(20) DEFAULT 'planned' COMMENT '作业状态(planned/picked/transiting/loaded/completed)',
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (ship_id) REFERENCES ships(ship_id),
    FOREIGN KEY (original_slot_id) REFERENCES yard_slots(slot_id)
) ENGINE=InnoDB COMMENT='海侧出场集装箱信息表(D2)';

-- ========================================================
-- 5. 核心数据类 D3: 海侧码头出、入场信息
-- 关联过程: 海侧作业计划(C)、海侧进箱/出场作业(U)
-- ========================================================
CREATE TABLE sea_terminal_io (
    io_record_id        VARCHAR(30) PRIMARY KEY COMMENT '出入场记录号',
    voyage_no           VARCHAR(20) NOT NULL COMMENT '航次号',
    ship_id             VARCHAR(20) NOT NULL COMMENT '船舶编号',

    -- 时间信息
    berth_time          DATETIME COMMENT '靠泊时间',
    departure_time      DATETIME COMMENT '离泊时间',

    -- 箱量统计
    inbound_total       INT DEFAULT 0 COMMENT '入场箱总量',
    outbound_total      INT DEFAULT 0 COMMENT '出场箱总量',

    -- 作业信息
    operation_sequence  TEXT COMMENT '装卸作业顺序',
    stowage_plan        TEXT COMMENT '舱位配载计划',
    operation_progress  DECIMAL(5,2) DEFAULT 0 COMMENT '作业进度百分比',

    -- 资源调度
    assigned_quay_cranes VARCHAR(100) COMMENT '分配岸桥(逗号分隔)',
    assigned_yard_cranes VARCHAR(100) COMMENT '分配场桥',
    assigned_trucks     VARCHAR(100) COMMENT '分配内集卡',

    -- 状态
    operation_status    VARCHAR(20) DEFAULT 'planned' COMMENT '作业状态(planned/berthing/loading/discharging/completed)',
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (ship_id) REFERENCES ships(ship_id)
) ENGINE=InnoDB COMMENT='海侧码头出、入场信息表(D3)';

-- ========================================================
-- 6. 核心数据类 D4: 陆侧入场集装箱信息
-- 关联过程: 陆侧进箱作业(C)、陆侧作业计划(U)
-- ========================================================
CREATE TABLE land_inbound_containers (
    container_id        VARCHAR(20) PRIMARY KEY COMMENT '箱号',
    container_type      VARCHAR(10) NOT NULL COMMENT '箱型',
    container_status    VARCHAR(20) DEFAULT 'intact' COMMENT '箱状态',

    -- 车辆信息
    truck_plate         VARCHAR(20) COMMENT '车牌号码',
    driver_name         VARCHAR(50) COMMENT '司机姓名',
    driver_phone        VARCHAR(20) COMMENT '司机电话',

    -- 单证信息
    document_no         VARCHAR(50) COMMENT '单证号(出口提单号)',
    document_type       VARCHAR(20) COMMENT '单证类型(出口提单/进口舱单)',

    -- 关联信息
    ship_id             VARCHAR(20) COMMENT '关联船名航次(出口箱)',
    voyage_no           VARCHAR(20) COMMENT '航次号',

    -- 时间信息
    entry_time          DATETIME COMMENT '入场时间(闸口放行时间)',
    gate_pass_time      DATETIME COMMENT '闸口通过时间',
    target_slot_id      VARCHAR(20) COMMENT '目标堆场位置',
    actual_slot_id      VARCHAR(20) COMMENT '实际落箱位置',

    -- 残损确认
    damage_check        VARCHAR(20) DEFAULT '完好' COMMENT '残损确认结果',
    damage_photo_url    VARCHAR(255) COMMENT '残损照片URL',

    -- 作业关联
    operation_id        VARCHAR(30) COMMENT '关联陆侧进箱作业号',
    plan_id             VARCHAR(30) COMMENT '关联陆侧作业计划号',

    process_status      VARCHAR(20) DEFAULT 'pending' COMMENT '作业状态(pending/gate_checking/inspecting/approved/landed/completed)',
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (ship_id) REFERENCES ships(ship_id),
    FOREIGN KEY (target_slot_id) REFERENCES yard_slots(slot_id),
    FOREIGN KEY (actual_slot_id) REFERENCES yard_slots(slot_id)
) ENGINE=InnoDB COMMENT='陆侧入场集装箱信息表(D4)';

-- ========================================================
-- 7. 核心数据类 D5: 陆侧出场集装箱信息
-- 关联过程: 陆侧出场作业(C)、陆侧作业计划(U)
-- ========================================================
CREATE TABLE land_outbound_containers (
    container_id        VARCHAR(20) PRIMARY KEY COMMENT '箱号',
    container_type      VARCHAR(10) NOT NULL COMMENT '箱型',
    container_status    VARCHAR(20) DEFAULT 'ready' COMMENT '箱状态',

    -- 车辆信息
    truck_plate         VARCHAR(20) COMMENT '车牌号码',
    driver_name         VARCHAR(50) COMMENT '司机姓名',
    driver_phone        VARCHAR(20) COMMENT '司机电话',

    -- 单证信息
    pickup_document_no  VARCHAR(50) COMMENT '提箱单证号(提货单)',
    document_type       VARCHAR(20) COMMENT '单证类型(提货单/出口提单)',

    -- 关联信息
    ship_id             VARCHAR(20) COMMENT '关联船名航次',
    voyage_no           VARCHAR(20) COMMENT '航次号',

    -- 位置信息
    original_slot_id    VARCHAR(20) COMMENT '原堆场位置',

    -- 时间信息
    exit_time           DATETIME COMMENT '出场时间(闸口放行时间)',
    gate_pass_time      DATETIME COMMENT '闸口通过时间',
    release_confirm_time DATETIME COMMENT '放行确认时间',

    -- 作业关联
    operation_id        VARCHAR(30) COMMENT '关联陆侧出场作业号',
    plan_id             VARCHAR(30) COMMENT '关联陆侧作业计划号',

    process_status      VARCHAR(20) DEFAULT 'planned' COMMENT '作业状态(planned/picking/transiting/gate_checking/released/completed)',
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (ship_id) REFERENCES ships(ship_id),
    FOREIGN KEY (original_slot_id) REFERENCES yard_slots(slot_id)
) ENGINE=InnoDB COMMENT='陆侧出场集装箱信息表(D5)';

-- ========================================================
-- 8. 核心数据类 D6: 陆侧闸口出、入场信息
-- 关联过程: 陆侧作业计划(C)、陆侧进箱/出场作业(U)
-- ========================================================
CREATE TABLE gate_io_records (
    record_id           VARCHAR(30) PRIMARY KEY COMMENT '通行记录号',
    gate_lane_no        VARCHAR(10) COMMENT '闸口通道号',
    io_type             VARCHAR(10) NOT NULL COMMENT '进出类型(inbound/outbound)',

    -- 车辆信息
    truck_plate         VARCHAR(20) NOT NULL COMMENT '车牌号码',
    driver_name         VARCHAR(50) COMMENT '司机姓名',

    -- 集装箱信息
    container_id        VARCHAR(20) COMMENT '箱号',
    container_type      VARCHAR(10) COMMENT '箱型',

    -- 单证核验
    document_no         VARCHAR(50) COMMENT '单证号',
    document_verify_result VARCHAR(20) DEFAULT 'passed' COMMENT '单证核验结果(passed/failed/pending)',

    -- 残损确认
    damage_check        VARCHAR(20) DEFAULT '完好' COMMENT '残损确认情况',
    damage_remark       TEXT COMMENT '残损备注',

    -- 时间信息
    entry_time          DATETIME COMMENT '入场时间',
    exit_time           DATETIME COMMENT '出场时间',
    pass_duration       INT COMMENT '通行时长(分钟)',

    -- 放行状态
    release_status      VARCHAR(20) DEFAULT 'pending' COMMENT '放行状态(pending/approved/rejected)',
    release_operator    VARCHAR(50) COMMENT '放行操作人员',

    -- 作业关联
    operation_id        VARCHAR(30) COMMENT '关联作业记录号',
    plan_id             VARCHAR(30) COMMENT '关联作业计划号',

    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='陆侧闸口出、入场信息表(D6)';

-- ========================================================
-- 9. 核心数据类 D7: 场内集装箱信息
-- 关联过程: 集装箱堆存日常管理(C)、场内调箱/海侧陆侧进出箱作业(U)
-- ========================================================
CREATE TABLE yard_container_inventory (
    inventory_id        INT AUTO_INCREMENT PRIMARY KEY COMMENT '台账记录ID',
    container_id        VARCHAR(20) NOT NULL COMMENT '箱号',
    container_type      VARCHAR(10) NOT NULL COMMENT '箱型',
    container_status    VARCHAR(20) DEFAULT 'in_yard' COMMENT '箱状态(in_yard/in_transit/outbound/damaged)',

    -- 位置信息
    current_slot_id     VARCHAR(20) COMMENT '当前堆场位置',
    previous_slot_id    VARCHAR(20) COMMENT '上一位置',
    position_history    TEXT COMMENT '历史位置记录(JSON格式)',

    -- 时间信息
    entry_time          DATETIME COMMENT '入场时间',
    expected_exit_time  DATETIME COMMENT '预计出场时间',
    actual_exit_time    DATETIME COMMENT '实际出场时间',
    dwell_time_hours    INT DEFAULT 0 COMMENT '停留时长(小时)',

    -- 关联信息
    ship_id             VARCHAR(20) COMMENT '关联船名航次',
    voyage_no           VARCHAR(20) COMMENT '航次号',
    pickup_plan_id      VARCHAR(30) COMMENT '提箱计划信息',

    -- 预警标记
    is_overdue          BOOLEAN DEFAULT FALSE COMMENT '是否超期滞留',
    overdue_days        INT DEFAULT 0 COMMENT '超期天数',
    alert_level         VARCHAR(10) DEFAULT 'normal' COMMENT '预警级别(normal/warning/critical)',

    -- 来源追踪
    source_type         VARCHAR(20) COMMENT '来源类型(sea_inbound/land_inbound)',
    source_record_id    VARCHAR(30) COMMENT '来源记录号',

    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (container_id) REFERENCES sea_inbound_containers(container_id),
    FOREIGN KEY (current_slot_id) REFERENCES yard_slots(slot_id),
    FOREIGN KEY (ship_id) REFERENCES ships(ship_id),
    INDEX idx_container (container_id),
    INDEX idx_slot (current_slot_id),
    INDEX idx_ship (ship_id)
) ENGINE=InnoDB COMMENT='场内集装箱信息表(D7)';

-- ========================================================
-- 10. 核心数据类 D8: 堆场作业记录
-- 关联过程: 场内调箱作业(C)、集装箱堆存日常管理/海侧陆侧进出箱作业(U)
-- ========================================================
CREATE TABLE yard_operation_records (
    record_id           VARCHAR(30) PRIMARY KEY COMMENT '作业记录号',
    operation_type      VARCHAR(20) NOT NULL COMMENT '作业类型(shift/land/pick/flip/inspect)',

    -- 集装箱信息
    container_id        VARCHAR(20) NOT NULL COMMENT '箱号',
    container_type      VARCHAR(10) COMMENT '箱型',

    -- 位置信息
    original_slot_id    VARCHAR(20) COMMENT '原堆位',
    target_slot_id      VARCHAR(20) COMMENT '目标堆位',

    -- 设备与人员
    equipment_id        VARCHAR(20) COMMENT '作业机械编号(岸桥/场桥)',
    equipment_type      VARCHAR(20) COMMENT '机械类型(QC/YC/RTG)',
    operator_name       VARCHAR(50) COMMENT '作业人员姓名',
    operator_id         VARCHAR(20) COMMENT '作业人员工号',

    -- 时间信息
    start_time          DATETIME COMMENT '作业开始时间',
    end_time            DATETIME COMMENT '作业结束时间',
    duration_minutes    INT COMMENT '作业时长(分钟)',

    -- 指令关联
    dispatch_order_id   VARCHAR(30) COMMENT '关联调度指令号',
    source_operation    VARCHAR(20) COMMENT '指令来源(sea_inbound/sea_outbound/land_inbound/land_outbound/dispatch)',

    -- 作业状态
    operation_status    VARCHAR(20) DEFAULT 'pending' COMMENT '作业状态(pending/in_progress/completed/cancelled)',
    completion_remark   TEXT COMMENT '作业完成备注',

    -- 成本核算
    operation_cost      DECIMAL(10,2) COMMENT '作业成本(元)',

    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (container_id) REFERENCES sea_inbound_containers(container_id),
    FOREIGN KEY (original_slot_id) REFERENCES yard_slots(slot_id),
    FOREIGN KEY (target_slot_id) REFERENCES yard_slots(slot_id)
) ENGINE=InnoDB COMMENT='堆场作业记录表(D8)';

-- ========================================================
-- 11. 核心数据类 D9: 场内调度指令信息
-- 关联过程: 场内作业计划/中控调度(C)、场内调箱/海侧陆侧进出箱作业(U)
-- ========================================================
CREATE TABLE dispatch_orders (
    order_id            VARCHAR(30) PRIMARY KEY COMMENT '指令号',
    order_type          VARCHAR(20) NOT NULL COMMENT '指令类型(sea_inbound/sea_outbound/land_inbound/land_outbound/yard_shift)',

    -- 时间信息
    issue_time          DATETIME NOT NULL COMMENT '下达时间',
    planned_finish_time DATETIME COMMENT '计划完成时间',
    actual_finish_time  DATETIME COMMENT '实际完成时间',

    -- 部门信息
    issue_dept          VARCHAR(50) COMMENT '下达部门(中控调度)',
    execute_dept        VARCHAR(50) COMMENT '执行部门(岸桥/场桥/闸口/内集卡班组)',

    -- 集装箱信息
    container_id        VARCHAR(20) COMMENT '箱号',
    container_type      VARCHAR(10) COMMENT '箱型',
    original_position   VARCHAR(20) COMMENT '原位置',
    target_position     VARCHAR(20) COMMENT '目标位置',

    -- 作业要求
    operation_requirement TEXT COMMENT '作业要求',
    priority_level      VARCHAR(10) DEFAULT 'normal' COMMENT '优先级(urgent/high/normal/low)',

    -- 执行状态
    execution_status    VARCHAR(20) DEFAULT 'issued' COMMENT '执行状态(issued/acknowledged/in_progress/completed/cancelled)',
    execution_progress  DECIMAL(5,2) DEFAULT 0 COMMENT '执行进度百分比',

    -- 关联计划
    related_plan_id     VARCHAR(30) COMMENT '关联作业计划号',
    related_ship_id     VARCHAR(20) COMMENT '关联船舶',

    -- 闭环管理
    completion_remark   TEXT COMMENT '完成备注',
    exception_reason    TEXT COMMENT '异常原因',

    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (container_id) REFERENCES sea_inbound_containers(container_id),
    FOREIGN KEY (related_ship_id) REFERENCES ships(ship_id)
) ENGINE=InnoDB COMMENT='场内调度指令信息表(D9)';

-- ========================================================
-- 12. 作业计划表 - 海侧作业计划
-- ========================================================
CREATE TABLE sea_operation_plans (
    plan_id             VARCHAR(30) PRIMARY KEY COMMENT '计划编号',
    plan_type           VARCHAR(20) NOT NULL COMMENT '计划类型(discharge/load)',
    voyage_no           VARCHAR(20) NOT NULL COMMENT '航次号',
    ship_id             VARCHAR(20) NOT NULL COMMENT '船舶编号',

    -- 时间计划
    planned_berth_time  DATETIME COMMENT '计划靠泊时间',
    planned_depart_time DATETIME COMMENT '计划离泊时间',
    actual_berth_time   DATETIME COMMENT '实际靠泊时间',
    actual_depart_time  DATETIME COMMENT '实际离泊时间',

    -- 箱量计划
    planned_inbound     INT DEFAULT 0 COMMENT '计划入场箱量',
    planned_outbound    INT DEFAULT 0 COMMENT '计划出场箱量',
    actual_inbound      INT DEFAULT 0 COMMENT '实际入场箱量',
    actual_outbound     INT DEFAULT 0 COMMENT '实际出场箱量',

    -- 资源配置
    assigned_quay_cranes VARCHAR(100) COMMENT '分配岸桥',
    assigned_yard_cranes VARCHAR(100) COMMENT '分配场桥',
    assigned_trucks     VARCHAR(100) COMMENT '分配内集卡',

    -- 进度与状态
    plan_status         VARCHAR(20) DEFAULT 'draft' COMMENT '计划状态(draft/approved/executing/completed/cancelled)',
    completion_rate     DECIMAL(5,2) DEFAULT 0 COMMENT '完成率',

    -- 关联数据类
    sea_io_record_id    VARCHAR(30) COMMENT '关联海侧码头出入场记录',

    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (ship_id) REFERENCES ships(ship_id)
) ENGINE=InnoDB COMMENT='海侧作业计划表';

-- ========================================================
-- 13. 作业计划表 - 陆侧作业计划
-- ========================================================
CREATE TABLE land_operation_plans (
    plan_id             VARCHAR(30) PRIMARY KEY COMMENT '计划编号',
    plan_type           VARCHAR(20) NOT NULL COMMENT '计划类型(inbound_outbound/inbound_delivery/outbound_export)',

    -- 时间计划
    planned_start_time  DATETIME COMMENT '计划开始时间',
    planned_end_time    DATETIME COMMENT '计划结束时间',
    actual_start_time   DATETIME COMMENT '实际开始时间',
    actual_end_time     DATETIME COMMENT '实际结束时间',

    -- 箱量计划
    planned_container_count INT DEFAULT 0 COMMENT '预计箱量',
    actual_container_count  INT DEFAULT 0 COMMENT '实际完成箱量',

    -- 闸口配置
    assigned_gate_lanes VARCHAR(50) COMMENT '分配闸口通道',

    -- 进度与状态
    plan_status         VARCHAR(20) DEFAULT 'draft' COMMENT '计划状态',
    completion_rate     DECIMAL(5,2) DEFAULT 0 COMMENT '完成率',

    -- 关联数据类
    gate_io_record_id   VARCHAR(30) COMMENT '关联闸口出入场记录',

    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='陆侧作业计划表';

-- ========================================================
-- 14. 用户与权限表
-- ========================================================
CREATE TABLE users (
    user_id             VARCHAR(20) PRIMARY KEY COMMENT '用户ID',
    username            VARCHAR(50) NOT NULL COMMENT '用户名',
    password_hash       VARCHAR(255) NOT NULL COMMENT '密码哈希',
    real_name           VARCHAR(50) COMMENT '真实姓名',
    role                VARCHAR(20) NOT NULL COMMENT '角色(admin/dispatcher/operator/gate_clerk/supervisor)',
    department          VARCHAR(50) COMMENT '所属部门',
    phone               VARCHAR(20) COMMENT '联系电话',
    email               VARCHAR(100) COMMENT '邮箱',
    status              VARCHAR(20) DEFAULT 'active' COMMENT '状态',
    last_login          DATETIME COMMENT '最后登录时间',
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='用户表';

-- ========================================================
-- 15. 系统日志表
-- ========================================================
CREATE TABLE system_logs (
    log_id              INT AUTO_INCREMENT PRIMARY KEY,
    log_type            VARCHAR(20) COMMENT '日志类型(operation/login/error/warning)',
    user_id             VARCHAR(20) COMMENT '操作用户',
    operation           VARCHAR(100) COMMENT '操作描述',
    table_name          VARCHAR(50) COMMENT '操作表名',
    record_id           VARCHAR(30) COMMENT '操作记录ID',
    old_value           TEXT COMMENT '修改前值',
    new_value           TEXT COMMENT '修改后值',
    ip_address          VARCHAR(50) COMMENT 'IP地址',
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='系统操作日志表';

-- ========================================================
-- 16. 异常告警表
-- ========================================================
CREATE TABLE alerts (
    alert_id            INT AUTO_INCREMENT PRIMARY KEY,
    alert_type          VARCHAR(30) COMMENT '告警类型(overdue/congestion/equipment/schedule)',
    alert_level         VARCHAR(10) COMMENT '告警级别(critical/warning/info)',
    alert_title         VARCHAR(200) COMMENT '告警标题',
    alert_content       TEXT COMMENT '告警内容',
    related_record_type VARCHAR(30) COMMENT '关联记录类型',
    related_record_id   VARCHAR(30) COMMENT '关联记录ID',
    is_resolved         BOOLEAN DEFAULT FALSE COMMENT '是否已处理',
    resolved_by         VARCHAR(20) COMMENT '处理人',
    resolved_time       DATETIME COMMENT '处理时间',
    resolution_remark   TEXT COMMENT '处理备注',
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='异常告警表';

-- ========================================================
-- 插入基础数据
-- ========================================================

-- 插入船舶数据
INSERT INTO ships (ship_id, ship_name, ship_type, ship_company, ship_length, ship_capacity) VALUES
('COSCO-2405', '中远海运白羊座', '集装箱船', '中远海运', 399.99, 20000),
('MAERSK-8821', '马士基浩南', '集装箱船', '马士基', 399.00, 18000),
('EVER-1803', '长荣海运', '集装箱船', '长荣海运', 368.00, 15000),
('MSC-0921', '地中海航运', '集装箱船', 'MSC', 350.00, 14000);

-- 插入堆场区域
INSERT INTO yard_zones (zone_id, zone_name, zone_type, total_slots, max_tier) VALUES
('A', 'A区-进口箱区', 'import', 576, 5),
('B', 'B区-出口箱区', 'export', 576, 5),
('C', 'C区-中转箱区', 'transit', 576, 5);

-- 插入用户数据
INSERT INTO users (user_id, username, password_hash, real_name, role, department) VALUES
('U001', 'dispatcher', '$2a$10$...', '中控调度员', 'dispatcher', '调度中心'),
('U002', 'gate_clerk', '$2a$10$...', '闸口管理员', 'gate_clerk', '闸口管理'),
('U003', 'yard_op', '$2a$10$...', '堆场管理员', 'operator', '堆场管理'),
('U004', 'admin', '$2a$10$...', '系统管理员', 'admin', '信息中心');

-- ========================================================
-- 创建视图 - 综合查询视图
-- ========================================================

-- 视图1: 场内集装箱综合视图
CREATE VIEW v_yard_container_full AS
SELECT 
    yci.container_id,
    yci.container_type,
    yci.container_status,
    yci.current_slot_id,
    ys.zone_id,
    yz.zone_name,
    yci.entry_time,
    yci.expected_exit_time,
    yci.dwell_time_hours,
    yci.is_overdue,
    yci.overdue_days,
    yci.alert_level,
    s.ship_name,
    s.ship_company,
    sic.manifest_info,
    sic.damage_status
FROM yard_container_inventory yci
LEFT JOIN yard_slots ys ON yci.current_slot_id = ys.slot_id
LEFT JOIN yard_zones yz ON ys.zone_id = yz.zone_id
LEFT JOIN ships s ON yci.ship_id = s.ship_id
LEFT JOIN sea_inbound_containers sic ON yci.container_id = sic.container_id;

-- 视图2: 今日作业汇总视图
CREATE VIEW v_today_operations AS
SELECT 
    '海侧进箱' as operation_type,
    COUNT(*) as count,
    SUM(CASE WHEN process_status = 'completed' THEN 1 ELSE 0 END) as completed
FROM sea_inbound_containers 
WHERE DATE(entry_time) = CURDATE()
UNION ALL
SELECT 
    '海侧出场' as operation_type,
    COUNT(*) as count,
    SUM(CASE WHEN process_status = 'completed' THEN 1 ELSE 0 END) as completed
FROM sea_outbound_containers 
WHERE DATE(exit_time) = CURDATE()
UNION ALL
SELECT 
    '陆侧进箱' as operation_type,
    COUNT(*) as count,
    SUM(CASE WHEN process_status = 'completed' THEN 1 ELSE 0 END) as completed
FROM land_inbound_containers 
WHERE DATE(entry_time) = CURDATE()
UNION ALL
SELECT 
    '陆侧出场' as operation_type,
    COUNT(*) as count,
    SUM(CASE WHEN process_status = 'completed' THEN 1 ELSE 0 END) as completed
FROM land_outbound_containers 
WHERE DATE(exit_time) = CURDATE();

-- 视图3: 堆场利用率视图
CREATE VIEW v_yard_utilization AS
SELECT 
    yz.zone_id,
    yz.zone_name,
    yz.zone_type,
    yz.total_slots,
    COUNT(CASE WHEN ys.slot_status = 'occupied' THEN 1 END) as occupied_count,
    COUNT(CASE WHEN ys.slot_status = 'empty' THEN 1 END) as empty_count,
    COUNT(CASE WHEN ys.slot_status = 'reserved' THEN 1 END) as reserved_count,
    COUNT(CASE WHEN ys.slot_status = 'maintenance' THEN 1 END) as maintenance_count,
    ROUND(COUNT(CASE WHEN ys.slot_status = 'occupied' THEN 1 END) * 100.0 / yz.total_slots, 2) as utilization_rate
FROM yard_zones yz
LEFT JOIN yard_slots ys ON yz.zone_id = ys.zone_id
GROUP BY yz.zone_id, yz.zone_name, yz.zone_type, yz.total_slots;

-- ========================================================
-- 创建存储过程
-- ========================================================

DELIMITER //

-- 存储过程1: 集装箱入场登记(海侧)
CREATE PROCEDURE sp_container_sea_inbound(
    IN p_container_id VARCHAR(20),
    IN p_container_type VARCHAR(10),
    IN p_ship_id VARCHAR(20),
    IN p_voyage_no VARCHAR(20),
    IN p_manifest_info VARCHAR(100),
    IN p_target_slot_id VARCHAR(20)
)
BEGIN
    DECLARE v_operation_id VARCHAR(30);
    SET v_operation_id = CONCAT('SI-', DATE_FORMAT(NOW(), '%Y%m%d'), '-', LPAD(FLOOR(RAND()*1000), 3, '0'));

    -- 插入海侧入场记录
    INSERT INTO sea_inbound_containers (
        container_id, container_type, ship_id, voyage_no, 
        manifest_info, target_slot_id, operation_id, process_status
    ) VALUES (
        p_container_id, p_container_type, p_ship_id, p_voyage_no,
        p_manifest_info, p_target_slot_id, v_operation_id, 'pending'
    );

    -- 插入场内台账
    INSERT INTO yard_container_inventory (
        container_id, container_type, current_slot_id, 
        ship_id, voyage_no, source_type, source_record_id
    ) VALUES (
        p_container_id, p_container_type, p_target_slot_id,
        p_ship_id, p_voyage_no, 'sea_inbound', v_operation_id
    );

    -- 更新箱位状态
    UPDATE yard_slots SET slot_status = 'reserved', current_container_id = p_container_id
    WHERE slot_id = p_target_slot_id;

    SELECT v_operation_id as operation_id;
END //

-- 存储过程2: 生成调度指令
CREATE PROCEDURE sp_create_dispatch_order(
    IN p_order_type VARCHAR(20),
    IN p_container_id VARCHAR(20),
    IN p_original_position VARCHAR(20),
    IN p_target_position VARCHAR(20),
    IN p_execute_dept VARCHAR(50),
    IN p_requirement TEXT
)
BEGIN
    DECLARE v_order_id VARCHAR(30);
    SET v_order_id = CONCAT('DI-', DATE_FORMAT(NOW(), '%Y%m%d'), '-', LPAD(FLOOR(RAND()*1000), 3, '0'));

    INSERT INTO dispatch_orders (
        order_id, order_type, issue_time, planned_finish_time,
        issue_dept, execute_dept, container_id, 
        original_position, target_position, operation_requirement
    ) VALUES (
        v_order_id, p_order_type, NOW(), DATE_ADD(NOW(), INTERVAL 30 MINUTE),
        '中控调度', p_execute_dept, p_container_id,
        p_original_position, p_target_position, p_requirement
    );

    SELECT v_order_id as order_id;
END //

-- 存储过程3: 完成作业并更新状态
CREATE PROCEDURE sp_complete_operation(
    IN p_record_id VARCHAR(30),
    IN p_operation_type VARCHAR(20)
)
BEGIN
    -- 更新作业记录状态
    UPDATE yard_operation_records 
    SET operation_status = 'completed', 
        end_time = NOW(),
        duration_minutes = TIMESTAMPDIFF(MINUTE, start_time, NOW())
    WHERE record_id = p_record_id;

    -- 根据作业类型更新相关表
    IF p_operation_type = 'sea_inbound' THEN
        UPDATE sea_inbound_containers SET process_status = 'completed' WHERE operation_id = p_record_id;
    ELSEIF p_operation_type = 'sea_outbound' THEN
        UPDATE sea_outbound_containers SET process_status = 'completed' WHERE operation_id = p_record_id;
    ELSEIF p_operation_type = 'land_inbound' THEN
        UPDATE land_inbound_containers SET process_status = 'completed' WHERE operation_id = p_record_id;
    ELSEIF p_operation_type = 'land_outbound' THEN
        UPDATE land_outbound_containers SET process_status = 'completed' WHERE operation_id = p_record_id;
    END IF;
END //

-- 存储过程4: 超期集装箱检查与告警
CREATE PROCEDURE sp_check_overdue_containers()
BEGIN
    -- 更新超期状态
    UPDATE yard_container_inventory
    SET is_overdue = TRUE,
        overdue_days = DATEDIFF(NOW(), expected_exit_time),
        alert_level = CASE 
            WHEN DATEDIFF(NOW(), expected_exit_time) > 7 THEN 'critical'
            WHEN DATEDIFF(NOW(), expected_exit_time) > 3 THEN 'warning'
            ELSE 'normal'
        END
    WHERE expected_exit_time < NOW() AND actual_exit_time IS NULL;

    -- 生成告警记录
    INSERT INTO alerts (alert_type, alert_level, alert_title, alert_content, related_record_type, related_record_id)
    SELECT 
        'overdue',
        CASE 
            WHEN overdue_days > 7 THEN 'critical'
            WHEN overdue_days > 3 THEN 'warning'
            ELSE 'info'
        END,
        CONCAT('集装箱超期滞留: ', container_id),
        CONCAT('箱号 ', container_id, ' 已超期 ', overdue_days, ' 天，当前位置: ', current_slot_id),
        'yard_container_inventory',
        container_id
    FROM yard_container_inventory
    WHERE is_overdue = TRUE AND overdue_days > 0
    AND container_id NOT IN (SELECT related_record_id FROM alerts WHERE alert_type = 'overdue' AND is_resolved = FALSE);
END //

DELIMITER ;

-- ========================================================
-- 创建触发器
-- ========================================================

-- 触发器1: 海侧入场记录插入时自动记录日志
DELIMITER //
CREATE TRIGGER trg_sea_inbound_insert_log
AFTER INSERT ON sea_inbound_containers
FOR EACH ROW
BEGIN
    INSERT INTO system_logs (log_type, operation, table_name, record_id, new_value)
    VALUES ('operation', '新增海侧进箱记录', 'sea_inbound_containers', NEW.container_id, 
            CONCAT('箱号:', NEW.container_id, ', 船名:', NEW.ship_id));
END //
DELIMITER ;

-- 触发器2: 调度指令状态变更时记录日志
DELIMITER //
CREATE TRIGGER trg_dispatch_update_log
AFTER UPDATE ON dispatch_orders
FOR EACH ROW
BEGIN
    IF OLD.execution_status != NEW.execution_status THEN
        INSERT INTO system_logs (log_type, operation, table_name, record_id, old_value, new_value)
        VALUES ('operation', '调度指令状态变更', 'dispatch_orders', NEW.order_id,
                OLD.execution_status, NEW.execution_status);
    END IF;
END //
DELIMITER ;

-- ========================================================
-- 创建索引优化
-- ========================================================

CREATE INDEX idx_sea_inbound_ship ON sea_inbound_containers(ship_id);
CREATE INDEX idx_sea_inbound_status ON sea_inbound_containers(process_status);
CREATE INDEX idx_sea_inbound_time ON sea_inbound_containers(entry_time);
CREATE INDEX idx_sea_outbound_ship ON sea_outbound_containers(ship_id);
CREATE INDEX idx_land_inbound_gate ON land_inbound_containers(truck_plate, entry_time);
CREATE INDEX idx_gate_io_time ON gate_io_records(entry_time, exit_time);
CREATE INDEX idx_yard_op_time ON yard_operation_records(start_time, end_time);
CREATE INDEX idx_dispatch_status ON dispatch_orders(execution_status);
CREATE INDEX idx_inventory_overdue ON yard_container_inventory(is_overdue, alert_level);

-- ========================================================
-- 数据完整性约束说明
-- ========================================================

/*
数据类与表的对应关系:
D1 海侧入场集装箱信息  -> sea_inbound_containers
D2 海侧出场集装箱信息  -> sea_outbound_containers  
D3 海侧码头出、入场信息 -> sea_terminal_io
D4 陆侧入场集装箱信息  -> land_inbound_containers
D5 陆侧出场集装箱信息  -> land_outbound_containers
D6 陆侧闸口出、入场信息 -> gate_io_records
D7 场内集装箱信息     -> yard_container_inventory
D8 堆场作业记录       -> yard_operation_records
D9 场内调度指令信息   -> dispatch_orders

过程与数据类关系(C=创建, U=使用):
海侧进箱作业: D1(C), D7(U), D9(U)
海侧出场作业: D2(C), D7(U), D9(U)
海侧作业计划: D3(C), D1(U), D2(U), D7(U), D9(U)
陆侧进箱作业: D4(C), D6(U), D7(U), D9(U)
陆侧出场作业: D5(C), D6(U), D7(U), D9(U)
陆侧作业计划: D6(C), D4(U), D5(U), D7(U), D9(U)
集装箱堆存日常管理: D7(C), D1(U), D2(U), D4(U), D5(U), D8(U), D9(U)
场内调箱作业: D8(C), D1(U), D2(U), D4(U), D5(U), D7(U), D9(U)
场内作业计划(中控): D9(C), D1(U), D2(U), D3(U), D4(U), D5(U), D6(U), D7(U), D8(U)
*/
