// ============================================================
// loading_widget.dart
// Centered loading spinner with an optional message below it.
// Shown in all screens while async data is loading from controller.
//
// Usage:
//   LoadingWidget()
//   LoadingWidget(message: 'Loading workouts...')
//
// Parameters:
//   message — optional text shown below the spinner
//
// Rules:
//   - StatelessWidget — no internal state needed
//   - Centered vertically and horizontally in its parent
//   - Spinner color should be AppColors.steelColor
//   - Message text style should be AppTheme bodyMedium
// ============================================================


import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
  
class LoadingWidget extends StatelessWidget {
  final String? message;
  
  const LoadingWidget({
    super.key,
    this.message,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.steelColor,
              ),
            ),
          ),
  
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}