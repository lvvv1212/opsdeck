-- LifeArchive 数据库初始化脚本
-- 运行前请确保已创建数据库: CREATE DATABASE life_archive DEFAULT CHARACTER SET utf8mb4;

-- 用户表
CREATE TABLE IF NOT EXISTS `user` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '用户ID',
    `username` VARCHAR(50) NOT NULL COMMENT '用户名',
    `password` VARCHAR(255) NOT NULL COMMENT '密码（BCrypt加密）',
    `email` VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
    `avatar` VARCHAR(255) DEFAULT NULL COMMENT '头像URL',
    `nickname` VARCHAR(50) DEFAULT NULL COMMENT '昵称',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除（0=未删除，1=已删除）',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`),
    UNIQUE KEY `uk_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 数字记忆表
CREATE TABLE IF NOT EXISTS `memory` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '记忆ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `title` VARCHAR(200) NOT NULL COMMENT '标题',
    `description` TEXT DEFAULT NULL COMMENT '描述',
    `content` TEXT DEFAULT NULL COMMENT '文本内容',
    `file_url` VARCHAR(500) DEFAULT NULL COMMENT '文件URL（图片/视频）',
    `file_type` VARCHAR(20) DEFAULT NULL COMMENT '文件类型（image/video/text）',
    `memory_type` VARCHAR(50) NOT NULL DEFAULT 'general' COMMENT '记忆类型（photo/video/diary/general）',
    `location` VARCHAR(200) DEFAULT NULL COMMENT '地点',
    `emotion` VARCHAR(50) DEFAULT NULL COMMENT '情绪',
    `tags` VARCHAR(500) DEFAULT NULL COMMENT '标签（JSON数组字符串）',
    `ai_summary` TEXT DEFAULT NULL COMMENT 'AI分析摘要',
    `event_time` DATETIME DEFAULT NULL COMMENT '事件发生时间',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_memory_type` (`memory_type`),
    KEY `idx_event_time` (`event_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数字记忆表';
