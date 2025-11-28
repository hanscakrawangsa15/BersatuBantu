import 'package:flutter/material.dart';
import 'package:bersatubantu/core/theme/app_colors.dart';
import 'package:bersatubantu/core/theme/app_constants.dart';
import 'package:bersatubantu/core/theme/app_text_style.dart';
import 'package:bersatubantu/core/theme/app_spacing.dart';
import 'package:bersatubantu/core/theme/app_text_styles.dart';



/// Custom text field dengan style konsisten
class CustomTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final bool enabled;

  const CustomTextField({
    Key? key,
    this.label,
    this.hint,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              label!,
              style: AppTextStyles.labelMedium,
            ),
          ),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          maxLines: maxLines,
          enabled: enabled,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.textSecondary, size: 22)
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.borderLight,
            contentPadding: AppSpacing.paddingMD,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(color: AppColors.borderLight, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
