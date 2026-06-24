# CloudBase 云函数

## auth-register

受信任的用户名/密码注册接口。

- CloudBase 函数名：`auth-register`
- 类型：HTTP Function
- Runtime：Node.js 18.15
- 网关路径：`/api/auth/register`
- dev URL：`https://little-hero-dev-d7f95sqy70d3a475.service.tcloudbase.com/api/auth/register`
- 环境变量：`CLOUDBASE_ENV_ID`

本地检查：

```bash
cd auth-register
npm install
npm test
npm audit --omit=dev
```

接口只创建 CloudBase Auth 用户，不保存手机号归属已验证状态，也不记录密码。注册成功后由客户端调用 Auth `/auth/v1/signin` 建立会话。

若配置了以下环境变量，注册成功后会调用业务 API 自动初始化默认家长资料、孩子档案、孩子设置和默认任务：

- `BUSINESS_API_INTERNAL_URL`：业务 API 内部访问地址，例如 `https://<env>.service.tcloudbase.com`
- `INTERNAL_API_SECRET`：内部接口共享密钥，需与 `api` 函数一致

未配置时注册不会失败，返回中会标记 `profileInitializationSkipped: true`。

## api

MVP 统一业务 HTTP API。本地已实现可测试的服务层和内存仓储，后续 CloudBase MySQL 开通后替换为 MySQL 仓储即可。

- CloudBase 函数名：`api`
- 类型：HTTP Function
- Runtime：Node.js 18.15
- 健康检查：`GET /health`
- 登录后聚合数据：`GET /api/bootstrap`
- 今日任务打卡：`POST /api/tasks/record`
- 任务管理同步：`POST /api/tasks/manage`
- 注册后内部初始化：`POST /internal/parents/default-profile`
- 迁移文件：`../database/migrations/001_mvp_foundation.sql`

本地检查：

```bash
cd api
npm test
```

### 环境变量

- `INTERNAL_API_SECRET`：内部初始化接口密钥。
- `AUTH_USERINFO_URL`：生产环境鉴权用的 CloudBase Auth 用户信息接口地址。当前本地测试通过 `Bearer test:<subject>:<username>` 注入身份。

### bootstrap 返回内容

`GET /api/bootstrap` 会在首次登录时幂等创建默认业务资料，并返回：

- 家长资料：账号、脱敏手机号、手机号归属验证状态。
- 孩子档案：昵称、年龄段、头像配置、是否需要完善档案。
- 今日任务：默认三项任务及当天状态。
- 资产快照：可用星星、累计星星、勋章数、今日心心。
- 勋章摘要：已获得数、总数和最近勋章。

### 任务接口

`POST /api/tasks/record` 用于完成、跳过和撤销当天任务。请求体：

```json
{
  "operationId": "client-generated-uuid",
  "childId": 1,
  "taskId": 101,
  "status": "done"
}
```

`status` 支持 `done`、`skipped`、`none`。服务端按 `operationId` 幂等处理，并结算普通完成星星、全完成奖励、连续 7 天奖励和基础勋章。

`POST /api/tasks/manage` 用于同步家长区任务管理操作。请求体：

```json
{
  "operationId": "client-generated-uuid",
  "action": "create",
  "taskId": 999,
  "name": "喝牛奶",
  "sortOrder": 40
}
```

`action` 支持 `create`、`update`、`delete`、`reorder`。

## 数据库迁移

Phase 2 的 MVP MySQL schema 已抽到：

```bash
database/migrations/001_mvp_foundation.sql
```

包含：`parent_profiles`、`children`、`child_settings`、`habit_templates`、`habits`、`habit_records`、`child_asset_snapshots`、`daily_hearts`、`star_transactions`、`badge_templates`、`child_badges`、`idempotency_operations`。
