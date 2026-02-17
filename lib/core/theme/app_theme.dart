import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

/// Tema principal de FutBase 3.0
///
/// Configura todos los aspectos visuales de la aplicación
/// siguiendo Material Design 3 con tema oscuro por defecto
class AppTheme {
  // ========== TEMA OSCURO (POR DEFECTO) ==========

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // ========== COLOR SCHEME ==========
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.backgroundDark,
        primaryContainer: Color(0xFF2A3318),
        onPrimaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        onSecondary: AppColors.white,
        secondaryContainer: Color(0xFF3D452B),
        onSecondaryContainer: AppColors.secondaryLight,
        tertiary: AppColors.warning,
        onTertiary: AppColors.backgroundDark,
        tertiaryContainer: Color(0xFF3D3218),
        onTertiaryContainer: AppColors.warningLight,
        error: AppColors.error,
        onError: AppColors.white,
        errorContainer: Color(0xFF3D1818),
        onErrorContainer: AppColors.errorLight,
        surface: AppColors.cardDark,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceDark,
        outline: AppColors.borderDark,
        outlineVariant: AppColors.borderDarkLight,
      ),

      // ========== SCAFFOLDS ==========
      scaffoldBackgroundColor: AppColors.backgroundDark,

      // ========== APP BAR ==========
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTypography.h6.copyWith(color: AppColors.textPrimary),
        iconTheme: const IconThemeData(
          color: AppColors.textSecondary,
          size: AppSpacing.iconMd,
        ),
      ),

      // ========== CARD ==========
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.cardDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusLg,
          side: const BorderSide(
            color: AppColors.borderDark,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // ========== ELEVATED BUTTON ==========
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.backgroundDark,
          textStyle: AppTypography.buttonMedium,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMd,
          ),
        ),
      ),

      // ========== FILLED BUTTON (Primary CTA) ==========
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.backgroundDark,
          textStyle: AppTypography.buttonMedium,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMd,
          ),
        ),
      ),

      // ========== TEXT BUTTON ==========
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.buttonMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),

      // ========== OUTLINED BUTTON ==========
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          foregroundColor: AppColors.textPrimary,
          textStyle: AppTypography.buttonMedium,
          side: const BorderSide(
            color: AppColors.borderDark,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMd,
          ),
        ),
      ),

      // ========== INPUT DECORATION ==========
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.borderDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        errorStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.error,
        ),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
      ),

      // ========== FLOATING ACTION BUTTON ==========
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.backgroundDark,
      ),

      // ========== CHIP ==========
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.borderDark,
        selectedColor: AppColors.primary,
        labelStyle: AppTypography.labelSmall.copyWith(
          color: AppColors.textPrimary,
        ),
        padding: AppSpacing.paddingSm,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusSm,
          side: const BorderSide(color: AppColors.borderDark),
        ),
      ),

      // ========== DIVIDER ==========
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
        space: AppSpacing.lg,
      ),

      // ========== ICON ==========
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: AppSpacing.iconMd,
      ),

      // ========== TIPOGRAFÍA ==========
      textTheme: AppTypography.textTheme,

      // ========== DIALOG ==========
      dialogTheme: DialogThemeData(
        elevation: 8,
        backgroundColor: AppColors.cardDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusXl,
          side: const BorderSide(color: AppColors.borderDark),
        ),
        titleTextStyle: AppTypography.h5.copyWith(color: AppColors.textPrimary),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),

      // ========== BOTTOM SHEET ==========
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.cardDark,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.radiusXl),
            topRight: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
      ),

      // ========== SNACKBAR ==========
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.cardDark,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          side: const BorderSide(color: AppColors.borderDark),
        ),
      ),

      // ========== NAVIGATION RAIL ==========
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.sidebarDark,
        selectedIconTheme: const IconThemeData(
          color: AppColors.primary,
        ),
        unselectedIconTheme: const IconThemeData(
          color: AppColors.textSecondary,
        ),
        selectedLabelTextStyle: AppTypography.labelSmall.copyWith(
          color: AppColors.primary,
        ),
        unselectedLabelTextStyle: AppTypography.labelSmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),

      // ========== NAVIGATION BAR ==========
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.all(
          AppTypography.labelSmall,
        ),
      ),

      // ========== CHECKBOX ==========
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.borderDarkLight;
        }),
        checkColor: WidgetStateProperty.all(AppColors.backgroundDark),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusXs,
        ),
      ),

      // ========== RADIO ==========
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.borderDarkLight;
        }),
      ),

      // ========== SWITCH ==========
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.5);
          }
          return AppColors.borderDark;
        }),
      ),

      // ========== TAB BAR ==========
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTypography.labelMedium,
        unselectedLabelStyle: AppTypography.labelMedium,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
        ),
      ),

      // ========== SCROLLBAR ==========
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(AppColors.borderDarkLight),
        trackColor: WidgetStateProperty.all(Colors.transparent),
        radius: const Radius.circular(10),
        thickness: WidgetStateProperty.all(4),
      ),
    );
  }

  // ========== TEMA CLARO ==========

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // ========== COLOR SCHEME ==========
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        primaryContainer: Color(0xFFE8F5B8),
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.secondary,
        onSecondary: AppColors.white,
        secondaryContainer: Color(0xFFE8E5DC),
        onSecondaryContainer: AppColors.secondaryDark,
        tertiary: AppColors.warning,
        onTertiary: AppColors.white,
        tertiaryContainer: Color(0xFFFFECDC),
        onTertiaryContainer: AppColors.warningDark,
        error: AppColors.error,
        onError: AppColors.white,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.gray900,
        surfaceContainerHighest: AppColors.backgroundLight,
        outline: AppColors.gray300,
        outlineVariant: AppColors.gray200,
      ),

      // ========== SCAFFOLDS ==========
      scaffoldBackgroundColor: AppColors.backgroundLight,

      // ========== APP BAR ==========
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTypography.h6.copyWith(color: AppColors.gray900),
        iconTheme: const IconThemeData(
          color: AppColors.gray700,
          size: AppSpacing.iconMd,
        ),
      ),

      // ========== CARD ==========
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusLg,
          side: const BorderSide(
            color: AppColors.gray200,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // ========== ELEVATED BUTTON ==========
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.backgroundDark,
          textStyle: AppTypography.buttonMedium,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMd,
          ),
        ),
      ),

      // ========== TEXT BUTTON ==========
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.buttonMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),

      // ========== OUTLINED BUTTON ==========
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.buttonMedium,
          side: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMd,
          ),
        ),
      ),

      // ========== INPUT DECORATION ==========
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.gray50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: const BorderSide(
            color: AppColors.gray300,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: const BorderSide(
            color: AppColors.gray300,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        labelStyle: AppTypography.bodyMedium,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.gray400,
        ),
        errorStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.error,
        ),
      ),

      // ========== CHIP ==========
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.gray100,
        selectedColor: AppColors.primary,
        labelStyle: AppTypography.labelSmall.copyWith(
          color: AppColors.gray900,
        ),
        padding: AppSpacing.paddingSm,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusSm,
        ),
      ),

      // ========== DIVIDER ==========
      dividerTheme: const DividerThemeData(
        color: AppColors.gray200,
        thickness: 1,
        space: AppSpacing.lg,
      ),

      // ========== ICON ==========
      iconTheme: const IconThemeData(
        color: AppColors.gray700,
        size: AppSpacing.iconMd,
      ),

      // ========== TIPOGRAFÍA ==========
      textTheme: AppTypography.textThemeLight,
    );
  }
}
