# Material 3 Implementation Guide

## Overview

This Flutter application now fully implements Material Design 3 (Material You) theming system based on:
- [Flutter Material Widgets Documentation](https://docs.flutter.dev/ui/widgets/material)
- [Material 3 Color System Overview](https://m3.material.io/styles/color/system/overview)

## Key Features Implemented

### ✅ Complete Material 3 Color System
- **Tonal Palettes**: Full implementation of primary, secondary, tertiary, neutral, and error color palettes
- **Dynamic Color Support**: Automatic integration with Android 12+ dynamic color (Material You)
- **High Contrast Modes**: Accessibility-focused high contrast themes for both light and dark modes
- **Surface Tonal System**: All 5 elevation levels using tonal color overlays (not shadows)

### ✅ Material 3 Typography
- Uses **Inter** font family via Google Fonts
- All 13 Material 3 text styles implemented (display, headline, title, body, label)
- Proper letter spacing and line heights according to M3 specifications

### ✅ Material 3 Components
All Flutter Material 3 widgets are properly themed:
- **Buttons**: FilledButton, FilledButton.tonal, ElevatedButton, OutlinedButton, TextButton
- **Icon Buttons**: Standard, Filled, FilledTonal, Outlined variants
- **FABs**: Small, Medium, Large, Extended variants
- **Cards**: Elevated, Filled, Outlined variants
- **Chips**: FilterChip, InputChip, ActionChip, ChoiceChip
- **Navigation**: NavigationBar, NavigationRail, NavigationDrawer
- **Text Fields**: Filled and Outlined variants
- **SearchBar**: Material 3 search component
- **Selection Controls**: Switch, Checkbox, Radio, Slider
- **Progress Indicators**: Circular and Linear
- **Badges**: With and without labels
- **Dialogs**: Material 3 rounded dialogs with icon support
- **BottomSheet**: Rounded corners with proper styling
- **List Tiles**: Fully themed with proper colors
- **And more...**

### ✅ Material 3 Motion System
- **Easing Curves**: Emphasized, Standard, Legacy curves
- **Duration System**: Short (50-200ms), Medium (250-400ms), Long (450-600ms), ExtraLong (700-1000ms)
- **Transition Patterns**: Shared Axis, Fade Through, Container Transform
- **Animated Components**: Custom M3 animated widgets and extensions

## File Structure

```
lib/
├── core/
│   ├── material3_color_scheme.dart    # M3 color system generator
│   ├── material3_motion.dart          # M3 motion and animation utilities
│   └── design_tokens.dart             # Design system tokens
├── providers/
│   └── theme_provider.dart            # Theme provider with M3 support
└── widgets/
    └── material3_showcase.dart        # M3 component examples
```

## Usage Examples

### 1. Using Material 3 Color Scheme

```dart
import 'package:flutter/material.dart';
import 'package:waste_classifier_flutter/core/material3_color_scheme.dart';

// Get the predefined Waste Wise color scheme
final lightScheme = Material3ColorScheme.wasteWiseLightScheme;
final darkScheme = Material3ColorScheme.wasteWiseDarkScheme;

// Or generate from a seed color
final customScheme = Material3ColorScheme.generateFromSeed(
  seedColor: const Color(0xFF4CAF50),
  brightness: Brightness.light,
);

// Access all M3 color roles
Widget build(BuildContext context) {
  final colors = Theme.of(context).colorScheme;
  
  return Container(
    color: colors.surface,                    // Surface color
    child: Card(
      color: colors.surfaceContainerHighest,  // Elevated surface
      child: Text(
        'Hello',
        style: TextStyle(color: colors.onSurface),
      ),
    ),
  );
}
```

### 2. Using Material 3 Motion

```dart
import 'package:waste_classifier_flutter/core/material3_motion.dart';

// Use M3 durations and curves
AnimatedContainer(
  duration: Material3Motion.durationMedium2,
  curve: Material3Motion.emphasized,
  color: isSelected ? colors.primary : colors.surface,
  child: child,
);

// Custom page transitions
Navigator.push(
  context,
  Material3Motion.sharedAxisPageRoute(
    page: NextScreen(),
    transitionType: SharedAxisTransitionType.horizontal,
  ),
);

// Use extension methods
widget.withFadeTransition(animation: animation)
      .withSlideTransition(animation: animation);
```

### 3. Using Material 3 Components

```dart
// Filled Button (Primary action)
FilledButton(
  onPressed: () {},
  child: const Text('Primary Action'),
);

// Filled Tonal Button (Secondary action)
FilledButton.tonal(
  onPressed: () {},
  child: const Text('Secondary Action'),
);

// Icon Buttons
IconButton.filled(
  onPressed: () {},
  icon: const Icon(Icons.favorite),
);

IconButton.filledTonal(
  onPressed: () {},
  icon: const Icon(Icons.share),
);

// Cards with different elevations
Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Text('Elevated Card'),
  ),
);

Card(
  elevation: 0,
  color: colors.surfaceContainerHighest,
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Text('Filled Card'),
  ),
);

// Navigation Bar (replaces BottomNavigationBar)
NavigationBar(
  selectedIndex: selectedIndex,
  onDestinationSelected: (index) => setState(() => selectedIndex = index),
  destinations: const [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.explore_outlined),
      selectedIcon: Icon(Icons.explore),
      label: 'Explore',
    ),
  ],
);
```

### 4. Accessing Theme Colors

```dart
Widget build(BuildContext context) {
  final colors = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;
  
  return Column(
    children: [
      // Primary colors
      Container(color: colors.primary),           // Main brand color
      Container(color: colors.primaryContainer),  // Primary container
      
      // Secondary colors
      Container(color: colors.secondary),
      Container(color: colors.secondaryContainer),
      
      // Tertiary colors (accent)
      Container(color: colors.tertiary),
      Container(color: colors.tertiaryContainer),
      
      // Surface colors (5 elevation levels)
      Container(color: colors.surface),
      Container(color: colors.surfaceContainerLowest),
      Container(color: colors.surfaceContainerLow),
      Container(color: colors.surfaceContainer),
      Container(color: colors.surfaceContainerHigh),
      Container(color: colors.surfaceContainerHighest),
      
      // Text with proper typography
      Text('Display Large', style: textTheme.displayLarge),
      Text('Headline Medium', style: textTheme.headlineMedium),
      Text('Body Large', style: textTheme.bodyLarge),
    ],
  );
}
```

## Theme Configuration

The app automatically applies Material 3 theming with the following features:

### Dynamic Color (Material You)
On Android 12+ devices, the app automatically adapts to the system's dynamic color scheme:
- Colors are extracted from the user's wallpaper
- Both light and dark themes adjust automatically
- Falls back to custom Waste Wise green theme on older devices

### High Contrast Mode
Enable high contrast mode for improved accessibility:
```dart
Provider.of<ThemeProvider>(context, listen: false).toggleHighContrast(true);
```

### Theme Switching
Toggle between light and dark modes:
```dart
Provider.of<ThemeProvider>(context, listen: false).toggleTheme(isDarkMode);
```

## Color Roles Reference

### Primary Colors
- `primary`: Main brand color, used for key components
- `onPrimary`: Text/icons on primary color
- `primaryContainer`: Standout fill color for key components
- `onPrimaryContainer`: Text/icons on primary container

### Secondary Colors
- `secondary`: Less prominent components
- `onSecondary`: Text/icons on secondary
- `secondaryContainer`: Secondary fill color
- `onSecondaryContainer`: Text/icons on secondary container

### Tertiary Colors
- `tertiary`: Contrasting accent color
- `onTertiary`: Text/icons on tertiary
- `tertiaryContainer`: Tertiary fill color
- `onTertiaryContainer`: Text/icons on tertiary container

### Surface Colors (New in M3)
- `surface`: Base surface color
- `surfaceContainerLowest`: Lowest elevation (lightest in light mode)
- `surfaceContainerLow`: Low elevation
- `surfaceContainer`: Medium elevation
- `surfaceContainerHigh`: High elevation
- `surfaceContainerHighest`: Highest elevation (darkest in light mode)

### Error Colors
- `error`: Error states and messages
- `onError`: Text/icons on error color
- `errorContainer`: Error fill color
- `onErrorContainer`: Text/icons on error container

### Outline Colors
- `outline`: Borders and dividers
- `outlineVariant`: Decorative elements

### Other Colors
- `inverseSurface`: Inverse surface (for snackbars, etc.)
- `onInverseSurface`: Text on inverse surface
- `inversePrimary`: Inverse primary
- `shadow`: Shadow color
- `scrim`: Scrim overlay
- `surfaceTint`: Surface tint overlay

## Typography Scale

### Display (Large, attention-grabbing text)
- `displayLarge`: 57sp / 64sp line height
- `displayMedium`: 45sp / 52sp line height
- `displaySmall`: 36sp / 44sp line height

### Headline (High-emphasis text)
- `headlineLarge`: 32sp / 40sp line height
- `headlineMedium`: 28sp / 36sp line height
- `headlineSmall`: 24sp / 32sp line height

### Title (Medium-emphasis text)
- `titleLarge`: 22sp / 28sp line height
- `titleMedium`: 16sp / 24sp line height
- `titleSmall`: 14sp / 20sp line height

### Body (Body text)
- `bodyLarge`: 16sp / 24sp line height
- `bodyMedium`: 14sp / 20sp line height
- `bodySmall`: 12sp / 16sp line height

### Label (Smaller, utility text)
- `labelLarge`: 14sp / 20sp line height
- `labelMedium`: 12sp / 16sp line height
- `labelSmall`: 11sp / 16sp line height

## Best Practices

1. **Use Semantic Colors**: Always use color roles (primary, surface, etc.) instead of hardcoded colors
2. **Follow M3 Guidelines**: Use FilledButton for primary actions, FilledButton.tonal for secondary
3. **Respect Surface Hierarchy**: Use appropriate surface container levels for elevation
4. **Use Proper Typography**: Apply correct text styles from the theme
5. **Test Both Themes**: Ensure UI works in both light and dark modes
6. **Consider Accessibility**: Test with high contrast mode enabled

## Testing the Implementation

To see all Material 3 components in action, navigate to the showcase screen:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const Material3Showcase(),
  ),
);
```

## Resources

- [Material 3 Design Kit](https://m3.material.io/)
- [Flutter Material Widgets](https://docs.flutter.dev/ui/widgets/material)
- [Material 3 Color System](https://m3.material.io/styles/color/system/overview)
- [Material 3 Typography](https://m3.material.io/styles/typography/overview)
- [Material 3 Motion](https://m3.material.io/styles/motion/overview)

## Migration from Material 2

If you have existing Material 2 code:

1. **Replace BottomNavigationBar** with **NavigationBar**
2. **Use FilledButton** instead of ElevatedButton for primary actions
3. **Update color references** to use new M3 color roles
4. **Replace custom shadows** with surface tonal elevation
5. **Update text styles** to use M3 typography scale

## Support

For questions or issues with the Material 3 implementation, please refer to:
- Flutter documentation: https://flutter.dev
- Material Design 3: https://m3.material.io
