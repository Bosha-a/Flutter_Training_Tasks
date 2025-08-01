import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? description;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String? retryButtonText;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.description,
    this.icon,
    this.onRetry,
    this.retryButtonText = 'Try Again',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Custom illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.article_outlined,
                size: 60,
                color: Colors.grey.shade400,
              ),
            ),

            const SizedBox(height: 24),

            // Friendly message
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),

            if (description != null) ...[
              const SizedBox(height: 12),
              Text(
                description!,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(retryButtonText!),
              ),
            ],

            // Suggestions for user action
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.accent,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Suggestions',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getSuggestionText(),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSuggestionText() {
    if (message.toLowerCase().contains('search')) {
      return '• Try different keywords\n• Check spelling\n• Use more general terms';
    } else if (message.toLowerCase().contains('bookmark')) {
      return '• Browse articles and tap bookmark icon\n• Bookmarks are saved locally\n• Access them anytime offline';
    } else if (message.toLowerCase().contains('category')) {
      return '• Try a different category\n• Check your internet connection\n• Pull down to refresh';
    } else {
      return '• Check your internet connection\n• Pull down to refresh\n• Try again in a moment';
    }
  }
}

// Specialized empty states
class NoArticlesFound extends EmptyStateWidget {
  const NoArticlesFound({super.key, super.onRetry})
    : super(
        message: 'No articles found',
        description: 'We couldn\'t find any articles at the moment.',
        icon: Icons.article_outlined,
      );
}

class NoSearchResults extends EmptyStateWidget {
  const NoSearchResults({super.key, super.onRetry})
    : super(
        message: 'No search results',
        description: 'Try adjusting your search terms or check the spelling.',
        icon: Icons.search_off,
      );
}

class NoBookmarks extends EmptyStateWidget {
  const NoBookmarks({super.key, super.onRetry})
    : super(
        message: 'No bookmarks yet',
        description: 'Start bookmarking articles you want to read later.',
        icon: Icons.bookmark_border,
      );
}

class NoInternetConnection extends EmptyStateWidget {
  const NoInternetConnection({super.key, super.onRetry})
    : super(
        message: 'No internet connection',
        description: 'Please check your connection and try again.',
        icon: Icons.wifi_off,
      );
}
