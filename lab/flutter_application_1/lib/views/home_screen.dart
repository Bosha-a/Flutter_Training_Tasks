import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/auth_cubit.dart';
import '../cubits/auth_state.dart';
import '../cubits/news_cubit.dart';
import '../cubits/news_state.dart';
import '../models/article_model.dart';
import '../repositories/news_repository.dart';
import '../services/news_service.dart';
import '../theme/app_colors.dart';
import '../widgets/article_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_state_widget.dart';
import 'article_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // Load more articles when reaching 80% of scroll
      context.read<NewsCubit>().loadMoreArticles();
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
        context.read<NewsCubit>().clearSearchAndRefresh();
      }
    });
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      context.read<NewsCubit>().searchNews(query.trim());
    }
  }

  Future<void> _onRefresh() async {
    await context.read<NewsCubit>().fetchTopHeadlines(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NewsCubit(NewsRepository(NewsService()))
        ..loadCategories()
        ..fetchTopHeadlines(),
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthLoggedOut) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              // Custom app bar with user session status
              CustomAppBar(
                title: 'News',
                onSearchTap: _toggleSearch,
                onNotificationTap: () {
                  // Handle notifications
                },
              ),

              // Search bar (when visible)
              if (_isSearchVisible)
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search news...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.primary,
                      ),
                      suffixIcon: IconButton(
                        onPressed: _toggleSearch,
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: _onSearchSubmitted,
                  ),
                ),

              // Horizontal category selection
              BlocBuilder<NewsCubit, NewsState>(
                builder: (context, state) {
                  final cubit = context.read<NewsCubit>();
                  return CategoryList(
                    categories: cubit.categories,
                    selectedCategoryId: cubit.selectedCategoryId,
                    onCategorySelected: (categoryId) {
                      cubit.selectCategory(categoryId);
                    },
                  );
                },
              ),

              // Vertical list of news articles
              Expanded(
                child: BlocBuilder<NewsCubit, NewsState>(
                  builder: (context, state) {
                    if (state is NewsLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    if (state is NewsError) {
                      return ErrorStateWidget(
                        message: state.message,
                        onRetry: () =>
                            context.read<NewsCubit>().retryLastOperation(),
                      );
                    }

                    if (state is NewsEmpty) {
                      return EmptyStateWidget(
                        message: state.message,
                        onRetry: () => context
                            .read<NewsCubit>()
                            .fetchTopHeadlines(refresh: true),
                      );
                    }

                    if (state is NewsOffline) {
                      return Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            color: AppColors.warning.withOpacity(0.1),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.wifi_off,
                                  color: AppColors.warning,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Offline mode - Showing cached articles',
                                  style: TextStyle(
                                    color: AppColors.warning,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: _buildArticlesList(state.articles, false),
                          ),
                        ],
                      );
                    }

                    if (state is NewsLoaded) {
                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: AppColors.primary,
                        child: _buildArticlesList(
                          state.articles,
                          state.hasMore,
                        ),
                      );
                    }

                    if (state is NewsRefreshing) {
                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: AppColors.primary,
                        child: Stack(
                          children: [
                            _buildArticlesList(state.articles, true),
                            const Positioned(
                              top: 16,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Card(
                                  child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text('Refreshing...'),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is NewsLoadingMore) {
                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: AppColors.primary,
                        child: _buildArticlesList(
                          state.articles,
                          true,
                          showLoadingIndicator: true,
                        ),
                      );
                    }

                    return const EmptyStateWidget(
                      message: 'Welcome to News App',
                      description: 'Pull down to load the latest news',
                    );
                  },
                ),
              ),
            ],
          ),

          // Floating action button for search
          floatingActionButton: !_isSearchVisible
              ? FloatingActionButton(
                  onPressed: _toggleSearch,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.search, color: Colors.white),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildArticlesList(
    List<Article> articles,
    bool hasMore, {
    bool showLoadingIndicator = false,
  }) {
    if (articles.isEmpty) {
      return const EmptyStateWidget(
        message: 'No articles available',
        description: 'Pull down to refresh or try a different category',
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: articles.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= articles.length) {
          // Loading indicator for pagination
          return showLoadingIndicator
              ? Container(
                  padding: const EdgeInsets.all(16),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              : const SizedBox.shrink();
        }

        final article = articles[index];
        return ArticleCard(
          article: article,
          onTap: () {
            // Navigate to article details
            _showArticleDetails(article);
          },
          onBookmarkTap: () {
            context.read<NewsCubit>().toggleBookmark(article);
          },
        );
      },
    );
  }

  void _showArticleDetails(Article article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ArticleDetailScreen(article: article),
      ),
    );
  }
}
