import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design_tokens.dart';
import '../core/material3_color_scheme.dart';

/// Legacy AppColors class maintained for backward compatibility
/// New code should use DesignTokens directly
class AppColors {
  static const Color primary = DesignTokens.primaryGreen;
  static const Color onPrimary = DesignTokens.textOnPrimary;
  static const Color primaryContainer = DesignTokens.primaryGreenPale;
  static const Color onPrimaryContainer = DesignTokens.textPrimary;
  
  static const Color secondary = DesignTokens.primaryGreenDark;
  static const Color onSecondary = DesignTokens.textOnPrimary;
  static const Color secondaryContainer = DesignTokens.primaryGreenLight;
  static const Color onSecondaryContainer = DesignTokens.textPrimary;
  
  static const Color surface = DesignTokens.backgroundCard;
  static const Color onSurface = DesignTokens.textPrimary;
  static const Color surfaceVariant = DesignTokens.gray100;
  static const Color onSurfaceVariant = DesignTokens.textSecondary;
  
  static const Color surfaceContainer = DesignTokens.gray50;
  static const Color surfaceContainerLow = DesignTokens.gray50;
  static const Color surfaceContainerHigh = DesignTokens.gray100;
  static const Color surfaceContainerHighest = DesignTokens.gray200;
  
  static const Color background = DesignTokens.backgroundPrimary;
  static const Color onBackground = DesignTokens.textPrimary;
  
  static const Color outline = DesignTokens.gray400;
  static const Color outlineVariant = DesignTokens.gray300;
  
  static const Color error = DesignTokens.error;
  static const Color onError = DesignTokens.textOnPrimary;
  static const Color errorContainer = Color(0xFFFFEBEE);
  static const Color onErrorContainer = DesignTokens.error;
  
  // Custom semantic colors
  static const Color success = DesignTokens.success;
  static const Color warning = DesignTokens.warning;
  static const Color info = DesignTokens.info;
  
  // Chart colors
  static const Color chartGreen = DesignTokens.primaryGreen;
  static const Color chartBlue = DesignTokens.accentBlue;
  static const Color chartOrange = DesignTokens.accentOrange;
  static const Color chartRed = DesignTokens.accentRed;
  static const Color chartPurple = DesignTokens.accentPurple;
  
  // Legacy color properties for backward compatibility
  static const Color text = DesignTokens.textPrimary;
  static const Color textLight = DesignTokens.textSecondary;
  static const Color textMuted = DesignTokens.textTertiary;
  static const Color primaryLight = DesignTokens.primaryGreenPale;
  static const Color backgroundLight = DesignTokens.backgroundPrimary;
  static const Color blue = DesignTokens.accentBlue;
  static const Color orange = DesignTokens.accentOrange;
  static const Color red = DesignTokens.accentRed;
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _isHighContrast = false;

  ThemeMode get themeMode => _themeMode;
  bool get isHighContrast => _isHighContrast;

  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggleHighContrast(bool enabled) {
    _isHighContrast = enabled;
    notifyListeners();
  }

  ThemeData getLightTheme(ColorScheme? lightDynamic) {
    // Use dynamic color if available (Android 12+), otherwise use our M3 scheme
    final colorScheme = Material3ColorScheme.getSchemeForMode(
      brightness: Brightness.light,
      highContrast: _isHighContrast,
      dynamicScheme: lightDynamic,
    );
    return _buildTheme(colorScheme, Brightness.light);
  }

  ThemeData getDarkTheme(ColorScheme? darkDynamic) {
    // Use dynamic color if available (Android 12+), otherwise use our M3 scheme
    final colorScheme = Material3ColorScheme.getSchemeForMode(
      brightness: Brightness.dark,
      highContrast: _isHighContrast,
      dynamicScheme: darkDynamic,
    );
    return _buildTheme(colorScheme, Brightness.dark);
  }

  ThemeData _buildTheme(ColorScheme colorScheme, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      
      // Material 3 Typography using DesignTokens
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: DesignTokens.displayLarge.fontSize,
          fontWeight: DesignTokens.displayLarge.fontWeight,
          letterSpacing: DesignTokens.displayLarge.letterSpacing,
          height: DesignTokens.displayLarge.height,
          color: colorScheme.onSurface,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: DesignTokens.displayMedium.fontSize,
          fontWeight: DesignTokens.displayMedium.fontWeight,
          letterSpacing: DesignTokens.displayMedium.letterSpacing,
          height: DesignTokens.displayMedium.height,
          color: colorScheme.onSurface,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: DesignTokens.displaySmall.fontSize,
          fontWeight: DesignTokens.displaySmall.fontWeight,
          letterSpacing: DesignTokens.displaySmall.letterSpacing,
          height: DesignTokens.displaySmall.height,
          color: colorScheme.onSurface,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: DesignTokens.headlineLarge.fontSize,
          fontWeight: DesignTokens.headlineLarge.fontWeight,
          letterSpacing: DesignTokens.headlineLarge.letterSpacing,
          height: DesignTokens.headlineLarge.height,
          color: colorScheme.onSurface,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: DesignTokens.headlineMedium.fontSize,
          fontWeight: DesignTokens.headlineMedium.fontWeight,
          letterSpacing: DesignTokens.headlineMedium.letterSpacing,
          height: DesignTokens.headlineMedium.height,
          color: colorScheme.onSurface,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: DesignTokens.headlineSmall.fontSize,
          fontWeight: DesignTokens.headlineSmall.fontWeight,
          letterSpacing: DesignTokens.headlineSmall.letterSpacing,
          height: DesignTokens.headlineSmall.height,
          color: colorScheme.onSurface,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: DesignTokens.titleLarge.fontSize,
          fontWeight: DesignTokens.titleLarge.fontWeight,
          letterSpacing: DesignTokens.titleLarge.letterSpacing,
          height: DesignTokens.titleLarge.height,
          color: colorScheme.onSurface,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: DesignTokens.titleMedium.fontSize,
          fontWeight: DesignTokens.titleMedium.fontWeight,
          letterSpacing: DesignTokens.titleMedium.letterSpacing,
          height: DesignTokens.titleMedium.height,
          color: colorScheme.onSurface,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: DesignTokens.titleSmall.fontSize,
          fontWeight: DesignTokens.titleSmall.fontWeight,
          letterSpacing: DesignTokens.titleSmall.letterSpacing,
          height: DesignTokens.titleSmall.height,
          color: colorScheme.onSurface,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: DesignTokens.bodyLarge.fontSize,
          fontWeight: DesignTokens.bodyLarge.fontWeight,
          letterSpacing: DesignTokens.bodyLarge.letterSpacing,
          height: DesignTokens.bodyLarge.height,
          color: colorScheme.onSurface,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: DesignTokens.bodyMedium.fontSize,
          fontWeight: DesignTokens.bodyMedium.fontWeight,
          letterSpacing: DesignTokens.bodyMedium.letterSpacing,
          height: DesignTokens.bodyMedium.height,
          color: colorScheme.onSurface,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: DesignTokens.bodySmall.fontSize,
          fontWeight: DesignTokens.bodySmall.fontWeight,
          letterSpacing: DesignTokens.bodySmall.letterSpacing,
          height: DesignTokens.bodySmall.height,
          color: colorScheme.onSurface,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: DesignTokens.labelLarge.fontSize,
          fontWeight: DesignTokens.labelLarge.fontWeight,
          letterSpacing: DesignTokens.labelLarge.letterSpacing,
          height: DesignTokens.labelLarge.height,
          color: colorScheme.onSurface,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: DesignTokens.labelMedium.fontSize,
          fontWeight: DesignTokens.labelMedium.fontWeight,
          letterSpacing: DesignTokens.labelMedium.letterSpacing,
          height: DesignTokens.labelMedium.height,
          color: colorScheme.onSurface,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: DesignTokens.labelSmall.fontSize,
          fontWeight: DesignTokens.labelSmall.fontWeight,
          letterSpacing: DesignTokens.labelSmall.letterSpacing,
          height: DesignTokens.labelSmall.height,
          color: colorScheme.onSurface,
        ),
      ),
      
      // Material 3 Components using DesignTokens
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: _isHighContrast ? 3 : 1,
          shadowColor: colorScheme.shadow,
          shape: RoundedRectangleBorder(borderRadius: DesignTokens.borderRadiusFull),
          padding: DesignTokens.buttonPadding,
          minimumSize: Size(64, DesignTokens.buttonHeight),
          textStyle: GoogleFonts.inter(
            fontSize: DesignTokens.labelLarge.fontSize,
            fontWeight: DesignTokens.labelLarge.fontWeight,
          ),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: DesignTokens.borderRadiusFull),
          padding: DesignTokens.buttonPadding,
          minimumSize: Size(64, DesignTokens.buttonHeight),
          textStyle: GoogleFonts.inter(
            fontSize: DesignTokens.labelLarge.fontSize,
            fontWeight: DesignTokens.labelLarge.fontWeight,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: DesignTokens.borderRadiusFull),
          padding: DesignTokens.buttonPadding,
          minimumSize: Size(64, DesignTokens.buttonHeight),
          textStyle: GoogleFonts.inter(
            fontSize: DesignTokens.labelLarge.fontSize,
            fontWeight: DesignTokens.labelLarge.fontWeight,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(borderRadius: DesignTokens.borderRadiusFull),
          padding: DesignTokens.buttonPadding,
          minimumSize: Size(64, DesignTokens.buttonHeight),
          textStyle: GoogleFonts.inter(
            fontSize: DesignTokens.labelLarge.fontSize,
            fontWeight: DesignTokens.labelLarge.fontWeight,
          ),
        ),
      ),
      
      cardTheme: CardThemeData(
        elevation: _isHighContrast ? DesignTokens.cardElevation * 2 : DesignTokens.cardElevation,
        shadowColor: colorScheme.shadow,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(borderRadius: DesignTokens.borderRadiusMD),
        color: colorScheme.surface,
        margin: EdgeInsets.zero,
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: DesignTokens.inputPadding,
        border: OutlineInputBorder(
          borderRadius: DesignTokens.borderRadiusXXL,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: DesignTokens.borderRadiusXXL,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: DesignTokens.borderRadiusXXL,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: DesignTokens.borderRadiusXXL,
          borderSide: BorderSide(color: colorScheme.error),
        ),
      ),
      
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 6,
        focusElevation: 8,
        hoverElevation: 8,
        highlightElevation: 12,
        shape: RoundedRectangleBorder(borderRadius: DesignTokens.borderRadiusLG),
      ),
      
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: DesignTokens.appBarElevation,
        scrolledUnderElevation: 3,
        surfaceTintColor: colorScheme.surfaceTint,
        shadowColor: colorScheme.shadow,
        toolbarHeight: DesignTokens.appBarHeight,
        titleTextStyle: GoogleFonts.inter(
          fontSize: DesignTokens.headlineLarge.fontSize,
          fontWeight: DesignTokens.headlineLarge.fontWeight,
          color: colorScheme.onSurface,
        ),
      ),
      
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        elevation: DesignTokens.bottomNavElevation,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: DesignTokens.labelSmall.fontSize,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: DesignTokens.labelSmall.fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        selectedColor: colorScheme.secondaryContainer,
        side: BorderSide(color: colorScheme.outline),
        shape: RoundedRectangleBorder(borderRadius: DesignTokens.borderRadiusSM),
        labelStyle: GoogleFonts.inter(
          fontSize: DesignTokens.labelMedium.fontSize,
          fontWeight: DesignTokens.labelMedium.fontWeight,
        ),
      ),
      
      // Additional component themes
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 24,
        shape: RoundedRectangleBorder(borderRadius: DesignTokens.borderRadiusXXL),
        titleTextStyle: GoogleFonts.inter(
          fontSize: DesignTokens.headlineSmall.fontSize,
          fontWeight: DesignTokens.headlineSmall.fontWeight,
          color: colorScheme.onSurface,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: DesignTokens.bodyMedium.fontSize,
          fontWeight: DesignTokens.bodyMedium.fontWeight,
          color: colorScheme.onSurface,
        ),
      ),
      
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: GoogleFonts.inter(
          fontSize: DesignTokens.bodyMedium.fontSize,
          color: colorScheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(borderRadius: DesignTokens.borderRadiusSM),
        behavior: SnackBarBehavior.floating,
      ),
      
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: DesignTokens.titleMedium.fontSize,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: DesignTokens.titleMedium.fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Material 3 NavigationBar (replaces BottomNavigationBar)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer,
        elevation: DesignTokens.bottomNavElevation,
        height: 80,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSecondaryContainer,
            );
          }
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              size: 24,
              color: colorScheme.onSecondaryContainer,
            );
          }
          return IconThemeData(
            size: 24,
            color: colorScheme.onSurfaceVariant,
          );
        }),
      ),
      
      // Material 3 NavigationRail
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        selectedIconTheme: IconThemeData(
          color: colorScheme.onSecondaryContainer,
          size: 24,
        ),
        unselectedIconTheme: IconThemeData(
          color: colorScheme.onSurfaceVariant,
          size: 24,
        ),
        selectedLabelTextStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        unselectedLabelTextStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant,
        ),
        indicatorColor: colorScheme.secondaryContainer,
      ),
      
      // Material 3 Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),
      
      // Material 3 Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      
      // Material 3 Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.onSurfaceVariant;
        }),
      ),
      
      // Material 3 Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.surfaceContainerHighest,
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withOpacity(0.12),
        valueIndicatorColor: colorScheme.primary,
        valueIndicatorTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorScheme.onPrimary,
        ),
      ),
      
      // Material 3 ProgressIndicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      ),
      
      // Material 3 Divider
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      
      // Material 3 ListTile
      listTileTheme: ListTileThemeData(
        tileColor: colorScheme.surface,
        selectedTileColor: colorScheme.secondaryContainer,
        selectedColor: colorScheme.onSecondaryContainer,
        iconColor: colorScheme.onSurfaceVariant,
        textColor: colorScheme.onSurface,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        subtitleTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.borderRadiusMD,
        ),
      ),
      
      // Material 3 Drawer
      drawerTheme: DrawerThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 1,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(
            right: Radius.circular(16),
          ),
        ),
      ),
      
      // Material 3 BottomSheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 3,
        modalElevation: 3,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
      ),
      
      // Material 3 PopupMenu
      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surface,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.borderRadiusMD,
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
        ),
      ),
      
      // Material 3 Badge
      badgeTheme: BadgeThemeData(
        backgroundColor: colorScheme.error,
        textColor: colorScheme.onError,
        textStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Material 3 Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: DesignTokens.borderRadiusSM,
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colorScheme.onInverseSurface,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      
      // Material 3 SearchBar
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStateProperty.all(colorScheme.surfaceContainerHigh),
        elevation: WidgetStateProperty.all(0),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 16),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: DesignTokens.borderRadiusFull,
          ),
        ),
        textStyle: WidgetStateProperty.all(
          GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface,
          ),
        ),
        hintStyle: WidgetStateProperty.all(
          GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      
      // Material 3 SearchView
      searchViewTheme: SearchViewThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 3,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.borderRadiusXXL,
        ),
        headerTextStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
        ),
        headerHintStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      
      // Set scaffold background
      scaffoldBackgroundColor: colorScheme.surface,
      
      // Splash and highlight colors
      splashColor: colorScheme.primary.withOpacity(0.12),
      highlightColor: colorScheme.primary.withOpacity(0.08),
      
      // Visual density for comfortable touch targets
      visualDensity: VisualDensity.standard,
      
      // Platform adaptive
      platform: TargetPlatform.android,
    );
  }
}
