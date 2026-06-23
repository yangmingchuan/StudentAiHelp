final phoneUsernamePattern = RegExp(r'^1[3-9]\d{9}$');
final passwordAllowedPattern = RegExp(r'^[A-Za-z0-9()!@#$%^&*|?><_-]+$');

String? validatePhoneUsername(String? value) {
  final username = value?.trim() ?? '';
  if (!phoneUsernamePattern.hasMatch(username)) {
    return '请输入合法的 11 位手机号格式账号';
  }
  return null;
}

String? validatePassword(String? value) {
  final password = value ?? '';
  if (password.length < 8 || password.length > 20) {
    return '密码长度需为 8-20 位';
  }
  if (!RegExp(r'^[A-Za-z0-9]').hasMatch(password)) {
    return '密码不能以特殊字符开头';
  }
  if (!passwordAllowedPattern.hasMatch(password)) {
    return '密码包含不支持的字符';
  }

  final categories = [
    RegExp('[a-z]').hasMatch(password),
    RegExp('[A-Z]').hasMatch(password),
    RegExp(r'\d').hasMatch(password),
    RegExp(r'[()!@#$%^&*|?><_-]').hasMatch(password),
  ].where((matches) => matches).length;

  if (categories < 3) {
    return '需包含大小写字母、数字、特殊字符中的至少三类';
  }
  return null;
}
