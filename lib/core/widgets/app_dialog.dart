import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_style.dart';

/// Widget untuk menampilkan dialog/modal custom
class AppDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final bool dismissible;
  final Color? backgroundColor;

  const AppDialog({
    Key? key,
    required this.title,
    required this.content,
    this.actions,
    this.dismissible = true,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: backgroundColor ?? AppColors.bgPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyle.headingMedium,
                    ),
                  ),
                  if (dismissible)
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Content
              content,

              // Actions
              if (actions != null && actions!.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: List.generate(
                    actions!.length,
                    (index) => Padding(
                      padding: EdgeInsets.only(
                        left: index > 0 ? 12 : 0,
                      ),
                      child: actions![index],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget untuk menampilkan snackbar/toast custom
class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onDismiss,
  }) {
    final (backgroundColor, iconData, textColor) =
        _getSnackBarStyle(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              iconData,
              color: textColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTextStyle.bodyMedium.copyWith(
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        duration: duration,
        dismissDirection: DismissDirection.horizontal,
        onVisible: () {},
      ),
    );
  }

  static (Color, IconData, Color) _getSnackBarStyle(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return (
          AppColors.successGreen,
          Icons.check_circle_rounded,
          AppColors.bgPrimary,
        );
      case SnackBarType.error:
        return (
          AppColors.errorRed,
          Icons.error_rounded,
          AppColors.bgPrimary,
        );
      case SnackBarType.warning:
        return (
          AppColors.warningYellow,
          Icons.warning_rounded,
          AppColors.textPrimary,
        );
      case SnackBarType.info:
        return (
          AppColors.infoBlue,
          Icons.info_rounded,
          AppColors.bgPrimary,
        );
    }
  }
}

enum SnackBarType { success, error, warning, info }
