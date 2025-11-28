import 'package:flutter/material.dart';
import 'package:bersatubantu/core/theme/app_colors.dart';
import 'package:bersatubantu/core/theme/app_constants.dart';
import 'package:bersatubantu/core/theme/app_text_style.dart';
import 'package:bersatubantu/core/theme/app_spacing.dart';



enum ButtonSize { small, medium, large }
enum ButtonVariant { primary, secondary, outline, text, danger }

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;
  final bool iconOnRight;
  final double? width;
  final EdgeInsets? padding;

  const AppButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.iconOnRight = false,
    this.width,
    this.padding,
  }) : super(key: key);

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isEffectivelyDisabled = widget.isDisabled || widget.isLoading;

    // Determine styling based on variant and state
    final (backgroundColor, foregroundColor, borderColor) =
        _getColorsByVariant();

    // Determine padding based on size
    final padding = widget.padding ??
        _getPaddingBySize(
          size: widget.size,
          hasIcon: widget.icon != null,
        );

    // Determine text style based on size
    final textStyle = _getTextStyleBySize();

    return SizedBox(
      width: widget.width,
      child: GestureDetector(
        onTapDown: isEffectivelyDisabled ? null : _onTapDown,
        onTapUp: isEffectivelyDisabled ? null : _onTapUp,
        onTapCancel: isEffectivelyDisabled ? null : _onTapCancel,
        onTap: isEffectivelyDisabled ? null : widget.onPressed,
        child: ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 0.95)
              .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
          child: Container(
            decoration: BoxDecoration(
              color: isEffectivelyDisabled
                  ? AppColors.bgTertiary
                  : backgroundColor,
              border: borderColor != null
                  ? Border.all(
                      color: borderColor,
                      width: 1.5,
                    )
                  : null,
              borderRadius: BorderRadius.circular(_getBorderRadius()),
              boxShadow: widget.variant == ButtonVariant.primary &&
                      !isEffectivelyDisabled
                  ? [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: padding,
                child: widget.isLoading
                    ? SizedBox(
                        height: textStyle.fontSize,
                        width: textStyle.fontSize,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isEffectivelyDisabled
                                ? AppColors.textTertiary
                                : foregroundColor,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null && !widget.iconOnRight) ...[
                            widget.icon!,
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Text(
                              widget.label,
                              style: textStyle.copyWith(
                                color: isEffectivelyDisabled
                                    ? AppColors.textTertiary
                                    : foregroundColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          if (widget.icon != null && widget.iconOnRight) ...[
                            const SizedBox(width: 8),
                            widget.icon!,
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  (Color, Color, Color?) _getColorsByVariant() {
    switch (widget.variant) {
      case ButtonVariant.primary:
        return (
          AppColors.primaryBlue,
          AppColors.bgPrimary,
          null,
        );
      case ButtonVariant.secondary:
        return (
          AppColors.bgSecondary,
          AppColors.primaryBlue,
          null,
        );
      case ButtonVariant.outline:
        return (
          AppColors.bgPrimary,
          AppColors.primaryBlue,
          AppColors.borderMedium,
        );
      case ButtonVariant.text:
        return (
          Colors.transparent,
          AppColors.primaryBlue,
          null,
        );
      case ButtonVariant.danger:
        return (
          AppColors.errorRed,
          AppColors.bgPrimary,
          null,
        );
    }
  }

  EdgeInsets _getPaddingBySize({
    required ButtonSize size,
    required bool hasIcon,
  }) {
    switch (size) {
      case ButtonSize.small:
        return EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        );
      case ButtonSize.medium:
        return EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        );
      case ButtonSize.large:
        return EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        );
    }
  }

  TextStyle _getTextStyleBySize() {
    switch (widget.size) {
      case ButtonSize.small:
        return AppTextStyle.buttonSmall;
      case ButtonSize.medium:
        return AppTextStyle.buttonMedium;
      case ButtonSize.large:
        return AppTextStyle.buttonLarge;
    }
  }

  double _getBorderRadius() {
    switch (widget.size) {
      case ButtonSize.small:
        return 8;
      case ButtonSize.medium:
        return 10;
      case ButtonSize.large:
        return 12;
    }
  }
}
