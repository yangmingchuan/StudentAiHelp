import 'package:flutter/foundation.dart';

enum AppFlavor { dev, staging, prod }

class AppEnvironment {
  const AppEnvironment({
    required this.flavor,
    required this.cloudBaseEnvId,
    required this.authApiBaseUrl,
    required this.functionApiBaseUrl,
    this.supabaseUrl = '',
    this.supabasePublishableKey = '',
  });

  factory AppEnvironment.fromDartDefines() {
    const flavorName = String.fromEnvironment(
      'APP_FLAVOR',
      defaultValue: 'dev',
    );
    const envId = String.fromEnvironment('CLOUDBASE_ENV_ID');
    const authApiBaseUrl = String.fromEnvironment('AUTH_API_BASE_URL');
    const functionApiBaseUrl = String.fromEnvironment('FUNCTION_API_BASE_URL');
    const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
    const supabaseKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
    if (supabaseUrl.isNotEmpty || supabaseKey.isNotEmpty) {
      return AppEnvironment(
        flavor: AppFlavor.values.firstWhere(
          (f) => f.name == flavorName,
          orElse: () => AppFlavor.dev,
        ),
        cloudBaseEnvId: '',
        authApiBaseUrl: supabaseUrl,
        functionApiBaseUrl: supabaseUrl,
        supabaseUrl: supabaseUrl,
        supabasePublishableKey: supabaseKey,
      );
    }

    // Only a plain debug launch may use the checked-in development endpoints.
    // Partial overrides must never accidentally mix two environments.
    if (kDebugMode &&
        flavorName == 'dev' &&
        envId.isEmpty &&
        authApiBaseUrl.isEmpty &&
        functionApiBaseUrl.isEmpty) {
      return development;
    }

    return AppEnvironment(
      flavor: AppFlavor.values.firstWhere(
        (flavor) => flavor.name == flavorName,
        orElse: () => AppFlavor.dev,
      ),
      cloudBaseEnvId: envId,
      authApiBaseUrl: authApiBaseUrl,
      functionApiBaseUrl: functionApiBaseUrl,
    );
  }

  final AppFlavor flavor;
  final String cloudBaseEnvId;
  final String authApiBaseUrl;
  final String functionApiBaseUrl;
  final String supabaseUrl;
  final String supabasePublishableKey;
  bool get usesSupabase => supabaseUrl.isNotEmpty;

  static const development = AppEnvironment(
    flavor: AppFlavor.dev,
    cloudBaseEnvId: '',
    authApiBaseUrl: 'https://onvhkbbfvvjvdzqsalcd.supabase.co',
    functionApiBaseUrl: 'https://onvhkbbfvvjvdzqsalcd.supabase.co',
    supabaseUrl: 'https://onvhkbbfvvjvdzqsalcd.supabase.co',
    supabasePublishableKey: 'sb_publishable_bg2UEFNq0rurAGZjHaBEXg_tIZWjYDz',
  );

  static const legacyDevelopment = AppEnvironment(
    flavor: AppFlavor.dev,
    cloudBaseEnvId: 'little-hero-dev-d7f95sqy70d3a475',
    authApiBaseUrl:
        'https://little-hero-dev-d7f95sqy70d3a475.api.tcloudbasegateway.com',
    functionApiBaseUrl:
        'https://little-hero-dev-d7f95sqy70d3a475.service.tcloudbase.com',
  );

  String get sessionNamespace => usesSupabase
      ? 'supabase|$supabaseUrl'
      : '$cloudBaseEnvId|$authApiBaseUrl';

  bool get isCloudConfigured => usesSupabase
      ? _isHttpsEndpoint(supabaseUrl) &&
            supabasePublishableKey.startsWith('sb_publishable_')
      : cloudBaseEnvId.isNotEmpty &&
            _isHttpsEndpoint(authApiBaseUrl) &&
            _isHttpsEndpoint(functionApiBaseUrl);

  static bool _isHttpsEndpoint(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        uri.scheme == 'https' &&
        uri.host.isNotEmpty &&
        uri.userInfo.isEmpty &&
        !uri.hasQuery &&
        !uri.hasFragment;
  }
}
