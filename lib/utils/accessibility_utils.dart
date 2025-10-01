import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Accessibility utilities for improved app usability
class AccessibilityUtils {
  /// Create semantic label for screen readers
  static String createSemanticLabel({
    required String text,
    String? hint,
    String? role,
    bool isButton = false,
    bool isHeading = false,
    bool isSelected = false,
    bool isExpanded = false,
  }) {
    final buffer = StringBuffer();
    
    // Add role if specified
    if (role != null) {
      buffer.write('$role. ');
    } else if (isButton) {
      buffer.write('Button. ');
    } else if (isHeading) {
      buffer.write('Heading. ');
    }
    
    // Add main text
    buffer.write(text);
    
    // Add state information
    if (isSelected) {
      buffer.write('. Selected');
    }
    if (isExpanded) {
      buffer.write('. Expanded');
    }
    
    // Add hint if provided
    if (hint != null) {
      buffer.write('. $hint');
    }
    
    return buffer.toString();
  }

  /// Announce message to screen reader
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Focus widget for accessibility
  static void focusWidget(FocusNode focusNode) {
    focusNode.requestFocus();
  }

  /// Check if screen reader is enabled
  static bool isScreenReaderEnabled(BuildContext context) {
    final data = MediaQuery.of(context);
    return data.accessibleNavigation;
  }

  /// Get appropriate text size for accessibility
  static double getAccessibleTextSize({
    required BuildContext context,
    required double baseSize,
    double maxScaleFactor = 2.0,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final scaledSize = mediaQuery.textScaler.scale(baseSize);
    return scaledSize.clamp(baseSize, baseSize * maxScaleFactor);
  }

  /// Create accessible button with proper semantics
  static Widget accessibleButton({
    required Widget child,
    required VoidCallback? onPressed,
    String? semanticLabel,
    String? tooltip,
    bool excludeSemantics = false,
    FocusNode? focusNode,
  }) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel,
      excludeSemantics: excludeSemantics,
      child: Tooltip(
        message: tooltip ?? '',
        child: Focus(
          focusNode: focusNode,
          child: child,
        ),
      ),
    );
  }

  /// Create accessible text field with proper semantics
  static Widget accessibleTextField({
    required TextEditingController controller,
    String? labelText,
    String? hintText,
    String? errorText,
    String? helperText,
    bool isRequired = false,
    TextInputType? keyboardType,
    FocusNode? focusNode,
    void Function(String)? onChanged,
    void Function()? onEditingComplete,
  }) {
    final semanticLabel = _buildTextFieldSemanticLabel(
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      helperText: helperText,
      isRequired: isRequired,
    );

    return Semantics(
      textField: true,
      label: semanticLabel,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          errorText: errorText,
          helperText: helperText,
        ),
      ),
    );
  }

  /// Create accessible list item with proper semantics
  static Widget accessibleListItem({
    required Widget child,
    VoidCallback? onTap,
    String? semanticLabel,
    bool isSelected = false,
    int? index,
    int? totalItems,
  }) {
    String label = semanticLabel ?? '';
    if (index != null && totalItems != null) {
      label += '. Item ${index + 1} of $totalItems';
    }
    if (isSelected) {
      label += '. Selected';
    }

    return Semantics(
      button: onTap != null,
      selected: isSelected,
      label: label,
      child: child,
    );
  }

  /// Create accessible card with proper semantics
  static Widget accessibleCard({
    required Widget child,
    String? semanticLabel,
    VoidCallback? onTap,
    bool isClickable = false,
  }) {
    return Semantics(
      container: true,
      button: isClickable,
      label: semanticLabel,
      child: child,
    );
  }

  /// Create accessible toggle with proper semantics
  static Widget accessibleToggle({
    required bool value,
    required void Function(bool) onChanged,
    String? label,
    String? enabledLabel,
    String? disabledLabel,
  }) {
    final semanticLabel = _buildToggleSemanticLabel(
      label: label,
      value: value,
      enabledLabel: enabledLabel,
      disabledLabel: disabledLabel,
    );

    return Semantics(
      toggled: value,
      label: semanticLabel,
      child: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  /// Create accessible progress indicator
  static Widget accessibleProgressIndicator({
    double? value,
    String? semanticLabel,
    String? semanticValue,
  }) {
    String label = semanticLabel ?? 'Loading';
    if (value != null) {
      final percentage = (value * 100).round();
      label += '. $percentage percent complete';
    }
    if (semanticValue != null) {
      label += '. $semanticValue';
    }

    return Semantics(
      value: value?.toStringAsFixed(2),
      label: label,
      child: LinearProgressIndicator(value: value),
    );
  }

  /// Create accessible tab bar
  static Widget accessibleTabBar({
    required List<Widget> tabs,
    required TabController controller,
    void Function(int)? onTap,
  }) {
    return Semantics(
      container: true,
      label: 'Tab bar',
      child: TabBar(
        controller: controller,
        onTap: onTap,
        tabs: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = controller.index == index;
          
          return Semantics(
            selected: isSelected,
            button: true,
            label: 'Tab ${index + 1} of ${tabs.length}${isSelected ? '. Selected' : ''}',
            child: tab,
          );
        }).toList(),
      ),
    );
  }

  /// Create accessible image with semantic description
  static Widget accessibleImage({
    required Widget image,
    required String semanticLabel,
    bool decorative = false,
  }) {
    return Semantics(
      image: !decorative,
      label: decorative ? '' : semanticLabel,
      excludeSemantics: decorative,
      child: image,
    );
  }

  static String _buildTextFieldSemanticLabel({
    String? labelText,
    String? hintText,
    String? errorText,
    String? helperText,
    bool isRequired = false,
  }) {
    final buffer = StringBuffer();
    
    if (labelText != null) {
      buffer.write(labelText);
      if (isRequired) {
        buffer.write('. Required');
      }
      buffer.write('. Text field');
    }
    
    if (hintText != null) {
      buffer.write('. $hintText');
    }
    
    if (errorText != null) {
      buffer.write('. Error: $errorText');
    }
    
    if (helperText != null) {
      buffer.write('. $helperText');
    }
    
    return buffer.toString();
  }

  static String _buildToggleSemanticLabel({
    String? label,
    required bool value,
    String? enabledLabel,
    String? disabledLabel,
  }) {
    final buffer = StringBuffer();
    
    if (label != null) {
      buffer.write(label);
    }
    
    buffer.write('. Toggle button');
    
    if (value) {
      buffer.write('. Enabled');
      if (enabledLabel != null) {
        buffer.write('. $enabledLabel');
      }
    } else {
      buffer.write('. Disabled');
      if (disabledLabel != null) {
        buffer.write('. $disabledLabel');
      }
    }
    
    return buffer.toString();
  }
}

/// Responsive breakpoint utilities
class ResponsiveUtils {
  static const double mobileBreakpoint = 480;
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;
  static const double largeDesktopBreakpoint = 1440;

  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// Get responsive value based on screen size
  static T getResponsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= largeDesktopBreakpoint && largeDesktop != null) {
      return largeDesktop;
    } else if (width >= desktopBreakpoint && desktop != null) {
      return desktop;
    } else if (width >= mobileBreakpoint && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  /// Get responsive column count
  static int getResponsiveColumns(BuildContext context, {
    int mobileColumns = 1,
    int? tabletColumns,
    int? desktopColumns,
  }) {
    return getResponsiveValue(
      context: context,
      mobile: mobileColumns,
      tablet: tabletColumns ?? (mobileColumns * 2),
      desktop: desktopColumns ?? (mobileColumns * 3),
    );
  }

  /// Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context, {
    EdgeInsets? mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    return getResponsiveValue(
      context: context,
      mobile: mobile ?? const EdgeInsets.all(16),
      tablet: tablet ?? const EdgeInsets.all(24),
      desktop: desktop ?? const EdgeInsets.all(32),
    );
  }

  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, {
    required double baseFontSize,
    double mobileScale = 1.0,
    double tabletScale = 1.1,
    double desktopScale = 1.2,
  }) {
    final scale = getResponsiveValue(
      context: context,
      mobile: mobileScale,
      tablet: tabletScale,
      desktop: desktopScale,
    );
    
    return baseFontSize * scale;
  }

  /// Create responsive grid delegate
  static SliverGridDelegate getResponsiveGridDelegate(
    BuildContext context, {
    double childAspectRatio = 1.0,
    double crossAxisSpacing = 8.0,
    double mainAxisSpacing = 8.0,
  }) {
    final columnCount = getResponsiveColumns(context);
    
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columnCount,
      childAspectRatio: childAspectRatio,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
    );
  }

  /// Get responsive margin
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    return getResponsivePadding(context);
  }

  /// Check if device supports hover (desktop/web)
  static bool supportsHover(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.windows ||
           Theme.of(context).platform == TargetPlatform.macOS ||
           Theme.of(context).platform == TargetPlatform.linux;
  }
}

/// Focus management utilities
class FocusUtils {
  /// Move focus to next widget
  static void focusNext(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  /// Move focus to previous widget
  static void focusPrevious(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }

  /// Remove focus from all widgets
  static void unfocusAll(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Check if widget has focus
  static bool hasFocus(FocusNode focusNode) {
    return focusNode.hasFocus;
  }

  /// Create focus traversal group
  static Widget createFocusTraversalGroup({
    required Widget child,
    FocusTraversalPolicy? policy,
  }) {
    return FocusTraversalGroup(
      policy: policy ?? WidgetOrderTraversalPolicy(),
      child: child,
    );
  }
}
