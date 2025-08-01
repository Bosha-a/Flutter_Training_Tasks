import 'package:dio/dio.dart';

import '../models/article_model.dart';
import '../utils/app_config.dart';

class NewsService {
  final Dio _dio = Dio();

  NewsService() {
    // Validate API configuration
    AppConfig.validateConfiguration();

    _dio.options.headers = {'X-API-Key': AppConfig.newsApiKey};

    // Set request timeouts
    _dio.options.connectTimeout = Duration(
      seconds: AppConfig.requestTimeoutSeconds,
    );
    _dio.options.receiveTimeout = Duration(
      seconds: AppConfig.requestTimeoutSeconds,
    );
  }

  // Get headlines by country - Latest news
  Future<List<Article>> getTopHeadlines({String country = 'us'}) async {
    try {
      final response = await _dio.get(
        '${AppConfig.newsApiBaseUrl}/top-headlines',
        queryParameters: {'country': country},
      );

      if (response.statusCode == 200) {
        final List<dynamic> articles = response.data['articles'];
        return articles.map((json) => Article.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load top headlines');
      }
    } catch (e) {
      throw Exception('Error fetching top headlines: $e');
    }
  }

  // Get headlines by category - Category filtering
  Future<List<Article>> getNewsByCategory({
    required String category,
    String country = 'us',
  }) async {
    try {
      final response = await _dio.get(
        '${AppConfig.newsApiBaseUrl}/top-headlines',
        queryParameters: {'country': country, 'category': category},
      );

      if (response.statusCode == 200) {
        final List<dynamic> articles = response.data['articles'];
        return articles.map((json) => Article.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load news by category');
      }
    } catch (e) {
      throw Exception('Error fetching news by category: $e');
    }
  }

  // Search functionality
  Future<List<Article>> searchNews({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '${AppConfig.newsApiBaseUrl}/everything',
        queryParameters: {
          'q': query,
          'page': page,
          'pageSize': pageSize,
          'sortBy': 'publishedAt',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> articles = response.data['articles'];
        return articles.map((json) => Article.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search news');
      }
    } catch (e) {
      throw Exception('Error searching news: $e');
    }
  }

  // Get news sources - Available news sources
  Future<List<Map<String, dynamic>>> getNewsSources() async {
    try {
      final response = await _dio.get('${AppConfig.newsApiBaseUrl}/sources');

      if (response.statusCode == 200) {
        final List<dynamic> sources = response.data['sources'];
        return sources.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load news sources');
      }
    } catch (e) {
      throw Exception('Error fetching news sources: $e');
    }
  }

  // Pagination support for loading more articles
  Future<List<Article>> loadMoreArticles({
    String? category,
    String? query,
    required int page,
    int pageSize = 20,
  }) async {
    try {
      Map<String, dynamic> queryParams = {'page': page, 'pageSize': pageSize};

      String endpoint;

      if (query != null && query.isNotEmpty) {
        // Search query
        endpoint = '${AppConfig.newsApiBaseUrl}/everything';
        queryParams['q'] = query;
        queryParams['sortBy'] = 'publishedAt';
      } else {
        // Top headlines with optional category
        endpoint = '${AppConfig.newsApiBaseUrl}/top-headlines';
        queryParams['country'] = 'us';
        if (category != null && category.isNotEmpty) {
          queryParams['category'] = category;
        }
      }

      final response = await _dio.get(endpoint, queryParameters: queryParams);

      if (response.statusCode == 200) {
        final List<dynamic> articles = response.data['articles'];
        return articles.map((json) => Article.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load more articles');
      }
    } catch (e) {
      throw Exception('Error loading more articles: $e');
    }
  }

  // Handle request timeout and caching
  Future<List<Article>> getCachedNews() async {
    // This would integrate with local caching mechanism
    // For now, return latest headlines
    return await getTopHeadlines();
  }

  // Set request timeout
  void setRequestTimeout(int timeoutInSeconds) {
    _dio.options.connectTimeout = Duration(seconds: timeoutInSeconds);
    _dio.options.receiveTimeout = Duration(seconds: timeoutInSeconds);
  }
}
