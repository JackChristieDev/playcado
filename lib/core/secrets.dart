class Secrets {
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');
  static bool get isSentryEnabled => sentryDsn.isNotEmpty;
}
