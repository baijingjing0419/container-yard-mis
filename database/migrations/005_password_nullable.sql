-- ========================================================
-- 迁移 005: users.password_hash 改为 NULLABLE
--   NULL = 待员工首次登录设置密码
-- ========================================================
SET NAMES utf8mb4;

ALTER TABLE users MODIFY COLUMN password_hash VARCHAR(255) NULL COMMENT '密码哈希(NULL=待员工首次登录设置)';

SELECT 'Migration 005: users.password_hash now nullable.' AS result;
