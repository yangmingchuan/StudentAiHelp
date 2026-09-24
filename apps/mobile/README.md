# 闯关小勇士移动客户端

Flutter Android/iOS 共享工程。

## 本地运行

```bash
fvm flutter pub get
./scripts/run_dev.sh
```

默认使用 `dev` 环境。开发配置在 `config/dev.json`；Android Studio 请选择共享的 `Development` 运行配置。普通 Debug Run 也会使用同一个开发环境，避免参数遗漏。

## 正式发布

```bash
cp config/prod.example.json config/prod.json
# 编辑 prod.json，填写正式 CloudBase EnvId 与正式 HTTPS 地址；不要写入密码、Token 或 SecretKey。
./scripts/build_release.sh appbundle config/prod.json
```

Release 构建会拒绝缺失配置、dev 环境、占位地址、HTTP 地址和客户端密钥；这一检查同时挂在 Android 与 iOS 的原生构建阶段，因此不会因为绕过脚本而失效。

客户端通过 HTTPS 调用 CloudBase Auth 和业务 HTTP API，不接入 CloudBase Web SDK，也不在安装包中保存 API Key。

注册由 `/api/auth/register` HTTP 云函数处理；登录、刷新会话和退出直接调用 CloudBase Auth OpenAPI。

## 快速运行 iOS dev

不需要打开 Xcode。先启动 iOS Simulator，然后在移动端工程目录执行：

```bash
./scripts/run_ios_dev.sh
```

默认运行到 `iPhone 17 Pro`。需要指定其他模拟器时：

```bash
./scripts/run_ios_dev.sh "iPhone 16 Pro"
```

进入 Flutter 交互模式后，直接按 `r` 热重载，按 `R` 热重启，按 `q` 停止运行。

## 登录保持

用户密码不保存在设备中。登录成功后，access token 与 refresh token 保存在 Android Keystore 或 iOS Keychain。access token 即将过期时自动刷新并原子性替换整对 Token；网络暂时不可用时保留本机会话，只有服务端明确返回 refresh token 无效/过期/撤销时才要求重新登录。
