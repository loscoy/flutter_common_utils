import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 应用主题配置
class AppThemeConfig {
  final Color primaryColor;
  final Color? secondaryColor;
  final Color? textfieldFillLight;
  final Color? textfieldFillDark;
  final String? fontFamily;

  const AppThemeConfig({
    required this.primaryColor,
    this.secondaryColor,
    this.textfieldFillLight,
    this.textfieldFillDark,
    this.fontFamily,
  });
}

/// 通用按钮样式
const _commonButtonStyle = ButtonStyle(
  overlayColor: WidgetStatePropertyAll(Colors.transparent),
  splashFactory: NoSplash.splashFactory,
  shadowColor: WidgetStatePropertyAll(Colors.transparent),
  elevation: WidgetStatePropertyAll(0),
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  minimumSize: WidgetStatePropertyAll(Size.zero),
  padding: WidgetStatePropertyAll(EdgeInsets.zero),
);

/// 应用主题生成器
class AppThemeGenerator {
  final AppThemeConfig config;

  AppThemeGenerator(this.config);

  ThemeData get lightTheme => _generateTheme(Brightness.light);
  ThemeData get darkTheme => _generateTheme(Brightness.dark);

  ThemeData _generateTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final textfieldFill = isDark
        ? (config.textfieldFillDark ?? const Color(0xFF1C1C1E))
        : (config.textfieldFillLight ?? const Color(0xFFF2F2F7));
    final hintTextColor = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : Colors.black.withValues(alpha: 0.5);
    final outlineColor =
        isDark ? const Color(0xff3e3e3e) : Colors.black.withValues(alpha: 0.06);
    final shadowColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.05);
    const cardBorderColor = Color(0xFF3E3E3E);

    final baseTheme = ThemeData(
      useMaterial3: false,
      scaffoldBackgroundColor: isDark ? Colors.black : Colors.grey[50],
      fontFamily: config.fontFamily ?? 'SF Pro Display',
      primaryColor: config.primaryColor,
      cupertinoOverrideTheme: const CupertinoThemeData(
        primaryColor: CupertinoColors.activeBlue,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: brightness,
        ),
        foregroundColor: Colors.black87,
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black87,
        ),
        actionsIconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      buttonTheme: const ButtonThemeData(splashColor: Colors.transparent),
      elevatedButtonTheme:
          const ElevatedButtonThemeData(style: _commonButtonStyle),
      textButtonTheme: const TextButtonThemeData(style: _commonButtonStyle),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isDark ? 8 : 20),
          side: isDark
              ? const BorderSide(color: cardBorderColor, width: 1)
              : BorderSide.none,
        ),
        color: Colors.white,
        margin: isDark ? EdgeInsets.zero : const EdgeInsets.all(8),
        shadowColor: Colors.black.withValues(alpha: 0.04),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: const OutlineInputBorder(borderSide: BorderSide.none),
        contentPadding: EdgeInsets.zero,
        hintStyle: TextStyle(fontSize: 16, color: hintTextColor, height: 1.0),
        fillColor: textfieldFill,
        isDense: true,
        isCollapsed: true,
      ),
      dialogTheme: DialogThemeData(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: Colors.grey[700],
          fontSize: 16,
          height: 1.5,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        backgroundColor: isDark ? Colors.black : Colors.white,
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey[100],
        selectedColor: config.primaryColor,
        secondarySelectedColor: config.primaryColor.withValues(alpha: 0.2),
        disabledColor: Colors.grey[300],
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        pressElevation: 0,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tileColor: Colors.transparent,
        selectedTileColor: config.primaryColor.withValues(alpha: 0.1),
        textColor: isDark ? Colors.white : Colors.black87,
        iconColor: Colors.grey[600],
        selectedColor: config.primaryColor,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return config.primaryColor;
          }
          return Colors.grey[400];
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return config.primaryColor.withValues(alpha: 0.5);
          }
          return Colors.grey[300];
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: config.primaryColor,
        linearTrackColor: const Color(0xFFE0E0E0),
        circularTrackColor: const Color(0xFFE0E0E0),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.black87,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
      ),
      iconTheme: IconThemeData(
        color: isDark ? Colors.white : Colors.grey[700],
        size: 24,
      ),
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: config.primaryColor,
              secondary: config.secondaryColor ?? config.primaryColor,
              error: Colors.red,
              surface: Colors.black,
              outline: outlineColor,
              shadow: shadowColor,
            )
          : ColorScheme.light(
              primary: config.primaryColor,
              primaryContainer: const Color(0xFFEDE7F6),
              secondary: config.secondaryColor ?? config.primaryColor,
              secondaryContainer: const Color(0xFFF3E5F5),
              surface: Colors.white,
              error: Colors.red,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: Colors.black87,
              onError: Colors.white,
              outline: outlineColor,
              shadow: shadowColor,
            ),
    );

    // Apply text theme
    const textTheme = TextTheme(
      displayLarge:
          TextStyle(fontSize: 32, fontWeight: FontWeight.w700, height: 1.2),
      displayMedium:
          TextStyle(fontSize: 28, fontWeight: FontWeight.w600, height: 1.3),
      displaySmall:
          TextStyle(fontSize: 24, fontWeight: FontWeight.w600, height: 1.3),
      headlineLarge:
          TextStyle(fontSize: 22, fontWeight: FontWeight.w600, height: 1.3),
      headlineMedium:
          TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.3),
      headlineSmall:
          TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3),
      titleLarge:
          TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4),
      titleMedium:
          TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.4),
      titleSmall:
          TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.4),
      bodyLarge:
          TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5),
      bodyMedium:
          TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5),
      bodySmall:
          TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.4),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
    );

    final textColor = isDark ? Colors.white : Colors.black;

    return baseTheme.copyWith(
      textTheme: textTheme.apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
      primaryTextTheme: textTheme.apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
    );
  }
}
