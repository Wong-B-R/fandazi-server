-- 第 1 周建表：账户 + 转盘用到的食堂数据
-- 组员7：在 MySQL 里执行本文件（库名必须是 fandazi）

CREATE DATABASE IF NOT EXISTS fandazi
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE fandazi;

CREATE TABLE IF NOT EXISTS user (
  id            BIGINT PRIMARY KEY AUTO_INCREMENT,
  openid        VARCHAR(64)  NOT NULL UNIQUE COMMENT '微信 openid',
  nickname      VARCHAR(32)  NOT NULL DEFAULT '' COMMENT '昵称',
  avatar        VARCHAR(255) NOT NULL DEFAULT '' COMMENT '头像',
  college       VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '学院',
  grade         VARCHAR(16)  NOT NULL DEFAULT '' COMMENT '年级，如 2024',
  campus_email  VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '校园邮箱',
  verified      TINYINT      NOT NULL DEFAULT 0 COMMENT '0未认证 1已认证',
  credit_score  INT          NOT NULL DEFAULT 100 COMMENT '鸽子信用分',
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT '用户';

CREATE TABLE IF NOT EXISTS user_taste (
  id         BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id    BIGINT      NOT NULL,
  tag        VARCHAR(16) NOT NULL COMMENT '爱吃辣/清淡/素食/清真等',
  created_at DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_user_tag (user_id, tag),
  KEY idx_user (user_id)
) COMMENT '口味标签，每人 1～5 个';

CREATE TABLE IF NOT EXISTS email_code (
  id         BIGINT PRIMARY KEY AUTO_INCREMENT,
  email      VARCHAR(64) NOT NULL,
  code       VARCHAR(8)  NOT NULL,
  expire_at  DATETIME    NOT NULL,
  used       TINYINT     NOT NULL DEFAULT 0,
  created_at DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_email (email)
) COMMENT '校园邮箱验证码';

CREATE TABLE IF NOT EXISTS canteen (
  id      BIGINT PRIMARY KEY AUTO_INCREMENT,
  name    VARCHAR(32) NOT NULL UNIQUE,
  enabled TINYINT     NOT NULL DEFAULT 1
) COMMENT '食堂';

CREATE TABLE IF NOT EXISTS stall (
  id         BIGINT PRIMARY KEY AUTO_INCREMENT,
  canteen_id BIGINT      NOT NULL,
  name       VARCHAR(32) NOT NULL,
  KEY idx_canteen (canteen_id)
) COMMENT '窗口';

CREATE TABLE IF NOT EXISTS dish (
  id            BIGINT PRIMARY KEY AUTO_INCREMENT,
  stall_id      BIGINT      NOT NULL,
  name          VARCHAR(32) NOT NULL,
  is_signature  TINYINT     NOT NULL DEFAULT 0 COMMENT '招牌菜',
  KEY idx_stall (stall_id)
) COMMENT '菜品';

CREATE TABLE IF NOT EXISTS spin_log (
  id         BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id    BIGINT   NOT NULL,
  canteen_id BIGINT   NOT NULL,
  stall_id   BIGINT   NOT NULL,
  dish_id    BIGINT   NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_user_time (user_id, created_at)
) COMMENT '转盘记录，用来限制每天 5 次';

INSERT INTO canteen (name) VALUES
  ('荔园食堂'),
  ('风华食堂'),
  ('文山食堂'),
  ('西南食堂')
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT INTO stall (canteen_id, name)
SELECT id, '一楼套餐窗口' FROM canteen WHERE name = '荔园食堂';
INSERT INTO stall (canteen_id, name)
SELECT id, '二楼麻辣烫' FROM canteen WHERE name = '荔园食堂';
INSERT INTO stall (canteen_id, name)
SELECT id, '风华面档' FROM canteen WHERE name = '风华食堂';
INSERT INTO stall (canteen_id, name)
SELECT id, '风华小炒' FROM canteen WHERE name = '风华食堂';
INSERT INTO stall (canteen_id, name)
SELECT id, '文山自选' FROM canteen WHERE name = '文山食堂';
INSERT INTO stall (canteen_id, name)
SELECT id, '西南粉面' FROM canteen WHERE name = '西南食堂';

INSERT INTO dish (stall_id, name, is_signature)
SELECT id, '荔枝鸡腿饭', 1 FROM stall WHERE name = '一楼套餐窗口';
INSERT INTO dish (stall_id, name, is_signature)
SELECT id, '番茄肥牛米线', 1 FROM stall WHERE name = '二楼麻辣烫';
INSERT INTO dish (stall_id, name, is_signature)
SELECT id, '牛肉汤面', 1 FROM stall WHERE name = '风华面档';
INSERT INTO dish (stall_id, name, is_signature)
SELECT id, '农家小炒肉', 1 FROM stall WHERE name = '风华小炒';
INSERT INTO dish (stall_id, name, is_signature)
SELECT id, '香菇滑鸡', 1 FROM stall WHERE name = '文山自选';
INSERT INTO dish (stall_id, name, is_signature)
SELECT id, '桂林米粉', 1 FROM stall WHERE name = '西南粉面';
