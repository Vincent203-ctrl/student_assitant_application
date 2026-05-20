/**
 * student name: Sinekhaya Vatsha/ 
 * studentNo: 222044842/
 */

import 'package:flutter/material.dart';
import '../../models/application_model.dart';
import '../../utils/app_constants.dart';

// =============================================
// APP LOADING INDICATOR
// =============================================
class AppLoadingIndicator extends StatelessWidget {
  final String? message;
  const AppLoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: AppTextStyles.bodySecondary),
          ],
        ],
      ),
    );
  }
}

// =============================================
// APP ERROR WIDGET
// =============================================
class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const AppErrorWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  color: AppColors.error, size: 40),
            ),
            const SizedBox(height: 16),
            Text('Something went wrong',
                style: AppTextStyles.heading3.copyWith(color: AppColors.error)),
            const SizedBox(height: 8),
            Text(message,
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =============================================
// STATUS BADGE
// =============================================
class StatusBadge extends StatelessWidget {
  final ApplicationStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 13, color: status.color),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================
// INFO ROW
// =============================================
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  const InfoRow(
      {super.key, required this.label, required this.value, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 10),
          ],
          Expanded(
            flex: 2,
            child: Text(label, style: AppTextStyles.label),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(value, style: AppTextStyles.body),
          ),
        ],
      ),
    );
  }
}

// =============================================
// SECTION CARD
// =============================================
class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData? icon;
  const SectionCard(
      {super.key, required this.title, required this.child, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 16, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                ],
                Text(title, style: AppTextStyles.heading3),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

// =============================================
// CONFIRM DIALOG
// =============================================
Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  Color? confirmColor,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: AppTextStyles.heading2),
      content: Text(message, style: AppTextStyles.body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(cancelText,
              style: const TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor ?? AppColors.primary,
          ),
          child: Text(confirmText),
        ),
      ],
    ),
  );
}

// =============================================
// EMPTY STATE WIDGET
// =============================================
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? action;
  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: AppTextStyles.heading2, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle,
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}

// =============================================
// APP SNACKBAR HELPER
// =============================================
void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
  bool isSuccess = false,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : isSuccess
                    ? Icons.check_circle_outline_rounded
                    : Icons.info_outline_rounded,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: isError
          ? AppColors.error
          : isSuccess
              ? AppColors.success
              : AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(12),
    ),
  );
}
