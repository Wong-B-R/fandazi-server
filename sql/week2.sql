-- 第 2 周建表：约饭核心流程（发起、浏览列表、筛选、详情、我的饭局、加入、退出、取消）
-- 组员7（数据库）：在 MySQL 的 fandazi 库里执行本文件，前提是已经执行过 week1.sql
-- v1.1（2026-11-26）：party 加 cancelled_at；pay_type 取值确定；window_name 改为可空
-- v1.2（2026-11-26）：对齐接口契约 v0.5.0 最终版。pay_type 去掉默认值，OWNER_PAY 定名“发起人先付”；user.status 扩成三态
-- v1.3（2026-11-26）：定稿。party 加 chk_party_cancelled_at；口味标签字典定为四个值
--
-- 执行说明：
--   1. 第三部分的新建表可以重复执行（IF NOT EXISTS）。
--   2. 第一、二部分是改 user 表。MySQL 不支持 ADD COLUMN IF NOT EXISTS，只能执行一次。
--   3. CHECK 约束要 MySQL 8.0.16 及以上才真正生效；5.7 会忽略，改由后端在接口里校验。
--   4. 标注【待确认】的只是取值，确认后改 COMMENT 即可，不影响表结构。

USE fandazi;

-- =====================================================================
-- 一、user 表：补账户状态（确定要加）
-- =====================================================================

-- “发起饭局”“加入饭局”都要求账户正常，第 1 周的 user 表没有这个字段
-- 接口的账户状态是三态：NORMAL 正常、RESTRICTED 受限、BANNED 封禁（契约 v0.5.0）
ALTER TABLE user
  ADD COLUMN status TINYINT NOT NULL DEFAULT 1 COMMENT '账户状态 1正常 2受限 0封禁' AFTER verified;

-- =====================================================================
-- 二、user 表：校园认证状态从 0/1 扩成 4 种
-- 【待确认】郭锦旋（认证字段与权限约定）、陈国鋆（登录认证状态原型）
-- =====================================================================
-- 任务描述里要求区分：未认证 / 待审核 / 已通过 / 已驳回，
-- 原来的 verified（0/1）只能表达“未认证 / 已通过”。
-- 如果确认仍按第 1 周的做法（邮箱验证码自动通过，没有审核环节），这一段整段不执行。

ALTER TABLE user
  ADD COLUMN verify_status TINYINT NOT NULL DEFAULT 0 COMMENT '校园认证状态 0未认证 1待审核 2已通过 3已驳回' AFTER campus_email;

-- 已经认证过的老用户按原字段回填
UPDATE user SET verify_status = 2 WHERE verified = 1;

-- =====================================================================
-- 三、新表
-- =====================================================================

-- 饭局
-- 口味筛选不加字段：按发起人的口味标签筛，party.owner_id 关联 user_taste.user_id（见设计文档 6.3）
-- 午饭/晚饭不加字段：按 meal_time 所在时间段判（见设计文档 6.3）
CREATE TABLE IF NOT EXISTS party (
  id            BIGINT       PRIMARY KEY AUTO_INCREMENT,
  owner_id      BIGINT       NOT NULL COMMENT '发起人，user.id',
  meal_time     DATETIME     NOT NULL COMMENT '约饭时间',
  canteen_id    BIGINT       NOT NULL COMMENT '食堂，canteen.id',
  window_name   VARCHAR(32)  NULL DEFAULT NULL COMMENT '窗口或店铺名称，选填，未填为 NULL',
  max_count     TINYINT      NOT NULL COMMENT '人数上限，2到6，含发起人',
  current_count TINYINT      NOT NULL DEFAULT 1 COMMENT '当前人数，含发起人',
  pay_type      TINYINT      NOT NULL COMMENT '付款方式 1AA 2各付各的 3发起人先付，必填无默认值',
  remark        VARCHAR(255) NOT NULL DEFAULT '' COMMENT '备注',
  status        TINYINT      NOT NULL DEFAULT 1 COMMENT '1报名中 2已满员 3已取消 4已结束',
  cancelled_at  DATETIME     NULL DEFAULT NULL COMMENT '取消时间，发起人取消饭局时写入，未取消为 NULL',
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_owner (owner_id),
  KEY idx_status_time (status, meal_time),
  KEY idx_canteen (canteen_id),
  CONSTRAINT chk_party_max_count CHECK (max_count BETWEEN 2 AND 6),
  CONSTRAINT chk_party_current_count CHECK (current_count >= 1 AND current_count <= max_count),
  CONSTRAINT chk_party_cancelled_at CHECK ((status = 3 AND cancelled_at IS NOT NULL) OR (status <> 3 AND cancelled_at IS NULL))
) COMMENT '饭局';

-- 饭局成员
CREATE TABLE IF NOT EXISTS party_member (
  id         BIGINT   PRIMARY KEY AUTO_INCREMENT,
  party_id   BIGINT   NOT NULL COMMENT '饭局，party.id',
  user_id    BIGINT   NOT NULL COMMENT '成员，user.id',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '加入时间',
  UNIQUE KEY uk_party_user (party_id, user_id),
  KEY idx_user (user_id)
) COMMENT '饭局成员，一人在一个饭局里只有一条';

-- 行为事件
CREATE TABLE IF NOT EXISTS behavior_event (
  id         BIGINT   PRIMARY KEY AUTO_INCREMENT,
  user_id    BIGINT   NOT NULL COMMENT '行为人，user.id',
  party_id   BIGINT   NOT NULL COMMENT '关联饭局，party.id',
  event_type TINYINT  NOT NULL COMMENT '1迟退，其余第四周再定',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发生时间',
  KEY idx_user_time (user_id, created_at),
  KEY idx_party (party_id)
) COMMENT '行为事件，给第四周信用分用';

-- =====================================================================
-- 四、口味标签字典（v1.3）
-- 接口契约 v0.5.0 的口味标签只有四个值。库里继续存中文，由后端映射成接口代码：
--   爱吃辣 = SPICY、清淡 = LIGHT、素食 = VEGETARIAN、清真 = HALAL
-- 第 1 周接口文档里的“重口”“少油”没有对应的接口代码，停用。
-- 库里如果已经有这两个标签的数据，执行一次下面这条清理；没有数据就不用执行。
-- =====================================================================

-- DELETE FROM user_taste WHERE tag IN ('重口', '少油');
