import 'package:flutter/material.dart';

/// Material 3 Color Scheme Generator
/// Based on Material Design 3 color system specifications
/// https://m3.material.io/styles/color/system/overview
class Material3ColorScheme {
  Material3ColorScheme._();

  /// Generate a complete Material 3 color scheme from a seed color
  /// Supports both light and dark modes with full tonal palettes
  static ColorScheme generateFromSeed({
    required Color seedColor,
    required Brightness brightness,
    Color? secondary,
    Color? tertiary,
    Color? error,
  }) {
    // Use Flutter's built-in ColorScheme.fromSeed for accurate M3 colors
    final baseScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
      secondary: secondary,
      tertiary: tertiary,
      error: error,
    );

    return baseScheme;
  }

  /// Predefined Material 3 color schemes for Waste Wise app
  
  /// Light theme color scheme with green eco-friendly palette
  static ColorScheme get wasteWiseLightScheme {
    return ColorScheme.fromSeed(
      seedColor: const Color(0xFF4CAF50),
      brightness: Brightness.light,
    ).copyWith(
      // Primary colors (main brand color - green)
      primary: const Color(0xFF006D1D),
      onPrimary: const Color(0xFFFFFFFF),
      primaryContainer: const Color(0xFF7AF18D),
      onPrimaryContainer: const Color(0xFF002204),
      
      // Secondary colors (supporting green)
      secondary: const Color(0xFF52634F),
      onSecondary: const Color(0xFFFFFFFF),
      secondaryContainer: const Color(0xFFD5E8CF),
      onSecondaryContainer: const Color(0xFF101F0F),
      
      // Tertiary colors (accent - teal/blue)
      tertiary: const Color(0xFF006874),
      onTertiary: const Color(0xFFFFFFFF),
      tertiaryContainer: const Color(0xFF9DF0FF),
      onTertiaryContainer: const Color(0xFF001F24),
      
      // Error colors
      error: const Color(0xFFBA1A1A),
      onError: const Color(0xFFFFFFFF),
      errorContainer: const Color(0xFFFFDAD6),
      onErrorContainer: const Color(0xFF410002),
      
      // Surface colors (Material 3 surface tonal system)
      surface: const Color(0xFFFCFDF7),
      onSurface: const Color(0xFF1A1C19),
      onSurfaceVariant: const Color(0xFF424940),
      
      // Surface containers (new in M3)
      surfaceContainerLowest: const Color(0xFFFFFFFF),
      surfaceContainerLow: const Color(0xFFF6F7F1),
      surfaceContainer: const Color(0xFFF0F1EB),
      surfaceContainerHigh: const Color(0xFFEAEBE5),
      surfaceContainerHighest: const Color(0xFFE4E6DF),
      
      // Outline colors
      outline: const Color(0xFF72796F),
      outlineVariant: const Color(0xFFC2C9BD),
      
      // Other surface colors
      inverseSurface: const Color(0xFF2F312D),
      onInverseSurface: const Color(0xFFF1F1EB),
      inversePrimary: const Color(0xFF5DD472),
      
      // Shadow and scrim
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
      
      // Surface tint
      surfaceTint: const Color(0xFF006D1D),
    );
  }

  /// Dark theme color scheme with green eco-friendly palette
  static ColorScheme get wasteWiseDarkScheme {
    return ColorScheme.fromSeed(
      seedColor: const Color(0xFF4CAF50),
      brightness: Brightness.dark,
    ).copyWith(
      // Primary colors (main brand color - green)
      primary: const Color(0xFF5DD472),
      onPrimary: const Color(0xFF00390B),
      primaryContainer: const Color(0xFF005316),
      onPrimaryContainer: const Color(0xFF7AF18D),
      
      // Secondary colors (supporting green)
      secondary: const Color(0xFFB9CCB4),
      onSecondary: const Color(0xFF243424),
      secondaryContainer: const Color(0xFF3A4B39),
      onSecondaryContainer: const Color(0xFFD5E8CF),
      
      // Tertiary colors (accent - teal/blue)
      tertiary: const Color(0xFF4FD8EB),
      onTertiary: const Color(0xFF00363D),
      tertiaryContainer: const Color(0xFF004F58),
      onTertiaryContainer: const Color(0xFF97F0FF),
      
      // Error colors
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      errorContainer: const Color(0xFF93000A),
      onErrorContainer: const Color(0xFFFFDAD6),
      
      // Surface colors (Material 3 surface tonal system)
      surface: const Color(0xFF1A1C19),
      onSurface: const Color(0xFFE2E3DD),
      onSurfaceVariant: const Color(0xFFC2C9BD),
      
      // Surface containers (new in M3)
      surfaceContainerLowest: const Color(0xFF0F110E),
      surfaceContainerLow: const Color(0xFF1A1C19),
      surfaceContainer: const Color(0xFF1E201D),
      surfaceContainerHigh: const Color(0xFF282B27),
      surfaceContainerHighest: const Color(0xFF333632),
      
      // Outline colors
      outline: const Color(0xFF8C9388),
      outlineVariant: const Color(0xFF424940),
      
      // Other surface colors
      inverseSurface: const Color(0xFFE2E3DD),
      onInverseSurface: const Color(0xFF1A1C19),
      inversePrimary: const Color(0xFF006D1D),
      
      // Shadow and scrim
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
      
      // Surface tint
      surfaceTint: const Color(0xFF5DD472),
    );
  }

  /// High contrast light theme for accessibility
  static ColorScheme get wasteWiseHighContrastLightScheme {
    return ColorScheme.fromSeed(
      seedColor: const Color(0xFF4CAF50),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF004D14),
      onPrimary: const Color(0xFFFFFFFF),
      primaryContainer: const Color(0xFF006D1D),
      onPrimaryContainer: const Color(0xFFFFFFFF),
      
      secondary: const Color(0xFF2A3B28),
      onSecondary: const Color(0xFFFFFFFF),
      secondaryContainer: const Color(0xFF3A4B39),
      onSecondaryContainer: const Color(0xFFFFFFFF),
      
      tertiary: const Color(0xFF003B43),
      onTertiary: const Color(0xFFFFFFFF),
      tertiaryContainer: const Color(0xFF004F58),
      onTertiaryContainer: const Color(0xFFFFFFFF),
      
      error: const Color(0xFF8C0009),
      onError: const Color(0xFFFFFFFF),
      errorContainer: const Color(0xFFBA1A1A),
      onErrorContainer: const Color(0xFFFFFFFF),
      
      surface: const Color(0xFFFFFFFF),
      onSurface: const Color(0xFF000000),
      onSurfaceVariant: const Color(0xFF212121),
      
      outline: const Color(0xFF424242),
      outlineVariant: const Color(0xFF757575),
    );
  }

  /// High contrast dark theme for accessibility
  static ColorScheme get wasteWiseHighContrastDarkScheme {
    return ColorScheme.fromSeed(
      seedColor: const Color(0xFF4CAF50),
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFFA3FF99),
      onPrimary: const Color(0xFF002204),
      primaryContainer: const Color(0xFF7AF18D),
      onPrimaryContainer: const Color(0xFF000000),
      
      secondary: const Color(0xFFD5E8CF),
      onSecondary: const Color(0xFF101F0F),
      secondaryContainer: const Color(0xFFB9CCB4),
      onSecondaryContainer: const Color(0xFF000000),
      
      tertiary: const Color(0xFFCCF5FF),
      onTertiary: const Color(0xFF001F24),
      tertiaryContainer: const Color(0xFF97F0FF),
      onTertiaryContainer: const Color(0xFF000000),
      
      error: const Color(0xFFFFEDEA),
      onError: const Color(0xFF410002),
      errorContainer: const Color(0xFFFFDAD6),
      onErrorContainer: const Color(0xFF000000),
      
      surface: const Color(0xFF000000),
      onSurface: const Color(0xFFFFFFFF),
      onSurfaceVariant: const Color(0xFFFFFFFF),
      
      outline: const Color(0xFFBDBDBD),
      outlineVariant: const Color(0xFF9E9E9E),
    );
  }

  /// Create custom color scheme from multiple seed colors
  static ColorScheme createCustomScheme({
    required Color primarySeed,
    required Color secondarySeed,
    required Color tertiarySeed,
    required Brightness brightness,
    Color? errorSeed,
  }) {
    return ColorScheme.fromSeed(
      seedColor: primarySeed,
      secondary: secondarySeed,
      tertiary: tertiarySeed,
      error: errorSeed,
      brightness: brightness,
    );
  }

  /// Get color scheme based on theme mode and contrast settings
  static ColorScheme getSchemeForMode({
    required Brightness brightness,
    bool highContrast = false,
    ColorScheme? dynamicScheme,
  }) {
    // Use dynamic color scheme if available (Android 12+)
    if (dynamicScheme != null) {
      return dynamicScheme;
    }

    // Otherwise use predefined schemes
    if (brightness == Brightness.light) {
      return highContrast 
          ? wasteWiseHighContrastLightScheme 
          : wasteWiseLightScheme;
    } else {
      return highContrast 
          ? wasteWiseHighContrastDarkScheme 
          : wasteWiseDarkScheme;
    }
  }
}

/// Extension to get Material 3 color roles
extension ColorSchemeRoles on ColorScheme {
  /// Surface dim - darkest surface variant
  Color get surfaceDim => surfaceContainerLowest;
  
  /// Surface bright - lightest surface variant
  Color get surfaceBright => brightness == Brightness.light 
      ? surfaceContainerLowest 
      : surfaceContainerHighest;
  
  /// Get state layer color with opacity for interactive states
  Color stateLayerColor(Color baseColor, double opacity) {
    return baseColor.withValues(alpha: opacity);
  }
  
  /// Material 3 state layer opacities
  static const double stateLayerOpacityHover = 0.08;
  static const double stateLayerOpacityFocus = 0.12;
  static const double stateLayerOpacityPressed = 0.12;
  static const double stateLayerOpacityDragged = 0.16;
  static const double stateLayerOpacityDisabled = 0.12;
}

/// Material 3 elevation tonal colors
/// In M3, elevation is communicated through tonal color overlays, not shadows
class Material3Elevation {
  Material3Elevation._();
  
  /// Get surface color at specified elevation level (0-5)
  static Color getSurfaceAtElevation(ColorScheme colorScheme, int level) {
    assert(level >= 0 && level <= 5, 'Elevation level must be between 0 and 5');
    
    switch (level) {
      case 0:
        return colorScheme.surface;
      case 1:
        return colorScheme.surfaceContainerLow;
      case 2:
        return colorScheme.surfaceContainer;
      case 3:
        return colorScheme.surfaceContainerHigh;
      case 4:
        return colorScheme.surfaceContainerHighest;
      case 5:
        return colorScheme.surfaceContainerHighest;
      default:
        return colorScheme.surface;
    }
  }
}
