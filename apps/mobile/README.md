# 猫咪打卡移动客户端

Flutter Android/iOS 共享工程。应用在 Android 和 iOS 上均显示为「猫咪打卡」，并使用统一的猫咪图标与启动页。

## 本地运行

```bash
fvm flutter pub get
./scripts/run_dev.sh
```

开发配置在 `config/dev.json`，指向现有 Supabase 项目；Android Studio 请选择共享的 `Development` 运行配置。普通 Debug Run 也使用该配置。

## 正式发布

```bash
cp config/prod.example.json config/prod.json
# 模板已填写当前 Supabase 项目；不要写入密码、Token 或服务端密钥。
./scripts/build_release.sh appbundle config/prod.json
```

Release 构建会拒绝缺失配置、dev 环境、占位地址、HTTP 地址和客户端密钥；这一检查同时挂在 Android 与 iOS 的原生构建阶段，因此不会因为绕过脚本而失效。

客户端通过 HTTPS 调用 Supabase Auth 与 `todo_sync` RPC，包内仅放公开 publishable key；数据库服务密钥只在 Supabase Edge Function 运行时使用。

旧账号首次登录经 `todo-auth` 函数验证 CloudBase 密码并创建 Supabase 账号；以后登录、刷新和退出直接调用 Supabase Auth。过渡期注册仍依赖旧 CloudBase 注册接口来保留原手机号格式账号命名空间。手机号归属没有短信验证。

## 数据迁移与同步

- 同一账号在两台设备上各自保存本地 SQLite，云端按 Supabase `auth.uid()` 隔离。新增的公开业务表全带 `todo_` 前缀，原项目表不改。
- SQLite 触发器把离线写入记录在本地队列；联网后上传，后台恢复时下载。任务、历史、休息日、奖励、经期、用药及更正/提醒都包含在内。
- 两台设备修改同一条记录时，上传会停在冲突队列；在「我的」中选择本机或云端。离线期间不要卸载 App，未上传的更改只在本机。
- 旧数据库仅在旧登录账号与新登录账号相同、且该账号尚未生成新数据库时自动复制；源文件不删除。若旧会话已清除，不会猜测旧文件属于哪个账号，也不会自动导入。
- 手机间同步健康文字时使用 TLS，接收设备会用自己的安全存储密钥重新加密。Supabase 管理员可读取云端明文，RLS 防止普通账号互看数据。

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

## 运行到 iPhone 真机

先通过数据线连接并解锁 iPhone；首次连接时，在手机上信任此电脑、开启「开发者模式」，并在「设置 → 通用 → VPN 与设备管理」中信任开发者证书。查看 Flutter 识别到的设备：

```bash
fvm flutter devices
```

输出中 iPhone 名称后的长串 ID 就是设备 ID。将它传给开发脚本即可从 Xcode/Flutter 调试器启动：

```bash
./scripts/run_dev.sh -d "设备 ID"
```

Debug 包仅用于连着 Xcode 或 `flutter run` 的开发调试。iOS 会在 Debug 包脱离调试器、被杀掉后再从桌面独立启动时主动结束进程；这是 Flutter 的调试限制，不是业务闪退。

若要验证「杀掉 App 后，再从桌面点图标」的冷启动，请改用 Profile 包：

```bash
fvm flutter build ios --profile --dart-define-from-file=config/dev.json
xcrun devicectl device install app --device "设备 ID" build/ios/iphoneos/Runner.app
```

Profile 包支持独立冷启动，也保留性能分析能力；正式上架请使用带正式配置的 Release 构建。

## 登录保持

用户密码不保存在设备中。登录成功后，access token 与 refresh token 保存在 Android Keystore 或 iOS Keychain。access token 即将过期时自动刷新并原子性替换整对 Token；网络暂时不可用时保留本机会话，只有服务端明确返回 refresh token 无效/过期/撤销时才要求重新登录。
