# 猫咪打卡移动客户端

Flutter Android/iOS 共享工程。应用在 Android 和 iOS 上均显示为「猫咪打卡」，并使用统一的猫咪图标与启动页。

## 本地运行

```bash
fvm flutter pub get
./scripts/run_dev.sh
```

开发配置在 `config/dev.json`，指向现有 Supabase 项目；Android Studio 真机日常运行请选择共享的 `Release` 配置，并点击 Run（三角形），不要点击 Debug。`Release` 使用 `config/prod.json`，可脱离调试器冷启动，不支持热重载；调试或模拟器运行请选择 `Development`。首次使用 Release 时先按下方说明创建 `config/prod.json`。

## iOS 真机签名

工程最低支持 iOS 15，Pods 的最低版本也统一设为至少 15，以兼容 Xcode 27。
用 Xcode 打开 `ios/Runner.xcworkspace`，在 Settings → Accounts 添加自己的 Apple 账号，
然后在 Runner → Signing & Capabilities 中启用 Automatically manage signing，选择有权限的 Team。
真机运行不需要之前模拟器使用的临时 `XCODE_XCCONFIG_FILE` 环境变量。
Release 使用 `prod.json` 中的正式配置；不要卸载 App，以保留未同步的本地数据。
开发签名有有效期，免费 Personal Team 的描述文件有效期为 7 天，过期需重新签名安装。

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

## 家长密码与任务模板

首次进入「我的 → 家长设置」需要输入并确认四位数字密码；以后进入家长设置或任务管理均需解锁。在家长区内部切换页面无需重复输入，离开家长区、切到后台或重启后重新锁定。家长设置中可以修改密码。

忘记四位密码时，可联网验证**当前账号的登录密码**后设置新密码；验证失败不会清除登录会话或打卡数据。账号登录密码也遗忘时仍需联系内测管理员，不提供短信找回。连续输错五次暂停尝试六十秒。

四位密码使用随机盐和 PBKDF2 保存于系统安全存储，按环境与账号隔离，仅保护本机入口，不通过业务数据同步；其他设备需各自设置。首次安装后应由家长先完成设置。

新增任务提供家务（扫地、擦桌子）、运动（跳绳、户外运动）、阅读（阅读绘本、朗读故事）六个快捷选项与独立透明图标。点击选项后仍可修改名称；已有任务不会自动增加。图标标识随任务同步，生成提示词见 `specs/task-icon-prompts.md`。

## 登录保持

用户密码不保存在设备中。登录成功后，access token 与 refresh token 保存在 Android Keystore 或 iOS Keychain。access token 即将过期时自动刷新并原子性替换整对 Token；网络暂时不可用时保留本机会话，只有服务端明确返回 refresh token 无效/过期/撤销时才要求重新登录。
