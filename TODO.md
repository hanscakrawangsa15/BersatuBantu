# TODO: Fix Flutter Compilation Errors

## Issues Identified
1. **File naming inconsistency**: `app_text_style.dart` (singular) but class is `AppTextStyles` (plural)
2. **Missing AppColors members**: `primaryBlue`, `bgPrimary`, `accentGreen`, etc. not defined
3. **Missing AppTextStyles members**: `headingLarge`, `buttonMedium`, etc. not defined
4. **Wrong import paths**: Many files import `app_text_styles.dart` (plural) but file is singular
5. **Wrong splash screen import**: `main.dart` imports `fitur/splash_screen.dart` but file is `fitur/welcome/splash_screen.dart`
6. **Missing AppSpacing method**: `responsivePadding` not defined
7. **Wrong import in phone_frame_layout.dart**: imports from `constants/` instead of `theme/`

## Tasks
- [ ] Rename `lib/core/theme/app_text_style.dart` to `lib/core/theme/app_text_styles.dart`
- [ ] Add missing color constants to `AppColors` class
- [ ] Add missing text style constants to `AppTextStyles` class
- [ ] Update all import statements to use correct file name
- [ ] Fix splash screen import in `main.dart`
- [ ] Add `responsivePadding` method to `AppSpacing` class
- [ ] Fix import path in `phone_frame_layout.dart`
- [ ] Test compilation after fixes
