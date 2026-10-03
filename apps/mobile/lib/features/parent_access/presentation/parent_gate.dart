import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:little_hero/features/auth/application/auth_controller.dart';
import 'package:little_hero/features/auth/domain/auth_exception.dart';
import 'package:little_hero/features/parent_access/data/parent_pin_store.dart';

/// Wrap the entire parent navigator, including direct /todos links. Leaving
/// this shell discards the unlock; navigating inside it retains the unlock.
class ParentGate extends StatefulWidget {
  const ParentGate({required this.child, super.key});
  final Widget child;
  @override
  State<ParentGate> createState() => _ParentGateState();
}

class _ParentGateState extends State<ParentGate> with WidgetsBindingObserver {
  bool _unlocked = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      // Remove the whole parent stack, including open approval/edit dialogs.
      if (mounted) context.go('/profile');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _unlocked
      ? widget.child
      : ParentPinPage(onUnlocked: () => setState(() => _unlocked = true));
}

enum _PinStep { loading, setup, unlock, recover, reset }

class ParentPinPage extends ConsumerStatefulWidget {
  const ParentPinPage({this.onUnlocked, this.change = false, super.key});
  final VoidCallback? onUnlocked;
  final bool change;
  @override
  ConsumerState<ParentPinPage> createState() => _ParentPinPageState();
}

class _ParentPinPageState extends ConsumerState<ParentPinPage> {
  final _pin = TextEditingController();
  final _confirmation = TextEditingController();
  final _accountPassword = TextEditingController();
  _PinStep _step = _PinStep.loading;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final configured = await ref.read(parentPinStoreProvider).isConfigured();
      if (!mounted) return;
      setState(() => _step = configured ? _PinStep.unlock : _PinStep.setup);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _step = _PinStep.recover;
        _error = '无法读取家长密码，请验证当前账号的登录密码后重设。';
      });
    }
  }

  void _switch(_PinStep step) {
    _pin.clear();
    _confirmation.clear();
    _accountPassword.clear();
    setState(() {
      _step = step;
      _error = null;
    });
  }

  Future<void> _submit() async {
    if (_busy) return;
    final store = ref.read(parentPinStoreProvider);
    final owner = ref.read(authControllerProvider).asData?.value?.subject;
    final step = _step;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (step == _PinStep.recover) {
        if (_accountPassword.text.isEmpty) {
          throw const ParentPinException('请输入当前账号的登录密码。');
        }
        await ref
            .read(authControllerProvider.notifier)
            .reauthenticate(_accountPassword.text);
        if (!mounted) return;
        _switch(_PinStep.reset);
        return;
      }
      if (step == _PinStep.setup || step == _PinStep.reset) {
        if (!RegExp(r'^[0-9]{4}$').hasMatch(_pin.text)) {
          throw const ParentPinException('请输入 4 位数字密码。');
        }
        if (_pin.text != _confirmation.text) {
          throw const ParentPinException('两次输入的密码不一致，请重新确认。');
        }
        await store.setPin(_pin.text, replace: step == _PinStep.reset);
      } else {
        await store.verify(_pin.text);
        if (!mounted) return;
        if (widget.change) {
          _switch(_PinStep.reset);
          return;
        }
      }
      if (!mounted ||
          ref.read(authControllerProvider).asData?.value?.subject != owner) {
        return;
      }
      if (widget.change) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('家长密码已更新')));
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/profile');
        }
      } else {
        widget.onUnlocked?.call();
      }
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _error = switch (error) {
          ParentPinException() => error.message,
          AuthException() => error.message,
          _ => '操作未完成，请稍后重试。',
        },
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _pin.dispose();
    _confirmation.dispose();
    _accountPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final setting = _step == _PinStep.setup || _step == _PinStep.reset;
    final recovering = _step == _PinStep.recover;
    final title = switch (_step) {
      _PinStep.setup => '设置家长密码',
      _PinStep.reset => '设置新密码',
      _PinStep.recover => '找回家长入口',
      _ => widget.change ? '验证原家长密码' : '家长验证',
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          tooltip: '返回',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (widget.change) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
      ),
      body: SafeArea(
        child: _step == _PinStep.loading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(Icons.lock_outline_rounded, size: 48),
                        const SizedBox(height: 20),
                        Text(
                          recovering
                              ? '联网验证当前账号的登录密码后，即可重新设置四位家长密码。'
                              : setting
                              ? '请由家长设置 4 位数字密码，用于保护任务安排和奖励管理。'
                              : '请输入 4 位家长密码。',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        if (recovering) ...[
                          Text(
                            '当前账号：${ref.watch(authControllerProvider).asData?.value?.username ?? ''}',
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            key: const ValueKey('parent-account-password'),
                            controller: _accountPassword,
                            enabled: !_busy,
                            obscureText: true,
                            autocorrect: false,
                            enableSuggestions: false,
                            decoration: const InputDecoration(
                              labelText: '账号登录密码',
                            ),
                            onSubmitted: (_) => _submit(),
                          ),
                        ] else ...[
                          _pinField(
                            _pin,
                            'parent-pin',
                            setting ? '输入四位密码' : '四位家长密码',
                          ),
                          if (setting) ...[
                            const SizedBox(height: 12),
                            _pinField(
                              _confirmation,
                              'parent-pin-confirm',
                              '再次确认密码',
                            ),
                          ],
                        ],
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              _error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: _busy ? null : _submit,
                          child: Text(
                            _busy
                                ? '请稍候…'
                                : recovering
                                ? '验证并重设'
                                : setting
                                ? (widget.change ? '保存新密码' : '保存并进入')
                                : '解锁',
                          ),
                        ),
                        if (_step == _PinStep.unlock)
                          TextButton(
                            onPressed: _busy
                                ? null
                                : () => _switch(_PinStep.recover),
                            child: const Text('忘记密码？'),
                          ),
                        if (recovering)
                          TextButton(
                            onPressed: _busy
                                ? null
                                : () => _switch(_PinStep.unlock),
                            child: const Text('返回四位密码解锁'),
                          ),
                        const SizedBox(height: 12),
                        Text(
                          recovering
                              ? '若账号登录密码也忘记了，请联系内测管理员；孩子的打卡记录不会被清空。'
                              : '密码仅用于当前账号在这台设备上的家长入口。忘记时可用账号登录密码重设。',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _pinField(
    TextEditingController controller,
    String key,
    String label,
  ) => TextField(
    key: ValueKey(key),
    controller: controller,
    enabled: !_busy,
    obscureText: true,
    enableSuggestions: false,
    autocorrect: false,
    keyboardType: TextInputType.number,
    maxLength: 4,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(4),
    ],
    decoration: InputDecoration(labelText: label, counterText: ''),
    onSubmitted: (_) => _submit(),
  );
}
