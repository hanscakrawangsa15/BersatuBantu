import 'package:flutter/material.dart';
import 'package:bersatubantu/core/theme/app_colors.dart';
import 'package:bersatubantu/core/theme/app_constants.dart';
import 'package:bersatubantu/core/theme/app_text_style.dart';
import 'package:bersatubantu/core/theme/app_spacing.dart';



class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool isPassword;
  final bool isReadOnly;
  final bool isRequired;
  final int maxLines;
  final int minLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSuffixIconPressed;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final EdgeInsets? contentPadding;

  const AppTextField({
    Key? key,
    required this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.isReadOnly = false,
    this.isRequired = false,
    this.maxLines = 1,
    this.minLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSuffixIconPressed,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.contentPadding,
  }) : super(key: key);

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _isPasswordVisible;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _isPasswordVisible = !widget.isPassword;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: widget.label,
                style: AppTextStyle.labelMedium.copyWith(
                  color: hasError
                      ? AppColors.errorRed
                      : AppColors.textPrimary,
                ),
              ),
              if (widget.isRequired)
                TextSpan(
                  text: ' *',
                  style: AppTextStyle.labelMedium.copyWith(
                    color: AppColors.errorRed,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // TextField
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasError
                  ? AppColors.errorRed
                  : _isFocused
                      ? AppColors.primaryBlue
                      : AppColors.borderLight,
              width: hasError || _isFocused ? 2 : 1.5,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            readOnly: widget.isReadOnly,
            obscureText: widget.isPassword && !_isPasswordVisible,
            maxLines: _isPasswordVisible || !widget.isPassword
                ? widget.maxLines
                : 1,
            minLines: widget.minLines,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            style: AppTextStyle.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            cursorColor: AppColors.primaryBlue,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTextStyle.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
              border: InputBorder.none,
              contentPadding: widget.contentPadding ??
                  EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: widget.maxLines > 1 ? 12 : 14,
                  ),
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      child: widget.prefixIcon,
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              suffixIcon: widget.isPassword
                  ? GestureDetector(
                      onTap: _togglePasswordVisibility,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    )
                  : widget.suffixIcon != null
                      ? GestureDetector(
                          onTap: widget.onSuffixIconPressed,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: widget.suffixIcon,
                          ),
                        )
                      : null,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
            ),
          ),
        ),

        // Error Text
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText!,
            style: AppTextStyle.captionSmall.copyWith(
              color: AppColors.errorRed,
            ),
          ),
        ],
      ],
    );
  }
}
