import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final String? errorDetails;
  final VoidCallback? onRetry;
  final String? retryButtonText;
  final bool isNetworkError;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.errorDetails,
    this.onRetry,
    this.retryButtonText = 'Try Again',
    this.isNetworkError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Network error illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_getErrorIcon(), size: 60, color: AppColors.error),
            ),

            const SizedBox(height: 24),

            // Clear error message
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),

            if (errorDetails != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.error.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  errorDetails!,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Retry button
            if (onRetry != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(retryButtonText!),
                ),
              ),

            const SizedBox(height: 16),

            // Help/support link
            TextButton(
              onPressed: () => _showHelpDialog(context),
              child: Text(
                'Need help?',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            // Error handling comprehensive
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.info_outline, color: AppColors.info, size: 24),
                  const SizedBox(height: 8),
                  Text(
                    'What you can do:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getHelpText(),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
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

  IconData _getErrorIcon() {
    if (isNetworkError) {
      return Icons.wifi_off;
    } else if (message.toLowerCase().contains('server')) {
      return Icons.dns;
    } else if (message.toLowerCase().contains('timeout')) {
      return Icons.timer_off;
    } else {
      return Icons.error_outline;
    }
  }

  String _getHelpText() {
    if (isNetworkError) {
      return '• Check your internet connection\n• Try switching between WiFi and mobile data\n• Restart your network connection';
    } else if (message.toLowerCase().contains('server')) {
      return '• The news service is temporarily unavailable\n• Please try again in a few minutes\n• Check if other apps work normally';
    } else if (message.toLowerCase().contains('rate limit')) {
      return '• Too many requests in a short time\n• Please wait a moment before trying again\n• Consider upgrading your news plan';
    } else {
      return '• Close and reopen the app\n• Check your internet connection\n• Contact support if problem persists';
    }
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Need Help?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'If you continue to experience issues:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 12),
            _buildHelpItem('Check app permissions'),
            _buildHelpItem('Restart the application'),
            _buildHelpItem('Update to latest version'),
            _buildHelpItem('Contact support team'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 16, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

// Specialized error states
class NetworkErrorWidget extends ErrorStateWidget {
  const NetworkErrorWidget({super.key, super.onRetry})
    : super(
        message: 'Connection lost',
        errorDetails: 'Please check your internet connection and try again.',
        isNetworkError: true,
      );
}

class ServerErrorWidget extends ErrorStateWidget {
  const ServerErrorWidget({super.key, super.onRetry})
    : super(
        message: 'Service temporarily unavailable',
        errorDetails:
            'Our news service is experiencing issues. Please try again later.',
      );
}

class TimeoutErrorWidget extends ErrorStateWidget {
  const TimeoutErrorWidget({super.key, super.onRetry})
    : super(
        message: 'Request timed out',
        errorDetails:
            'The request took too long to complete. Please try again.',
      );
}
