# 闯关小勇士 — CloudBase 数据库表设计

> 目标：方便在 CloudBase MySQL 中创建和维护业务表。  
> 账号体系：手机号 + 密码由 CloudBase Auth 维护，业务数据库不保存明文密码。  
> 数据归属：家长是账号主体，孩子是家长账号下的档案。

---

## 一、建库原则

### 1.1 使用 CloudBase MySQL

本项目建议使用 CloudBase MySQL，而不是文档型数据库，原因：

- 家长、孩子、习惯、打卡、学习记录、勋章、奖励之间关系明确。
- 后续数据看板需要按日期、孩子、能力点做统计。
- MySQL 表结构更适合维护模板内容和孩子行为记录。

### 1.2 CloudBase Auth 与业务表边界

CloudBase Auth 负责：

- 手机号注册。
- 密码登录。
- 登录态、AccessToken、RefreshToken。
- 找回密码 / 重置密码。

业务数据库负责：

- 家长业务资料。
- 孩子档案。
- 习惯与打卡。
- 数学/英语学习进度。
- 勋章与奖励。

**不要创建 `auth_users` 表，也不要在业务表保存密码。**

### 1.3 `_openid` 字段约定

CloudBase MySQL 建表建议包含：

```sql
_openid VARCHAR(64) DEFAULT '' NOT NULL
```

用途：

- 用户登录后写入数据时，CloudBase 可自动填充当前用户身份。
- 用户私有数据通过 `_openid` 做读写隔离。
- 模板表也保留 `_openid` 字段，系统模板数据可为空字符串。

### 1.4 命名规范

- 表名：小写蛇形，如 `habit_records`。
- 主键：统一使用 `id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY`。
- 时间字段：`created_at`、`updated_at`、`deleted_at`。
- 软删除：业务表优先使用 `deleted_at`，不要物理删除孩子成长记录。
- JSON 字段：配置类字段使用 `JSON`，例如头像配置、题目素材、答案配置。

### 1.5 固定知识、题目与媒体文件边界

- 固定知识仍建议保存在云端模板表中，安装包只内置某个已审核版本的内容快照。
- 大量相似数学题优先保存“生成模板 + 参数范围”，少量图形题、Boss 题和人工讲解题保存为固定题。
- 图片、音频、绘本页面等二进制文件放 CloudBase 云存储，MySQL 只保存资源键、版本、校验值和授权信息。
- Room 保存已发布内容的本地缓存；孩子答题、阅读和掌握度记录仍同步到云端。
- 任何商业绘本或配音资源在入库前都必须关联有效授权记录。

---

## 二、建表顺序

建议按以下顺序创建：

1. 账号与孩子：`parent_profiles`、`children`、`child_settings`
2. 习惯系统：`habit_templates`、`habits`、`habit_records`
3. 星星与心心：`daily_hearts`、`star_transactions`
4. 数学系统：`math_skills`、`math_islands`、`math_levels`、`math_question_templates`、`math_questions`、`math_attempts`、`math_skill_mastery`
5. 英语系统：`english_skills`、`english_contents`、`english_series`、`english_books`、`english_book_pages`、`english_audio_segments`、`english_book_questions`、`english_reading_progress`、`english_attempts`、`english_skill_mastery`
6. 勋章与奖励：`badge_templates`、`child_badges`、`rewards`、`reward_redemptions`
7. 内容资源：`content_licenses`、`content_packs`、`local_assets`
8. 统计日志：`app_event_logs`

---

## 三、表清单

| 表名 | 用途 | 数据归属 |
|------|------|---------|
| `parent_profiles` | 家长业务资料 | 家长私有 |
| `children` | 孩子档案 | 家长私有 |
| `child_settings` | 孩子设置 | 家长私有 |
| `habit_templates` | 习惯模板 | 系统只读 |
| `habits` | 家长配置的孩子习惯 | 家长私有 |
| `habit_records` | 每日打卡记录 | 家长私有 |
| `daily_hearts` | 每日小心心账户 | 家长私有 |
| `star_transactions` | 星星流水 | 家长私有 |
| `math_skills` | 数学能力点 | 系统只读 |
| `math_islands` | 数学岛屿 | 系统只读 |
| `math_levels` | 数学关卡 | 系统只读 |
| `math_question_templates` | 可参数化数学题模板 | 系统只读 |
| `math_questions` | 数学题目 | 系统只读 |
| `math_attempts` | 数学答题记录 | 家长私有 |
| `math_skill_mastery` | 数学能力掌握度 | 家长私有 |
| `english_skills` | 英语能力点 | 系统只读 |
| `english_contents` | 英语内容 | 系统只读 |
| `english_series` | 连续分级阅读系列 | 系统只读 |
| `english_books` | 分级绘本图书 | 系统只读 |
| `english_book_pages` | 绘本页面与文字 | 系统只读 |
| `english_audio_segments` | 整页、逐句和单词音频片段 | 系统只读 |
| `english_book_questions` | 绘本读后理解题 | 系统只读 |
| `english_reading_progress` | 孩子绘本阅读进度 | 家长私有 |
| `english_attempts` | 英语练习记录 | 家长私有 |
| `english_skill_mastery` | 英语能力掌握度 | 家长私有 |
| `badge_templates` | 勋章模板 | 系统只读 |
| `child_badges` | 孩子已获勋章 | 家长私有 |
| `rewards` | 家长配置奖励 | 家长私有 |
| `reward_redemptions` | 奖励兑换记录 | 家长私有 |
| `content_licenses` | 内容数字版权与有效期 | 后台私有 |
| `content_packs` | 内容包版本 | 系统只读 |
| `local_assets` | 资源索引 | 系统只读 |
| `app_event_logs` | 行为统计日志 | 家长私有 |

---

## 四、建表 SQL

> 说明：以下 SQL 偏向 MVP 可落地。外键先不强制创建，应用层保证关系正确，便于 CloudBase 控制台维护和后续迭代。

```sql
CREATE TABLE IF NOT EXISTS parent_profiles (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  phone_masked VARCHAR(32) DEFAULT '' NOT NULL,
  display_name VARCHAR(32) DEFAULT '' NOT NULL,
  privacy_policy_version VARCHAR(32) DEFAULT '' NOT NULL,
  child_privacy_rule_version VARCHAR(32) DEFAULT '' NOT NULL,
  consent_at DATETIME NULL,
  last_login_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  UNIQUE KEY uk_parent_openid (_openid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS children (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  nickname VARCHAR(16) NOT NULL,
  gender VARCHAR(16) DEFAULT 'unknown' NOT NULL,
  age_stage VARCHAR(16) DEFAULT '5-6' NOT NULL,
  birth_year SMALLINT UNSIGNED NULL,
  avatar_config JSON NULL,
  level INT UNSIGNED DEFAULT 1 NOT NULL,
  experience INT UNSIGNED DEFAULT 0 NOT NULL,
  star_count INT UNSIGNED DEFAULT 0 NOT NULL,
  badge_count INT UNSIGNED DEFAULT 0 NOT NULL,
  is_active TINYINT(1) DEFAULT 1 NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  KEY idx_children_openid (_openid),
  KEY idx_children_active (_openid, is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS child_settings (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  child_id BIGINT UNSIGNED NOT NULL,
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
  KEY idx_habit_templates_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS habits (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  child_id BIGINT UNSIGNED NOT NULL,
  template_id BIGINT UNSIGNED NULL,
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
  independence_level VARCHAR(16) DEFAULT 'unknown' NOT NULL,
  mood VARCHAR(16) DEFAULT 'unknown' NOT NULL,
  duration_minutes INT UNSIGNED NULL,
  note VARCHAR(200) DEFAULT '' NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_habit_record_day (child_id, habit_id, record_date),
  KEY idx_habit_records_child_date (_openid, child_id, record_date),
  KEY idx_habit_records_status (child_id, status)
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
  source_type VARCHAR(32) NOT NULL,
  source_id BIGINT UNSIGNED NULL,
  delta INT NOT NULL,
  balance_after INT UNSIGNED NOT NULL,
  reason VARCHAR(100) DEFAULT '' NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_star_transactions_child (_openid, child_id, created_at),
  KEY idx_star_transactions_source (source_type, source_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS math_skills (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  code VARCHAR(64) NOT NULL,
  name VARCHAR(32) NOT NULL,
  category VARCHAR(32) NOT NULL,
  target_description VARCHAR(300) DEFAULT '' NOT NULL,
  recommended_age_min TINYINT UNSIGNED DEFAULT 5 NOT NULL,
  recommended_age_max TINYINT UNSIGNED DEFAULT 6 NOT NULL,
  sort_order INT UNSIGNED DEFAULT 0 NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_math_skill_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS math_islands (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  code VARCHAR(64) NOT NULL,
  name VARCHAR(32) NOT NULL,
  description VARCHAR(300) DEFAULT '' NOT NULL,
  icon_name VARCHAR(32) DEFAULT '' NOT NULL,
  sort_order INT UNSIGNED DEFAULT 0 NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_math_island_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS math_levels (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  island_code VARCHAR(64) NOT NULL,
  skill_code VARCHAR(64) NOT NULL,
  code VARCHAR(64) NOT NULL,
  name VARCHAR(32) NOT NULL,
  level_type VARCHAR(16) DEFAULT 'normal' NOT NULL,
  difficulty TINYINT UNSIGNED DEFAULT 1 NOT NULL,
  unlock_cost INT UNSIGNED DEFAULT 1 NOT NULL,
  pass_question_count INT UNSIGNED DEFAULT 5 NOT NULL,
  sort_order INT UNSIGNED DEFAULT 0 NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_math_level_code (code),
  KEY idx_math_levels_island (island_code, sort_order),
  KEY idx_math_levels_skill (skill_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS math_question_templates (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  code VARCHAR(64) NOT NULL,
  skill_code VARCHAR(64) NOT NULL,
  level_code VARCHAR(64) DEFAULT '' NOT NULL,
  question_type VARCHAR(32) NOT NULL,
  generator_type VARCHAR(32) NOT NULL,
  difficulty TINYINT UNSIGNED DEFAULT 1 NOT NULL,
  prompt_template VARCHAR(300) NOT NULL,
  parameter_rules JSON NOT NULL,
  answer_rule JSON NOT NULL,
  distractor_rules JSON NULL,
  asset_payload JSON NULL,
  is_active TINYINT(1) DEFAULT 1 NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_math_question_template_code (code),
  KEY idx_math_question_templates_level (level_code, is_active),
  KEY idx_math_question_templates_skill (skill_code, difficulty)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS math_questions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  code VARCHAR(64) NOT NULL,
  skill_code VARCHAR(64) NOT NULL,
  level_code VARCHAR(64) DEFAULT '' NOT NULL,
  question_type VARCHAR(32) NOT NULL,
  source_type VARCHAR(32) DEFAULT 'original' NOT NULL,
  content_pack_code VARCHAR(64) DEFAULT '' NOT NULL,
  difficulty TINYINT UNSIGNED DEFAULT 1 NOT NULL,
  prompt_text VARCHAR(300) NOT NULL,
  asset_payload JSON NULL,
  answer_payload JSON NOT NULL,
  explanation_text VARCHAR(300) DEFAULT '' NOT NULL,
  is_active TINYINT(1) DEFAULT 1 NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_math_question_code (code),
  KEY idx_math_questions_level (level_code, is_active),
  KEY idx_math_questions_skill (skill_code, difficulty)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS math_attempts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  child_id BIGINT UNSIGNED NOT NULL,
  question_id BIGINT UNSIGNED NULL,
  question_template_code VARCHAR(64) DEFAULT '' NOT NULL,
  skill_code VARCHAR(64) NOT NULL,
  level_code VARCHAR(64) NOT NULL,
  generated_payload JSON NULL,
  question_snapshot JSON NOT NULL,
  selected_answer_payload JSON NULL,
  is_correct TINYINT(1) DEFAULT 0 NOT NULL,
  attempt_count INT UNSIGNED DEFAULT 1 NOT NULL,
  duration_seconds INT UNSIGNED DEFAULT 0 NOT NULL,
  used_hint TINYINT(1) DEFAULT 0 NOT NULL,
  used_manipulative TINYINT(1) DEFAULT 0 NOT NULL,
  answered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_math_attempts_child_time (_openid, child_id, answered_at),
  KEY idx_math_attempts_skill (child_id, skill_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS math_skill_mastery (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  child_id BIGINT UNSIGNED NOT NULL,
  skill_code VARCHAR(64) NOT NULL,
  mastery_level VARCHAR(16) DEFAULT 'not_started' NOT NULL,
  recent_accuracy DECIMAL(5,2) DEFAULT 0.00 NOT NULL,
  total_attempts INT UNSIGNED DEFAULT 0 NOT NULL,
  correct_attempts INT UNSIGNED DEFAULT 0 NOT NULL,
  last_practiced_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_math_mastery_child_skill (child_id, skill_code),
  KEY idx_math_mastery_openid (_openid, child_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS english_skills (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  code VARCHAR(64) NOT NULL,
  name VARCHAR(32) NOT NULL,
  category VARCHAR(32) NOT NULL,
  target_description VARCHAR(300) DEFAULT '' NOT NULL,
  sort_order INT UNSIGNED DEFAULT 0 NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_english_skill_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS english_contents (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  code VARCHAR(64) NOT NULL,
  skill_code VARCHAR(64) NOT NULL,
  content_type VARCHAR(32) NOT NULL,
  theme VARCHAR(32) DEFAULT '' NOT NULL,
  display_text VARCHAR(100) NOT NULL,
  chinese_text VARCHAR(100) DEFAULT '' NOT NULL,
  phonetic_text VARCHAR(100) DEFAULT '' NOT NULL,
  example_text VARCHAR(200) DEFAULT '' NOT NULL,
  image_asset_key VARCHAR(100) DEFAULT '' NOT NULL,
  audio_asset_key VARCHAR(100) DEFAULT '' NOT NULL,
  trace_asset_key VARCHAR(100) DEFAULT '' NOT NULL,
  pronunciation_variant VARCHAR(16) DEFAULT 'general' NOT NULL,
  content_pack_code VARCHAR(64) DEFAULT '' NOT NULL,
  license_code VARCHAR(64) DEFAULT '' NOT NULL,
  difficulty TINYINT UNSIGNED DEFAULT 1 NOT NULL,
  sort_order INT UNSIGNED DEFAULT 0 NOT NULL,
  is_active TINYINT(1) DEFAULT 1 NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_english_content_code (code),
  KEY idx_english_contents_skill (skill_code, content_type),
  KEY idx_english_contents_theme (theme, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS english_series (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  code VARCHAR(64) NOT NULL,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(500) DEFAULT '' NOT NULL,
  source_type VARCHAR(32) DEFAULT 'original' NOT NULL,
  level_system VARCHAR(32) DEFAULT 'internal' NOT NULL,
  min_level INT UNSIGNED DEFAULT 1 NOT NULL,
  max_level INT UNSIGNED DEFAULT 1 NOT NULL,
  cover_asset_key VARCHAR(100) DEFAULT '' NOT NULL,
  license_code VARCHAR(64) DEFAULT '' NOT NULL,
  sort_order INT UNSIGNED DEFAULT 0 NOT NULL,
  is_active TINYINT(1) DEFAULT 1 NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_english_series_code (code),
  KEY idx_english_series_active (is_active, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS english_books (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  code VARCHAR(64) NOT NULL,
  series_code VARCHAR(64) NOT NULL,
  title VARCHAR(150) NOT NULL,
  subtitle VARCHAR(150) DEFAULT '' NOT NULL,
  level_no INT UNSIGNED DEFAULT 1 NOT NULL,
  sequence_no INT UNSIGNED DEFAULT 1 NOT NULL,
  word_count INT UNSIGNED DEFAULT 0 NOT NULL,
  target_words JSON NULL,
  target_sentences JSON NULL,
  cover_asset_key VARCHAR(100) DEFAULT '' NOT NULL,
  full_audio_asset_key VARCHAR(100) DEFAULT '' NOT NULL,
  license_code VARCHAR(64) DEFAULT '' NOT NULL,
  is_active TINYINT(1) DEFAULT 1 NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_english_book_code (code),
  KEY idx_english_books_series (series_code, level_no, sequence_no),
  KEY idx_english_books_active (is_active, level_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS english_book_pages (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  book_code VARCHAR(64) NOT NULL,
  page_no INT UNSIGNED NOT NULL,
  page_type VARCHAR(16) DEFAULT 'story' NOT NULL,
  display_text TEXT NOT NULL,
  chinese_text TEXT NULL,
  image_asset_key VARCHAR(100) DEFAULT '' NOT NULL,
  page_audio_asset_key VARCHAR(100) DEFAULT '' NOT NULL,
  word_timing_payload JSON NULL,
  interaction_payload JSON NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_english_book_page (book_code, page_no),
  KEY idx_english_book_pages_book (book_code, page_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS english_audio_segments (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  book_code VARCHAR(64) NOT NULL,
  page_no INT UNSIGNED NOT NULL,
  segment_type VARCHAR(16) DEFAULT 'sentence' NOT NULL,
  segment_order INT UNSIGNED DEFAULT 1 NOT NULL,
  display_text VARCHAR(500) DEFAULT '' NOT NULL,
  audio_asset_key VARCHAR(100) NOT NULL,
  start_ms INT UNSIGNED DEFAULT 0 NOT NULL,
  end_ms INT UNSIGNED DEFAULT 0 NOT NULL,
  speaker_code VARCHAR(64) DEFAULT '' NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_english_audio_segments_page (book_code, page_no, segment_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS english_book_questions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  code VARCHAR(64) NOT NULL,
  book_code VARCHAR(64) NOT NULL,
  page_no INT UNSIGNED NULL,
  skill_code VARCHAR(64) DEFAULT 'graded_reading' NOT NULL,
  question_type VARCHAR(32) NOT NULL,
  difficulty TINYINT UNSIGNED DEFAULT 1 NOT NULL,
  prompt_text VARCHAR(500) NOT NULL,
  asset_payload JSON NULL,
  answer_payload JSON NOT NULL,
  explanation_text VARCHAR(500) DEFAULT '' NOT NULL,
  sort_order INT UNSIGNED DEFAULT 0 NOT NULL,
  is_active TINYINT(1) DEFAULT 1 NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_english_book_question_code (code),
  KEY idx_english_book_questions_book (book_code, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS english_reading_progress (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  child_id BIGINT UNSIGNED NOT NULL,
  book_code VARCHAR(64) NOT NULL,
  status VARCHAR(16) DEFAULT 'not_started' NOT NULL,
  last_page_no INT UNSIGNED DEFAULT 0 NOT NULL,
  progress_percent DECIMAL(5,2) DEFAULT 0.00 NOT NULL,
  read_count INT UNSIGNED DEFAULT 0 NOT NULL,
  listen_duration_seconds INT UNSIGNED DEFAULT 0 NOT NULL,
  comprehension_accuracy DECIMAL(5,2) DEFAULT 0.00 NOT NULL,
  last_read_at DATETIME NULL,
  completed_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_english_reading_progress (child_id, book_code),
  KEY idx_english_reading_progress_child (_openid, child_id, last_read_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS english_attempts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  child_id BIGINT UNSIGNED NOT NULL,
  content_code VARCHAR(64) DEFAULT '' NOT NULL,
  book_code VARCHAR(64) DEFAULT '' NOT NULL,
  book_question_code VARCHAR(64) DEFAULT '' NOT NULL,
  page_no INT UNSIGNED NULL,
  skill_code VARCHAR(64) NOT NULL,
  activity_type VARCHAR(32) NOT NULL,
  is_correct TINYINT(1) DEFAULT 0 NOT NULL,
  duration_seconds INT UNSIGNED DEFAULT 0 NOT NULL,
  repeat_count INT UNSIGNED DEFAULT 0 NOT NULL,
  parent_confirmed_speaking TINYINT(1) DEFAULT 0 NOT NULL,
  answered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_english_attempts_child_time (_openid, child_id, answered_at),
  KEY idx_english_attempts_skill (child_id, skill_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS english_skill_mastery (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  child_id BIGINT UNSIGNED NOT NULL,
  skill_code VARCHAR(64) NOT NULL,
  mastery_level VARCHAR(16) DEFAULT 'new_friend' NOT NULL,
  recent_accuracy DECIMAL(5,2) DEFAULT 0.00 NOT NULL,
  total_attempts INT UNSIGNED DEFAULT 0 NOT NULL,
  repeat_count INT UNSIGNED DEFAULT 0 NOT NULL,
  parent_confirmed_speaking TINYINT(1) DEFAULT 0 NOT NULL,
  last_practiced_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_english_mastery_child_skill (child_id, skill_code),
  KEY idx_english_mastery_openid (_openid, child_id)
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
  is_golden TINYINT(1) DEFAULT 0 NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_child_badge (child_id, badge_code),
  KEY idx_child_badges_openid (_openid, child_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS rewards (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  child_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(50) NOT NULL,
  icon_name VARCHAR(32) DEFAULT '' NOT NULL,
  badge_cost INT UNSIGNED DEFAULT 1 NOT NULL,
  stock_count INT UNSIGNED NULL,
  is_active TINYINT(1) DEFAULT 1 NOT NULL,
  sort_order INT UNSIGNED DEFAULT 0 NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  KEY idx_rewards_child (_openid, child_id, is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS reward_redemptions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  child_id BIGINT UNSIGNED NOT NULL,
  reward_id BIGINT UNSIGNED NOT NULL,
  badge_cost INT UNSIGNED DEFAULT 0 NOT NULL,
  status VARCHAR(16) DEFAULT 'pending' NOT NULL,
  requested_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  completed_at DATETIME NULL,
  note VARCHAR(200) DEFAULT '' NOT NULL,
  KEY idx_reward_redemptions_child (_openid, child_id, requested_at),
  KEY idx_reward_redemptions_status (child_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS content_licenses (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  code VARCHAR(64) NOT NULL,
  content_owner VARCHAR(150) NOT NULL,
  licensor VARCHAR(150) DEFAULT '' NOT NULL,
  source_type VARCHAR(32) NOT NULL,
  territory VARCHAR(100) DEFAULT 'CN' NOT NULL,
  language_scope VARCHAR(100) DEFAULT '' NOT NULL,
  usage_scope JSON NOT NULL,
  allow_offline_cache TINYINT(1) DEFAULT 0 NOT NULL,
  allow_derivative TINYINT(1) DEFAULT 0 NOT NULL,
  valid_from DATE NULL,
  valid_until DATE NULL,
  proof_storage_path VARCHAR(500) DEFAULT '' NOT NULL,
  status VARCHAR(16) DEFAULT 'pending' NOT NULL,
  note VARCHAR(500) DEFAULT '' NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_content_license_code (code),
  KEY idx_content_licenses_status (status, valid_until)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS content_packs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  code VARCHAR(64) NOT NULL,
  name VARCHAR(64) NOT NULL,
  version VARCHAR(32) NOT NULL,
  content_type VARCHAR(32) NOT NULL,
  license_code VARCHAR(64) DEFAULT '' NOT NULL,
  manifest_asset_key VARCHAR(100) NOT NULL,
  checksum VARCHAR(128) NOT NULL,
  min_app_version VARCHAR(32) DEFAULT '' NOT NULL,
  publish_status VARCHAR(16) DEFAULT 'draft' NOT NULL,
  is_builtin TINYINT(1) DEFAULT 1 NOT NULL,
  released_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_content_pack_code_version (code, version)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS local_assets (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  asset_key VARCHAR(100) NOT NULL,
  asset_type VARCHAR(32) NOT NULL,
  mime_type VARCHAR(100) DEFAULT '' NOT NULL,
  content_pack_code VARCHAR(64) DEFAULT '' NOT NULL,
  license_code VARCHAR(64) DEFAULT '' NOT NULL,
  local_path VARCHAR(300) DEFAULT '' NOT NULL,
  storage_path VARCHAR(500) DEFAULT '' NOT NULL,
  access_level VARCHAR(16) DEFAULT 'private' NOT NULL,
  file_size_bytes BIGINT UNSIGNED DEFAULT 0 NOT NULL,
  duration_ms INT UNSIGNED DEFAULT 0 NOT NULL,
  checksum VARCHAR(128) DEFAULT '' NOT NULL,
  version VARCHAR(32) DEFAULT '' NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_local_asset_key (asset_key),
  KEY idx_local_assets_pack (content_pack_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS app_event_logs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  _openid VARCHAR(64) DEFAULT '' NOT NULL,
  child_id BIGINT UNSIGNED NULL,
  event_name VARCHAR(64) NOT NULL,
  event_payload JSON NULL,
  occurred_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_app_events_openid_time (_openid, occurred_at),
  KEY idx_app_events_name_time (event_name, occurred_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

## 五、字段枚举建议

### 5.1 `habit_records.status`

| 值 | 含义 |
|----|------|
| `none` | 未操作 |
| `completed` | 已完成 |
| `skipped` | 已跳过 |

### 5.2 `habit_records.independence_level`

| 值 | 含义 |
|----|------|
| `independent` | 独立完成 |
| `reminded` | 提醒后完成 |
| `assisted` | 家长协助完成 |
| `unknown` | 未记录 |

### 5.3 `habit_records.mood`

| 值 | 含义 |
|----|------|
| `happy` | 愉快 |
| `neutral` | 一般 |
| `resistant` | 抗拒 |
| `unknown` | 未记录 |

### 5.4 `math_skill_mastery.mastery_level`

| 值 | 含义 |
|----|------|
| `not_started` | 未开始 |
| `learning` | 认识中 |
| `basic` | 基本掌握 |
| `stable` | 稳定掌握 |

### 5.5 `english_skill_mastery.mastery_level`

| 值 | 含义 |
|----|------|
| `new_friend` | 新朋友 |
| `seen` | 见过啦 |
| `recognized` | 认得出 |
| `understood` | 听得懂 |
| `speaking` | 会开口 |

### 5.6 `reward_redemptions.status`

| 值 | 含义 |
|----|------|
| `pending` | 待家长确认 |
| `completed` | 已兑换 |
| `cancelled` | 已取消 |

### 5.7 内容来源 `source_type`

| 值 | 含义 |
|----|------|
| `original` | 团队原创并持有完整数字使用权 |
| `public_domain` | 已确认原始作品进入公共领域 |
| `licensed` | 从版权方取得书面数字授权 |

### 5.8 `content_licenses.status`

| 值 | 含义 |
|----|------|
| `pending` | 权利文件仍在审核，不允许发布 |
| `active` | 授权有效，可按 `usage_scope` 发布 |
| `expired` | 授权到期，应停止新下载并按约定清理缓存 |
| `revoked` | 授权撤销，应立即下架 |

### 5.9 `content_packs.publish_status`

| 值 | 含义 |
|----|------|
| `draft` | 草稿，不对客户端展示 |
| `reviewing` | 内容、教学和版权审核中 |
| `published` | 已发布，客户端可下载 |
| `retired` | 已下架，不再提供新下载 |

### 5.10 `english_reading_progress.status`

| 值 | 含义 |
|----|------|
| `not_started` | 尚未开始 |
| `reading` | 阅读中 |
| `completed` | 已完整读完 |
| `reviewing` | 正在复读或完成理解练习 |

---

## 六、权限维护建议

### 6.1 用户私有表

以下表只允许当前登录用户读写自己的 `_openid` 数据：

- `parent_profiles`
- `children`
- `child_settings`
- `habits`
- `habit_records`
- `daily_hearts`
- `star_transactions`
- `math_attempts`
- `math_skill_mastery`
- `english_reading_progress`
- `english_attempts`
- `english_skill_mastery`
- `child_badges`
- `rewards`
- `reward_redemptions`
- `app_event_logs`

### 6.2 系统模板表

以下表建议客户端只读，写入和修改只允许后台管理端或云函数执行：

- `habit_templates`
- `math_skills`
- `math_islands`
- `math_levels`
- `math_question_templates`
- `math_questions`
- `english_skills`
- `english_contents`
- `english_series`
- `english_books`
- `english_book_pages`
- `english_audio_segments`
- `english_book_questions`
- `badge_templates`
- `content_packs`
- `local_assets`

### 6.3 后台私有表

以下表不建议直接开放给客户端读取或写入：

- `content_licenses`：可能包含合同证明路径、授权范围和商业信息，只允许后台管理端与发布云函数访问。

### 6.4 敏感操作

以下操作不建议客户端直接写数据库，应通过云函数完成：

- 注册后初始化默认孩子档案。
- 初始化默认习惯。
- 星星增减和流水写入。
- 每日小心心重置。
- 勋章发放。
- 奖励兑换扣减。
- 内容包发布、下架和授权状态校验。
- 生成受控的版权资源临时下载地址。
- 删除孩子档案或重置全部数据。

---

## 七、初始化数据建议

MVP 最少需要初始化：

- `habit_templates`：3-4 岁默认习惯、5-6 岁幼升小默认习惯。
- `math_skills`：数数、数量对应、数字识别、比较大小、分合、10 以内加减、图形、空间、规律。
- `math_islands`：数数岛、数字岛、比较岛、分合岛、加减岛、图形规律岛。
- `math_levels`：每个岛 5 个普通关 + 1 个 Boss 关。
- `math_question_templates`：数数、比较、数的分合、10 以内加减等 10-20 个受控生成模板。
- `math_questions`：80-120 道图形题、情境题和 Boss 固定题。
- `english_skills`：兴趣、听辨、字母认知、字母音、基础词汇、日常表达、儿歌韵律、课堂指令、分级阅读。
- `english_contents`：26 个大小写字母描边、30-50 个基础词汇、3-5 首具有合法来源的儿歌。
- `english_series` / `english_books`：MVP 可先放 1 个原创系列、2-3 本短故事验证连续阅读流程；商业绘本授权前不入库。
- `english_book_pages` / `english_audio_segments`：保存原创绘本页面结构、逐页文字和逐句音频索引。
- `english_book_questions`：每本 2-4 道图片选择、顺序排列或角色理解题。
- `english_reading_progress`：无需初始化，由孩子首次打开图书时创建。
- `badge_templates`：习惯、数学、英语、特殊勋章。
- `content_licenses`：为原创、公共领域和商业授权内容分别建立可追溯记录。
- `content_packs`：内置基础资源包及其版本、清单、校验值和发布状态。
- `local_assets`：图片、真人发音、描边路径、绘本页面、音频、Lottie、题目 JSON 的资源索引。

---

## 八、后续维护注意事项

- 字段新增优先使用 `ALTER TABLE ADD COLUMN`，不要直接删字段。
- 涉及孩子数据的表优先软删除，保留 `deleted_at`。
- 模板表用 `code` 做稳定业务标识，不要在客户端硬编码自增 `id`。
- App 客户端展示时优先使用 `code`、`child_id`、日期维度查询。
- 不要在客户端保存 CloudBase API Key。
- 不要把图片、PDF、MP3 等大文件直接存进 MySQL；只保存 CloudBase 云存储路径和资源元数据。
- 商业版权资源默认使用私有存储与临时下载地址，不在数据库保存长期公开 URL。
- 内容发布前必须同时通过教学审核、技术校验和版权状态校验；`license_code` 无效时不得发布。
- 授权到期任务应自动把关联内容包改为 `retired`，并按合同约定停止下载或清理本地缓存。
- 购买纸质书、家庭账号或学校订阅通常不等于取得第三方 App 的复制与分发权。
- 手机号只在 CloudBase Auth 中维护；业务表最多保存脱敏后的 `phone_masked`。
- 儿童真实姓名、学校、身份证、精确定位等信息不进入 MVP 数据库。
