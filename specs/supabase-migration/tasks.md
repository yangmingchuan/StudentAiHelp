# Supabase 迁移实施清单

> 状态：用户已确认提醒、审计和隐私改造；认证路径仍待选择。本地功能与 SQL 迁移脚本可先实施，
> 不会直接改动 Supabase 项目。

- [ ] 确认认证路径：手机号验证码，或邮箱 + 重设密码。
- [ ] 备份 CloudBase 数据与 Android/iOS 本地 SQLite；记录可恢复位置和数据条数。
- [ ] 新增 `supabase_flutter`、环境配置与会话恢复；保留 CloudBase 适配层作为过渡开关。
- [ ] 在 Supabase 以版本化 SQL migration 创建账户、家庭、待办、药箱、经期表、索引、RLS、触发器和 RPC。
- [x] 已准备版本化 RLS migration：`supabase/migrations/202609240001_secure_family_health.sql`；待确认认证迁移时再执行到项目。
- [ ] 生成最小 `profiles` 的注册后触发器，创建默认家庭与成员关系。
- [ ] 实现奖励结算 RPC / Edge Function，并为重复 `operation_id` 编写事务测试。
- [ ] 为 Drift 的待办、用药、经期数据实现本地优先 outbox、失败重试、冲突规则与导入映射。
- [ ] 实现 CloudBase → Supabase 数据导出、映射、幂等导入和数量对账；不导入或暴露密码哈希。
- [ ] 将登录、注册、会话恢复、登出、错误文案替换为选定的 Supabase 登录方式。
- [x] 重构用药首页：复用日夜场景、常规字重、今日时间线、小状态标记、玻璃 Tab；保留完整的药品、成员、历史录入能力。
- [x] 建立本地通知、提醒状态（待办/已完成/已跳过/已取消）与设备重启后的重建逻辑。
- [x] 建立用药记录的作废、更正和关联审计，禁止静默覆盖。
- [x] 对本地健康字段启用设备密钥 AES-GCM 加密，并在读取旧数据时完成惰性迁移。
- [ ] Android 真机、Android 模拟器和冷启动验证：会话恢复、RLS 拒绝跨用户读取、离线重试、迁移数据完整性。
- [ ] 观察期确认无误后，才停用 CloudBase 写入；CloudBase 数据保留可回滚备份。
