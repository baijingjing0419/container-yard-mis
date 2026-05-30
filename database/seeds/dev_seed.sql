-- ========================================================
-- 开发环境种子数据 — 繁忙码头快照
-- 2026-05-30 10:30: 5船在泊 / 200箱在场 / 74%利用率
-- ========================================================
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE users; TRUNCATE ships; TRUNCATE containers_master;
TRUNCATE sea_inbound_containers; TRUNCATE sea_outbound_containers; TRUNCATE sea_terminal_io;
TRUNCATE land_inbound_containers; TRUNCATE land_outbound_containers; TRUNCATE gate_io_records;
TRUNCATE yard_container_inventory; TRUNCATE yard_operation_records; TRUNCATE dispatch_orders;
TRUNCATE sea_operation_plans; TRUNCATE land_operation_plans;
TRUNCATE container_move_logs; TRUNCATE system_logs; TRUNCATE alerts;
UPDATE yard_slots SET slot_status='empty', current_container_id=NULL, version=0;

-- 1. 用户 (20人, 密码=123)
INSERT INTO users (user_id, username, password_hash, real_name, role, department, phone, email, status) VALUES
('5','admin','pbkdf2:sha256:100000$eb200bbb81328c4c1ae36744bf49ef40$3545f7c0a496beb85d6307dabb93605a885a508ec46ffea6d649af7aa42cf1f0','系统管理员','admin','信息中心','13800000005','admin@yard.local','active'),
('1','dispatcher','pbkdf2:sha256:100000$a4b5b5cb3800ab20bb3c71844710c9ac$c32e4e805279d2e5ca006b8ffc15cb9ac4072f278fb9a955673db74816f7a11a','李明','dispatcher','调度中心','13800000001','dispatcher@yard.local','active'),
('2','gate_clerk','pbkdf2:sha256:100000$91aa7141c2ee1c325ef5bdb502880478$ff4258bc012f4c676952507a69bb4b10fadf667ac9783cd84260c3a754c97e70','王芳','gate_clerk','闸口管理','13800000002','gate@yard.local','active'),
('3','qc_op','pbkdf2:sha256:100000$aba1cc89b7fab7f357f331642aba2564$098af06cdeadece719804f0798092a8420f280ff743c263d7463049fd65aa8d5','赵岸','qc_op','岸桥班组','13800000003','qc_op@yard.local','active'),
('4','yc_op','pbkdf2:sha256:100000$5fe13c29d0edcbbdd14d998887e7b965$210afc380ea7fcab3c346cb09df06bace17399267ccffe34c5fe0b05e8516a76','钱场','yc_op','场桥班组','13800000004','yc_op@yard.local','active'),
('10','chen','pbkdf2:sha256:100000$a4b5b5cb3800ab20bb3c71844710c9ac$c32e4e805279d2e5ca006b8ffc15cb9ac4072f278fb9a955673db74816f7a11a','陈调度','dispatcher','调度中心','13800000010','chen@yard.local','active'),
('11','liu','pbkdf2:sha256:100000$91aa7141c2ee1c325ef5bdb502880478$ff4258bc012f4c676952507a69bb4b10fadf667ac9783cd84260c3a754c97e70','刘闸口','gate_clerk','闸口管理','13800000011','liu@yard.local','active'),
('12','sun','pbkdf2:sha256:100000$aba1cc89b7fab7f357f331642aba2564$098af06cdeadece719804f0798092a8420f280ff743c263d7463049fd65aa8d5','孙岸桥','qc_op','岸桥班组','13800000012','sun@yard.local','active'),
('13','zhou','pbkdf2:sha256:100000$5fe13c29d0edcbbdd14d998887e7b965$210afc380ea7fcab3c346cb09df06bace17399267ccffe34c5fe0b05e8516a76','周场桥','yc_op','场桥班组','13800000013','zhou@yard.local','active'),
('20','wu','pbkdf2:sha256:100000$a4b5b5cb3800ab20bb3c71844710c9ac$c32e4e805279d2e5ca006b8ffc15cb9ac4072f278fb9a955673db74816f7a11a','吴调度','dispatcher','调度中心','13800000020','wu@yard.local','active'),
('21','zheng','pbkdf2:sha256:100000$91aa7141c2ee1c325ef5bdb502880478$ff4258bc012f4c676952507a69bb4b10fadf667ac9783cd84260c3a754c97e70','郑闸口','gate_clerk','闸口管理','13800000021','zheng@yard.local','active'),
('22','guo','pbkdf2:sha256:100000$aba1cc89b7fab7f357f331642aba2564$098af06cdeadece719804f0798092a8420f280ff743c263d7463049fd65aa8d5','郭岸桥','qc_op','岸桥班组','13800000022','guo@yard.local','active'),
('23','huang','pbkdf2:sha256:100000$5fe13c29d0edcbbdd14d998887e7b965$210afc380ea7fcab3c346cb09df06bace17399267ccffe34c5fe0b05e8516a76','黄场桥','yc_op','场桥班组','13800000023','huang@yard.local','active'),
('24','lin','pbkdf2:sha256:100000$5fe13c29d0edcbbdd14d998887e7b965$210afc380ea7fcab3c346cb09df06bace17399267ccffe34c5fe0b05e8516a76','林场桥','yc_op','场桥班组','13800000024','lin@yard.local','active'),
('25','xu','pbkdf2:sha256:100000$aba1cc89b7fab7f357f331642aba2564$098af06cdeadece719804f0798092a8420f280ff743c263d7463049fd65aa8d5','徐岸桥','qc_op','岸桥班组','13800000025','xu@yard.local','active');

-- 2. 船舶 (8艘, 5艘在泊)
INSERT INTO ships (ship_id, ship_name, ship_type, ship_company, ship_length, ship_capacity, status) VALUES
('COSCO-2405','中远海运白羊座','集装箱船','中远海运',399.99,20000,'active'),
('MAERSK-8821','马士基浩南','集装箱船','马士基',399.00,18000,'active'),
('EVER-1803','长荣海运','集装箱船','长荣海运',368.00,15000,'active'),
('MSC-0921','地中海航运','集装箱船','MSC',350.00,14000,'active'),
('ONE-0601','海洋网联','集装箱船','ONE',364.00,14500,'active'),
('HMM-0301','现代商船','集装箱船','HMM',340.00,13500,'active'),
('YML-0101','阳明海运','集装箱船','YANGMING',335.00,12000,'active'),
('HLC-0501','赫伯罗特','集装箱船','HAPAG-LLOYD',356.00,15500,'active');

-- 3. 集装箱主数据 (200箱)
INSERT INTO containers_master (container_id, container_type, tare_weight, owner_company, size_code) VALUES
('MAEU7000001','40GP',3055.0,'MAERSK','42G1'),
('CMAU7000002','20GP',3734.0,'CMA-CGM','22G1'),
('MAEU7000003','40HQ',3800.0,'MAERSK','45G1'),
('ZIMU7000004','40GP',2899.0,'ZIM','42G1'),
('ZIMU7000005','40GP',3701.0,'ZIM','42G1'),
('HLBU7000006','40GP',2938.0,'HAPAG-LLOYD','42G1'),
('COSU7000007','40GP',2253.0,'COSCO','42G1'),
('ONEE7000008','40HQ',2954.0,'ONE','45G1'),
('HLBU7000009','20GP',2697.0,'HAPAG-LLOYD','22G1'),
('YMLU7000010','40GP',2761.0,'YANGMING','42G1'),
('HMMU7000011','40GP',3999.0,'HMM','42G1'),
('CMAU7000012','20GP',2245.0,'CMA-CGM','22G1'),
('HMMU7000013','40HQ',3159.0,'HMM','45G1'),
('ONEE7000014','40GP',2969.0,'ONE','42G1'),
('ZIMU7000015','40GP',2147.0,'ZIM','42G1'),
('HMMU7000016','40GP',2976.0,'HMM','42G1'),
('MAEU7000017','40GP',3793.0,'MAERSK','42G1'),
('CMAU7000018','40GP',3748.0,'CMA-CGM','42G1'),
('YMLU7000019','40GP',3625.0,'YANGMING','42G1'),
('ZIMU7000020','40GP',2856.0,'ZIM','42G1'),
('CMAU7000021','40GP',3705.0,'CMA-CGM','42G1'),
('ZIMU7000022','40GP',3075.0,'ZIM','42G1'),
('COSU7000023','40GP',2527.0,'COSCO','42G1'),
('MSCU7000024','40HQ',3929.0,'MSC','45G1'),
('CMAU7000025','20GP',2295.0,'CMA-CGM','22G1'),
('ZIMU7000026','40GP',2993.0,'ZIM','42G1'),
('HLBU7000027','40HQ',3714.0,'HAPAG-LLOYD','45G1'),
('MAEU7000028','20GP',3431.0,'MAERSK','22G1'),
('HLBU7000029','20GP',3866.0,'HAPAG-LLOYD','22G1'),
('CMAU7000030','40GP',3164.0,'CMA-CGM','42G1'),
('ONEE7000031','40GP',3620.0,'ONE','42G1'),
('CMAU7000032','20GP',3010.0,'CMA-CGM','22G1'),
('YMLU7000033','40GP',2485.0,'YANGMING','42G1'),
('ONEE7000034','40HQ',2163.0,'ONE','45G1'),
('ZIMU7000035','40GP',3627.0,'ZIM','42G1'),
('HLBU7000036','40GP',3851.0,'HAPAG-LLOYD','42G1'),
('ONEE7000037','20GP',3023.0,'ONE','22G1'),
('CMAU7000038','40GP',3635.0,'CMA-CGM','42G1'),
('CMAU7000039','20GP',3824.0,'CMA-CGM','22G1'),
('ONEE7000040','40GP',2970.0,'ONE','42G1'),
('MAEU7000041','40GP',3410.0,'MAERSK','42G1'),
('CMAU7000042','40GP',2961.0,'CMA-CGM','42G1'),
('MSCU7000043','40GP',3701.0,'MSC','42G1'),
('HLBU7000044','40HQ',3332.0,'HAPAG-LLOYD','45G1'),
('HLBU7000045','40GP',2284.0,'HAPAG-LLOYD','42G1'),
('YMLU7000046','40HQ',2954.0,'YANGMING','45G1'),
('COSU7000047','40HQ',2100.0,'COSCO','45G1'),
('ZIMU7000048','40GP',3871.0,'ZIM','42G1'),
('MAEU7000049','40GP',3608.0,'MAERSK','42G1'),
('EISU7000050','40HQ',3280.0,'EVERGREEN','45G1'),
('CMAU7000051','40GP',3370.0,'CMA-CGM','42G1'),
('HMMU7000052','40HQ',2110.0,'HMM','45G1'),
('ZIMU7000053','40GP',3562.0,'ZIM','42G1'),
('HLBU7000054','20GP',3469.0,'HAPAG-LLOYD','22G1'),
('MSCU7000055','40GP',2524.0,'MSC','42G1'),
('ZIMU7000056','40HQ',3921.0,'ZIM','45G1'),
('CMAU7000057','40GP',2260.0,'CMA-CGM','42G1'),
('MSCU7000058','40HQ',3589.0,'MSC','45G1'),
('ZIMU7000059','40GP',3065.0,'ZIM','42G1'),
('YMLU7000060','40HQ',3088.0,'YANGMING','45G1'),
('EISU7000061','40GP',2127.0,'EVERGREEN','42G1'),
('MAEU7000062','40GP',3787.0,'MAERSK','42G1'),
('COSU7000063','40GP',3328.0,'COSCO','42G1'),
('COSU7000064','40HQ',3070.0,'COSCO','45G1'),
('HMMU7000065','20GP',2677.0,'HMM','22G1'),
('HMMU7000066','40HQ',3045.0,'HMM','45G1'),
('HLBU7000067','40GP',3275.0,'HAPAG-LLOYD','42G1'),
('MSCU7000068','40HQ',3223.0,'MSC','45G1'),
('EISU7000069','40GP',3284.0,'EVERGREEN','42G1'),
('HLBU7000070','40GP',2543.0,'HAPAG-LLOYD','42G1'),
('MAEU7000071','40GP',2858.0,'MAERSK','42G1'),
('EISU7000072','20GP',3851.0,'EVERGREEN','22G1'),
('COSU7000073','20GP',3135.0,'COSCO','22G1'),
('COSU7000074','40GP',3749.0,'COSCO','42G1'),
('EISU7000075','40GP',3451.0,'EVERGREEN','42G1'),
('COSU7000076','40HQ',3327.0,'COSCO','45G1'),
('EISU7000077','40GP',3800.0,'EVERGREEN','42G1'),
('MSCU7000078','40HQ',3356.0,'MSC','45G1'),
('MSCU7000079','40GP',2618.0,'MSC','42G1'),
('CMAU7000080','40GP',3749.0,'CMA-CGM','42G1'),
('YMLU7000081','40GP',2456.0,'YANGMING','42G1'),
('MSCU7000082','40GP',2981.0,'MSC','42G1'),
('YMLU7000083','40GP',2989.0,'YANGMING','42G1'),
('HMMU7000084','40GP',3016.0,'HMM','42G1'),
('MAEU7000085','40GP',3614.0,'MAERSK','42G1'),
('ONEE7000086','40HQ',3711.0,'ONE','45G1'),
('EISU7000087','40HQ',3912.0,'EVERGREEN','45G1'),
('HLBU7000088','20GP',2728.0,'HAPAG-LLOYD','22G1'),
('CMAU7000089','20GP',2447.0,'CMA-CGM','22G1'),
('COSU7000090','40GP',3708.0,'COSCO','42G1'),
('HMMU7000091','40GP',3406.0,'HMM','42G1'),
('CMAU7000092','40HQ',2308.0,'CMA-CGM','45G1'),
('ONEE7000093','40GP',3527.0,'ONE','42G1'),
('EISU7000094','40GP',2660.0,'EVERGREEN','42G1'),
('ONEE7000095','20GP',3156.0,'ONE','22G1'),
('MAEU7000096','40GP',2283.0,'MAERSK','42G1'),
('YMLU7000097','40HQ',2301.0,'YANGMING','45G1'),
('COSU7000098','40GP',3472.0,'COSCO','42G1'),
('MSCU7000099','20GP',3297.0,'MSC','22G1'),
('CMAU7000100','40GP',2626.0,'CMA-CGM','42G1'),
('MAEU7000101','40GP',3870.0,'MAERSK','42G1'),
('MSCU7000102','40GP',2587.0,'MSC','42G1'),
('COSU7000103','40GP',3746.0,'COSCO','42G1'),
('ONEE7000104','40GP',3934.0,'ONE','42G1'),
('COSU7000105','40HQ',2547.0,'COSCO','45G1'),
('ONEE7000106','40HQ',2278.0,'ONE','45G1'),
('CMAU7000107','40GP',3977.0,'CMA-CGM','42G1'),
('HMMU7000108','40GP',3582.0,'HMM','42G1'),
('ZIMU7000109','20GP',3344.0,'ZIM','22G1'),
('ZIMU7000110','40HQ',3857.0,'ZIM','45G1'),
('HMMU7000111','40GP',2510.0,'HMM','42G1'),
('HLBU7000112','40GP',3960.0,'HAPAG-LLOYD','42G1'),
('MAEU7000113','20GP',2811.0,'MAERSK','22G1'),
('CMAU7000114','20GP',3951.0,'CMA-CGM','22G1'),
('ONEE7000115','40GP',2655.0,'ONE','42G1'),
('HMMU7000116','40HQ',3497.0,'HMM','45G1'),
('YMLU7000117','40HQ',2635.0,'YANGMING','45G1'),
('HMMU7000118','40GP',3482.0,'HMM','42G1'),
('MAEU7000119','40GP',3559.0,'MAERSK','42G1'),
('HMMU7000120','40GP',3816.0,'HMM','42G1'),
('CMAU7000121','40GP',2475.0,'CMA-CGM','42G1'),
('COSU7000122','20GP',3995.0,'COSCO','22G1'),
('MSCU7000123','40GP',2333.0,'MSC','42G1'),
('COSU7000124','40HQ',3093.0,'COSCO','45G1'),
('ZIMU7000125','20GP',3949.0,'ZIM','22G1'),
('ONEE7000126','40HQ',2907.0,'ONE','45G1'),
('MSCU7000127','40GP',2889.0,'MSC','42G1'),
('YMLU7000128','40HQ',3576.0,'YANGMING','45G1'),
('EISU7000129','40HQ',2449.0,'EVERGREEN','45G1'),
('COSU7000130','20GP',3463.0,'COSCO','22G1'),
('CMAU7000131','20GP',3154.0,'CMA-CGM','22G1'),
('ONEE7000132','40HQ',2534.0,'ONE','45G1'),
('COSU7000133','40GP',3128.0,'COSCO','42G1'),
('YMLU7000134','40GP',3921.0,'YANGMING','42G1'),
('MSCU7000135','20GP',3228.0,'MSC','22G1'),
('MSCU7000136','40GP',2172.0,'MSC','42G1'),
('CMAU7000137','40GP',2747.0,'CMA-CGM','42G1'),
('CMAU7000138','20GP',2703.0,'CMA-CGM','22G1'),
('COSU7000139','20GP',3958.0,'COSCO','22G1'),
('HLBU7000140','40HQ',3943.0,'HAPAG-LLOYD','45G1'),
('CMAU7000141','40HQ',3862.0,'CMA-CGM','45G1'),
('YMLU7000142','20GP',3955.0,'YANGMING','22G1'),
('EISU7000143','40GP',3675.0,'EVERGREEN','42G1'),
('HMMU7000144','40HQ',2812.0,'HMM','45G1'),
('HLBU7000145','20GP',2969.0,'HAPAG-LLOYD','22G1'),
('HLBU7000146','20GP',3203.0,'HAPAG-LLOYD','22G1'),
('EISU7000147','40HQ',3293.0,'EVERGREEN','45G1'),
('MSCU7000148','40GP',3798.0,'MSC','42G1'),
('HMMU7000149','40GP',3434.0,'HMM','42G1'),
('COSU7000150','20GP',2428.0,'COSCO','22G1'),
('ONEE7000151','40GP',3139.0,'ONE','42G1'),
('ONEE7000152','40HQ',3458.0,'ONE','45G1'),
('MAEU7000153','40HQ',3113.0,'MAERSK','45G1'),
('ZIMU7000154','40GP',3188.0,'ZIM','42G1'),
('YMLU7000155','40GP',3124.0,'YANGMING','42G1'),
('CMAU7000156','20GP',3357.0,'CMA-CGM','22G1'),
('CMAU7000157','40HQ',2263.0,'CMA-CGM','45G1'),
('YMLU7000158','40GP',3140.0,'YANGMING','42G1'),
('ONEE7000159','40HQ',3501.0,'ONE','45G1'),
('EISU7000160','40HQ',3808.0,'EVERGREEN','45G1'),
('ONEE7000161','40GP',2643.0,'ONE','42G1'),
('MSCU7000162','40GP',2459.0,'MSC','42G1'),
('COSU7000163','40GP',3331.0,'COSCO','42G1'),
('YMLU7000164','40GP',3643.0,'YANGMING','42G1'),
('CMAU7000165','40HQ',3472.0,'CMA-CGM','45G1'),
('COSU7000166','40HQ',2698.0,'COSCO','45G1'),
('MSCU7000167','40HQ',2154.0,'MSC','45G1'),
('MAEU7000168','40GP',3369.0,'MAERSK','42G1'),
('COSU7000169','40GP',2221.0,'COSCO','42G1'),
('ONEE7000170','40HQ',3111.0,'ONE','45G1'),
('ZIMU7000171','40GP',2571.0,'ZIM','42G1'),
('MAEU7000172','40GP',3021.0,'MAERSK','42G1'),
('MAEU7000173','40GP',2599.0,'MAERSK','42G1'),
('ONEE7000174','20GP',2323.0,'ONE','22G1'),
('HLBU7000175','40GP',2330.0,'HAPAG-LLOYD','42G1'),
('CMAU7000176','40HQ',3674.0,'CMA-CGM','45G1'),
('HLBU7000177','40GP',2756.0,'HAPAG-LLOYD','42G1'),
('MAEU7000178','40HQ',3636.0,'MAERSK','45G1'),
('ONEE7000179','40GP',3531.0,'ONE','42G1'),
('EISU7000180','40HQ',2718.0,'EVERGREEN','45G1'),
('CMAU7000181','40GP',2730.0,'CMA-CGM','42G1'),
('HLBU7000182','40GP',2696.0,'HAPAG-LLOYD','42G1'),
('EISU7000183','40GP',2518.0,'EVERGREEN','42G1'),
('HMMU7000184','40GP',2878.0,'HMM','42G1'),
('ZIMU7000185','40GP',2504.0,'ZIM','42G1'),
('HLBU7000186','20GP',3176.0,'HAPAG-LLOYD','22G1'),
('MSCU7000187','40GP',2608.0,'MSC','42G1'),
('MAEU7000188','40GP',2606.0,'MAERSK','42G1'),
('HLBU7000189','40GP',2376.0,'HAPAG-LLOYD','42G1'),
('ONEE7000190','40HQ',2730.0,'ONE','45G1'),
('MSCU7000191','40GP',3568.0,'MSC','42G1'),
('ONEE7000192','40GP',3191.0,'ONE','42G1'),
('YMLU7000193','40GP',2141.0,'YANGMING','42G1'),
('HMMU7000194','20GP',2878.0,'HMM','22G1'),
('MAEU7000195','20GP',3558.0,'MAERSK','22G1'),
('HLBU7000196','20GP',3710.0,'HAPAG-LLOYD','22G1'),
('CMAU7000197','40GP',2499.0,'CMA-CGM','42G1'),
('HMMU7000198','20GP',2728.0,'HMM','22G1'),
('YMLU7000199','20GP',2429.0,'YANGMING','22G1'),
('ONEE7000200','40GP',3433.0,'ONE','42G1');

-- 4. 海侧进箱 (80箱)
INSERT INTO sea_inbound_containers (container_id, container_type, container_status, ship_id, voyage_no, manifest_info, target_slot_id, actual_slot_id, process_status) VALUES
('MAEU7000001','40GP','intact','COSCO-2405','V2405','BL-XXX-001','A-13-01','A-13-01','landed'),
('CMAU7000002','20GP','intact','COSCO-2405','V2405','BL-XXX-002','A-02-04','A-02-04','landed'),
('MAEU7000003','40HQ','intact','COSCO-2405','V2405','BL-XXX-003','A-04-06','A-04-06','landed'),
('ZIMU7000004','40GP','intact','COSCO-2405','V2405','BL-XXX-004','A-07-04','A-07-04','landed'),
('ZIMU7000005','40GP','intact','COSCO-2405','V2405','BL-XXX-005','A-02-02','A-02-02','landed'),
('HLBU7000006','40GP','intact','COSCO-2405','V2405','BL-XXX-006','A-13-04','A-13-04','landed'),
('COSU7000007','40GP','intact','COSCO-2405','V2405','BL-XXX-007','A-05-02','A-05-02','landed'),
('ONEE7000008','40HQ','intact','COSCO-2405','V2405','BL-XXX-008','A-10-06','A-10-06','landed'),
('HLBU7000009','20GP','intact','COSCO-2405','V2405','BL-XXX-009','A-04-01','A-04-01','landed'),
('YMLU7000010','40GP','intact','COSCO-2405','V2405','BL-XXX-010','A-12-06','A-12-06','landed'),
('HMMU7000011','40GP','intact','COSCO-2405','V2405','BL-XXX-011','A-12-04','A-12-04','landed'),
('CMAU7000012','20GP','intact','COSCO-2405','V2405','BL-XXX-012','A-15-06','A-15-06','landed'),
('HMMU7000013','40HQ','intact','COSCO-2405','V2405','BL-XXX-013','A-06-02','A-06-02','landed'),
('ONEE7000014','40GP','intact','COSCO-2405','V2405','BL-XXX-014','A-09-05','A-09-05','landed'),
('ZIMU7000015','40GP','intact','COSCO-2405','V2405','BL-XXX-015','A-01-04','A-01-04','landed'),
('HMMU7000016','40GP','intact','COSCO-2405','V2405','BL-XXX-016','A-08-05','A-08-05','landed'),
('MAEU7000017','40GP','intact','COSCO-2405','V2405','BL-XXX-017','A-12-02','A-12-02','landed'),
('CMAU7000018','40GP','intact','COSCO-2405','V2405','BL-XXX-018','A-10-04','A-10-04','landed'),
('YMLU7000019','40GP','intact','COSCO-2405','V2405','BL-XXX-019','A-09-04','A-09-04','landed'),
('ZIMU7000020','40GP','intact','COSCO-2405','V2405','BL-XXX-020','A-01-01','A-01-01','landed'),
('CMAU7000021','40GP','intact','COSCO-2405','V2405','BL-XXX-021','A-14-02','A-14-02','landed'),
('ZIMU7000022','40GP','intact','COSCO-2405','V2405','BL-XXX-022','A-07-05','A-07-05','landed'),
('COSU7000023','40GP','intact','COSCO-2405','V2405','BL-XXX-023','A-04-03','A-04-03','landed'),
('MSCU7000024','40HQ','intact','COSCO-2405','V2405','BL-XXX-024','A-11-04','A-11-04','landed'),
('CMAU7000025','20GP','intact','COSCO-2405','V2405','BL-XXX-025','A-05-04','A-05-04','landed'),
('ZIMU7000026','40GP','intact','COSCO-2405','V2405','BL-XXX-026','A-13-05','A-13-05','landed'),
('HLBU7000027','40HQ','intact','COSCO-2405','V2405','BL-XXX-027','A-15-02','A-15-02','landed'),
('MAEU7000028','20GP','intact','COSCO-2405','V2405','BL-XXX-028','A-08-03','A-08-03','landed'),
('HLBU7000029','20GP','intact','COSCO-2405','V2405','BL-XXX-029','A-13-06','A-13-06','landed'),
('CMAU7000030','40GP','intact','COSCO-2405','V2405','BL-XXX-030','A-15-01','A-15-01','landed'),
('ONEE7000031','40GP','intact','COSCO-2405','V2405','BL-XXX-031','A-10-02','A-10-02','landed'),
('CMAU7000032','20GP','intact','COSCO-2405','V2405','BL-XXX-032','A-04-05','A-04-05','landed'),
('YMLU7000033','40GP','intact','COSCO-2405','V2405','BL-XXX-033','A-09-01','A-09-01','landed'),
('ONEE7000034','40HQ','intact','COSCO-2405','V2405','BL-XXX-034','A-04-04','A-04-04','landed'),
('ZIMU7000035','40GP','intact','COSCO-2405','V2405','BL-XXX-035','A-06-01','A-06-01','landed'),
('HLBU7000036','40GP','intact','COSCO-2405','V2405','BL-XXX-036','A-15-03','A-15-03','landed'),
('ONEE7000037','20GP','intact','COSCO-2405','V2405','BL-XXX-037','A-06-03','A-06-03','landed'),
('CMAU7000038','40GP','intact','COSCO-2405','V2405','BL-XXX-038','A-09-02','A-09-02','landed'),
('CMAU7000039','20GP','intact','COSCO-2405','V2405','BL-XXX-039','A-02-06','A-02-06','landed'),
('ONEE7000040','40GP','intact','COSCO-2405','V2405','BL-XXX-040','A-15-04','A-15-04','landed'),
('MAEU7000041','40GP','intact','COSCO-2405','V2405','BL-XXX-041','A-09-03','A-09-03','landed'),
('CMAU7000042','40GP','intact','COSCO-2405','V2405','BL-XXX-042','A-03-06','A-03-06','landed'),
('MSCU7000043','40GP','intact','COSCO-2405','V2405','BL-XXX-043','A-12-01','A-12-01','landed'),
('HLBU7000044','40HQ','intact','COSCO-2405','V2405','BL-XXX-044','A-02-01','A-02-01','landed'),
('HLBU7000045','40GP','intact','COSCO-2405','V2405','BL-XXX-045','A-02-03','A-02-03','landed'),
('YMLU7000046','40HQ','intact','EVER-1803','V1803','BL-XXX-046','A-12-05','A-12-05','landed'),
('COSU7000047','40HQ','intact','EVER-1803','V1803','BL-XXX-047','A-07-02','A-07-02','landed'),
('ZIMU7000048','40GP','intact','EVER-1803','V1803','BL-XXX-048','A-10-03','A-10-03','landed'),
('MAEU7000049','40GP','intact','EVER-1803','V1803','BL-XXX-049','A-06-04','A-06-04','landed'),
('EISU7000050','40HQ','intact','EVER-1803','V1803','BL-XXX-050','A-10-01','A-10-01','landed'),
('CMAU7000051','40GP','intact','EVER-1803','V1803','BL-XXX-051','A-13-02','A-13-02','landed'),
('HMMU7000052','40HQ','intact','EVER-1803','V1803','BL-XXX-052','A-07-01','A-07-01','landed'),
('ZIMU7000053','40GP','intact','EVER-1803','V1803','BL-XXX-053','A-01-06','A-01-06','landed'),
('HLBU7000054','20GP','intact','EVER-1803','V1803','BL-XXX-054','A-11-05','A-11-05','landed'),
('MSCU7000055','40GP','intact','EVER-1803','V1803','BL-XXX-055','A-08-04','A-08-04','landed'),
('ZIMU7000056','40HQ','intact','EVER-1803','V1803','BL-XXX-056','A-12-03','A-12-03','landed'),
('CMAU7000057','40GP','intact','EVER-1803','V1803','BL-XXX-057','A-14-04','A-14-04','landed'),
('MSCU7000058','40HQ','intact','EVER-1803','V1803','BL-XXX-058','A-07-03','A-07-03','landed'),
('ZIMU7000059','40GP','intact','EVER-1803','V1803','BL-XXX-059','A-03-02','A-03-02','landed'),
('YMLU7000060','40HQ','intact','EVER-1803','V1803','BL-XXX-060','A-05-06','A-05-06','landed'),
('EISU7000061','40GP','intact','EVER-1803','V1803','BL-XXX-061','A-14-06','A-14-06','landed'),
('MAEU7000062','40GP','intact','EVER-1803','V1803','BL-XXX-062','A-03-03','A-03-03','landed'),
('COSU7000063','40GP','intact','EVER-1803','V1803','BL-XXX-063','A-11-03','A-11-03','landed'),
('COSU7000064','40HQ','intact','EVER-1803','V1803','BL-XXX-064','A-15-05','A-15-05','landed'),
('HMMU7000065','20GP','intact','EVER-1803','V1803','BL-XXX-065','A-04-02','A-04-02','landed'),
('HMMU7000066','40HQ','intact','EVER-1803','V1803','BL-XXX-066','A-03-01','A-03-01','landed'),
('HLBU7000067','40GP','intact','EVER-1803','V1803','BL-XXX-067','A-14-03','A-14-03','landed'),
('MSCU7000068','40HQ','intact','EVER-1803','V1803','BL-XXX-068','A-05-01','A-05-01','landed'),
('EISU7000069','40GP','intact','EVER-1803','V1803','BL-XXX-069','A-02-05','A-02-05','landed'),
('HLBU7000070','40GP','intact','EVER-1803','V1803','BL-XXX-070','A-08-06','A-08-06','landed'),
('MAEU7000071','40GP','intact','EVER-1803','V1803','BL-XXX-071','A-06-06','A-06-06','landed'),
('EISU7000072','20GP','intact','EVER-1803','V1803','BL-XXX-072','A-11-06','A-11-06','landed'),
('COSU7000073','20GP','intact','EVER-1803','V1803','BL-XXX-073','A-10-05','A-10-05','landed'),
('COSU7000074','40GP','intact','EVER-1803','V1803','BL-XXX-074','A-05-03','A-05-03','landed'),
('EISU7000075','40GP','intact','EVER-1803','V1803','BL-XXX-075','A-01-03','A-01-03','landed'),
('COSU7000076','40HQ','intact','EVER-1803','V1803','BL-XXX-076','A-07-06','A-07-06','landed'),
('EISU7000077','40GP','intact','EVER-1803','V1803','BL-XXX-077','A-06-05','A-06-05','landed'),
('MSCU7000078','40HQ','intact','EVER-1803','V1803','BL-XXX-078','A-03-04','A-03-04','landed'),
('MSCU7000079','40GP','intact','EVER-1803','V1803','BL-XXX-079','A-05-05','A-05-05','landed'),
('CMAU7000080','40GP','intact','EVER-1803','V1803','BL-XXX-080','A-01-05','A-01-05','landed');

-- 5. 陆侧进箱 (75箱)
INSERT INTO land_inbound_containers (container_id, container_type, container_status, truck_plate, driver_name, document_no, ship_id, target_slot_id, actual_slot_id, damage_check, process_status) VALUES
('YMLU7000081','40GP','intact','HUA5523','孙明','DOC-E001','EVER-1803','B-11-05','B-11-05','完好','landed'),
('MSCU7000082','40GP','intact','HUA1609','李强','DOC-E002','EVER-1803','B-09-03','B-09-03','完好','landed'),
('YMLU7000083','40GP','intact','HUA1686','李强','DOC-E003','EVER-1803','B-11-01','B-11-01','完好','landed'),
('HMMU7000084','40GP','intact','HUA9644','吴斌','DOC-E004','EVER-1803','B-13-04','B-13-04','完好','landed'),
('MAEU7000085','40GP','intact','HUA2782','周峰','DOC-E005','EVER-1803','B-08-06','B-08-06','完好','landed'),
('ONEE7000086','40HQ','intact','HUA8486','陈涛','DOC-E006','EVER-1803','B-02-05','B-02-05','完好','landed'),
('EISU7000087','40HQ','intact','HUA8841','郑浩','DOC-E007','EVER-1803','B-05-06','B-05-06','完好','landed'),
('HLBU7000088','20GP','intact','HUA1359','王磊','DOC-E008','EVER-1803','B-10-03','B-10-03','完好','landed'),
('CMAU7000089','20GP','intact','HUA6216','王磊','DOC-E009','EVER-1803','B-02-01','B-02-01','完好','landed'),
('COSU7000090','40GP','intact','HUA1435','李强','DOC-E010','EVER-1803','B-02-02','B-02-02','完好','landed'),
('HMMU7000091','40GP','intact','HUA7419','李强','DOC-E011','EVER-1803','B-04-04','B-04-04','完好','landed'),
('CMAU7000092','40HQ','intact','HUA3755','郑浩','DOC-E012','EVER-1803','B-04-01','B-04-01','完好','landed'),
('ONEE7000093','40GP','intact','HUA5177','张伟','DOC-E013','EVER-1803','B-11-02','B-11-02','完好','landed'),
('EISU7000094','40GP','intact','HUA1756','李强','DOC-E014','EVER-1803','B-13-06','B-13-06','完好','landed'),
('ONEE7000095','20GP','intact','HUA9533','李强','DOC-E015','EVER-1803','B-07-02','B-07-02','完好','landed'),
('MAEU7000096','40GP','intact','HUA6487','王磊','DOC-E016','EVER-1803','B-15-01','B-15-01','完好','landed'),
('YMLU7000097','40HQ','intact','HUA6030','吴斌','DOC-E017','EVER-1803','B-01-01','B-01-01','完好','landed'),
('COSU7000098','40GP','intact','HUA4965','钱勇','DOC-E018','EVER-1803','B-03-04','B-03-04','完好','landed'),
('MSCU7000099','20GP','intact','HUA8678','赵刚','DOC-E019','EVER-1803','B-13-02','B-13-02','完好','landed'),
('CMAU7000100','40GP','intact','HUA7554','赵刚','DOC-E020','EVER-1803','B-12-03','B-12-03','完好','landed'),
('MAEU7000101','40GP','intact','HUA9422','钱勇','DOC-E021','EVER-1803','B-09-05','B-09-05','完好','landed'),
('MSCU7000102','40GP','intact','HUA7862','张伟','DOC-E022','EVER-1803','B-01-02','B-01-02','完好','landed'),
('COSU7000103','40GP','intact','HUA9011','赵刚','DOC-E023','EVER-1803','B-05-05','B-05-05','完好','landed'),
('ONEE7000104','40GP','intact','HUA4019','吴斌','DOC-E024','EVER-1803','B-05-01','B-05-01','完好','landed'),
('COSU7000105','40HQ','intact','HUA4090','李强','DOC-E025','EVER-1803','B-01-06','B-01-06','完好','landed'),
('ONEE7000106','40HQ','intact','HUA8803','陈涛','DOC-E026','EVER-1803','B-03-03','B-03-03','完好','landed'),
('CMAU7000107','40GP','intact','HUA7252','吴斌','DOC-E027','EVER-1803','B-01-05','B-01-05','完好','landed'),
('HMMU7000108','40GP','intact','HUA9682','张伟','DOC-E028','EVER-1803','B-06-04','B-06-04','完好','landed'),
('ZIMU7000109','20GP','intact','HUA9174','赵刚','DOC-E029','EVER-1803','B-14-01','B-14-01','完好','landed'),
('ZIMU7000110','40HQ','intact','HUA7303','张伟','DOC-E030','EVER-1803','B-12-05','B-12-05','完好','landed'),
('HMMU7000111','40GP','intact','HUA9675','吴斌','DOC-E031','EVER-1803','B-12-04','B-12-04','完好','landed'),
('HLBU7000112','40GP','intact','HUA3298','孙明','DOC-E032','EVER-1803','B-08-01','B-08-01','完好','landed'),
('MAEU7000113','20GP','intact','HUA4949','郑浩','DOC-E033','EVER-1803','B-09-01','B-09-01','完好','landed'),
('CMAU7000114','20GP','intact','HUA6142','孙明','DOC-E034','EVER-1803','B-02-06','B-02-06','完好','landed'),
('ONEE7000115','40GP','intact','HUA8073','陈涛','DOC-E035','EVER-1803','B-04-02','B-04-02','完好','landed'),
('HMMU7000116','40HQ','intact','HUA1430','钱勇','DOC-E036','EVER-1803','B-03-06','B-03-06','完好','landed'),
('YMLU7000117','40HQ','intact','HUA9519','王磊','DOC-E037','EVER-1803','B-01-03','B-01-03','完好','landed'),
('HMMU7000118','40GP','intact','HUA9689','李强','DOC-E038','EVER-1803','B-14-02','B-14-02','完好','landed'),
('MAEU7000119','40GP','intact','HUA7037','赵刚','DOC-E039','EVER-1803','B-07-01','B-07-01','完好','landed'),
('HMMU7000120','40GP','intact','HUA2244','郑浩','DOC-E040','EVER-1803','B-10-05','B-10-05','完好','landed'),
('CMAU7000121','40GP','intact','HUA3786','吴斌','DOC-E041','EVER-1803','B-09-04','B-09-04','完好','landed'),
('COSU7000122','20GP','intact','HUA7642','李强','DOC-E042','EVER-1803','B-08-03','B-08-03','完好','landed'),
('MSCU7000123','40GP','intact','HUA2731','周峰','DOC-E043','EVER-1803','B-10-04','B-10-04','完好','landed'),
('COSU7000124','40HQ','intact','HUA7568','张伟','DOC-E044','EVER-1803','B-07-03','B-07-03','完好','landed'),
('ZIMU7000125','20GP','intact','HUA5002','赵刚','DOC-E045','EVER-1803','B-14-03','B-14-03','完好','landed'),
('ONEE7000126','40HQ','intact','HUA1837','孙明','DOC-E046','EVER-1803','B-03-01','B-03-01','完好','landed'),
('MSCU7000127','40GP','intact','HUA3768','郑浩','DOC-E047','EVER-1803','B-15-02','B-15-02','完好','landed'),
('YMLU7000128','40HQ','intact','HUA5364','钱勇','DOC-E048','EVER-1803','B-14-05','B-14-05','完好','landed'),
('EISU7000129','40HQ','intact','HUA2385','孙明','DOC-E049','EVER-1803','B-07-04','B-07-04','完好','landed'),
('COSU7000130','20GP','intact','HUA3746','张伟','DOC-E050','EVER-1803','B-11-04','B-11-04','完好','landed'),
('CMAU7000131','20GP','intact','HUA4580','郑浩','DOC-E051','EVER-1803','B-05-02','B-05-02','完好','landed'),
('ONEE7000132','40HQ','intact','HUA2895','吴斌','DOC-E052','EVER-1803','B-15-03','B-15-03','完好','landed'),
('COSU7000133','40GP','intact','HUA1582','钱勇','DOC-E053','EVER-1803','B-14-04','B-14-04','完好','landed'),
('YMLU7000134','40GP','intact','HUA8650','郑浩','DOC-E054','EVER-1803','B-04-03','B-04-03','完好','landed'),
('MSCU7000135','20GP','intact','HUA1567','赵刚','DOC-E055','EVER-1803','B-15-04','B-15-04','完好','landed'),
('MSCU7000136','40GP','intact','HUA8888','张伟','DOC-E056','EVER-1803','B-09-06','B-09-06','完好','landed'),
('CMAU7000137','40GP','intact','HUA5772','李强','DOC-E057','EVER-1803','B-14-06','B-14-06','完好','landed'),
('CMAU7000138','20GP','intact','HUA3758','李强','DOC-E058','EVER-1803','B-06-06','B-06-06','完好','landed'),
('COSU7000139','20GP','intact','HUA5573','赵刚','DOC-E059','EVER-1803','B-02-03','B-02-03','完好','landed'),
('HLBU7000140','40HQ','intact','HUA1119','孙明','DOC-E060','EVER-1803','B-06-02','B-06-02','完好','landed'),
('CMAU7000141','40HQ','intact','HUA1714','吴斌','DOC-E061','EVER-1803','B-08-04','B-08-04','完好','landed'),
('YMLU7000142','20GP','intact','HUA5249','李强','DOC-E062','EVER-1803','B-10-02','B-10-02','完好','landed'),
('EISU7000143','40GP','intact','HUA9954','王磊','DOC-E063','EVER-1803','B-13-03','B-13-03','完好','landed'),
('HMMU7000144','40HQ','intact','HUA9969','郑浩','DOC-E064','EVER-1803','B-06-05','B-06-05','完好','landed'),
('HLBU7000145','20GP','intact','HUA9850','赵刚','DOC-E065','EVER-1803','B-13-01','B-13-01','完好','landed'),
('HLBU7000146','20GP','intact','HUA9114','张伟','DOC-E066','EVER-1803','B-03-05','B-03-05','完好','landed'),
('EISU7000147','40HQ','intact','HUA9874','钱勇','DOC-E067','EVER-1803','B-15-06','B-15-06','完好','landed'),
('MSCU7000148','40GP','intact','HUA4740','郑浩','DOC-E068','EVER-1803','B-10-01','B-10-01','完好','landed'),
('HMMU7000149','40GP','intact','HUA7438','吴斌','DOC-E069','EVER-1803','B-05-03','B-05-03','完好','landed'),
('COSU7000150','20GP','intact','HUA2432','赵刚','DOC-E070','EVER-1803','B-06-01','B-06-01','完好','landed'),
('ONEE7000151','40GP','intact','HUA1515','张伟','DOC-E071','EVER-1803','B-10-06','B-10-06','完好','landed'),
('ONEE7000152','40HQ','intact','HUA7774','周峰','DOC-E072','EVER-1803','B-01-04','B-01-04','完好','landed'),
('MAEU7000153','40HQ','intact','HUA2464','吴斌','DOC-E073','EVER-1803','B-05-04','B-05-04','完好','landed'),
('ZIMU7000154','40GP','intact','HUA3924','王磊','DOC-E074','EVER-1803','B-03-02','B-03-02','完好','landed'),
('YMLU7000155','40GP','intact','HUA4881','王磊','DOC-E075','EVER-1803','B-09-02','B-09-02','完好','landed');

-- 6. 陆侧出场 (10箱提箱中)
INSERT INTO land_outbound_containers (container_id, container_type, container_status, truck_plate, driver_name, pickup_document_no, original_slot_id, process_status) VALUES
('MAEU7000001','40GP','ready','HUA4266','提箱司机1','DOC-L01','A-13-01','picking'),
('CMAU7000002','20GP','ready','HUA9271','提箱司机2','DOC-L02','A-02-04','picking'),
('MAEU7000003','40HQ','ready','HUA6522','提箱司机3','DOC-L03','A-04-06','picking'),
('ZIMU7000004','40GP','ready','HUA7550','提箱司机4','DOC-L04','A-07-04','picking'),
('ZIMU7000005','40GP','ready','HUA5569','提箱司机5','DOC-L05','A-02-02','picking'),
('HLBU7000006','40GP','ready','HUA3767','提箱司机6','DOC-L06','A-13-04','picking'),
('COSU7000007','40GP','ready','HUA8669','提箱司机7','DOC-L07','A-05-02','picking'),
('ONEE7000008','40HQ','ready','HUA2514','提箱司机8','DOC-L08','A-10-06','picking'),
('HLBU7000009','20GP','ready','HUA1310','提箱司机9','DOC-L09','A-04-01','picking'),
('YMLU7000010','40GP','ready','HUA6641','提箱司机10','DOC-L10','A-12-06','picking');

-- 7. 场内台账 (190箱)
INSERT INTO yard_container_inventory (container_id, container_type, container_status, current_slot_id, previous_slot_id, entry_time, expected_exit_time, actual_exit_time, dwell_time_hours, ship_id, voyage_no, is_overdue, overdue_days, alert_level, source_type, source_record_id) VALUES
('MAEU7000001','40GP','in_yard','A-13-01',NULL,'2026-05-30 08:04:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','MAEU7000001'),
('CMAU7000002','20GP','in_yard','A-02-04',NULL,'2026-05-30 08:47:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','CMAU7000002'),
('MAEU7000003','40HQ','in_yard','A-04-06',NULL,'2026-05-30 08:48:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','MAEU7000003'),
('ZIMU7000004','40GP','in_yard','A-07-04',NULL,'2026-05-30 08:08:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','ZIMU7000004'),
('ZIMU7000005','40GP','in_yard','A-02-02',NULL,'2026-05-30 08:36:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','ZIMU7000005'),
('HLBU7000006','40GP','in_yard','A-13-04',NULL,'2026-05-30 08:55:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','HLBU7000006'),
('COSU7000007','40GP','in_yard','A-05-02',NULL,'2026-05-30 08:33:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','COSU7000007'),
('ONEE7000008','40HQ','in_yard','A-10-06',NULL,'2026-05-30 08:49:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','ONEE7000008'),
('HLBU7000009','20GP','in_yard','A-04-01',NULL,'2026-05-30 08:15:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','HLBU7000009'),
('YMLU7000010','40GP','in_yard','A-12-06',NULL,'2026-05-30 08:52:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','YMLU7000010'),
('HMMU7000011','40GP','in_yard','A-12-04',NULL,'2026-05-30 08:52:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','HMMU7000011'),
('CMAU7000012','20GP','in_yard','A-15-06',NULL,'2026-05-30 08:30:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','CMAU7000012'),
('HMMU7000013','40HQ','in_yard','A-06-02',NULL,'2026-05-30 08:55:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','HMMU7000013'),
('ONEE7000014','40GP','in_yard','A-09-05',NULL,'2026-05-30 08:44:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','ONEE7000014'),
('ZIMU7000015','40GP','in_yard','A-01-04',NULL,'2026-05-30 08:09:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','ZIMU7000015'),
('HMMU7000016','40GP','in_yard','A-08-05',NULL,'2026-05-30 08:43:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','HMMU7000016'),
('MAEU7000017','40GP','in_yard','A-12-02',NULL,'2026-05-30 08:51:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','MAEU7000017'),
('CMAU7000018','40GP','in_yard','A-10-04',NULL,'2026-05-30 08:20:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','CMAU7000018'),
('YMLU7000019','40GP','in_yard','A-09-04',NULL,'2026-05-30 08:11:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','YMLU7000019'),
('ZIMU7000020','40GP','in_yard','A-01-01',NULL,'2026-05-30 08:31:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','ZIMU7000020'),
('CMAU7000021','40GP','in_yard','A-14-02',NULL,'2026-05-30 08:35:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','CMAU7000021'),
('ZIMU7000022','40GP','in_yard','A-07-05',NULL,'2026-05-30 08:07:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','ZIMU7000022'),
('COSU7000023','40GP','in_yard','A-04-03',NULL,'2026-05-30 08:08:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','COSU7000023'),
('MSCU7000024','40HQ','in_yard','A-11-04',NULL,'2026-05-30 08:00:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','MSCU7000024'),
('CMAU7000025','20GP','in_yard','A-05-04',NULL,'2026-05-30 08:52:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','CMAU7000025'),
('ZIMU7000026','40GP','in_yard','A-13-05',NULL,'2026-05-30 08:24:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','ZIMU7000026'),
('HLBU7000027','40HQ','in_yard','A-15-02',NULL,'2026-05-30 08:05:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','HLBU7000027'),
('MAEU7000028','20GP','in_yard','A-08-03',NULL,'2026-05-30 08:44:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','MAEU7000028'),
('HLBU7000029','20GP','in_yard','A-13-06',NULL,'2026-05-30 08:31:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','HLBU7000029'),
('CMAU7000030','40GP','in_yard','A-15-01',NULL,'2026-05-30 08:40:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','CMAU7000030'),
('ONEE7000031','40GP','in_yard','A-10-02',NULL,'2026-05-30 08:26:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','ONEE7000031'),
('CMAU7000032','20GP','in_yard','A-04-05',NULL,'2026-05-30 08:42:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','CMAU7000032'),
('YMLU7000033','40GP','in_yard','A-09-01',NULL,'2026-05-30 08:36:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','YMLU7000033'),
('ONEE7000034','40HQ','in_yard','A-04-04',NULL,'2026-05-30 08:21:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','ONEE7000034'),
('ZIMU7000035','40GP','in_yard','A-06-01',NULL,'2026-05-30 08:32:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','ZIMU7000035'),
('HLBU7000036','40GP','in_yard','A-15-03',NULL,'2026-05-30 08:22:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','HLBU7000036'),
('ONEE7000037','20GP','in_yard','A-06-03',NULL,'2026-05-30 08:05:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','ONEE7000037'),
('CMAU7000038','40GP','in_yard','A-09-02',NULL,'2026-05-30 08:47:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','CMAU7000038'),
('CMAU7000039','20GP','in_yard','A-02-06',NULL,'2026-05-30 08:43:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','CMAU7000039'),
('ONEE7000040','40GP','in_yard','A-15-04',NULL,'2026-05-30 08:37:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','ONEE7000040'),
('MAEU7000041','40GP','in_yard','A-09-03',NULL,'2026-05-30 08:01:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','MAEU7000041'),
('CMAU7000042','40GP','in_yard','A-03-06',NULL,'2026-05-30 08:41:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','CMAU7000042'),
('MSCU7000043','40GP','in_yard','A-12-01',NULL,'2026-05-30 08:16:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','MSCU7000043'),
('HLBU7000044','40HQ','in_yard','A-02-01',NULL,'2026-05-30 08:15:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','HLBU7000044'),
('HLBU7000045','40GP','in_yard','A-02-03',NULL,'2026-05-30 08:07:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','HLBU7000045'),
('YMLU7000046','40HQ','in_yard','A-12-05',NULL,'2026-05-30 08:24:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','YMLU7000046'),
('COSU7000047','40HQ','in_yard','A-07-02',NULL,'2026-05-30 08:56:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','COSU7000047'),
('ZIMU7000048','40GP','in_yard','A-10-03',NULL,'2026-05-30 08:15:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','ZIMU7000048'),
('MAEU7000049','40GP','in_yard','A-06-04',NULL,'2026-05-30 08:19:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','MAEU7000049'),
('EISU7000050','40HQ','in_yard','A-10-01',NULL,'2026-05-30 08:38:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','EISU7000050'),
('CMAU7000051','40GP','in_yard','A-13-02',NULL,'2026-05-30 08:43:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','CMAU7000051'),
('HMMU7000052','40HQ','in_yard','A-07-01',NULL,'2026-05-30 08:36:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','HMMU7000052'),
('ZIMU7000053','40GP','in_yard','A-01-06',NULL,'2026-05-30 08:43:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','ZIMU7000053'),
('HLBU7000054','20GP','in_yard','A-11-05',NULL,'2026-05-30 08:36:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','HLBU7000054'),
('MSCU7000055','40GP','in_yard','A-08-04',NULL,'2026-05-30 08:11:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','MSCU7000055'),
('ZIMU7000056','40HQ','in_yard','A-12-03',NULL,'2026-05-30 08:19:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','ZIMU7000056'),
('CMAU7000057','40GP','in_yard','A-14-04',NULL,'2026-05-30 08:47:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','CMAU7000057'),
('MSCU7000058','40HQ','in_yard','A-07-03',NULL,'2026-05-30 08:34:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','MSCU7000058'),
('ZIMU7000059','40GP','in_yard','A-03-02',NULL,'2026-05-30 08:00:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','ZIMU7000059'),
('YMLU7000060','40HQ','in_yard','A-05-06',NULL,'2026-05-30 08:01:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','YMLU7000060'),
('EISU7000061','40GP','in_yard','A-14-06',NULL,'2026-05-30 08:21:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','EISU7000061'),
('MAEU7000062','40GP','in_yard','A-03-03',NULL,'2026-05-30 08:58:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','MAEU7000062'),
('COSU7000063','40GP','in_yard','A-11-03',NULL,'2026-05-30 08:47:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','COSU7000063'),
('COSU7000064','40HQ','in_yard','A-15-05',NULL,'2026-05-30 08:11:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','COSU7000064'),
('HMMU7000065','20GP','in_yard','A-04-02',NULL,'2026-05-30 08:45:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','HMMU7000065'),
('HMMU7000066','40HQ','in_yard','A-03-01',NULL,'2026-05-30 08:29:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','HMMU7000066'),
('HLBU7000067','40GP','in_yard','A-14-03',NULL,'2026-05-30 08:37:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','HLBU7000067'),
('MSCU7000068','40HQ','in_yard','A-05-01',NULL,'2026-05-30 08:06:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','MSCU7000068'),
('EISU7000069','40GP','in_yard','A-02-05',NULL,'2026-05-30 08:15:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','EISU7000069'),
('HLBU7000070','40GP','in_yard','A-08-06',NULL,'2026-05-30 08:42:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','HLBU7000070'),
('MAEU7000071','40GP','in_yard','A-06-06',NULL,'2026-05-30 08:30:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','MAEU7000071'),
('EISU7000072','20GP','in_yard','A-11-06',NULL,'2026-05-30 08:48:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','EISU7000072'),
('COSU7000073','20GP','in_yard','A-10-05',NULL,'2026-05-30 08:10:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','COSU7000073'),
('COSU7000074','40GP','in_yard','A-05-03',NULL,'2026-05-30 08:38:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','COSU7000074'),
('EISU7000075','40GP','in_yard','A-01-03',NULL,'2026-05-30 08:32:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','EISU7000075'),
('COSU7000076','40HQ','in_yard','A-07-06',NULL,'2026-05-30 08:59:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','COSU7000076'),
('EISU7000077','40GP','in_yard','A-06-05',NULL,'2026-05-30 08:42:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','EISU7000077'),
('MSCU7000078','40HQ','in_yard','A-03-04',NULL,'2026-05-30 08:30:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','MSCU7000078'),
('MSCU7000079','40GP','in_yard','A-05-05',NULL,'2026-05-30 08:07:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','MSCU7000079'),
('CMAU7000080','40GP','in_yard','A-01-05',NULL,'2026-05-30 08:04:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','CMAU7000080'),
('YMLU7000081','40GP','in_yard','B-11-05',NULL,'2026-05-30 08:08:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','YMLU7000081'),
('MSCU7000082','40GP','in_yard','B-09-03',NULL,'2026-05-30 08:00:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','MSCU7000082'),
('YMLU7000083','40GP','in_yard','B-11-01',NULL,'2026-05-30 08:39:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','YMLU7000083'),
('HMMU7000084','40GP','in_yard','B-13-04',NULL,'2026-05-30 08:33:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','HMMU7000084'),
('MAEU7000085','40GP','in_yard','B-08-06',NULL,'2026-05-30 08:19:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','MAEU7000085'),
('ONEE7000086','40HQ','in_yard','B-02-05',NULL,'2026-05-30 08:09:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','ONEE7000086'),
('EISU7000087','40HQ','in_yard','B-05-06',NULL,'2026-05-30 08:26:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','EISU7000087'),
('HLBU7000088','20GP','in_yard','B-10-03',NULL,'2026-05-30 08:16:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','HLBU7000088'),
('CMAU7000089','20GP','in_yard','B-02-01',NULL,'2026-05-30 08:01:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','CMAU7000089'),
('COSU7000090','40GP','in_yard','B-02-02',NULL,'2026-05-30 08:28:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','COSU7000090'),
('HMMU7000091','40GP','in_yard','B-04-04',NULL,'2026-05-30 08:38:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','HMMU7000091'),
('CMAU7000092','40HQ','in_yard','B-04-01',NULL,'2026-05-30 08:18:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','CMAU7000092'),
('ONEE7000093','40GP','in_yard','B-11-02',NULL,'2026-05-30 08:09:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','ONEE7000093'),
('EISU7000094','40GP','in_yard','B-13-06',NULL,'2026-05-30 08:24:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','EISU7000094'),
('ONEE7000095','20GP','in_yard','B-07-02',NULL,'2026-05-30 08:40:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','ONEE7000095'),
('MAEU7000096','40GP','in_yard','B-15-01',NULL,'2026-05-30 08:40:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','MAEU7000096'),
('YMLU7000097','40HQ','in_yard','B-01-01',NULL,'2026-05-30 08:00:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','YMLU7000097'),
('COSU7000098','40GP','in_yard','B-03-04',NULL,'2026-05-30 08:28:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','COSU7000098'),
('MSCU7000099','20GP','in_yard','B-13-02',NULL,'2026-05-30 08:37:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','MSCU7000099'),
('CMAU7000100','40GP','in_yard','B-12-03',NULL,'2026-05-30 08:07:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','CMAU7000100'),
('MAEU7000101','40GP','in_yard','B-09-05',NULL,'2026-05-30 08:06:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','MAEU7000101'),
('MSCU7000102','40GP','in_yard','B-01-02',NULL,'2026-05-30 08:14:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','MSCU7000102'),
('COSU7000103','40GP','in_yard','B-05-05',NULL,'2026-05-30 08:53:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','COSU7000103'),
('ONEE7000104','40GP','in_yard','B-05-01',NULL,'2026-05-30 08:20:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','ONEE7000104'),
('COSU7000105','40HQ','in_yard','B-01-06',NULL,'2026-05-30 08:28:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','COSU7000105'),
('ONEE7000106','40HQ','in_yard','B-03-03',NULL,'2026-05-30 08:51:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','ONEE7000106'),
('CMAU7000107','40GP','in_yard','B-01-05',NULL,'2026-05-30 08:04:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','CMAU7000107'),
('HMMU7000108','40GP','in_yard','B-06-04',NULL,'2026-05-30 08:54:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','HMMU7000108'),
('ZIMU7000109','20GP','in_yard','B-14-01',NULL,'2026-05-30 08:24:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','ZIMU7000109'),
('ZIMU7000110','40HQ','in_yard','B-12-05',NULL,'2026-05-30 08:17:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','ZIMU7000110'),
('HMMU7000111','40GP','in_yard','B-12-04',NULL,'2026-05-30 08:28:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','HMMU7000111'),
('HLBU7000112','40GP','in_yard','B-08-01',NULL,'2026-05-30 08:49:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','HLBU7000112'),
('MAEU7000113','20GP','in_yard','B-09-01',NULL,'2026-05-30 08:28:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','MAEU7000113'),
('CMAU7000114','20GP','in_yard','B-02-06',NULL,'2026-05-30 08:46:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','CMAU7000114'),
('ONEE7000115','40GP','in_yard','B-04-02',NULL,'2026-05-30 08:53:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','ONEE7000115'),
('HMMU7000116','40HQ','in_yard','B-03-06',NULL,'2026-05-30 08:19:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','HMMU7000116'),
('YMLU7000117','40HQ','in_yard','B-01-03',NULL,'2026-05-30 08:16:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','YMLU7000117'),
('HMMU7000118','40GP','in_yard','B-14-02',NULL,'2026-05-30 08:28:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','HMMU7000118'),
('MAEU7000119','40GP','in_yard','B-07-01',NULL,'2026-05-30 08:47:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','MAEU7000119'),
('HMMU7000120','40GP','in_yard','B-10-05',NULL,'2026-05-30 08:39:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','HMMU7000120'),
('CMAU7000121','40GP','in_yard','B-09-04',NULL,'2026-05-30 08:26:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','CMAU7000121'),
('COSU7000122','20GP','in_yard','B-08-03',NULL,'2026-05-30 08:30:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','COSU7000122'),
('MSCU7000123','40GP','in_yard','B-10-04',NULL,'2026-05-30 08:18:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','MSCU7000123'),
('COSU7000124','40HQ','in_yard','B-07-03',NULL,'2026-05-30 08:55:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','COSU7000124'),
('ZIMU7000125','20GP','in_yard','B-14-03',NULL,'2026-05-30 08:20:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','ZIMU7000125'),
('ONEE7000126','40HQ','in_yard','B-03-01',NULL,'2026-05-30 08:52:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','ONEE7000126'),
('MSCU7000127','40GP','in_yard','B-15-02',NULL,'2026-05-30 08:10:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','MSCU7000127'),
('YMLU7000128','40HQ','in_yard','B-14-05',NULL,'2026-05-30 08:06:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','YMLU7000128'),
('EISU7000129','40HQ','in_yard','B-07-04',NULL,'2026-05-30 08:39:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','EISU7000129'),
('COSU7000130','20GP','in_yard','B-11-04',NULL,'2026-05-30 08:35:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','COSU7000130'),
('CMAU7000131','20GP','in_yard','B-05-02',NULL,'2026-05-30 08:01:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','CMAU7000131'),
('ONEE7000132','40HQ','in_yard','B-15-03',NULL,'2026-05-30 08:13:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','ONEE7000132'),
('COSU7000133','40GP','in_yard','B-14-04',NULL,'2026-05-30 08:13:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','COSU7000133'),
('YMLU7000134','40GP','in_yard','B-04-03',NULL,'2026-05-30 08:44:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','YMLU7000134'),
('MSCU7000135','20GP','in_yard','B-15-04',NULL,'2026-05-30 08:18:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','MSCU7000135'),
('MSCU7000136','40GP','in_yard','B-09-06',NULL,'2026-05-30 08:45:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','MSCU7000136'),
('CMAU7000137','40GP','in_yard','B-14-06',NULL,'2026-05-30 08:48:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','CMAU7000137'),
('CMAU7000138','20GP','in_yard','B-06-06',NULL,'2026-05-30 08:25:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','CMAU7000138'),
('COSU7000139','20GP','in_yard','B-02-03',NULL,'2026-05-30 08:14:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','COSU7000139'),
('HLBU7000140','40HQ','in_yard','B-06-02',NULL,'2026-05-30 08:55:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','HLBU7000140'),
('CMAU7000141','40HQ','in_yard','B-08-04',NULL,'2026-05-30 08:44:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','CMAU7000141'),
('YMLU7000142','20GP','in_yard','B-10-02',NULL,'2026-05-30 08:42:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','YMLU7000142'),
('EISU7000143','40GP','in_yard','B-13-03',NULL,'2026-05-30 08:20:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','EISU7000143'),
('HMMU7000144','40HQ','in_yard','B-06-05',NULL,'2026-05-30 08:10:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','HMMU7000144'),
('HLBU7000145','20GP','in_yard','B-13-01',NULL,'2026-05-30 08:51:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','HLBU7000145'),
('HLBU7000146','20GP','in_yard','B-03-05',NULL,'2026-05-30 08:06:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','HLBU7000146'),
('EISU7000147','40HQ','in_yard','B-15-06',NULL,'2026-05-30 08:14:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','EISU7000147'),
('MSCU7000148','40GP','in_yard','B-10-01',NULL,'2026-05-30 08:24:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','MSCU7000148'),
('HMMU7000149','40GP','in_yard','B-05-03',NULL,'2026-05-30 08:08:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','HMMU7000149'),
('COSU7000150','20GP','in_yard','B-06-01',NULL,'2026-05-30 08:38:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','COSU7000150'),
('ONEE7000151','40GP','in_yard','B-10-06',NULL,'2026-05-30 08:21:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','ONEE7000151'),
('ONEE7000152','40HQ','in_yard','B-01-04',NULL,'2026-05-30 08:41:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','ONEE7000152'),
('MAEU7000153','40HQ','in_yard','B-05-04',NULL,'2026-05-30 08:34:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','MAEU7000153'),
('ZIMU7000154','40GP','in_yard','B-03-02',NULL,'2026-05-30 08:25:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','ZIMU7000154'),
('YMLU7000155','40GP','in_yard','B-09-02',NULL,'2026-05-30 08:13:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','land_inbound','YMLU7000155'),
('CMAU7000156','20GP','in_yard','C-01-03',NULL,'2026-05-30 08:39:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','CMAU7000156'),
('CMAU7000157','40HQ','in_yard','C-02-01',NULL,'2026-05-30 08:35:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','CMAU7000157'),
('YMLU7000158','40GP','in_yard','C-07-01',NULL,'2026-05-30 08:19:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','YMLU7000158'),
('ONEE7000159','40HQ','in_yard','C-15-02',NULL,'2026-05-30 08:58:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','ONEE7000159'),
('EISU7000160','40HQ','in_yard','C-15-03',NULL,'2026-05-30 08:34:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','EISU7000160'),
('ONEE7000161','40GP','in_yard','C-11-03',NULL,'2026-05-30 08:34:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','ONEE7000161'),
('MSCU7000162','40GP','in_yard','C-06-02',NULL,'2026-05-30 08:24:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','MSCU7000162'),
('COSU7000163','40GP','in_yard','C-12-04',NULL,'2026-05-30 08:44:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','COSU7000163'),
('YMLU7000164','40GP','in_yard','C-09-02',NULL,'2026-05-30 08:16:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','YMLU7000164'),
('CMAU7000165','40HQ','in_yard','C-13-05',NULL,'2026-05-30 08:22:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','CMAU7000165'),
('COSU7000166','40HQ','in_yard','C-11-01',NULL,'2026-05-30 08:55:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','COSU7000166'),
('MSCU7000167','40HQ','in_yard','C-05-06',NULL,'2026-05-30 08:59:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','MSCU7000167'),
('MAEU7000168','40GP','in_yard','C-07-02',NULL,'2026-05-30 08:28:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','MAEU7000168'),
('COSU7000169','40GP','in_yard','C-14-04',NULL,'2026-05-30 08:15:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','COSU7000169'),
('ONEE7000170','40HQ','in_yard','C-06-05',NULL,'2026-05-30 08:11:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','ONEE7000170'),
('ZIMU7000171','40GP','in_yard','C-13-06',NULL,'2026-05-30 08:32:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','ZIMU7000171'),
('MAEU7000172','40GP','in_yard','C-13-01',NULL,'2026-05-30 08:19:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','MAEU7000172'),
('MAEU7000173','40GP','in_yard','C-14-03',NULL,'2026-05-30 08:02:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','MAEU7000173'),
('ONEE7000174','20GP','in_yard','C-15-01',NULL,'2026-05-30 08:47:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','ONEE7000174'),
('HLBU7000175','40GP','in_yard','C-06-04',NULL,'2026-05-30 08:39:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','HLBU7000175'),
('CMAU7000176','40HQ','in_yard','C-09-05',NULL,'2026-05-30 08:52:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','CMAU7000176'),
('HLBU7000177','40GP','in_yard','C-14-06',NULL,'2026-05-30 08:12:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','HLBU7000177'),
('MAEU7000178','40HQ','in_yard','C-01-05',NULL,'2026-05-30 08:19:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','MAEU7000178'),
('ONEE7000179','40GP','in_yard','C-11-06',NULL,'2026-05-30 08:10:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','ONEE7000179'),
('EISU7000180','40HQ','in_yard','C-07-06',NULL,'2026-05-30 08:54:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','EISU7000180'),
('CMAU7000181','40GP','in_yard','C-02-03',NULL,'2026-05-30 08:27:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','CMAU7000181'),
('HLBU7000182','40GP','in_yard','C-03-03',NULL,'2026-05-30 08:42:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','HLBU7000182'),
('EISU7000183','40GP','in_yard','C-03-05',NULL,'2026-05-30 08:37:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','EISU7000183'),
('HMMU7000184','40GP','in_yard','C-03-04',NULL,'2026-05-30 08:08:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','HMMU7000184'),
('ZIMU7000185','40GP','in_yard','C-01-01',NULL,'2026-05-30 08:28:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','ZIMU7000185'),
('HLBU7000186','20GP','in_yard','C-10-03',NULL,'2026-05-30 08:24:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','HLBU7000186'),
('MSCU7000187','40GP','in_yard','C-04-06',NULL,'2026-05-30 08:40:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','MSCU7000187'),
('MAEU7000188','40GP','in_yard','C-04-01',NULL,'2026-05-30 08:31:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','MAEU7000188'),
('HLBU7000189','40GP','in_yard','C-03-06',NULL,'2026-05-30 08:43:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','HLBU7000189'),
('ONEE7000190','40HQ','in_yard','C-02-04',NULL,'2026-05-30 08:03:00',NULL,NULL,0,'COSCO-2405','V2405',0,0,'normal','sea_inbound','ONEE7000190');

-- 8. 调度指令 (30条)
INSERT INTO dispatch_orders (order_id, order_type, issue_time, planned_finish_time, actual_finish_time, issue_dept, execute_dept, container_id, original_position, target_position, operation_requirement, priority_level, execution_status, execution_progress, related_plan_id, related_ship_id, completion_remark, exception_reason) VALUES
('DI-20260530-001','yard_shift','2026-05-30 07:19:00','2026-05-30 18:00:00',NULL,'中控调度','场桥班组','HLBU7000189','C-03-06','A-09-04','场内翻箱','high','completed',52,'SP-20260530-T02','EVER-1803',NULL,NULL),
('DI-20260530-002','yard_shift','2026-05-30 07:56:00','2026-05-30 18:00:00',NULL,'中控调度','场桥班组','CMAU7000137','B-14-06','C-11-05','场内翻箱','urgent','in_progress',44,'SP-20260530-T04','EVER-1803',NULL,NULL),
('DI-20260530-003','sea_inbound','2026-05-30 07:00:00','2026-05-30 18:00:00',NULL,'中控调度','场桥班组','HMMU7000108','B-06-04','B-06-04','场内翻箱','high','completed',31,'SP-20260530-T05','EVER-1803',NULL,NULL),
('DI-20260530-004','land_inbound','2026-05-30 07:22:00','2026-05-30 18:00:00',NULL,'中控调度','场桥班组','MSCU7000191','C-10-04','C-10-04','装船提箱','normal','issued',27,'SP-20260530-T02','MAERSK-8821',NULL,NULL),
('DI-20260530-005','yard_shift','2026-05-30 07:25:00','2026-05-30 18:00:00',NULL,'中控调度','场桥班组','COSU7000122','B-08-03','A-01-02','装船提箱','high','completed',47,'SP-20260530-T01','EVER-1803',NULL,NULL),
('DI-20260530-006','sea_inbound','2026-05-30 07:06:00','2026-05-30 18:00:00',NULL,'中控调度','场桥班组','CMAU7000030','A-15-01','A-15-01','卸船落箱','high','in_progress',58,'SP-20260530-T05','MAERSK-8821',NULL,NULL),
('DI-20260530-007','yard_shift','2026-05-30 07:33:00','2026-05-30 18:00:00',NULL,'中控调度','场桥班组','ONEE7000161','C-11-03','A-13-02','场内翻箱','normal','completed',39,'SP-20260530-T01','COSCO-2405',NULL,NULL),
('DI-20260530-008','sea_inbound','2026-05-30 07:48:00','2026-05-30 18:00:00',NULL,'中控调度','场桥班组','HLBU7000088','B-10-03','B-10-03','闸口入场','high','in_progress',12,'SP-20260530-T01','COSCO-2405',NULL,NULL),
('DI-20260530-009','yard_shift','2026-05-30 07:55:00','2026-05-30 18:00:00',NULL,'中控调度','场桥班组','ZIMU7000125','B-14-03','B-07-05','卸船落箱','normal','in_progress',44,'SP-20260530-T02','COSCO-2405',NULL,NULL),
('DI-20260530-010','land_inbound','2026-05-30 07:29:00','2026-05-30 18:00:00',NULL,'中控调度','场桥班组','ZIMU7000026','A-13-05','A-13-05','卸船落箱','normal','completed',2,'SP-20260530-T04','MAERSK-8821',NULL,NULL),
('DI-20260530-011','sea_inbound','2026-05-30 07:28:00','2026-05-30 18:00:00',NULL,'中控调度','场桥班组','YMLU7000128','B-14-05','B-14-05','闸口入场','high','issued',44,'SP-20260530-T01','COSCO-2405',NULL,NULL),
('DI-20260530-012','land_inbound','2026-05-30 07:11:00','2026-05-30 18:00:00',NULL,'中控调度','场桥班组','ZIMU7000110','B-12-05','B-12-05','装船提箱','normal','issued',54,'SP-20260530-T01','MAERSK-8821',NULL,NULL),
('DI-20260530-013','sea_inbound','2026-05-30 07:00:00','2026-05-30 18:00:00',NULL,'中控调度','场桥班组','ONEE7000037','A-06-03','A-06-03','闸口入场','normal','in_progress',100,'SP-20260530-T01','EVER-1803',NULL,NULL),
('DI-20260530-014','sea_inbound','2026-05-30 07:23:00','2026-05-30 18:00:00',NULL,'中控调度','场桥班组','YMLU7000193','C-08-03','C-08-03','卸船落箱','high','issued',73,'SP-20260530-T05','MAERSK-8821',NULL,NULL),
('DI-20260530-015','sea_outbound','2026-05-30 07:27:00','2026-05-30 18:00:00',NULL,'中控调度','场桥班组','YMLU7000158','C-07-01','C-07-01','装船提箱','normal','in_progress',67,'SP-20260530-T04','MAERSK-8821',NULL,NULL),
('DI-20260530-016','sea_inbound','2026-05-30 07:35:00','2026-05-30 18:00:00',NULL,'中控调度','场桥班组','CMAU7000157','C-02-01','C-02-01','闸口入场','high','in_progress',37,'SP-20260530-T04','EVER-1803',NULL,NULL),
('DI-20260530-017','sea_outbound','2026-05-30 07:13:00','2026-05-30 18:00:00',NULL,'中控调度','场桥班组','HLBU7000182','C-03-03','C-03-03','场内翻箱','normal','completed',66,'SP-20260530-T03','MAERSK-8821',NULL,NULL),
('DI-20260530-018','sea_outbound','2026-05-30 07:07:00','2026-05-30 18:00:00',NULL,'中控调度','场桥班组','CMAU7000156','C-01-03','C-01-03','装船提箱','normal','in_progress',76,'SP-20260530-T05','MAERSK-8821',NULL,NULL),
('DI-20260530-019','yard_shift','2026-05-30 07:20:00','2026-05-30 18:00:00',NULL,'中控调度','场桥班组','MSCU7000187','C-04-06','A-11-03','闸口入场','high','completed',78,'SP-20260530-T04','EVER-1803',NULL,NULL),
('DI-20260530-020','land_inbound','2026-05-30 07:43:00','2026-05-30 18:00:00',NULL,'中控调度','场桥班组','MAEU7000028','A-08-03','A-08-03','闸口入场','high','completed',74,'SP-20260530-T03','EVER-1803',NULL,NULL),
('DI-20260530-021','land_inbound','2026-05-30 07:22:00','2026-05-30 18:00:00',NULL,'中控调度','场桥班组','ZIMU7000004','A-07-04','A-07-04','场内翻箱','high','completed',32,'SP-20260530-T04','COSCO-2405',NULL,NULL),
('DI-20260530-022','sea_outbound','2026-05-30 07:26:00','2026-05-30 18:00:00',NULL,'中控调度','场桥班组','HMMU7000120','B-10-05','B-10-05','卸船落箱','high','issued',90,'SP-20260530-T03','EVER-1803',NULL,NULL),
('DI-20260530-023','yard_shift','2026-05-30 07:50:00','2026-05-30 18:00:00',NULL,'中控调度','场桥班组','ONEE7000014','A-09-05','A-05-06','场内翻箱','high','completed',49,'SP-20260530-T03','EVER-1803',NULL,NULL),
('DI-20260530-024','sea_outbound','2026-05-30 07:00:00','2026-05-30 18:00:00',NULL,'中控调度','场桥班组','ZIMU7000053','A-01-06','A-01-06','卸船落箱','normal','in_progress',29,'SP-20260530-T02','COSCO-2405',NULL,NULL),
('DI-20260530-025','yard_shift','2026-05-30 07:23:00','2026-05-30 18:00:00',NULL,'中控调度','场桥班组','ONEE7000159','C-15-02','C-03-02','卸船落箱','urgent','issued',37,'SP-20260530-T02','COSCO-2405',NULL,NULL),
('DI-20260530-026','land_inbound','2026-05-30 07:14:00','2026-05-30 18:00:00',NULL,'中控调度','场桥班组','CMAU7000030','A-15-01','A-15-01','卸船落箱','normal','issued',75,'SP-20260530-T04','COSCO-2405',NULL,NULL),
('DI-20260530-027','sea_inbound','2026-05-30 07:28:00','2026-05-30 18:00:00',NULL,'中控调度','场桥班组','HMMU7000144','B-06-05','B-06-05','闸口入场','normal','issued',47,'SP-20260530-T05','EVER-1803',NULL,NULL),
('DI-20260530-028','land_inbound','2026-05-30 07:12:00','2026-05-30 18:00:00',NULL,'中控调度','场桥班组','ONEE7000014','A-09-05','A-09-05','装船提箱','normal','completed',34,'SP-20260530-T05','COSCO-2405',NULL,NULL),
('DI-20260530-029','yard_shift','2026-05-30 07:25:00','2026-05-30 18:00:00',NULL,'中控调度','场桥班组','HMMU7000184','C-03-04','A-05-04','闸口入场','high','issued',61,'SP-20260530-T04','EVER-1803',NULL,NULL),
('DI-20260530-030','yard_shift','2026-05-30 07:09:00','2026-05-30 18:00:00',NULL,'中控调度','场桥班组','MAEU7000001','A-13-01','B-06-06','闸口入场','normal','issued',24,'SP-20260530-T03','EVER-1803',NULL,NULL);

-- 9. 作业记录 (70条)
INSERT INTO yard_operation_records (record_id, operation_type, container_id, original_slot_id, target_slot_id, equipment_id, equipment_type, operator_name, operator_id, start_time, end_time, duration_minutes, dispatch_order_id, source_operation, operation_status, completion_remark, operation_cost) VALUES
('YM-20260530-001','pick','MSCU7000135','A-03-04','B-15-01','YC-06','YC','操作员6号','98','2026-05-30 08:51:00',NULL,NULL,'DI-20260530-025','dispatch','in_progress',NULL,NULL),
('YM-20260530-002','land','ONEE7000008','A-01-06','B-02-01','YC-08','YC','操作员13号','60','2026-05-30 08:23:00',NULL,NULL,'DI-20260530-003','dispatch','in_progress',NULL,NULL),
('YM-20260530-003','land','MAEU7000003','C-12-04','A-10-03','YC-05','YC','操作员18号','53','2026-05-30 08:12:00',NULL,NULL,'DI-20260530-008','dispatch','in_progress',NULL,NULL),
('YM-20260530-004','land','MSCU7000024','B-03-05','A-14-04','YC-02','YC','操作员8号','54','2026-05-30 08:35:00',NULL,NULL,'DI-20260530-015','dispatch','in_progress',NULL,NULL),
('YM-20260530-005','pick','HLBU7000044','A-06-05','B-02-02','YC-05','YC','操作员4号','85','2026-05-30 08:16:00',NULL,NULL,'DI-20260530-013','dispatch','in_progress',NULL,NULL),
('YM-20260530-006','flip','CMAU7000121','C-11-03','B-10-03','YC-04','YC','操作员6号','18','2026-05-30 08:30:00',NULL,NULL,'DI-20260530-012','dispatch','in_progress',NULL,NULL),
('YM-20260530-007','flip','MAEU7000153','A-08-06','B-14-06','YC-01','YC','操作员18号','38','2026-05-30 08:54:00',NULL,NULL,'DI-20260530-012','dispatch','in_progress',NULL,NULL),
('YM-20260530-008','flip','MAEU7000071','C-11-02','A-10-04','YC-05','YC','操作员5号','60','2026-05-30 08:29:00',NULL,NULL,'DI-20260530-009','dispatch','in_progress',NULL,NULL),
('YM-20260530-009','flip','HLBU7000027','B-01-01','B-10-01','YC-02','YC','操作员9号','63','2026-05-30 08:52:00',NULL,NULL,'DI-20260530-022','dispatch','in_progress',NULL,NULL),
('YM-20260530-010','land','MSCU7000123','B-01-04','B-09-06','YC-05','YC','操作员5号','16','2026-05-30 08:58:00',NULL,NULL,'DI-20260530-023','dispatch','in_progress',NULL,NULL),
('YM-20260530-011','land','EISU7000075','C-09-03','A-07-02','YC-04','YC','操作员7号','11','2026-05-30 08:34:00',NULL,NULL,'DI-20260530-030','dispatch','in_progress',NULL,NULL),
('YM-20260530-012','land','YMLU7000081','B-13-06','A-01-04','YC-06','YC','操作员4号','76','2026-05-30 08:31:00',NULL,NULL,'DI-20260530-009','dispatch','in_progress',NULL,NULL),
('YM-20260530-013','pick','HLBU7000175','B-04-06','B-05-05','YC-01','YC','操作员12号','83','2026-05-30 08:43:00',NULL,NULL,'DI-20260530-027','dispatch','in_progress',NULL,NULL),
('YM-20260530-014','flip','MSCU7000127','C-08-06','C-12-06','YC-01','YC','操作员11号','35','2026-05-30 08:23:00',NULL,NULL,'DI-20260530-028','dispatch','in_progress',NULL,NULL),
('YM-20260530-015','shift','HMMU7000066','C-03-01','B-07-06','YC-07','YC','操作员18号','20','2026-05-30 08:48:00',NULL,NULL,'DI-20260530-028','dispatch','in_progress',NULL,NULL),
('YM-20260530-016','flip','COSU7000166','A-12-04','C-14-02','YC-08','YC','操作员2号','15','2026-05-30 08:38:00',NULL,NULL,'DI-20260530-021','dispatch','in_progress',NULL,NULL),
('YM-20260530-017','pick','CMAU7000038','C-11-02','C-03-03','YC-02','YC','操作员12号','25','2026-05-30 08:16:00',NULL,NULL,'DI-20260530-004','dispatch','in_progress',NULL,NULL),
('YM-20260530-018','pick','ZIMU7000109','B-03-03','B-01-01','YC-05','YC','操作员7号','11','2026-05-30 08:43:00',NULL,NULL,'DI-20260530-015','dispatch','in_progress',NULL,NULL),
('YM-20260530-019','land','YMLU7000010','C-05-03','B-11-06','YC-03','YC','操作员13号','92','2026-05-30 08:51:00',NULL,NULL,'DI-20260530-029','dispatch','in_progress',NULL,NULL),
('YM-20260530-020','pick','CMAU7000051','B-13-01','B-09-03','YC-05','YC','操作员14号','65','2026-05-30 08:27:00',NULL,NULL,'DI-20260530-010','dispatch','in_progress',NULL,NULL),
('YM-20260530-021','shift','HMMU7000111','B-11-02','A-12-05','YC-07','YC','操作员13号','37','2026-05-30 08:23:00',NULL,NULL,'DI-20260530-028','dispatch','in_progress',NULL,NULL),
('YM-20260530-022','shift','HLBU7000140','C-08-06','B-14-03','YC-06','YC','操作员8号','52','2026-05-30 08:56:00',NULL,NULL,'DI-20260530-024','dispatch','in_progress',NULL,NULL),
('YM-20260530-023','shift','COSU7000023','B-02-02','B-14-05','YC-03','YC','操作员3号','38','2026-05-30 08:11:00',NULL,NULL,'DI-20260530-015','dispatch','in_progress',NULL,NULL),
('YM-20260530-024','flip','YMLU7000199','B-03-03','B-05-03','YC-07','YC','操作员15号','15','2026-05-30 08:29:00',NULL,NULL,'DI-20260530-027','dispatch','in_progress',NULL,NULL),
('YM-20260530-025','land','ZIMU7000185','B-02-03','A-07-02','YC-01','YC','操作员9号','69','2026-05-30 08:56:00',NULL,NULL,'DI-20260530-027','dispatch','in_progress',NULL,NULL),
('YM-20260530-026','land','ONEE7000179','A-06-01','C-15-01','YC-07','YC','操作员11号','25','2026-05-30 08:05:00',NULL,NULL,'DI-20260530-014','dispatch','in_progress',NULL,NULL),
('YM-20260530-027','flip','CMAU7000176','B-04-03','A-03-03','YC-01','YC','操作员17号','41','2026-05-30 08:08:00',NULL,NULL,'DI-20260530-028','dispatch','in_progress',NULL,NULL),
('YM-20260530-028','land','MSCU7000148','B-05-04','B-03-03','YC-05','YC','操作员20号','11','2026-05-30 08:17:00',NULL,NULL,'DI-20260530-022','dispatch','in_progress',NULL,NULL),
('YM-20260530-029','flip','COSU7000073','A-13-03','B-05-02','YC-08','YC','操作员9号','19','2026-05-30 08:33:00',NULL,NULL,'DI-20260530-015','dispatch','in_progress',NULL,NULL),
('YM-20260530-030','shift','YMLU7000033','B-15-02','B-15-02','YC-07','YC','操作员1号','21','2026-05-30 08:25:00',NULL,NULL,'DI-20260530-006','dispatch','in_progress',NULL,NULL),
('YM-20260530-031','shift','ONEE7000095','C-03-03','A-07-04','YC-01','YC','操作员3号','12','2026-05-30 08:56:00',NULL,NULL,'DI-20260530-002','dispatch','in_progress',NULL,NULL),
('YM-20260530-032','flip','HMMU7000011','B-10-06','A-05-01','YC-01','YC','操作员1号','12','2026-05-30 08:03:00',NULL,NULL,'DI-20260530-016','dispatch','in_progress',NULL,NULL),
('YM-20260530-033','shift','MAEU7000028','C-04-05','A-15-02','YC-04','YC','操作员20号','35','2026-05-30 08:31:00',NULL,NULL,'DI-20260530-005','dispatch','in_progress',NULL,NULL),
('YM-20260530-034','pick','YMLU7000010','C-05-06','C-15-05','YC-01','YC','操作员7号','77','2026-05-30 08:19:00',NULL,NULL,'DI-20260530-002','dispatch','in_progress',NULL,NULL),
('YM-20260530-035','shift','MSCU7000123','C-09-01','A-10-01','YC-07','YC','操作员13号','23','2026-05-30 08:04:00',NULL,NULL,'DI-20260530-028','dispatch','in_progress',NULL,NULL),
('YM-20260530-036','land','COSU7000103','B-09-01','C-07-01','YC-02','YC','操作员3号','13','2026-05-30 08:11:00',NULL,NULL,'DI-20260530-001','dispatch','in_progress',NULL,NULL),
('YM-20260530-037','pick','CMAU7000131','B-02-06','A-01-01','YC-01','YC','操作员10号','36','2026-05-30 08:40:00',NULL,NULL,'DI-20260530-001','dispatch','in_progress',NULL,NULL),
('YM-20260530-038','land','CMAU7000002','B-05-03','A-14-01','YC-07','YC','操作员7号','21','2026-05-30 08:28:00',NULL,NULL,'DI-20260530-025','dispatch','in_progress',NULL,NULL),
('YM-20260530-039','pick','MSCU7000127','A-13-02','B-08-05','YC-06','YC','操作员6号','41','2026-05-30 08:37:00',NULL,NULL,'DI-20260530-027','dispatch','in_progress',NULL,NULL),
('YM-20260530-040','land','CMAU7000021','A-06-06','C-02-04','YC-08','YC','操作员2号','21','2026-05-30 08:45:00',NULL,NULL,'DI-20260530-017','dispatch','in_progress',NULL,NULL),
('YM-20260530-041','pick','YMLU7000199','C-15-06','C-11-02','YC-01','YC','操作员11号','87','2026-05-30 08:31:00',NULL,NULL,'DI-20260530-026','dispatch','in_progress',NULL,NULL),
('YM-20260530-042','flip','HLBU7000045','A-14-05','B-07-02','YC-02','YC','操作员7号','17','2026-05-30 08:31:00',NULL,NULL,'DI-20260530-007','dispatch','in_progress',NULL,NULL),
('YM-20260530-043','pick','ZIMU7000125','A-07-01','C-04-03','YC-07','YC','操作员4号','25','2026-05-30 08:35:00',NULL,NULL,'DI-20260530-012','dispatch','in_progress',NULL,NULL),
('YM-20260530-044','pick','COSU7000150','A-08-04','B-06-02','YC-08','YC','操作员1号','70','2026-05-30 08:25:00',NULL,NULL,'DI-20260530-022','dispatch','in_progress',NULL,NULL),
('YM-20260530-045','land','YMLU7000081','B-07-03','B-10-06','YC-01','YC','操作员14号','52','2026-05-30 08:14:00',NULL,NULL,'DI-20260530-013','dispatch','in_progress',NULL,NULL),
('YM-20260530-046','land','MSCU7000102','C-04-04','C-04-01','YC-03','YC','操作员11号','35','2026-05-30 08:29:00',NULL,NULL,'DI-20260530-019','dispatch','in_progress',NULL,NULL),
('YM-20260530-047','land','CMAU7000141','A-07-02','A-06-06','YC-05','YC','操作员4号','97','2026-05-30 08:57:00',NULL,NULL,'DI-20260530-015','dispatch','in_progress',NULL,NULL),
('YM-20260530-048','flip','CMAU7000181','A-11-02','C-07-02','YC-05','YC','操作员8号','62','2026-05-30 08:47:00',NULL,NULL,'DI-20260530-027','dispatch','in_progress',NULL,NULL),
('YM-20260530-049','pick','CMAU7000039','C-08-01','A-13-03','YC-01','YC','操作员20号','11','2026-05-30 08:11:00',NULL,NULL,'DI-20260530-026','dispatch','in_progress',NULL,NULL),
('YM-20260530-050','shift','MAEU7000188','A-02-05','B-05-03','YC-03','YC','操作员5号','47','2026-05-30 08:47:00',NULL,NULL,'DI-20260530-001','dispatch','in_progress',NULL,NULL),
('YM-20260530-051','pick','ONEE7000104','A-11-01','C-08-04','YC-04','YC','操作员15号','97','2026-05-30 08:01:00',NULL,NULL,'DI-20260530-023','dispatch','in_progress',NULL,NULL),
('YM-20260530-052','shift','COSU7000163','C-06-02','A-04-03','YC-07','YC','操作员2号','85','2026-05-30 08:41:00','2026-05-30 08:34:00',18,'DI-20260530-029','dispatch','completed',NULL,NULL),
('YM-20260530-053','flip','EISU7000143','C-15-06','A-13-04','YC-05','YC','操作员4号','16','2026-05-30 08:07:00','2026-05-30 11:58:00',19,'DI-20260530-011','dispatch','completed',NULL,NULL),
('YM-20260530-054','land','YMLU7000060','B-14-01','A-05-03','YC-06','YC','操作员6号','65','2026-05-30 08:37:00','2026-05-30 10:56:00',25,'DI-20260530-013','dispatch','completed',NULL,NULL),
('YM-20260530-055','flip','EISU7000050','C-07-05','C-02-02','YC-03','YC','操作员15号','27','2026-05-30 08:44:00','2026-05-30 08:41:00',18,'DI-20260530-013','dispatch','completed',NULL,NULL),
('YM-20260530-056','land','HLBU7000177','C-03-03','A-12-03','YC-03','YC','操作员4号','68','2026-05-30 08:33:00','2026-05-30 10:25:00',3,'DI-20260530-007','dispatch','completed',NULL,NULL),
('YM-20260530-057','land','HLBU7000006','A-14-01','A-03-01','YC-04','YC','操作员18号','52','2026-05-30 08:48:00','2026-05-30 11:38:00',30,'DI-20260530-013','dispatch','completed',NULL,NULL),
('YM-20260530-058','pick','HLBU7000067','B-05-01','A-04-02','YC-08','YC','操作员10号','14','2026-05-30 08:25:00','2026-05-30 10:55:00',12,'DI-20260530-025','dispatch','completed',NULL,NULL),
('YM-20260530-059','land','HMMU7000052','C-11-03','A-03-03','YC-01','YC','操作员2号','70','2026-05-30 08:12:00','2026-05-30 11:04:00',25,'DI-20260530-014','dispatch','completed',NULL,NULL),
('YM-20260530-060','land','COSU7000166','A-15-05','A-14-05','YC-05','YC','操作员8号','53','2026-05-30 08:40:00','2026-05-30 10:04:00',15,'DI-20260530-008','dispatch','completed',NULL,NULL),
('YM-20260530-061','shift','EISU7000094','A-09-04','C-03-04','YC-01','YC','操作员4号','19','2026-05-30 08:16:00','2026-05-30 09:06:00',14,'DI-20260530-011','dispatch','completed',NULL,NULL),
('YM-20260530-062','land','EISU7000050','A-06-02','A-01-03','YC-03','YC','操作员12号','30','2026-05-30 08:10:00','2026-05-30 08:22:00',28,'DI-20260530-001','dispatch','completed',NULL,NULL),
('YM-20260530-063','land','ONEE7000095','A-14-06','A-02-01','YC-05','YC','操作员18号','75','2026-05-30 08:08:00','2026-05-30 10:52:00',5,'DI-20260530-029','dispatch','completed',NULL,NULL),
('YM-20260530-064','pick','COSU7000074','A-05-06','A-12-06','YC-03','YC','操作员7号','57','2026-05-30 08:25:00','2026-05-30 08:52:00',9,'DI-20260530-017','dispatch','completed',NULL,NULL),
('YM-20260530-065','pick','MAEU7000188','A-03-02','A-14-03','YC-03','YC','操作员6号','78','2026-05-30 08:44:00','2026-05-30 11:13:00',17,'DI-20260530-007','dispatch','completed',NULL,NULL),
('YM-20260530-066','pick','ZIMU7000125','C-01-05','A-11-04','YC-05','YC','操作员1号','59','2026-05-30 08:19:00','2026-05-30 09:18:00',28,'DI-20260530-012','dispatch','completed',NULL,NULL),
('YM-20260530-067','shift','HLBU7000177','B-12-02','B-14-06','YC-03','YC','操作员9号','19','2026-05-30 08:48:00','2026-05-30 11:27:00',10,'DI-20260530-005','dispatch','completed',NULL,NULL),
('YM-20260530-068','flip','CMAU7000181','A-01-02','C-08-06','YC-05','YC','操作员9号','15','2026-05-30 08:40:00','2026-05-30 11:25:00',14,'DI-20260530-024','dispatch','completed',NULL,NULL),
('YM-20260530-069','land','ONEE7000192','C-12-05','A-12-05','YC-04','YC','操作员20号','53','2026-05-30 08:25:00','2026-05-30 08:42:00',13,'DI-20260530-008','dispatch','completed',NULL,NULL),
('YM-20260530-070','land','COSU7000073','C-14-06','C-06-02','YC-08','YC','操作员1号','43','2026-05-30 08:26:00','2026-05-30 08:21:00',15,'DI-20260530-019','dispatch','completed',NULL,NULL);

-- 10. 闸口通行 (40车次)
INSERT INTO gate_io_records (record_id, gate_lane_no, io_type, truck_plate, driver_name, container_id, container_type, document_no, document_verify_result, damage_check, damage_remark, entry_time, exit_time, pass_duration, release_status, release_operator, operation_id, plan_id) VALUES
('GATE-20260530-001','L02','inbound','HUA4331','司机17号','HMMU7000120','20GP','DOC-G001','passed','完好',NULL,'2026-05-30 11:10:24',NULL,NULL,'approved','闸口管理员','SI-001','SP-T01'),
('GATE-20260530-002','L05','outbound','HUA8612','司机4号','MAEU7000003','20GP','DOC-G002','passed','完好',NULL,'2026-05-30 11:25:18',NULL,NULL,'approved','闸口管理员','SI-002','SP-T01'),
('GATE-20260530-003','L03','inbound','HUA7545','司机20号','MSCU7000079','40GP','DOC-G003','passed','完好',NULL,'2026-05-30 08:29:11',NULL,NULL,'approved','闸口管理员','SI-003','SP-T01'),
('GATE-20260530-004','L01','inbound','HUA7834','司机18号','COSU7000063','40GP','DOC-G004','passed','完好',NULL,'2026-05-30 10:24:43',NULL,NULL,'approved','闸口管理员','SI-004','SP-T01'),
('GATE-20260530-005','L01','outbound','HUA6554','司机13号','EISU7000129','20GP','DOC-G005','passed','完好',NULL,'2026-05-30 10:22:05',NULL,NULL,'approved','闸口管理员','SI-005','SP-T01'),
('GATE-20260530-006','L04','inbound','HUA9949','司机2号','YMLU7000128','20GP','DOC-G006','passed','完好',NULL,'2026-05-30 11:11:02',NULL,NULL,'approved','闸口管理员','SI-006','SP-T01'),
('GATE-20260530-007','L02','outbound','HUA3800','司机6号','HLBU7000009','20GP','DOC-G007','passed','完好',NULL,'2026-05-30 11:56:28',NULL,NULL,'approved','闸口管理员','SI-007','SP-T01'),
('GATE-20260530-008','L04','inbound','HUA5067','司机20号','YMLU7000128','40GP','DOC-G008','passed','完好',NULL,'2026-05-30 07:00:01',NULL,NULL,'approved','闸口管理员','SI-008','SP-T01'),
('GATE-20260530-009','L05','outbound','HUA7678','司机1号','ONEE7000008','40GP','DOC-G009','passed','完好',NULL,'2026-05-30 11:51:08',NULL,NULL,'approved','闸口管理员','SI-009','SP-T01'),
('GATE-20260530-010','L02','inbound','HUA9081','司机1号','COSU7000023','20GP','DOC-G010','passed','完好',NULL,'2026-05-30 10:39:09',NULL,NULL,'approved','闸口管理员','SI-010','SP-T01'),
('GATE-20260530-011','L05','inbound','HUA6119','司机6号','YMLU7000128','20GP','DOC-G011','passed','完好',NULL,'2026-05-30 08:03:44',NULL,NULL,'approved','闸口管理员','SI-011','SP-T01'),
('GATE-20260530-012','L04','inbound','HUA5530','司机9号','ZIMU7000056','40GP','DOC-G012','passed','完好',NULL,'2026-05-30 10:49:28',NULL,NULL,'approved','闸口管理员','SI-012','SP-T01'),
('GATE-20260530-013','L03','outbound','HUA7306','司机9号','HLBU7000054','40GP','DOC-G013','passed','完好',NULL,'2026-05-30 08:07:27',NULL,NULL,'approved','闸口管理员','SI-013','SP-T01'),
('GATE-20260530-014','L04','outbound','HUA8334','司机20号','MAEU7000041','40GP','DOC-G014','passed','完好',NULL,'2026-05-30 09:05:44',NULL,NULL,'approved','闸口管理员','SI-014','SP-T01'),
('GATE-20260530-015','L03','inbound','HUA5749','司机10号','CMAU7000114','20GP','DOC-G015','passed','完好',NULL,'2026-05-30 11:42:25',NULL,NULL,'approved','闸口管理员','SI-015','SP-T01'),
('GATE-20260530-016','L04','inbound','HUA6749','司机6号','MAEU7000017','20GP','DOC-G016','passed','完好',NULL,'2026-05-30 11:36:02',NULL,NULL,'approved','闸口管理员','SI-016','SP-T01'),
('GATE-20260530-017','L02','inbound','HUA3757','司机3号','YMLU7000033','20GP','DOC-G017','passed','完好',NULL,'2026-05-30 10:45:25',NULL,NULL,'approved','闸口管理员','SI-017','SP-T01'),
('GATE-20260530-018','L05','outbound','HUA3574','司机6号','HMMU7000120','40GP','DOC-G018','passed','完好',NULL,'2026-05-30 08:33:12',NULL,NULL,'approved','闸口管理员','SI-018','SP-T01'),
('GATE-20260530-019','L01','inbound','HUA5474','司机16号','MSCU7000024','40HQ','DOC-G019','passed','完好',NULL,'2026-05-30 07:57:42',NULL,NULL,'approved','闸口管理员','SI-019','SP-T01'),
('GATE-20260530-020','L02','inbound','HUA3448','司机20号','COSU7000047','40GP','DOC-G020','passed','完好',NULL,'2026-05-30 10:18:10',NULL,NULL,'approved','闸口管理员','SI-020','SP-T01'),
('GATE-20260530-021','L03','outbound','HUA6262','司机16号','HLBU7000146','20GP','DOC-G021','passed','完好',NULL,'2026-05-30 08:30:06',NULL,NULL,'approved','闸口管理员','SI-021','SP-T01'),
('GATE-20260530-022','L04','outbound','HUA4557','司机10号','HMMU7000084','40GP','DOC-G022','passed','完好',NULL,'2026-05-30 10:55:50',NULL,NULL,'approved','闸口管理员','SI-022','SP-T01'),
('GATE-20260530-023','L01','outbound','HUA5238','司机11号','MAEU7000001','40GP','DOC-G023','passed','完好',NULL,'2026-05-30 07:18:23',NULL,NULL,'approved','闸口管理员','SI-023','SP-T01'),
('GATE-20260530-024','L05','inbound','HUA7730','司机2号','EISU7000147','40HQ','DOC-G024','passed','完好',NULL,'2026-05-30 09:53:40',NULL,NULL,'approved','闸口管理员','SI-024','SP-T01'),
('GATE-20260530-025','L05','inbound','HUA6392','司机2号','ONEE7000008','40HQ','DOC-G025','passed','完好',NULL,'2026-05-30 09:45:33',NULL,NULL,'approved','闸口管理员','SI-025','SP-T01'),
('GATE-20260530-026','L03','inbound','HUA5657','司机18号','CMAU7000030','40GP','DOC-G026','passed','完好',NULL,'2026-05-30 07:13:51',NULL,NULL,'approved','闸口管理员','SI-026','SP-T01'),
('GATE-20260530-027','L02','inbound','HUA7109','司机14号','HMMU7000011','40HQ','DOC-G027','passed','完好',NULL,'2026-05-30 07:35:45',NULL,NULL,'approved','闸口管理员','SI-027','SP-T01'),
('GATE-20260530-028','L02','outbound','HUA9380','司机3号','CMAU7000156','40HQ','DOC-G028','passed','完好',NULL,'2026-05-30 11:26:04',NULL,NULL,'approved','闸口管理员','SI-028','SP-T01'),
('GATE-20260530-029','L01','inbound','HUA2020','司机4号','MSCU7000148','20GP','DOC-G029','passed','完好',NULL,'2026-05-30 09:45:57',NULL,NULL,'approved','闸口管理员','SI-029','SP-T01'),
('GATE-20260530-030','L03','inbound','HUA6056','司机13号','MAEU7000017','40HQ','DOC-G030','passed','完好',NULL,'2026-05-30 07:22:59',NULL,NULL,'approved','闸口管理员','SI-030','SP-T01'),
('GATE-20260530-031','L04','inbound','HUA5052','司机20号','MSCU7000162','20GP','DOC-G031','passed','完好',NULL,'2026-05-30 08:48:04',NULL,NULL,'approved','闸口管理员','SI-031','SP-T01'),
('GATE-20260530-032','L01','inbound','HUA6752','司机10号','EISU7000147','20GP','DOC-G032','passed','完好',NULL,'2026-05-30 07:54:40',NULL,NULL,'approved','闸口管理员','SI-032','SP-T01'),
('GATE-20260530-033','L05','inbound','HUA2085','司机18号','CMAU7000165','20GP','DOC-G033','passed','完好',NULL,'2026-05-30 11:52:57',NULL,NULL,'approved','闸口管理员','SI-033','SP-T01'),
('GATE-20260530-034','L01','inbound','HUA6425','司机8号','ZIMU7000020','40HQ','DOC-G034','passed','完好',NULL,'2026-05-30 08:14:31',NULL,NULL,'approved','闸口管理员','SI-034','SP-T01'),
('GATE-20260530-035','L02','inbound','HUA7265','司机19号','HMMU7000194','40HQ','DOC-G035','passed','完好',NULL,'2026-05-30 11:20:54',NULL,NULL,'approved','闸口管理员','SI-035','SP-T01'),
('GATE-20260530-036','L01','outbound','HUA9594','司机11号','COSU7000074','40GP','DOC-G036','passed','完好',NULL,'2026-05-30 09:29:19',NULL,NULL,'approved','闸口管理员','SI-036','SP-T01'),
('GATE-20260530-037','L03','inbound','HUA6461','司机19号','EISU7000069','20GP','DOC-G037','passed','完好',NULL,'2026-05-30 11:02:46',NULL,NULL,'approved','闸口管理员','SI-037','SP-T01'),
('GATE-20260530-038','L04','inbound','HUA6986','司机17号','HMMU7000091','40HQ','DOC-G038','passed','完好',NULL,'2026-05-30 08:48:20',NULL,NULL,'approved','闸口管理员','SI-038','SP-T01'),
('GATE-20260530-039','L02','inbound','HUA6294','司机14号','ZIMU7000020','20GP','DOC-G039','passed','完好',NULL,'2026-05-30 10:45:13',NULL,NULL,'approved','闸口管理员','SI-039','SP-T01'),
('GATE-20260530-040','L03','inbound','HUA6639','司机13号','CMAU7000021','40GP','DOC-G040','passed','完好',NULL,'2026-05-30 09:31:50',NULL,NULL,'approved','闸口管理员','SI-040','SP-T01');

-- 11. 海侧计划 (5条)
INSERT INTO sea_operation_plans (plan_id, plan_type, voyage_no, ship_id, planned_berth_time, planned_depart_time, actual_berth_time, planned_inbound, planned_outbound, actual_inbound, actual_outbound, assigned_quay_cranes, assigned_yard_cranes, assigned_trucks, plan_status, completion_rate) VALUES
('SP-20260530-T01','discharge','V2405','COSCO-2405','2026-05-30 06:00:00','2026-05-30 22:00:00','2026-05-30 06:15:00',45,0,45,0,'QC-01,QC-02','YC-01,YC-02,YC-03','IT-01~05','executing',100),
('SP-20260530-T02','load','V8821','MAERSK-8821','2026-05-30 08:00:00','2026-05-31 02:00:00','2026-05-30 08:10:00',0,40,0,12,'QC-03,QC-04','YC-04,YC-05','IT-06~08','executing',30),
('SP-20260530-T03','load','V1803','EVER-1803','2026-05-30 04:00:00','2026-05-30 18:00:00','2026-05-30 04:30:00',35,45,35,22,'QC-05,QC-06','YC-01,YC-06,YC-07','IT-09~11','executing',63),
('SP-20260530-T04','discharge','V0921','MSC-0921','2026-05-30 09:30:00','2026-05-31 04:00:00','2026-05-30 09:45:00',38,0,8,0,'QC-01','YC-08','IT-12~13','executing',21),
('SP-20260530-T05','discharge','V0601','ONE-0601','2026-05-30 12:00:00','2026-05-31 06:00:00',NULL,32,0,0,0,'QC-02','YC-09','IT-14~15','approved',0);

-- 12. 移动流水 (60条)
INSERT INTO container_move_logs (log_id, container_id, from_slot_id, to_slot_id, move_time, operator_name, operation_id, equipment_id, remark) VALUES
(1,'ONEE7000093','A-15-06','C-10-03','2026-05-30 11:44:18','操作员6号','YM-20260530-001','YC-07','卸船落箱'),
(2,'MSCU7000167','C-14-03','A-03-03','2026-05-30 09:42:13','操作员8号','YM-20260530-002','YC-02','卸船落箱'),
(3,'HMMU7000120','A-03-06','B-11-04','2026-05-30 08:44:01','操作员16号','YM-20260530-003','YC-05','卸船落箱'),
(4,'HMMU7000118','C-15-06','C-04-05','2026-05-30 10:12:43','操作员18号','YM-20260530-004','YC-07','卸船落箱'),
(5,'MAEU7000168','A-09-02','A-13-04','2026-05-30 09:47:50','操作员9号','YM-20260530-005','YC-02','卸船落箱'),
(6,'YMLU7000134','C-09-06','A-06-01','2026-05-30 08:41:41','操作员9号','YM-20260530-006','YC-01','卸船落箱'),
(7,'ZIMU7000110','B-10-06','C-01-02','2026-05-30 08:06:17','操作员7号','YM-20260530-007','YC-06','卸船落箱'),
(8,'MAEU7000071','C-03-03','A-14-04','2026-05-30 11:03:46','操作员15号','YM-20260530-008','YC-06','卸船落箱'),
(9,'COSU7000098','C-07-04','A-07-03','2026-05-30 10:09:44','操作员9号','YM-20260530-009','YC-07','卸船落箱'),
(10,'COSU7000103','B-10-02','A-15-04','2026-05-30 08:55:09','操作员1号','YM-20260530-010','YC-03','卸船落箱'),
(11,'EISU7000129','B-14-05','B-08-05','2026-05-30 08:42:21','操作员18号','YM-20260530-011','YC-01','卸船落箱'),
(12,'MAEU7000041','C-09-02','C-13-02','2026-05-30 11:51:43','操作员15号','YM-20260530-012','YC-02','卸船落箱'),
(13,'ZIMU7000125','C-14-04','C-08-01','2026-05-30 11:31:32','操作员9号','YM-20260530-013','YC-07','卸船落箱'),
(14,'HMMU7000198','A-03-03','C-08-06','2026-05-30 11:29:34','操作员12号','YM-20260530-014','YC-06','卸船落箱'),
(15,'ONEE7000126','B-08-02','C-10-03','2026-05-30 10:00:47','操作员12号','YM-20260530-015','YC-06','卸船落箱'),
(16,'HLBU7000196','B-06-02','B-10-03','2026-05-30 10:31:03','操作员18号','YM-20260530-016','YC-08','卸船落箱'),
(17,'EISU7000129','B-08-02','B-05-06','2026-05-30 07:25:57','操作员6号','YM-20260530-017','YC-05','卸船落箱'),
(18,'YMLU7000199','B-03-05','C-06-03','2026-05-30 10:04:31','操作员15号','YM-20260530-018','YC-05','卸船落箱'),
(19,'YMLU7000134','B-11-02','C-03-04','2026-05-30 09:02:52','操作员7号','YM-20260530-019','YC-03','卸船落箱'),
(20,'ZIMU7000004','A-06-03','A-02-03','2026-05-30 10:10:53','操作员5号','YM-20260530-020','YC-01','卸船落箱'),
(21,'ZIMU7000053','B-06-03','C-03-02','2026-05-30 09:02:20','操作员17号','YM-20260530-021','YC-01','卸船落箱'),
(22,'COSU7000122','C-05-04','C-12-05','2026-05-30 11:51:21','操作员10号','YM-20260530-022','YC-06','卸船落箱'),
(23,'COSU7000122','A-02-03','A-08-05','2026-05-30 07:55:24','操作员19号','YM-20260530-023','YC-03','卸船落箱'),
(24,'CMAU7000157','B-12-03','B-10-03','2026-05-30 08:28:05','操作员16号','YM-20260530-024','YC-05','卸船落箱'),
(25,'YMLU7000081','A-15-05','B-05-02','2026-05-30 08:20:55','操作员4号','YM-20260530-025','YC-02','卸船落箱'),
(26,'HMMU7000084','B-01-01','C-04-04','2026-05-30 11:28:12','操作员13号','YM-20260530-026','YC-07','场内归位翻箱'),
(27,'COSU7000124','B-15-06','C-14-01','2026-05-30 07:19:29','操作员7号','YM-20260530-027','YC-03','场内归位翻箱'),
(28,'MSCU7000058','A-07-02','A-09-06','2026-05-30 09:23:08','操作员18号','YM-20260530-028','YC-08','场内归位翻箱'),
(29,'MSCU7000123','A-03-02','B-03-03','2026-05-30 08:46:28','操作员9号','YM-20260530-029','YC-05','场内归位翻箱'),
(30,'ZIMU7000004','B-10-02','B-01-06','2026-05-30 07:36:49','操作员14号','YM-20260530-030','YC-05','场内归位翻箱'),
(31,'HLBU7000045','C-13-04','A-08-02','2026-05-30 09:59:56','操作员7号','YM-20260530-031','YC-02','场内归位翻箱'),
(32,'EISU7000077','B-13-02','B-04-04','2026-05-30 09:36:05','操作员17号','YM-20260530-032','YC-04','场内归位翻箱'),
(33,'CMAU7000131','A-07-01','B-02-03','2026-05-30 11:21:51','操作员16号','YM-20260530-033','YC-05','场内归位翻箱'),
(34,'YMLU7000193','B-06-02','A-09-02','2026-05-30 09:34:24','操作员13号','YM-20260530-034','YC-03','场内归位翻箱'),
(35,'MSCU7000167','C-04-02','A-02-06','2026-05-30 08:23:44','操作员5号','YM-20260530-035','YC-01','场内归位翻箱'),
(36,'ZIMU7000185','B-13-03','A-05-03','2026-05-30 10:23:56','操作员3号','YM-20260530-036','YC-02','场内归位翻箱'),
(37,'ONEE7000174','C-15-01','B-11-01','2026-05-30 10:57:52','操作员20号','YM-20260530-037','YC-06','场内归位翻箱'),
(38,'COSU7000139','B-12-04','C-15-02','2026-05-30 11:58:03','操作员6号','YM-20260530-038','YC-08','场内归位翻箱'),
(39,'ZIMU7000020','A-05-04','C-15-03','2026-05-30 08:34:53','操作员13号','YM-20260530-039','YC-06','场内归位翻箱'),
(40,'ONEE7000190','B-15-06','C-12-06','2026-05-30 07:20:22','操作员3号','YM-20260530-040','YC-04','场内归位翻箱'),
(41,'ONEE7000014','A-12-06','A-09-04','2026-05-30 10:04:19','操作员13号','YM-20260530-041','YC-06','场内归位翻箱'),
(42,'EISU7000094','B-04-05','C-15-06','2026-05-30 08:44:10','操作员7号','YM-20260530-042','YC-05','场内归位翻箱'),
(43,'YMLU7000134','C-08-04','B-14-01','2026-05-30 07:59:48','操作员6号','YM-20260530-043','YC-03','场内归位翻箱'),
(44,'COSU7000103','B-11-03','B-08-03','2026-05-30 11:51:02','操作员17号','YM-20260530-044','YC-03','场内归位翻箱'),
(45,'CMAU7000057','B-12-04','C-10-02','2026-05-30 09:13:00','操作员11号','YM-20260530-045','YC-01','场内归位翻箱'),
(46,'MAEU7000178','C-08-03','A-03-02','2026-05-30 11:08:09','操作员15号','YM-20260530-046','YC-06','场内归位翻箱'),
(47,'HMMU7000084','B-12-05','B-04-05','2026-05-30 09:35:53','操作员8号','YM-20260530-047','YC-05','场内归位翻箱'),
(48,'COSU7000073','C-04-04','B-14-05','2026-05-30 09:42:22','操作员3号','YM-20260530-048','YC-06','场内归位翻箱'),
(49,'MSCU7000187','C-15-03','B-10-03','2026-05-30 11:54:10','操作员20号','YM-20260530-049','YC-02','场内归位翻箱'),
(50,'MAEU7000119','A-11-04','B-02-02','2026-05-30 10:05:40','操作员7号','YM-20260530-050','YC-08','场内归位翻箱'),
(51,'MSCU7000055','A-13-04','B-01-03','2026-05-30 10:23:09','操作员14号','YM-20260530-051','YC-01','装船提箱'),
(52,'YMLU7000081','C-11-04','C-08-04','2026-05-30 10:03:20','操作员4号','YM-20260530-052','YC-04','装船提箱'),
(53,'YMLU7000199','C-11-02','C-03-05','2026-05-30 07:09:21','操作员8号','YM-20260530-053','YC-03','装船提箱'),
(54,'HLBU7000088','C-11-02','B-12-02','2026-05-30 08:29:02','操作员16号','YM-20260530-054','YC-04','装船提箱'),
(55,'COSU7000007','C-05-02','A-02-02','2026-05-30 11:03:34','操作员13号','YM-20260530-055','YC-03','装船提箱'),
(56,'ONEE7000115','C-12-05','B-03-03','2026-05-30 08:26:17','操作员9号','YM-20260530-056','YC-06','装船提箱'),
(57,'MAEU7000041','C-11-04','B-08-04','2026-05-30 08:26:40','操作员18号','YM-20260530-057','YC-01','装船提箱'),
(58,'EISU7000069','B-15-01','A-03-03','2026-05-30 07:18:44','操作员4号','YM-20260530-058','YC-08','装船提箱'),
(59,'MAEU7000041','C-03-05','A-12-05','2026-05-30 09:43:43','操作员5号','YM-20260530-059','YC-03','装船提箱'),
(60,'ONEE7000086','A-01-06','B-09-02','2026-05-30 08:57:04','操作员13号','YM-20260530-060','YC-06','装船提箱');

-- 13. 告警 (7条)
INSERT INTO alerts (alert_type, alert_level, alert_title, alert_content, related_record_type, related_record_id, is_resolved, created_at) VALUES
('overdue','warning','集装箱超期滞留','箱号 MAEU7000044 已超期5天','yard_container_inventory','MAEU7000044',0,'2026-05-30 08:00:00'),
('overdue','critical','集装箱严重超期','箱号 HMMU7000049 已超期12天','yard_container_inventory','HMMU7000049',0,'2026-05-30 07:30:00'),
('congestion','warning','A区进口箱区89%满载','A区利用率接近饱和，建议启动疏港','yard_zones','A',0,'2026-05-30 09:15:00'),
('congestion','info','B区出口箱区83%满载','B区利用率持续上升','yard_zones','B',0,'2026-05-30 09:45:00'),
('equipment','info','QC-03保养提醒','QC-03已运行400小时','dispatch_orders','DI-T03',0,'2026-05-30 10:00:00'),
('schedule','warning','MSC-0921靠泊延误','延误15分钟','sea_terminal_io','MSC-0921',0,'2026-05-30 09:50:00'),
('overdue','critical','集装箱滞留超15天','箱号 ONEE7000032 滞留16天','yard_container_inventory','ONEE7000032',0,'2026-05-30 06:00:00');

-- 14. 箱位状态 (A:80/90 B:75/90 C:45/90)
UPDATE yard_slots SET slot_status='occupied', current_container_id='MAEU7000001' WHERE slot_id='A-13-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='CMAU7000002' WHERE slot_id='A-02-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MAEU7000003' WHERE slot_id='A-04-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ZIMU7000004' WHERE slot_id='A-07-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ZIMU7000005' WHERE slot_id='A-02-02';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HLBU7000006' WHERE slot_id='A-13-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='COSU7000007' WHERE slot_id='A-05-02';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ONEE7000008' WHERE slot_id='A-10-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HLBU7000009' WHERE slot_id='A-04-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='YMLU7000010' WHERE slot_id='A-12-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HMMU7000011' WHERE slot_id='A-12-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='CMAU7000012' WHERE slot_id='A-15-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HMMU7000013' WHERE slot_id='A-06-02';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ONEE7000014' WHERE slot_id='A-09-05';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ZIMU7000015' WHERE slot_id='A-01-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HMMU7000016' WHERE slot_id='A-08-05';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MAEU7000017' WHERE slot_id='A-12-02';
UPDATE yard_slots SET slot_status='occupied', current_container_id='CMAU7000018' WHERE slot_id='A-10-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='YMLU7000019' WHERE slot_id='A-09-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ZIMU7000020' WHERE slot_id='A-01-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='CMAU7000021' WHERE slot_id='A-14-02';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ZIMU7000022' WHERE slot_id='A-07-05';
UPDATE yard_slots SET slot_status='occupied', current_container_id='COSU7000023' WHERE slot_id='A-04-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MSCU7000024' WHERE slot_id='A-11-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='CMAU7000025' WHERE slot_id='A-05-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ZIMU7000026' WHERE slot_id='A-13-05';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HLBU7000027' WHERE slot_id='A-15-02';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MAEU7000028' WHERE slot_id='A-08-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HLBU7000029' WHERE slot_id='A-13-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='CMAU7000030' WHERE slot_id='A-15-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ONEE7000031' WHERE slot_id='A-10-02';
UPDATE yard_slots SET slot_status='occupied', current_container_id='CMAU7000032' WHERE slot_id='A-04-05';
UPDATE yard_slots SET slot_status='occupied', current_container_id='YMLU7000033' WHERE slot_id='A-09-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ONEE7000034' WHERE slot_id='A-04-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ZIMU7000035' WHERE slot_id='A-06-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HLBU7000036' WHERE slot_id='A-15-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ONEE7000037' WHERE slot_id='A-06-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='CMAU7000038' WHERE slot_id='A-09-02';
UPDATE yard_slots SET slot_status='occupied', current_container_id='CMAU7000039' WHERE slot_id='A-02-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ONEE7000040' WHERE slot_id='A-15-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MAEU7000041' WHERE slot_id='A-09-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='CMAU7000042' WHERE slot_id='A-03-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MSCU7000043' WHERE slot_id='A-12-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HLBU7000044' WHERE slot_id='A-02-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HLBU7000045' WHERE slot_id='A-02-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='YMLU7000046' WHERE slot_id='A-12-05';
UPDATE yard_slots SET slot_status='occupied', current_container_id='COSU7000047' WHERE slot_id='A-07-02';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ZIMU7000048' WHERE slot_id='A-10-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MAEU7000049' WHERE slot_id='A-06-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='EISU7000050' WHERE slot_id='A-10-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='CMAU7000051' WHERE slot_id='A-13-02';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HMMU7000052' WHERE slot_id='A-07-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ZIMU7000053' WHERE slot_id='A-01-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HLBU7000054' WHERE slot_id='A-11-05';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MSCU7000055' WHERE slot_id='A-08-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ZIMU7000056' WHERE slot_id='A-12-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='CMAU7000057' WHERE slot_id='A-14-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MSCU7000058' WHERE slot_id='A-07-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ZIMU7000059' WHERE slot_id='A-03-02';
UPDATE yard_slots SET slot_status='occupied', current_container_id='YMLU7000060' WHERE slot_id='A-05-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='EISU7000061' WHERE slot_id='A-14-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MAEU7000062' WHERE slot_id='A-03-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='COSU7000063' WHERE slot_id='A-11-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='COSU7000064' WHERE slot_id='A-15-05';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HMMU7000065' WHERE slot_id='A-04-02';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HMMU7000066' WHERE slot_id='A-03-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HLBU7000067' WHERE slot_id='A-14-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MSCU7000068' WHERE slot_id='A-05-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='EISU7000069' WHERE slot_id='A-02-05';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HLBU7000070' WHERE slot_id='A-08-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MAEU7000071' WHERE slot_id='A-06-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='EISU7000072' WHERE slot_id='A-11-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='COSU7000073' WHERE slot_id='A-10-05';
UPDATE yard_slots SET slot_status='occupied', current_container_id='COSU7000074' WHERE slot_id='A-05-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='EISU7000075' WHERE slot_id='A-01-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='COSU7000076' WHERE slot_id='A-07-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='EISU7000077' WHERE slot_id='A-06-05';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MSCU7000078' WHERE slot_id='A-03-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MSCU7000079' WHERE slot_id='A-05-05';
UPDATE yard_slots SET slot_status='occupied', current_container_id='CMAU7000080' WHERE slot_id='A-01-05';
UPDATE yard_slots SET slot_status='occupied', current_container_id='YMLU7000081' WHERE slot_id='B-11-05';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MSCU7000082' WHERE slot_id='B-09-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='YMLU7000083' WHERE slot_id='B-11-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HMMU7000084' WHERE slot_id='B-13-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MAEU7000085' WHERE slot_id='B-08-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ONEE7000086' WHERE slot_id='B-02-05';
UPDATE yard_slots SET slot_status='occupied', current_container_id='EISU7000087' WHERE slot_id='B-05-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HLBU7000088' WHERE slot_id='B-10-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='CMAU7000089' WHERE slot_id='B-02-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='COSU7000090' WHERE slot_id='B-02-02';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HMMU7000091' WHERE slot_id='B-04-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='CMAU7000092' WHERE slot_id='B-04-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ONEE7000093' WHERE slot_id='B-11-02';
UPDATE yard_slots SET slot_status='occupied', current_container_id='EISU7000094' WHERE slot_id='B-13-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ONEE7000095' WHERE slot_id='B-07-02';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MAEU7000096' WHERE slot_id='B-15-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='YMLU7000097' WHERE slot_id='B-01-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='COSU7000098' WHERE slot_id='B-03-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MSCU7000099' WHERE slot_id='B-13-02';
UPDATE yard_slots SET slot_status='occupied', current_container_id='CMAU7000100' WHERE slot_id='B-12-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MAEU7000101' WHERE slot_id='B-09-05';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MSCU7000102' WHERE slot_id='B-01-02';
UPDATE yard_slots SET slot_status='occupied', current_container_id='COSU7000103' WHERE slot_id='B-05-05';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ONEE7000104' WHERE slot_id='B-05-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='COSU7000105' WHERE slot_id='B-01-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ONEE7000106' WHERE slot_id='B-03-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='CMAU7000107' WHERE slot_id='B-01-05';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HMMU7000108' WHERE slot_id='B-06-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ZIMU7000109' WHERE slot_id='B-14-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ZIMU7000110' WHERE slot_id='B-12-05';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HMMU7000111' WHERE slot_id='B-12-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HLBU7000112' WHERE slot_id='B-08-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MAEU7000113' WHERE slot_id='B-09-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='CMAU7000114' WHERE slot_id='B-02-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ONEE7000115' WHERE slot_id='B-04-02';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HMMU7000116' WHERE slot_id='B-03-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='YMLU7000117' WHERE slot_id='B-01-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HMMU7000118' WHERE slot_id='B-14-02';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MAEU7000119' WHERE slot_id='B-07-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HMMU7000120' WHERE slot_id='B-10-05';
UPDATE yard_slots SET slot_status='occupied', current_container_id='CMAU7000121' WHERE slot_id='B-09-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='COSU7000122' WHERE slot_id='B-08-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MSCU7000123' WHERE slot_id='B-10-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='COSU7000124' WHERE slot_id='B-07-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ZIMU7000125' WHERE slot_id='B-14-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ONEE7000126' WHERE slot_id='B-03-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MSCU7000127' WHERE slot_id='B-15-02';
UPDATE yard_slots SET slot_status='occupied', current_container_id='YMLU7000128' WHERE slot_id='B-14-05';
UPDATE yard_slots SET slot_status='occupied', current_container_id='EISU7000129' WHERE slot_id='B-07-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='COSU7000130' WHERE slot_id='B-11-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='CMAU7000131' WHERE slot_id='B-05-02';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ONEE7000132' WHERE slot_id='B-15-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='COSU7000133' WHERE slot_id='B-14-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='YMLU7000134' WHERE slot_id='B-04-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MSCU7000135' WHERE slot_id='B-15-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MSCU7000136' WHERE slot_id='B-09-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='CMAU7000137' WHERE slot_id='B-14-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='CMAU7000138' WHERE slot_id='B-06-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='COSU7000139' WHERE slot_id='B-02-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HLBU7000140' WHERE slot_id='B-06-02';
UPDATE yard_slots SET slot_status='occupied', current_container_id='CMAU7000141' WHERE slot_id='B-08-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='YMLU7000142' WHERE slot_id='B-10-02';
UPDATE yard_slots SET slot_status='occupied', current_container_id='EISU7000143' WHERE slot_id='B-13-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HMMU7000144' WHERE slot_id='B-06-05';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HLBU7000145' WHERE slot_id='B-13-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HLBU7000146' WHERE slot_id='B-03-05';
UPDATE yard_slots SET slot_status='occupied', current_container_id='EISU7000147' WHERE slot_id='B-15-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MSCU7000148' WHERE slot_id='B-10-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HMMU7000149' WHERE slot_id='B-05-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='COSU7000150' WHERE slot_id='B-06-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ONEE7000151' WHERE slot_id='B-10-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ONEE7000152' WHERE slot_id='B-01-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MAEU7000153' WHERE slot_id='B-05-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ZIMU7000154' WHERE slot_id='B-03-02';
UPDATE yard_slots SET slot_status='occupied', current_container_id='YMLU7000155' WHERE slot_id='B-09-02';
UPDATE yard_slots SET slot_status='occupied', current_container_id='CMAU7000156' WHERE slot_id='C-01-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='CMAU7000157' WHERE slot_id='C-02-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='YMLU7000158' WHERE slot_id='C-07-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ONEE7000159' WHERE slot_id='C-15-02';
UPDATE yard_slots SET slot_status='occupied', current_container_id='EISU7000160' WHERE slot_id='C-15-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ONEE7000161' WHERE slot_id='C-11-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MSCU7000162' WHERE slot_id='C-06-02';
UPDATE yard_slots SET slot_status='occupied', current_container_id='COSU7000163' WHERE slot_id='C-12-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='YMLU7000164' WHERE slot_id='C-09-02';
UPDATE yard_slots SET slot_status='occupied', current_container_id='CMAU7000165' WHERE slot_id='C-13-05';
UPDATE yard_slots SET slot_status='occupied', current_container_id='COSU7000166' WHERE slot_id='C-11-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MSCU7000167' WHERE slot_id='C-05-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MAEU7000168' WHERE slot_id='C-07-02';
UPDATE yard_slots SET slot_status='occupied', current_container_id='COSU7000169' WHERE slot_id='C-14-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ONEE7000170' WHERE slot_id='C-06-05';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ZIMU7000171' WHERE slot_id='C-13-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MAEU7000172' WHERE slot_id='C-13-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MAEU7000173' WHERE slot_id='C-14-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ONEE7000174' WHERE slot_id='C-15-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HLBU7000175' WHERE slot_id='C-06-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='CMAU7000176' WHERE slot_id='C-09-05';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HLBU7000177' WHERE slot_id='C-14-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MAEU7000178' WHERE slot_id='C-01-05';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ONEE7000179' WHERE slot_id='C-11-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='EISU7000180' WHERE slot_id='C-07-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='CMAU7000181' WHERE slot_id='C-02-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HLBU7000182' WHERE slot_id='C-03-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='EISU7000183' WHERE slot_id='C-03-05';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HMMU7000184' WHERE slot_id='C-03-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ZIMU7000185' WHERE slot_id='C-01-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HLBU7000186' WHERE slot_id='C-10-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MSCU7000187' WHERE slot_id='C-04-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MAEU7000188' WHERE slot_id='C-04-01';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HLBU7000189' WHERE slot_id='C-03-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ONEE7000190' WHERE slot_id='C-02-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MSCU7000191' WHERE slot_id='C-10-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ONEE7000192' WHERE slot_id='C-01-02';
UPDATE yard_slots SET slot_status='occupied', current_container_id='YMLU7000193' WHERE slot_id='C-08-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HMMU7000194' WHERE slot_id='C-09-04';
UPDATE yard_slots SET slot_status='occupied', current_container_id='MAEU7000195' WHERE slot_id='C-12-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HLBU7000196' WHERE slot_id='C-09-06';
UPDATE yard_slots SET slot_status='occupied', current_container_id='CMAU7000197' WHERE slot_id='C-14-02';
UPDATE yard_slots SET slot_status='occupied', current_container_id='HMMU7000198' WHERE slot_id='C-09-03';
UPDATE yard_slots SET slot_status='occupied', current_container_id='YMLU7000199' WHERE slot_id='C-02-05';
UPDATE yard_slots SET slot_status='occupied', current_container_id='ONEE7000200' WHERE slot_id='C-07-04';

SET FOREIGN_KEY_CHECKS = 1;
