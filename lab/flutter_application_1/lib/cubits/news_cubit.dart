import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/article_model.dart';
import '../models/category_model.dart';
import '../repositories/news_repository.dart';
import 'news_state.dart';

class NewsCubit extends Cubit<NewsState> {
  final NewsRepository _newsRepository;

  // Core methods for state management flow
  List<Article> _currentArticles = [];
  List<Category> _categories = [];
  String _selectedCategoryId = 'general';
  int _currentPage = 1;
  String _currentSearchQuery = '';
  bool _hasMore = true;

  NewsCubit(this._newsRepository) : super(NewsInitial());

  // Check cache first for offline support
  Future<void> fetchTopHeadlines({bool refresh = false}) async {
    try {
      if (refresh) {
        emit(NewsRefreshing(articles: _currentArticles));
      } else {
        emit(NewsLoading());
      }

      final articles = await _newsRepository.getTopHeadlines(
        useCache: !refresh,
      );

      if (articles.isEmpty) {
        emit(const NewsEmpty());
      } else {
        _currentArticles = articles;
        _currentPage = 1;
        _hasMore = true;
        emit(NewsLoaded(articles: articles, hasMore: _hasMore));
      }
    } catch (e) {
      // Emit loading state before API calls
      final isOffline = await _newsRepository.isOffline();
      if (isOffline) {
        final cachedArticles = await _newsRepository.getTopHeadlines(
          useCache: true,
        );
        if (cachedArticles.isNotEmpty) {
          emit(NewsOffline(articles: cachedArticles));
        } else {
          emit(
            NewsError(
              message: 'No internet connection and no cached data available',
            ),
          );
        }
      } else {
        emit(NewsError(message: 'Failed to load news: ${e.toString()}'));
      }
    }
  }

  // Handle pagination for offline scroll
  Future<void> loadMoreArticles() async {
    if (!_hasMore || state is NewsLoadingMore) return;

    try {
      emit(NewsLoadingMore(articles: _currentArticles));

      final newArticles = await _newsRepository.loadMoreArticles(
        category: _selectedCategoryId != 'general' ? _selectedCategoryId : null,
        query: _currentSearchQuery.isNotEmpty ? _currentSearchQuery : null,
        page: _currentPage + 1,
      );

      if (newArticles.isEmpty) {
        _hasMore = false;
        emit(NewsLoaded(articles: _currentArticles, hasMore: false));
      } else {
        _currentPage++;
        _currentArticles.addAll(newArticles);
        emit(NewsLoaded(articles: _currentArticles, hasMore: true));
      }
    } catch (e) {
      emit(NewsLoaded(articles: _currentArticles, hasMore: _hasMore));
      // Handle scroll position maintenance
    }
  }

  // Manage error states with retry options
  Future<void> retryLastOperation() async {
    if (_currentSearchQuery.isNotEmpty) {
      await searchNews(_currentSearchQuery);
    } else if (_selectedCategoryId != 'general') {
      await fetchNewsByCategory(_selectedCategoryId);
    } else {
      await fetchTopHeadlines();
    }
  }

  // Fallback to cache when API fails
  Future<void> fetchNewsByCategory(String categoryId) async {
    try {
      emit(NewsLoading());

      _selectedCategoryId = categoryId;
      _currentPage = 1;
      _currentSearchQuery = '';

      final articles = await _newsRepository.getNewsByCategory(
        category: categoryId,
      );

      if (articles.isEmpty) {
        emit(const NewsEmpty(message: 'No articles found for this category'));
      } else {
        _currentArticles = articles;
        _hasMore = true;
        emit(NewsLoaded(articles: articles, hasMore: _hasMore));
      }
    } catch (e) {
      emit(NewsError(message: 'Failed to load category news: ${e.toString()}'));
    }
  }

  // Background cache updates
  Future<void> searchNews(String query) async {
    if (query.trim().isEmpty) {
      await fetchTopHeadlines();
      return;
    }

    try {
      emit(NewsLoading());

      _currentSearchQuery = query;
      _currentPage = 1;
      _selectedCategoryId = 'general';

      final articles = await _newsRepository.searchNews(query: query);

      if (articles.isEmpty) {
        emit(const NewsEmpty(message: 'No articles found for your search'));
      } else {
        _currentArticles = articles;
        _hasMore = true;
        emit(NewsLoaded(articles: articles, hasMore: _hasMore));
      }
    } catch (e) {
      emit(NewsError(message: 'Search failed: ${e.toString()}'));
    }
  }

  // Selective cache clearing
  Future<void> clearSearchAndRefresh() async {
    _currentSearchQuery = '';
    _selectedCategoryId = 'general';
    await fetchTopHeadlines(refresh: true);
  }

  // Include timestamp for expiration
  Future<void> loadCategories() async {
    try {
      _categories = await _newsRepository.getCategories();
      // Categories are loaded as part of the main state, not separate emission needed
    } catch (e) {
      // Categories loading error is not critical, use defaults
      _categories = Category.getDefaultCategories();
    }
  }

  // Category selection logic
  void selectCategory(String categoryId) {
    if (categoryId == _selectedCategoryId) return;

    _categories = Category.updateCategorySelection(_categories, categoryId);
    fetchNewsByCategory(categoryId);
  }

  // Bookmark management
  Future<void> toggleBookmark(Article article) async {
    try {
      final isBookmarked = await _newsRepository.isArticleBookmarked(
        article.id,
      );

      if (isBookmarked) {
        await _newsRepository.removeBookmark(article.id);
      } else {
        await _newsRepository.bookmarkArticle(article);
      }

      // Update current articles list with bookmark status
      _updateArticleBookmarkStatus(article.id, !isBookmarked);
    } catch (e) {
      emit(NewsError(message: 'Failed to update bookmark: ${e.toString()}'));
    }
  }

  // Get bookmarked articles
  Future<void> fetchBookmarkedArticles() async {
    try {
      emit(NewsLoading());

      final bookmarkedArticles = await _newsRepository.getBookmarkedArticles();

      if (bookmarkedArticles.isEmpty) {
        emit(const NewsEmpty(message: 'No bookmarked articles found'));
      } else {
        emit(NewsLoaded(articles: bookmarkedArticles, hasMore: false));
      }
    } catch (e) {
      emit(NewsError(message: 'Failed to load bookmarks: ${e.toString()}'));
    }
  }

  // Offline mode support
  Future<void> syncDataInBackground() async {
    try {
      await _newsRepository.syncData();
    } catch (e) {
      // Silent background sync failure
    }
  }

  // Clear all cache
  Future<void> clearCache() async {
    try {
      await _newsRepository.clearCache();
      await fetchTopHeadlines(refresh: true);
    } catch (e) {
      emit(NewsError(message: 'Failed to clear cache: ${e.toString()}'));
    }
  }

  // Helper method to update bookmark status in current articles
  void _updateArticleBookmarkStatus(String articleId, bool isBookmarked) {
    _currentArticles = _currentArticles.map((article) {
      if (article.id == articleId) {
        return article.copyWith(isBookmarked: isBookmarked);
      }
      return article;
    }).toList();

    if (state is NewsLoaded) {
      emit(NewsLoaded(articles: _currentArticles, hasMore: _hasMore));
    } else if (state is NewsOffline) {
      emit(NewsOffline(articles: _currentArticles));
    }
  }

  // Get current categories
  List<Category> get categories => _categories;
  String get selectedCategoryId => _selectedCategoryId;
  bool get hasMore => _hasMore;
  String get currentSearchQuery => _currentSearchQuery;
}
