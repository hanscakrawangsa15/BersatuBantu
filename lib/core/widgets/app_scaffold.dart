import 'package:flutter/material.dart';
import 'package:bersatubantu/core/theme/app_colors.dart';
import 'package:bersatubantu/core/theme/app_constants.dart';
import 'package:bersatubantu/core/theme/app_text_style.dart';
import 'package:bersatubantu/core/theme/app_spacing.dart';


/// Base scaffold template untuk semua screen dalam aplikasi
/// Gunakan widget ini sebagai wrapper untuk semua screen fitur
class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottomNavigationBar;
  final bool showAppBar;
  final EdgeInsets? bodyPadding;

  const AppScaffold({
    Key? key,
    this.title,
    required this.body,
    this.floatingActionButton,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.bottomNavigationBar,
    this.showAppBar = true,
    this.bodyPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.bgPrimary,
      appBar: showAppBar
          ? AppBar(
              title: title != null
                  ? Text(
                      title!,
                      style: AppTextStyle.headingLarge,
                    )
                  : null,
              leading: showBackButton
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded),
                      onPressed: onBackPressed ??
                          () {
                            Navigator.pop(context);
                          },
                    )
                  : null,
              actions: actions,
            )
          : null,
      body: bodyPadding != null
          ? Padding(
              padding: bodyPadding!,
              child: body,
            )
          : body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
