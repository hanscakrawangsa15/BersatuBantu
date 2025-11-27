import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_style.dart';

/// Widget untuk card dengan gambar, title, dan action
/// Cocok untuk kartu fitur, donasi, aktivitas, dll
class FeatureCard extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? image;
  final ImageProvider? imageProvider;
  final Color? imageBackgroundColor;
  final Widget? topRightBadge;
  final VoidCallback? onTap;
  final List<Widget>? actionButtons;
  final EdgeInsets? padding;

  const FeatureCard({
    Key? key,
    required this.title,
    this.description,
    this.image,
    this.imageProvider,
    this.imageBackgroundColor,
    this.topRightBadge,
    this.onTap,
    this.actionButtons,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 160,
                    color: imageBackgroundColor ?? AppColors.bgSecondary,
                    child: image ??
                        (imageProvider != null
                            ? Image(
                                image: imageProvider!,
                                fit: BoxFit.cover,
                              )
                            : const SizedBox.expand()),
                  ),
                  // Top Right Badge
                  if (topRightBadge != null)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: topRightBadge!,
                    ),
                ],
              ),

              // Content Section
              Padding(
                padding: padding ?? const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: AppTextStyle.headingSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Description
                    if (description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        description!,
                        style: AppTextStyle.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Action Buttons
                    if (actionButtons != null && actionButtons!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(
                          actionButtons!.length,
                          (index) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: index < actionButtons!.length - 1
                                    ? 8
                                    : 0,
                              ),
                              child: actionButtons![index],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Badge widget untuk menampilkan status atau kategori
class AppBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsets? padding;

  const AppBadge({
    Key? key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyle.labelSmall.copyWith(
          color: textColor ?? AppColors.bgPrimary,
        ),
      ),
    );
  }
}
