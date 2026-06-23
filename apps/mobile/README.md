# 闯关小勇士移动客户端

Flutter Android/iOS 共享工程。

## 本地运行

```bash
fvm flutter pub get
fvm flutter run
```

默认使用 `dev` 环境。连接 CloudBase 前必须显式传入完整 EnvId 和 API 地址：

```bash
fvm flutter run \
  --dart-define=APP_FLAVOR=dev \
  --dart-define=CLOUDBASE_ENV_ID=little-hero-dev-d7f95sqy70d3a475 \
  --dart-define=AUTH_API_BASE_URL=https://little-hero-dev-d7f95sqy70d3a475.api.tcloudbasegateway.com \
  --dart-define=FUNCTION_API_BASE_URL=https://little-hero-dev-d7f95sqy70d3a475.service.tcloudbase.com
```

客户端通过 HTTPS 调用 CloudBase Auth 和业务 HTTP API，不接入 CloudBase Web SDK，也不在安装包中保存 API Key。

注册由 `/api/auth/register` HTTP 云函数处理；登录、刷新会话和退出直接调用 CloudBase Auth OpenAPI。
