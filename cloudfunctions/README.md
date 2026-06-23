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
