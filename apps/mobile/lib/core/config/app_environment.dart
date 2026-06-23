enum AppFlavor { dev, staging, prod }

class AppEnvironment {
  const AppEnvironment({
    required this.flavor,
    required this.cloudBaseEnvId,
    required this.authApiBaseUrl,
    required this.functionApiBaseUrl,
  });

  factory AppEnvironment.fromDartDefines() {
    const flavorName = String.fromEnvironment(
      'APP_FLAVOR',
      defaultValue: 'dev',
    );
    const envId = String.fromEnvironment('CLOUDBASE_ENV_ID');
    const authApiBaseUrl = String.fromEnvironment('AUTH_API_BASE_URL');
    const functionApiBaseUrl = String.fromEnvironment('FUNCTION_API_BASE_URL');

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

  bool get isCloudConfigured =>
      cloudBaseEnvId.isNotEmpty &&
      authApiBaseUrl.isNotEmpty &&
      functionApiBaseUrl.isNotEmpty;
}
