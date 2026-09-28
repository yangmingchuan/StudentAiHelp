import 'dart:convert';
import 'dart:io';

/// Called by both native build systems, even when flutter build bypasses scripts.
void main(List<String> args) {
  try {
    final Map<String, String> config;
    if (args.length == 2 && args.first == '--file') {
      final value =
          jsonDecode(File(args[1]).readAsStringSync()) as Map<String, dynamic>;
      config = value.map((key, value) => MapEntry(key, value.toString()));
    } else if (args.length == 2 && args.first == '--defines') {
      config = {};
      for (final encoded
          in args[1].split(',').where((part) => part.isNotEmpty)) {
        final pair = utf8.decode(base64.decode(encoded));
        final split = pair.indexOf('=');
        if (split > 0) {
          config[pair.substring(0, split)] = pair.substring(split + 1);
        }
      }
    } else {
      throw const FormatException(
        '使用 --file <配置.json> 或 --defines <DART_DEFINES>',
      );
    }
    validateReleaseConfig(config);
    stdout.writeln('发布环境配置检查通过（未检查云端可用性或发布签名）。');
  } catch (error) {
    stderr.writeln('禁止生成缺少正式服务配置的发布包：$error');
    exitCode = 1;
  }
}

void validateReleaseConfig(Map<String, String> config) {
  if ((config['SUPABASE_URL'] ?? '').isNotEmpty ||
      (config['SUPABASE_PUBLISHABLE_KEY'] ?? '').isNotEmpty) {
    final url = Uri.tryParse(config['SUPABASE_URL'] ?? '');
    final key = config['SUPABASE_PUBLISHABLE_KEY'] ?? '';
    if (config['APP_FLAVOR'] != 'prod' ||
        url == null ||
        url.scheme != 'https' ||
        url.host.isEmpty ||
        url.userInfo.isNotEmpty ||
        url.hasQuery ||
        url.hasFragment ||
        !key.startsWith('sb_publishable_') ||
        key.contains('REPLACE_') ||
        key.length < 25 ||
        config.containsKey('CLOUDBASE_ENV_ID') ||
        config.containsKey('AUTH_API_BASE_URL') ||
        config.containsKey('FUNCTION_API_BASE_URL')) {
      throw const FormatException(
        '必须提供正式 Supabase HTTPS 地址和 publishable key，且不能混用 CloudBase 地址。',
      );
    }
    for (final name in config.keys) {
      if (RegExp(
        r'(SECRET|PASSWORD|PRIVATE_KEY|ACCESS_TOKEN|REFRESH_TOKEN|SERVICE_ROLE)',
        caseSensitive: false,
      ).hasMatch(name)) {
        throw const FormatException('客户端配置不能包含服务端密钥。');
      }
    }
    return;
  }
  final env = config['CLOUDBASE_ENV_ID'] ?? '';
  if (config['APP_FLAVOR'] != 'prod' ||
      env.trim().isEmpty ||
      env == 'little-hero-dev-d7f95sqy70d3a475' ||
      env.contains('REPLACE_')) {
    throw const FormatException('必须提供 APP_FLAVOR=prod 和真实的正式 EnvId；不能使用开发环境。');
  }
  for (final key in ['AUTH_API_BASE_URL', 'FUNCTION_API_BASE_URL']) {
    final uri = Uri.tryParse(config[key] ?? '');
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        uri.host.contains('REPLACE_') ||
        uri.host.endsWith('.invalid') ||
        uri.host.contains('little-hero-dev-d7f95sqy70d3a475')) {
      throw FormatException('$key 必须是有效的正式 HTTPS 服务地址。');
    }
  }
  for (final key in config.keys) {
    if (RegExp(
      r'(SECRET|PASSWORD|PRIVATE_KEY|ACCESS_TOKEN|REFRESH_TOKEN)',
      caseSensitive: false,
    ).hasMatch(key)) {
      throw const FormatException('客户端发布配置不能包含密码或服务端密钥。');
    }
  }
}
