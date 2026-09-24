# 闯关小勇士

一款面向家庭内部使用的儿童习惯养成 App。孩子通过完成每日任务获得星星、勋章和即时反馈，家长可以管理任务和账号；同时提供妈妈工具和家庭用药记录等照护辅助功能。

当前项目处于 MVP 阶段，重点打通 Flutter 移动端、本地数据库、CloudBase 认证和业务 HTTP API 的基础闭环。

## 当前功能

- 家长手机号格式账号注册、登录、刷新会话和退出登录
- 首页每日任务打卡、星星资产展示和完成奖励动画
- 家长区任务管理：新增、编辑、删除、排序
- 妈妈工具：周期设置、日历、分析、建议和日记入口
- 家庭用药：成员、药品、用药记录、提醒和效期信息展示
- 本地优先的数据层，支持后续同步到 CloudBase

## 技术栈

- 移动端：Flutter、Riverpod、go_router、Dio、Drift/SQLite
- 安全存储：flutter_secure_storage
- 后端：CloudBase HTTP Functions、Node.js
- 数据库设计：CloudBase MySQL schema migration

## 项目结构

```text
.
├── apps/mobile/                  # Flutter Android/iOS 客户端
├── cloudfunctions/               # CloudBase HTTP 云函数
│   ├── api/                      # 业务 API
│   └── auth-register/            # 注册接口
├── database/migrations/          # 数据库迁移 SQL
├── specs/                        # 需求、设计和任务拆分
├── PRD.md                        # 产品需求文档
└── CloudBase-数据库表设计.md       # 数据库设计说明
```

## 本地运行移动端

```bash
cd apps/mobile
fvm flutter pub get
./scripts/run_dev.sh
```

`run_dev.sh` 会读取受版本控制的开发环境配置，Android Studio 中请选择 `Development` 运行配置。普通 Debug 启动也仅会回退到同一套开发环境；正式 Release 永远不会回退到开发环境。

## 发布配置

发布前复制 `apps/mobile/config/prod.example.json` 为 `apps/mobile/config/prod.json`，填入**真实正式环境**的 EnvId 和两个 HTTPS 地址。此文件被 Git 忽略，不能放密码、SecretId、SecretKey 或 Token。

```bash
cd apps/mobile
./scripts/build_release.sh appbundle config/prod.json # Android Play / 上架包
./scripts/build_release.sh ipa config/prod.json       # iOS 发布包
```

Android 和 iOS 的 Release 编译都会校验这份配置：漏配、误用 dev、非 HTTPS、占位地址或意外放入密钥会直接阻止构建，避免把“尚未配置 CloudBase”发布给用户。

登录成功后的 access token 与 refresh token 会保存在系统安全存储中（Android Keystore / iOS Keychain）。access token 到期会自动刷新；仅当 refresh token 明确失效或撤销时才重新登录，断网不会清除本机登录状态。

iOS 模拟器快速启动：

```bash
cd apps/mobile
./scripts/run_ios_dev.sh
```

## 本地检查

移动端：

```bash
cd apps/mobile
flutter test
flutter analyze
```

云函数：

```bash
cd cloudfunctions/api
npm test

cd ../auth-register
npm install
npm test
```

## 更多文档

- 移动端运行说明：[apps/mobile/README.md](apps/mobile/README.md)
- 云函数说明：[cloudfunctions/README.md](cloudfunctions/README.md)
- 产品需求：[PRD.md](PRD.md)
- 数据库设计：[CloudBase-数据库表设计.md](CloudBase-数据库表设计.md)
