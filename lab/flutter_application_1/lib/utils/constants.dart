class AppConstants {
  // API Constants
  static const String newsApiBaseUrl = 'https://newsapi.org/v2';

  // Storage Keys
  static const String cachedArticlesKey = 'cached_articles';
  static const String bookmarkedArticlesKey = 'bookmarked_articles';
  static const String cacheTimestampKey = 'cache_timestamp';
  static const String userPreferencesKey = 'user_preferences';
  static const String selectedCategoryKey = 'selected_category';

  // Default Values
  static const String defaultCountry = 'us';
  static const String defaultCategory = 'general';
  static const int defaultPageSize = 20;
  static const int maxCacheSize = 100;
  static const int cacheExpirationHours = 1;
  static const int requestTimeoutSeconds = 30;

  // Categories
  static const List<String> availableCategories = [
    'general',
    'business',
    'entertainment',
    'health',
    'science',
    'sports',
    'technology',
  ];

  // Error Messages
  static const String networkErrorMessage =
      'Please check your internet connection';
  static const String serverErrorMessage = 'Service temporarily unavailable';
  static const String noArticlesMessage = 'No articles found';
  static const String apiKeyErrorMessage = 'API key is missing or invalid';

  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enableBookmarks = true;
  static const bool enableSearch = true;
  static const bool enablePushNotifications = true;

  // App Info
  static const String appName = 'News App';
  static const String appVersion = '1.0.0';
  static const String supportEmail = 'support@newsapp.com';
}
