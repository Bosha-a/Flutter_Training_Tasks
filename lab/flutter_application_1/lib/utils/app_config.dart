import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // News API Configuration
  static String get newsApiKey => dotenv.env['API_KEY'] ?? '';
  static String get newsApiBaseUrl =>
      dotenv.env['NEWS_API_BASE_URL'] ?? 'https://newsapi.org/v2';

  // App Configuration
  static String get appName => 'News App';
  static String get appVersion => '1.0.0';

  // Cache Configuration
  static int get cacheExpirationHours => 1;
  static int get defaultPageSize => 20;
  static int get maxCacheSize => 100; // Maximum number of cached articles

  // Request Configuration
  static int get requestTimeoutSeconds => 30;
  static int get retryAttempts => 3;

  // Validation
  static bool get isNewsApiKeyValid => newsApiKey.isNotEmpty;

  static void validateConfiguration() {
    if (!isNewsApiKeyValid) {
      throw Exception('NEWS_API_KEY is required but not found in .env file');
    }

    if (newsApiBaseUrl.isEmpty) {
      throw Exception(
        'NEWS_API_BASE_URL is required but not found in .env file',
      );
    }
  }

  // Environment check
  static bool get isDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  // Logging configuration
  static bool get enableLogging => isDebugMode;
  static bool get enableCrashReporting => !isDebugMode;

  // Feature flags (can be moved to remote config later)
  static bool get enablePushNotifications => true;
  static bool get enableOfflineMode => true;
  static bool get enableBookmarks => true;
  static bool get enableSearch => true;
  static bool get enableCategoryFilter => true;
}
