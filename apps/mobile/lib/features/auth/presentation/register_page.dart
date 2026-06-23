import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:little_hero/features/auth/application/auth_controller.dart';
import 'package:little_hero/features/auth/domain/auth_exception.dart';
import 'package:little_hero/features/auth/presentation/auth_validators.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _privacyAccepted = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!_privacyAccepted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先同意隐私政策和儿童个人信息保护规则。')));
      return;
    }

    try {
      await ref
          .read(authControllerProvider.notifier)
          .register(
            username: _usernameController.text.trim(),
            password: _passwordController.text,
          );
    } catch (error) {
      if (!mounted) return;
      final message = error is AuthException ? error.message : '注册失败，请稍后重试。';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('注册家长账号'),
        leading: IconButton(
          onPressed: () => context.go('/login'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newUsername],
                      decoration: const InputDecoration(
                        labelText: '手机号格式账号',
                        prefixIcon: Icon(Icons.phone_android_rounded),
                      ),
                      validator: validatePhoneUsername,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText: '设置 8-20 位密码',
                        helperText: '需满足大小写字母、数字、特殊字符中的至少三类',
                        helperMaxLines: 2,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                          ),
                        ),
                      ),
                      validator: validatePassword,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => isLoading ? null : _submit(),
                      decoration: const InputDecoration(
                        labelText: '确认密码',
                        prefixIcon: Icon(Icons.lock_reset_rounded),
                      ),
                      validator: (value) => value != _passwordController.text
                          ? '两次输入的密码不一致'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      value: _privacyAccepted,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: isLoading
                          ? null
                          : (value) => setState(
                              () => _privacyAccepted = value ?? false,
                            ),
                      title: const Text('我已阅读并同意隐私政策和儿童个人信息保护规则'),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: isLoading ? null : _submit,
                      child: Text(isLoading ? '注册中…' : '注册并登录'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: isLoading ? null : () => context.go('/login'),
                      child: const Text('已有账号？返回登录'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'MVP 内测不发送短信验证码，手机号仅作为账号格式，不代表已验证归属。',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
