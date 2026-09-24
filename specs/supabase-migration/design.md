# Supabase 认证、数据与用药页设计

## 设计规范：用药页

| 项目 | 规范 |
| --- | --- |
| 目的 | 让家长快速确认“今天谁在何时吃了什么”，其次才是管理药箱和家庭成员。 |
| 场景 | 沿用已验收的草地 / 星空背景；日间 07:00–17:00，夜间其余时间。 |
| 层级 | 顶部为“家庭药箱”+ 猫咪；随后是今日完成数、下一次提醒、紧凑的今日时间线；档案和成员收纳为次级操作。 |
| 卡片 | 白天为暖白半透明卡，夜间为深蓝半透明卡；圆角 22–26；不做厚重阴影。 |
| 字体 | 跟随现有 Flutter 中文系统字体，全部 `FontWeight.w400`；不引入新的远程字体。 |
| 操作 | 右下 / 时间线内提供“记录用药”；列表项以小圆形完成状态表示，不使用过大的勾选框。 |
| 安全 | 明确展示“记录，不替代医嘱”的短提示；不展示医学建议、风险评分或自动剂量判断。 |

`CycleScene`、`CycleCard`、`CycleHeading` 是已建立的共享视觉基础。实施时将抽取中性的
`CareScene` / `CareCard`（或保留兼容别名），让用药页与经期页真正复用同一日夜实现。

## Supabase 架构

```text
Flutter
  ├─ Supabase Auth（会话恢复、刷新、登出）
  ├─ Drift SQLite（离线缓存 / 同步队列）
  └─ Repositories（本地先写，网络恢复后幂等 upsert）
              │ publishable / anon key
              ▼
Supabase Postgres + RLS
  ├─ 家庭待办与奖励（家庭成员可访问）
  ├─ 用药与照护对象（家庭成员可访问）
  └─ 经期手记（仅本人可访问）
              │
              └─ Edge Function（仅奖励结算、迁移等服务端事务；service-role 仅放密钥环境变量）
```

客户端使用 `supabase_flutter`，并以 `--dart-define` / 未提交的本地配置注入：

```text
SUPABASE_URL=https://onvhkbbfvvjvdzqsalcd.supabase.co
SUPABASE_PUBLISHABLE_KEY=<仅客户端公开 key>
```

不得把 service-role key 写进 Flutter、Git 历史、截图或聊天记录。首期不必启用 Realtime；
本地同步队列完成后可按需加订阅。

## 推荐表结构

所有 ID 使用 `uuid`，所有时间使用 `timestamptz`，所有可同步的写操作包含 `operation_id uuid`
并设置唯一约束。

### 账户与家庭

| 表 | 关键字段 | 用途 |
| --- | --- | --- |
| `profiles` | `id PK -> auth.users`, `display_name`, `timezone`, `created_at` | 每个账号一份公开最小档案。 |
| `households` | `id`, `owner_id -> profiles`, `name` | 家庭数据边界。 |
| `household_members` | `household_id`, `profile_id`, `role(owner/caregiver)` | 家庭共同管理数据的权限来源。 |
| `children` | `id`, `household_id`, `nickname`, `gender`, `age_stage`, `avatar_config`, `is_active` | 儿童与任务归属。 |
| `care_recipients` | `id`, `household_id`, `display_name`, `relationship`, `age_note`, `allergy_note`, `condition_note`, `is_active` | 用药对象；可关联儿童但不强制，适合全家。 |

### 待办、打卡与奖励

| 表 | 关键字段 / 约束 | 用途 |
| --- | --- | --- |
| `habit_templates` | `code UNIQUE`, `name`, `icon_key`, `category`, `sort_order` | 预置“刷牙、阅读英语、练习数学”等。 |
| `habits` | `id`, `child_id`, `template_code?`, `title`, `icon_key`, `sort_order`, `is_active`, `archived_at` | 用户可编辑的任务定义。对 `(child_id) where is_active` 的数量由事务 / RPC 限制为 10。 |
| `habit_records` | `habit_id`, `child_id`, `record_date`, `status`, `operation_id UNIQUE`; `UNIQUE(habit_id, record_date)` | 每日状态，避免重复打卡。 |
| `star_transactions` | `child_id`, `source_type`, `source_id`, `operation_id UNIQUE`, `delta`, `balance_after`, `lifetime_after` | 不可变奖励账本。 |
| `daily_awards` | `child_id`, `award_date`, `award_type`, `stars`, `UNIQUE(child_id, award_date, award_type)` | 全完成日、连续完成等额外奖励。 |
| `child_badges` | `child_id`, `badge_code`, `earned_date`, `UNIQUE(child_id, badge_code)` | 已获得徽章。 |

星星计算与奖励入账走一个 `security definer` RPC 或 Edge Function，在一个事务中更新记录、
奖励和徽章；客户端只有调用权限，不能直接写 `star_transactions`。

### 药箱

| 表 | 关键字段 / 约束 | 用途 |
| --- | --- | --- |
| `medicines` | `id`, `household_id`, `name`, `specification`, `default_dosage`, `storage_location`, `expires_on`, `stock_note`, `usage_note`, `archived_at` | 药品档案。 |
| `medication_administrations` | `id`, `household_id`, `recipient_id`, `medicine_id`, `taken_at`, `dosage_text`, `reason`, `note`, `recorded_by`, `operation_id UNIQUE` | 实际一次用药事实记录。 |
| `medication_reminders` | `id`, `household_id`, `recipient_id`, `medicine_id`, `scheduled_at`, `dosage_text`, `status`, `source_administration_id?`, `operation_id UNIQUE` | 计划提醒；完成后保留状态而非删除。 |

旧本地 `member_name` / `medicine_name` 只在找不到匹配档案时作为迁移快照字段保留，不能取代
外键。提醒推送属于后续能力，首期只做应用内显示。

### 经期手记

| 表 | 关键字段 / 约束 | 用途 |
| --- | --- | --- |
| `cycle_profiles` | `user_id PK -> profiles`, `period_length_days`, `cycle_length_days`, `birth_date?`, `updated_at` | 个人设置。 |
| `cycle_periods` | `id`, `user_id`, `started_on`, `ended_on?`, `source`, `operation_id UNIQUE`; `UNIQUE(user_id, started_on)` | 实际经期的明确起点和可选结束日。 |
| `cycle_daily_logs` | `id`, `user_id`, `log_date`, `flow_level`, `symptoms text[]`, `diary_text`, `operation_id UNIQUE`; `UNIQUE(user_id, log_date)` | 每日经量、症状、手记。 |

下次经期和阶段为客户端根据**实际** `cycle_periods` + `cycle_profiles` 推算的派生结果；不得作为
患者事实落库。现有 `last_period_start_date` 可迁移成一条 `cycle_periods` 记录。

## RLS 与迁移

- `profiles` / `cycle_*`：`auth.uid() = user_id`（或 `id`），无家庭共享例外。
- 家庭、儿童、待办、药箱表：通过 `household_members.profile_id = auth.uid()` 的 `EXISTS` 策略，
  对同一家庭成员开放 `SELECT/INSERT/UPDATE`；默认无 `DELETE`，用 `archived_at` 软删除。
- 所有表启用 RLS，表、视图、函数均设置 `search_path`；不为图省事使用匿名全表策略。
- 迁移顺序：备份本地 SQLite 与 CloudBase 导出 → 建表/RLS/函数 → 以映射表导入 → 对账数量与
  抽样内容 → 切换读路径 → 一段观察期后再考虑关闭 CloudBase 写入。
- CloudBase 的账号 ID 到 Supabase `auth.users.id` 必须存于仅服务端可读的 `legacy_identity_map`；
  它不存密码哈希。旧账号首次登录时走手机验证码或重设密码以绑定身份。

## 未决选择

1. **推荐手机号验证码登录**：须启用 Phone Auth 并配置短信服务商，手机号必须为 `+86...` 形式。
2. **邮箱 + 新密码**：当前 Supabase 配置已可用，但旧的“手机号账号”需要补充邮箱或提供迁移领取流程。
3. **暂不迁移认证**：先完成 Supabase 数据层，再由 CloudBase 颁发受控迁移票据；实现较复杂，适合用户量较大时。

因当前项目的 Supabase Auth 用户为零、CloudBase 仍有用户，推荐选择 1（如果你愿意配置短信）
或 2（如果已有用户邮箱），不要直接替换现网登录。
