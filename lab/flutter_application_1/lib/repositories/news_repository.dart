import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/article_model.dart';
import '../models/category_model.dart';
import '../services/news_service.dart';

class NewsRepository {
  final NewsService _newsService;
  static const String _cachedArticlesKey = 'cached_articles';
  static const String _bookmarkedArticlesKey = 'bookmarked_articles';
  static const String _cacheTimestampKey = 'cache_timestamp';
  static const int _cacheExpirationHours = 1; // Cache expires after 1 hour

  NewsRepository(this._newsService);

  // Abstract data layer from UI
  Future<List<Article>> getTopHeadlines({bool useCache = true}) async {
    try {
      // Check cache first if offline support needed
      if (useCache) {
        final cachedArticles = await _getCachedArticles();
        final isCacheExpired = await _isCacheExpired();
        if (cachedArticles.isNotEmpty && !isCacheExpired) {
          return cachedArticles;
        }
      }

      final articles = await _newsService.getTopHeadlines();

      // Cache the results
      await _cacheArticles(articles);

      return articles;
    } catch (e) {
      // Fallback to cache when API fails
      final cachedArticles = await _getCachedArticles();
      if (cachedArticles.isNotEmpty) {
        return cachedArticles;
      }
      throw Exception('Failed to load headlines: $e');
    }
  }

  // Handle both API and local data
  Future<List<Article>> getNewsByCategory({
    required String category,
    bool useCache = true,
  }) async {
    try {
      final articles = await _newsService.getNewsByCategory(category: category);
      return articles;
    } catch (e) {
      // Implement caching strategies
      throw Exception('Failed to load news by category: $e');
    }
  }

  // Implement caching strategies
  Future<List<Article>> searchNews({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      return await _newsService.searchNews(
        query: query,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      throw Exception('Failed to search news: $e');
    }
  }

  // Manage offline capabilities
  Future<bool> isOffline() async {
    try {
      await _newsService.getTopHeadlines();
      return false;
    } catch (e) {
      return true;
    }
  }

  // Handle data synchronization
  Future<void> syncData() async {
    try {
      final articles = await _newsService.getTopHeadlines();
      await _cacheArticles(articles);
    } catch (e) {
      // Handle sync errors
      throw Exception('Failed to sync data: $e');
    }
  }

  // Pagination logic
  Future<List<Article>> loadMoreArticles({
    String? category,
    String? query,
    required int page,
    int pageSize = 20,
  }) async {
    try {
      return await _newsService.loadMoreArticles(
        category: category,
        query: query,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      throw Exception('Failed to load more articles: $e');
    }
  }

  // Bookmark article() - Local storage
  Future<void> bookmarkArticle(Article article) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarkedArticles = await getBookmarkedArticles();

      final updatedBookmarks = [
        ...bookmarkedArticles,
        article.copyWith(isBookmarked: true),
      ];
      final bookmarksJson = updatedBookmarks.map((a) => a.toJson()).toList();

      await prefs.setString(_bookmarkedArticlesKey, jsonEncode(bookmarksJson));
    } catch (e) {
      throw Exception('Failed to bookmark article: $e');
    }
  }

  // Remove bookmark
  Future<void> removeBookmark(String articleId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarkedArticles = await getBookmarkedArticles();

      final updatedBookmarks = bookmarkedArticles
          .where((article) => article.id != articleId)
          .toList();

      final bookmarksJson = updatedBookmarks.map((a) => a.toJson()).toList();
      await prefs.setString(_bookmarkedArticlesKey, jsonEncode(bookmarksJson));
    } catch (e) {
      throw Exception('Failed to remove bookmark: $e');
    }
  }

  // Get bookmarked articles from storage
  Future<List<Article>> getBookmarkedArticles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksString = prefs.getString(_bookmarkedArticlesKey);

      if (bookmarksString == null) return [];

      final List<dynamic> bookmarksJson = jsonDecode(bookmarksString);
      return bookmarksJson.map((json) => Article.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Check if article is bookmarked
  Future<bool> isArticleBookmarked(String articleId) async {
    final bookmarkedArticles = await getBookmarkedArticles();
    return bookmarkedArticles.any((article) => article.id == articleId);
  }

  // Clear cache() - For data refresh
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cachedArticlesKey);
      await prefs.remove(_cacheTimestampKey);
    } catch (e) {
      throw Exception('Failed to clear cache: $e');
    }
  }

  // Get categories
  Future<List<Category>> getCategories() async {
    return Category.getDefaultCategories();
  }

  // Private methods for caching
  Future<void> _cacheArticles(List<Article> articles) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final articlesJson = articles.map((a) => a.toJson()).toList();
      await prefs.setString(_cachedArticlesKey, jsonEncode(articlesJson));
      await prefs.setInt(
        _cacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      // Ignore cache errors
    }
  }

  Future<List<Article>> _getCachedArticles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final articlesString = prefs.getString(_cachedArticlesKey);

      if (articlesString == null) return [];

      final List<dynamic> articlesJson = jsonDecode(articlesString);
      return articlesJson.map((json) => Article.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> _isCacheExpired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_cacheTimestampKey) ?? 0;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final expirationTime = cacheTime.add(
        Duration(hours: _cacheExpirationHours),
      );
      return DateTime.now().isAfter(expirationTime);
    } catch (e) {
      return true;
    }
  }
}
