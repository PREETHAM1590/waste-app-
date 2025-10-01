import 'package:flutter/material.dart';

/// Core design tokens extracted from the Waste Wise design system
/// Based on the 15 provided design screens
class DesignTokens {
  DesignTokens._();

  // ============================================================================
  // COLOR PALETTE - Green-focused environmental theme
  // ============================================================================
  
  /// Primary Brand Colors
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryGreenDark = Color(0xFF388E3C);
  static const Color primaryGreenLight = Color(0xFF81C784);
  static const Color primaryGreenPale = Color(0xFFE8F5E8);
  
  /// Accent Colors
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentYellow = Color(0xFFFFC107);
  static const Color accentRed = Color(0xFFE53935);
  static const Color accentPurple = Color(0xFF9C27B0);
  
  /// Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);
  
  /// Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);
  
  /// Background Colors
  static const Color backgroundPrimary = Color(0xFFFAFAFA);
  static const Color backgroundCard = Color(0xFFFFFFFF);
  static const Color backgroundOverlay = Color(0x80000000);
  
  /// Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // ============================================================================
  // TYPOGRAPHY SCALE - Inter font family
  // ============================================================================
  
  /// Display Text Styles
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.25,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );
  
  /// Headline Text Styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );
  
  /// Title Text Styles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  /// Body Text Styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.5,
  );
  
  /// Label Text Styles
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.25,
    height: 1.4,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.4,
  );

  // ============================================================================
  // MATERIAL 3 SURFACE COLORS
  // ============================================================================
  
  /// Material 3 Surface Tints
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDim = Color(0xFFF5F5F5);
  static const Color surfaceBright = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFF0F0F0);
  static const Color surfaceContainerLow = Color(0xFFF8F8F8);
  static const Color surfaceContainerHigh = Color(0xFFE8E8E8);
  static const Color surfaceContainerHighest = Color(0xFFE0E0E0);
  
  // ============================================================================
  // MATERIAL 3 STATE LAYERS
  // ============================================================================
  
  static const double stateLayerHover = 0.08;
  static const double stateLayerFocus = 0.12;
  static const double stateLayerPressed = 0.16;
  static const double stateLayerDragged = 0.16;
  static const double stateLayerSelected = 0.12;
  static const double stateLayerDisabled = 0.38;
  
  // ============================================================================
  // SPACING SCALE - 8pt grid system
  // ============================================================================
  
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space56 = 56.0;
  static const double space64 = 64.0;
  static const double space72 = 72.0;
  static const double space80 = 80.0;
  static const double space96 = 96.0;
  
  /// Common padding patterns
  static const EdgeInsets paddingXS = EdgeInsets.all(space4);
  static const EdgeInsets paddingSM = EdgeInsets.all(space8);
  static const EdgeInsets paddingMD = EdgeInsets.all(space16);
  static const EdgeInsets paddingLG = EdgeInsets.all(space24);
  static const EdgeInsets paddingXL = EdgeInsets.all(space32);
  
  static const EdgeInsets paddingHorizontalSM = EdgeInsets.symmetric(horizontal: space8);
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(horizontal: space16);
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(horizontal: space24);
  
  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(vertical: space8);
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(vertical: space16);
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(vertical: space24);

  // ============================================================================
  // BORDER RADIUS - Consistent rounded corners
  // ============================================================================
  
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusFull = 999.0;
  
  static const BorderRadius borderRadiusXS = BorderRadius.all(Radius.circular(radiusXS));
  static const BorderRadius borderRadiusSM = BorderRadius.all(Radius.circular(radiusSM));
  static const BorderRadius borderRadiusMD = BorderRadius.all(Radius.circular(radiusMD));
  static const BorderRadius borderRadiusLG = BorderRadius.all(Radius.circular(radiusLG));
  static const BorderRadius borderRadiusXL = BorderRadius.all(Radius.circular(radiusXL));
  static const BorderRadius borderRadiusXXL = BorderRadius.all(Radius.circular(radiusXXL));
  static const BorderRadius borderRadiusFull = BorderRadius.all(Radius.circular(radiusFull));

  // ============================================================================
  // ELEVATION & SHADOWS
  // ============================================================================
  
  static const List<BoxShadow> shadowSM = [
    BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> shadowMD = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> shadowLG = [
    BoxShadow(
      color: Color(0x1F000000),
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> shadowXL = [
    BoxShadow(
      color: Color(0x26000000),
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];

  // ============================================================================
  // COMPONENT SPECIFICATIONS
  // ============================================================================
  
  /// App Bar
  static const double appBarHeight = 56.0;
  static const double appBarElevation = 0.0;
  
  /// Bottom Navigation
  static const double bottomNavHeight = 80.0;
  static const double bottomNavElevation = 8.0;
  
  /// Cards
  static const double cardElevation = 2.0;
  static const EdgeInsets cardPadding = EdgeInsets.all(space16);
  static const EdgeInsets cardMargin = EdgeInsets.all(space8);
  
  /// Buttons
  static const double buttonHeight = 48.0;
  static const double buttonSmallHeight = 36.0;
  static const double buttonLargeHeight = 56.0;
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: space24, vertical: space12);
  static const EdgeInsets buttonSmallPadding = EdgeInsets.symmetric(horizontal: space16, vertical: space8);
  
  /// FAB (Floating Action Button)
  static const double fabSize = 56.0;
  static const double fabMiniSize = 40.0;
  static const double fabLargeSize = 96.0;
  
  /// Input Fields
  static const double inputHeight = 56.0;
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(horizontal: space16, vertical: space16);
  
  /// Icons
  static const double iconSM = 16.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 48.0;
  
  /// Avatar Sizes
  static const double avatarXS = 24.0;
  static const double avatarSM = 32.0;
  static const double avatarMD = 48.0;
  static const double avatarLG = 64.0;
  static const double avatarXL = 96.0;

  // ============================================================================
  // MATERIAL 3 COMPONENT SPECIFICATIONS
  // ============================================================================
  
  /// Material 3 Card Variants
  static const double cardElevated = 1.0;
  static const double cardFilled = 0.0;
  static const double cardOutlined = 0.0;
  
  /// Material 3 Button Heights
  static const double buttonM3Height = 40.0;
  static const double buttonM3LargeHeight = 48.0;
  static const double buttonM3SmallHeight = 32.0;
  
  /// Material 3 FAB Variants
  static const double fabM3Small = 40.0;
  static const double fabM3Medium = 56.0;
  static const double fabM3Large = 96.0;
  static const double fabM3Extended = 48.0;
  
  /// Material 3 Navigation Heights
  static const double navBarM3Height = 80.0;
  static const double navRailM3Width = 80.0;
  static const double navDrawerM3Width = 360.0;
  
  /// Material 3 Search Bar
  static const double searchBarM3Height = 56.0;
  static const double searchBarM3BorderRadius = 28.0;
  
  /// Material 3 Chips
  static const double chipM3Height = 32.0;
  static const double chipM3BorderRadius = 8.0;
  
  /// Material 3 Dialog
  static const double dialogM3BorderRadius = 28.0;
  static const double dialogM3MinWidth = 280.0;
  static const double dialogM3MaxWidth = 560.0;
  
  /// Material 3 Bottom Sheet
  static const double bottomSheetM3BorderRadius = 28.0;
  static const double bottomSheetM3HandleWidth = 32.0;
  static const double bottomSheetM3HandleHeight = 4.0;
  
  // ============================================================================
  // ANIMATION DURATIONS & CURVES
  // ============================================================================
  
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 250);
  static const Duration animationSlow = Duration(milliseconds: 350);
  static const Duration animationPageTransition = Duration(milliseconds: 300);
  static const Duration animationSharedElement = Duration(milliseconds: 375);
  
  /// Material 3 Motion Curves
  static const Curve curveStandard = Curves.easeInOutCubicEmphasized;
  static const Curve curveDecelerated = Curves.easeOutCubic;
  static const Curve curveAccelerated = Curves.easeInCubic;
  static const Curve curveEmphasized = Curves.easeInOutCubicEmphasized;
  
  // ============================================================================
  // BREAKPOINTS - Responsive design
  // ============================================================================
  
  static const double breakpointMobile = 480.0;
  static const double breakpointTablet = 768.0;
  static const double breakpointDesktop = 1024.0;
  static const double breakpointWide = 1440.0;
  
  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  /// Get responsive padding based on screen width
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < breakpointMobile) {
      return paddingMD;
    } else if (width < breakpointTablet) {
      return paddingLG;
    } else {
      return paddingXL;
    }
  }
  
  /// Get responsive text style based on screen width
  static TextStyle getResponsiveTextStyle(BuildContext context, TextStyle baseStyle) {
    final width = MediaQuery.of(context).size.width;
    if (width < breakpointMobile) {
      return baseStyle.copyWith(fontSize: baseStyle.fontSize! * 0.9);
    } else if (width > breakpointDesktop) {
      return baseStyle.copyWith(fontSize: baseStyle.fontSize! * 1.1);
    }
    return baseStyle;
  }
}

/// Extension to add width property to double for spacing
extension SpaceExtension on double {
  Widget get width => SizedBox(width: this);
  Widget get height => SizedBox(height: this);
}
