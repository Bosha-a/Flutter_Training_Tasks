import 'package:equatable/equatable.dart';

import '../models/article_model.dart';
import '../models/category_model.dart';

abstract class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object?> get props => [];
}

// Initial state before any data loaded
class NewsInitial extends NewsState {}

// Loading state during API calls
class NewsLoading extends NewsState {}

// Loaded state with articles, has more data
class NewsLoaded extends NewsState {
  final List<Article> articles;
  final bool hasMore;

  const NewsLoaded({required this.articles, this.hasMore = true});

  @override
  List<Object?> get props => [articles, hasMore];
}

// Error state with message and can retry option
class NewsError extends NewsState {
  final String message;
  final bool canRetry;

  const NewsError({required this.message, this.canRetry = true});

  @override
  List<Object?> get props => [message, canRetry];
}

// Empty state when no articles found
class NewsEmpty extends NewsState {
  final String message;

  const NewsEmpty({this.message = 'No articles found'});

  @override
  List<Object?> get props => [message];
}

// Offline state when cached data is available
class NewsOffline extends NewsState {
  final List<Article> articles;

  const NewsOffline({required this.articles});

  @override
  List<Object?> get props => [articles];
}

// Additional state for pull-to-refresh functionality
class NewsRefreshing extends NewsState {
  final List<Article> articles; // Keep current articles while refreshing

  const NewsRefreshing({required this.articles});

  @override
  List<Object?> get props => [articles];
}

// State for loading more articles during pagination
class NewsLoadingMore extends NewsState {
  final List<Article> articles; // Current articles

  const NewsLoadingMore({required this.articles});

  @override
  List<Object?> get props => [articles];
}

// State for category management
class NewsCategoryState extends NewsState {
  final List<Category> categories;
  final String selectedCategoryId;
  final List<Article> articles;
  final bool isLoading;

  const NewsCategoryState({
    required this.categories,
    required this.selectedCategoryId,
    required this.articles,
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [
    categories,
    selectedCategoryId,
    articles,
    isLoading,
  ];
}

// State for search functionality
class NewsSearchState extends NewsState {
  final String query;
  final List<Article> searchResults;
  final bool isSearching;
  final bool hasMoreResults;

  const NewsSearchState({
    required this.query,
    required this.searchResults,
    this.isSearching = false,
    this.hasMoreResults = true,
  });

  @override
  List<Object?> get props => [
    query,
    searchResults,
    isSearching,
    hasMoreResults,
  ];
}

// State for bookmarks management
class NewsBookmarkState extends NewsState {
  final List<Article> bookmarkedArticles;
  final bool isLoading;

  const NewsBookmarkState({
    required this.bookmarkedArticles,
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [bookmarkedArticles, isLoading];
}
