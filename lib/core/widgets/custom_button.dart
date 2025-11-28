import 'package:flutter/material.dart';
import 'package:bersatubantu/core/theme/app_colors.dart';
import 'package:bersatubantu/core/theme/app_constants.dart';
import 'package:bersatubantu/core/theme/app_text_style.dart';
import 'package:bersatubantu/core/theme/app_spacing.dart';
import 'package:bersatubantu/core/theme/app_text_styles.dart';


/// Custom button dengan style konsisten
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final bool isLoading;
  final IconData? icon;
  final bool isOutlined;
  
  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.isLoading = false,
    this.icon,
    this.isOutlined = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primary;
    final txtColor = textColor ?? Colors.white;
    
    Widget buttonChild = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(txtColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: txtColor, size: 20),
                AppSpacing.horizontalSpaceSM,
              ],
              Text(
                text,
                style: AppTextStyles.button.copyWith(color: txtColor),
              ),
            ],
          );
    
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? AppConstants.buttonHeightLarge,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: bgColor,
                side: BorderSide(color: bgColor, width: 2),
                padding: padding ?? AppSpacing.paddingMD,
                shape: RoundedRectangleBorder(
                  borderRadius: borderRadius ?? 
                      BorderRadius.circular(AppConstants.radiusMedium),
                ),
              ),
              child: buttonChild,
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColor,
                foregroundColor: txtColor,
                padding: padding ?? AppSpacing.paddingMD,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: borderRadius ?? 
                      BorderRadius.circular(AppConstants.radiusMedium),
                ),
              ),
              child: buttonChild,
            ),
    );
  }
}
