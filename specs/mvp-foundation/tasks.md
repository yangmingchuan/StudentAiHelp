# 闯关小勇士 MVP 实施计划

> 需求基线：[requirements.md](requirements.md)  
> 技术设计：[design.md](design.md)

## Phase 1：Flutter 双端工程与基础架构

- [x] 1. 初始化 Flutter Android/iOS 工程
  - 工程放置于 `apps/mobile`
  - 使用 Flutter stable，并通过 FVM 固定项目版本
  - Android 最低版本设为 API 26，iOS 最低版本设为 iOS 13
  - _Requirements: 9, 10_

- [x] 2. 建立客户端基础架构
  - 引入 Riverpod、go_router、Dio、freezed、Drift 等基础依赖
  - 建立 `app`、`core`、`features` 分层目录
  - 预留 dev、staging、prod 显式环境配置
  - _Requirements: 9, 10_

- [x] 3. 建立 App 外壳与四 Tab
  - 默认进入任务 Tab
  - 提供任务、数学、英语、我的四个入口
  - 数学和英语仅展示“内容准备中”
  - _Requirement: 9_

- [x] 4. 建立质量基线
  - 配置静态分析与格式化
  - 添加基础 Widget 测试
  - 验证 Android 与 iOS Simulator 构建
  - _Requirements: 9, 10_

## Phase 2：CloudBase、认证与数据基础

- [x] 5. 确认 CloudBase 环境与 Auth OpenAPI
  - 创建或绑定 dev 环境，并显式记录完整 EnvId
  - 确认用户名/密码注册、登录、刷新和退出端点
  - 客户端不保存 API Key
  - _Requirements: 1, 2_

- [ ] 6. 建立核心数据库迁移与后端 API
  - 根据冻结后的业务规则校准数据库设计
  - 创建 MVP 核心表、索引和约束
  - 建立鉴权、幂等与统一错误响应
  - _Requirements: 2, 3, 4, 5, 6, 7, 8, 10_

## Phase 3：MVP 核心业务闭环

- [ ] 7. 实现注册、登录与孩子档案初始化
  - [x] 注册、登录、会话刷新、退出和登录态路由
  - [ ] 注册成功后的默认孩子档案初始化（随核心数据库 API 实现）
  - _Requirements: 1, 2_

- [ ] 8. 实现今日任务、打卡、跳过与撤销
  - _Requirements: 3, 4, 10_

- [ ] 9. 实现星星、连续奖励、全完成奖励和勋章结算
  - _Requirements: 4, 5, 7_

- [ ] 10. 实现每日小心心恢复与资产展示
  - _Requirement: 6_

- [ ] 11. 实现家长入口和任务管理
  - _Requirement: 8_

## Phase 4：双端验收与内测

- [ ] 12. 完成离线同步、异常恢复和边界测试
  - _Requirement: 10_

- [ ] 13. 完成 Android/iOS 真机回归和内测构建
  - _Requirements: 1-10_
