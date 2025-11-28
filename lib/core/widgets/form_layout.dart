import 'package:flutter/material.dart';
import 'package:bersatubantu/core/theme/app_colors.dart';
import 'package:bersatubantu/core/theme/app_constants.dart';
import 'package:bersatubantu/core/theme/app_text_style.dart';
import 'package:bersatubantu/core/theme/app_spacing.dart';


/// Widget untuk form layout yang konsisten
/// Gunakan untuk screen login, registrasi, atau form apapun
class FormLayout extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final List<Widget> fields;
  final Widget? submitButton;
  final Widget? bottomWidget;
  final ScrollPhysics? physics;

  const FormLayout({
    Key? key,
    this.title,
    this.subtitle,
    required this.fields,
    this.submitButton,
    this.bottomWidget,
    this.physics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            if (title != null) ...[
              Text(
                title!,
                style: AppTextStyle.displaySmall,
              ),
              const SizedBox(height: 8),
            ],
            if (subtitle != null) ...[
              Text(
                subtitle!,
                style: AppTextStyle.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
            ] else if (title != null) ...[
              const SizedBox(height: 24),
            ],

            // Form Fields
            ...List.generate(
              fields.length,
              (index) => Column(
                children: [
                  fields[index],
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Submit Button
            if (submitButton != null) ...[
              const SizedBox(height: 8),
              submitButton!,
              const SizedBox(height: 24),
            ],

            // Bottom Widget (Login links, social buttons, dll)
            if (bottomWidget != null) ...[
              bottomWidget!,
            ],
          ],
        ),
      ),
    );
  }
}
