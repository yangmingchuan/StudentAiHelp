-- Little Hero MVP foundation schema.
-- Target: CloudBase MySQL. This file is intentionally limited to Phase 2 tables.

CREATE TABLE IF NOT EXISTS parent_profiles (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  auth_subject VARCHAR(128) NOT NULL,
  username VARCHAR(32) NOT NULL,
  phone_masked VARCHAR(32) DEFAULT '' NOT NULL,
  display_name VARCHAR(32) DEFAULT '' NOT NULL,
  phone_ownership_verified TINYINT(1) DEFAULT 0 NOT NULL,
  privacy_policy_version VARCHAR(32) DEFAULT '' NOT NULL,
  child_privacy_rule_version VARCHAR(32) DEFAULT '' NOT NULL,
  consent_at DATETIME NULL,
  last_login_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  UNIQUE KEY uk_parent_auth_subject (auth_subject),
  UNIQUE KEY uk_parent_username (username),
  KEY idx_parent_openid (_openid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS children (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  parent_id BIGINT UNSIGNED NOT NULL,
  nickname VARCHAR(16) NOT NULL,
  gender VARCHAR(16) DEFAULT 'unknown' NOT NULL,
  age_stage VARCHAR(16) DEFAULT '5-6' NOT NULL,
  avatar_config JSON NULL,
  level INT UNSIGNED DEFAULT 1 NOT NULL,
  experience INT UNSIGNED DEFAULT 0 NOT NULL,
  is_active TINYINT(1) DEFAULT 1 NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  KEY idx_children_parent (parent_id, is_active),
  KEY idx_children_openid (_openid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS child_settings (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  child_id BIGINT UNSIGNED NOT NULL,
  timezone VARCHAR(64) DEFAULT 'Asia/Shanghai' NOT NULL,
  daily_heart_limit INT UNSIGNED DEFAULT 10 NOT NULL,
  parent_gate_enabled TINYINT(1) DEFAULT 1 NOT NULL,
  sound_enabled TINYINT(1) DEFAULT 1 NOT NULL,
  music_enabled TINYINT(1) DEFAULT 1 NOT NULL,
  max_daily_learning_minutes INT UNSIGNED DEFAULT 30 NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_child_settings_child (child_id),
  KEY idx_child_settings_openid (_openid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS habit_templates (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  code VARCHAR(64) NOT NULL,
  name VARCHAR(16) NOT NULL,
  icon_name VARCHAR(32) NOT NULL,
  category VARCHAR(32) NOT NULL,
  recommended_age_min TINYINT UNSIGNED DEFAULT 3 NOT NULL,
  recommended_age_max TINYINT UNSIGNED DEFAULT 6 NOT NULL,
  default_enabled TINYINT(1) DEFAULT 0 NOT NULL,
  sort_order INT UNSIGNED DEFAULT 0 NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_habit_template_code (code),
  KEY idx_habit_templates_default (default_enabled, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS habits (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  child_id BIGINT UNSIGNED NOT NULL,
  template_code VARCHAR(64) DEFAULT '' NOT NULL,
  name VARCHAR(16) NOT NULL,
  icon_name VARCHAR(32) NOT NULL,
  category VARCHAR(32) DEFAULT 'custom' NOT NULL,
  is_active TINYINT(1) DEFAULT 1 NOT NULL,
  sort_order INT UNSIGNED DEFAULT 0 NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  KEY idx_habits_child (_openid, child_id, is_active),
  KEY idx_habits_sort (child_id, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS habit_records (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  child_id BIGINT UNSIGNED NOT NULL,
  habit_id BIGINT UNSIGNED NOT NULL,
  record_date DATE NOT NULL,
  status VARCHAR(16) DEFAULT 'none' NOT NULL,
  operation_id VARCHAR(64) DEFAULT '' NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_habit_record_day (child_id, habit_id, record_date),
  KEY idx_habit_records_child_date (_openid, child_id, record_date),
  KEY idx_habit_records_operation (operation_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS child_asset_snapshots (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  child_id BIGINT UNSIGNED NOT NULL,
  available_stars INT UNSIGNED DEFAULT 0 NOT NULL,
  lifetime_stars INT UNSIGNED DEFAULT 0 NOT NULL,
  badge_count INT UNSIGNED DEFAULT 0 NOT NULL,
  today_hearts_remaining INT UNSIGNED DEFAULT 10 NOT NULL,
  today_hearts_limit INT UNSIGNED DEFAULT 10 NOT NULL,
  snapshot_date DATE NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_asset_snapshot_child_date (child_id, snapshot_date),
  KEY idx_asset_snapshots_openid (_openid, child_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS daily_hearts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  child_id BIGINT UNSIGNED NOT NULL,
  heart_date DATE NOT NULL,
  total_limit INT UNSIGNED DEFAULT 10 NOT NULL,
  used_count INT UNSIGNED DEFAULT 0 NOT NULL,
  remaining_count INT UNSIGNED DEFAULT 10 NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_daily_hearts_child_date (child_id, heart_date),
  KEY idx_daily_hearts_openid (_openid, child_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS star_transactions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  child_id BIGINT UNSIGNED NOT NULL,
  operation_id VARCHAR(64) NOT NULL,
  source_type VARCHAR(32) NOT NULL,
  source_id BIGINT UNSIGNED NULL,
  delta INT NOT NULL,
  balance_after INT UNSIGNED NOT NULL,
  lifetime_after INT UNSIGNED NOT NULL,
  reason VARCHAR(100) DEFAULT '' NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_star_transactions_operation (operation_id, source_type),
  KEY idx_star_transactions_child (_openid, child_id, created_at),
  KEY idx_star_transactions_source (source_type, source_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS badge_templates (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  code VARCHAR(64) NOT NULL,
  name VARCHAR(32) NOT NULL,
  category VARCHAR(32) NOT NULL,
  icon_name VARCHAR(32) NOT NULL,
  requirement_type VARCHAR(64) NOT NULL,
  requirement_payload JSON NOT NULL,
  sort_order INT UNSIGNED DEFAULT 0 NOT NULL,
  is_active TINYINT(1) DEFAULT 1 NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_badge_template_code (code),
  KEY idx_badge_templates_category (category, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS child_badges (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  child_id BIGINT UNSIGNED NOT NULL,
  badge_code VARCHAR(64) NOT NULL,
  earned_date DATE NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_child_badge (child_id, badge_code),
  KEY idx_child_badges_openid (_openid, child_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS idempotency_operations (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  operation_id VARCHAR(64) NOT NULL,
  operation_type VARCHAR(64) NOT NULL,
  actor_subject VARCHAR(128) NOT NULL,
  request_hash VARCHAR(128) DEFAULT '' NOT NULL,
  response_payload JSON NULL,
  status VARCHAR(16) DEFAULT 'succeeded' NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_idempotency_operation (operation_id),
  KEY idx_idempotency_actor (actor_subject, operation_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO habit_templates
  (code, name, icon_name, category, recommended_age_min, recommended_age_max, default_enabled, sort_order)
VALUES
  ('brush_teeth', '自己刷牙', 'clean_hands_rounded', 'daily_care', 3, 6, 1, 10),
  ('make_bed', '整理床铺', 'bed_rounded', 'daily_care', 4, 6, 1, 20),
  ('read_book', '阅读绘本', 'auto_stories_rounded', 'learning', 3, 6, 1, 30)
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  icon_name = VALUES(icon_name),
  category = VALUES(category),
  default_enabled = VALUES(default_enabled),
  sort_order = VALUES(sort_order);

INSERT INTO badge_templates
  (code, name, category, icon_name, requirement_type, requirement_payload, sort_order)
VALUES
  ('first_star', '第一颗星', 'task', 'star_rounded', 'lifetime_stars_at_least', JSON_OBJECT('count', 1), 10),
  ('three_done_day', '全完成日', 'task', 'workspace_premium_rounded', 'full_completion_days_at_least', JSON_OBJECT('count', 1), 20),
  ('seven_day_streak', '七天勇士', 'task', 'local_fire_department_rounded', 'full_completion_streak_at_least', JSON_OBJECT('days', 7), 30)
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  icon_name = VALUES(icon_name),
  requirement_type = VALUES(requirement_type),
  requirement_payload = VALUES(requirement_payload),
  sort_order = VALUES(sort_order);
