# Material 3 Design System - Waste Wise App

## 🎨 Overview

This document outlines the complete Material 3 design system implementation across all screens in the Waste Wise application, featuring glass morphism effects, dynamic theming, and comprehensive component library.

## ✨ Key Features

### 1. Dynamic Color Theming
- **Material You** integration with `dynamic_color` package
- System-wide color extraction on Android 12+
- Custom green eco-friendly color schemes for light and dark modes
- High contrast accessibility themes

### 2. Glass Morphism Design
- iOS-inspired frosted glass effects using `BackdropFilter`
- Premium glass cards with blur and transparency
- Gradient backgrounds with subtle color overlays
- Platform-adaptive corner radius (iOS vs Android)

### 3. Material 3 Components
All components follow Material Design 3 specifications with proper:
- Surface tonal elevation system
- State layers for interactive elements
- Typography hierarchy with Inter font family
- Motion and transitions using easing curves

## 🏗️ Architecture

### Theme Provider (`theme_provider.dart`)
Central theme management with:
- Light/Dark mode switching
- High contrast mode for accessibility
- Dynamic color scheme support
- Comprehensive component theming

### Design Tokens (`design_tokens.dart`)
Centralized design values:
- Spacing scale (4px base)
- Typography scale (Material 3 type system)
- Color semantic tokens
- Border radius variants
- Animation durations

### Material 3 Color Scheme (`material3_color_scheme.dart`)
Four predefined color schemes:
- `wasteWiseLightScheme` - Standard light theme
- `wasteWiseDarkScheme` - Standard dark theme  
- `wasteWiseHighContrastLightScheme` - Accessible light theme
- `wasteWiseHighContrastDarkScheme` - Accessible dark theme

## 📱 Screen-by-Screen Implementation

### Navigation
**File:** `main_screen.dart`
- ✅ Material 3 NavigationBar with NavigationDestination
- ✅ Animated FAB with gradient and shadow
- ✅ Glass morphism bottom navigation
- ✅ Smooth page transitions

### Authentication Screens
**Files:** `unified_login_screen.dart`, `create_account_screen.dart`

**Material 3 Components:**
- ✅ FilledButton for primary actions (Google Sign-In)
- ✅ OutlinedButton for secondary actions
- ✅ TextFormField with Material 3 styling
- ✅ Surface containers with proper elevation
- ✅ Error containers with semantic colors

**Visual Elements:**
```dart
// Primary Action Button
FilledButton.icon(
  icon: Icon(Icons.g_mobiledata),
  label: Text('Continue with Google'),
  style: FilledButton.styleFrom(
    backgroundColor: theme.colorScheme.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)

// Input Fields
TextFormField(
  decoration: InputDecoration(
    labelText: 'Email',
    filled: true,
    fillColor: theme.colorScheme.surfaceContainerHighest,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(28),
    ),
  ),
)
```

### Home Screen
**File:** `home_screen.dart`

**Material 3 Components:**
- ✅ SliverAppBar with Material 3 surface tint
- ✅ Card widgets with elevation levels
- ✅ Glass morphism stat cards
- ✅ Shimmer loading states
- ✅ Badge components for notifications
- ✅ CircularProgressIndicator with Material 3 styling

**Layout Structure:**
```
├── SliverAppBar (with flexibleSpace)
│   ├── Welcome greeting
│   ├── Notification badge
│   └── Profile avatar
├── Stats Cards Row
│   ├── Eco-Points Card (GlassCard)
│   └── Achievements Card (GlassCard)
├── Central Scan FAB
├── Quick Access Grid
│   ├── Education (GlassActionButton)
│   ├── Guidelines (GlassActionButton)
│   ├── Marketplace (GlassActionButton)
│   └── Carbon Tracker (GlassActionButton)
└── Recent Activity List
```

### Profile & Settings
**Files:** `profile_screen.dart`, `settings_screen.dart`

**Material 3 Components:**
- ✅ ListTile with Material 3 styling
- ✅ Switch with adaptive theming
- ✅ Dividers with proper outline color
- ✅ Surface containers for sections
- ✅ CircleAvatar with primary container color

**Settings Example:**
```dart
Card(
  child: Column(
    children: [
      ListTile(
        leading: Icon(Icons.palette_outlined),
        title: Text('Dark Mode'),
        trailing: Switch(
          value: isDark,
          onChanged: (value) => toggleTheme(value),
        ),
      ),
      Divider(height: 1),
      ListTile(
        leading: Icon(Icons.accessibility_outlined),
        title: Text('High Contrast'),
        trailing: Switch(
          value: isHighContrast,
          onChanged: (value) => toggleHighContrast(value),
        ),
      ),
    ],
  ),
)
```

### Classification Screen
**File:** `classification_screen.dart`

**Material 3 Components:**
- ✅ BottomSheet with rounded corners
- ✅ Card for classification results
- ✅ LinearProgressIndicator for confidence
- ✅ Chip widgets for waste categories
- ✅ FAB for camera access

**Result Display:**
```dart
BottomSheet(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(28),
    ),
  ),
  child: Card(
    elevation: 0,
    color: theme.colorScheme.surfaceContainerLow,
    child: Column(
      children: [
        // Classification result
        // Confidence meter
        // Action buttons
      ],
    ),
  ),
)
```

### Education & Guidelines
**Files:** `education_screen.dart`, `guidelines_screen.dart`

**Material 3 Components:**
- ✅ SearchBar with Material 3 styling
- ✅ FilterChip for category selection
- ✅ Card grid for content items
- ✅ ExpansionPanel for detailed content
- ✅ Rich text with proper typography

**Filter Bar:**
```dart
SearchBar(
  hintText: 'Search guidelines...',
  leading: Icon(Icons.search),
  shape: MaterialStateProperty.all(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(28),
    ),
  ),
)

Wrap(
  spacing: 8,
  children: categories.map((category) => 
    FilterChip(
      label: Text(category),
      selected: selectedCategory == category,
      onSelected: (selected) => selectCategory(category),
    ),
  ).toList(),
)
```

### Marketplace
**File:** `marketplace_screen.dart`

**Material 3 Components:**
- ✅ Card grid for products
- ✅ Chip filters for categories/price
- ✅ FAB for shopping cart
- ✅ Badge for cart item count
- ✅ Surface containers for product details

**Product Card:**
```dart
Card(
  clipBehavior: Clip.antiAlias,
  child: Column(
    children: [
      // Product image with AspectRatio
      Container(
        color: theme.colorScheme.surfaceContainerHigh,
        child: Image.asset(product.image),
      ),
      // Product info
      Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              product.name,
              style: theme.textTheme.titleMedium,
            ),
            Row(
              children: [
                Text(
                  product.ecoPoints,
                  style: theme.textTheme.labelLarge,
                ),
                Chip(
                  label: Text('Eco-Friendly'),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  ),
)
```

### Gamification Screens
**Files:** `badges_screen.dart`, `challenges_screen.dart`, `leaderboard_screen.dart`

**Material 3 Components:**
- ✅ GridView with Card items
- ✅ LinearProgressIndicator for challenge progress
- ✅ CircularProgressIndicator for loading
- ✅ ListTile for leaderboard entries
- ✅ Badge components for achievements

**Challenge Card:**
```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.emoji_events_outlined,
              color: theme.colorScheme.primary,
            ),
            Text(
              challenge.title,
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
        SizedBox(height: 12),
        LinearProgressIndicator(
          value: challenge.progress,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          color: theme.colorScheme.primary,
        ),
        Text(
          '${(challenge.progress * 100).toInt()}% Complete',
          style: theme.textTheme.labelSmall,
        ),
      ],
    ),
  ),
)
```

### Carbon Footprint Screen
**File:** `carbon_footprint_screen.dart`

**Material 3 Components:**
- ✅ SegmentedButton for time period selection
- ✅ Card for chart display
- ✅ Surface containers for statistics
- ✅ Chips for filter options
- ✅ FAB for adding new entries

**Segmented Filter:**
```dart
SegmentedButton<TimePeriod>(
  segments: [
    ButtonSegment(value: TimePeriod.week, label: Text('Week')),
    ButtonSegment(value: TimePeriod.month, label: Text('Month')),
    ButtonSegment(value: TimePeriod.year, label: Text('Year')),
  ],
  selected: {selectedPeriod},
  onSelectionChanged: (Set<TimePeriod> selection) {
    setState(() => selectedPeriod = selection.first);
  },
)
```

## 🎭 Glass Morphism Components

### GlassCard Widget
**File:** `app_theme.dart`

Reusable frosted glass card with:
- Adjustable blur strength
- Opacity control
- Custom colors
- Border options
- Shadow customization

```dart
GlassCard(
  blur: 20.0,
  opacity: 0.15,
  borderRadius: 20,
  padding: EdgeInsets.all(20),
  child: Column(
    children: [
      // Card content
    ],
  ),
)
```

### GlassActionButton Widget
Animated glass button with:
- Icon and label
- Scale animation on press
- Glassmorphism effect
- Custom color theming

```dart
GlassActionButton(
  icon: Icons.school_outlined,
  label: 'Education',
  color: theme.colorScheme.primary,
  onTap: () => context.push('/education'),
)
```

### GradientButton Widget
Premium gradient button with:
- Customizable gradient colors
- Icon support
- Loading state
- Shadow effects

```dart
GradientButton(
  text: 'Get Started',
  icon: Icons.arrow_forward,
  onPressed: () => navigate(),
  colors: [
    theme.colorScheme.primary,
    theme.colorScheme.tertiary,
  ],
)
```

## 🎬 Animations & Transitions

### Page Transitions
**File:** `app_theme.dart`

Platform-adaptive transitions:
- **iOS:** Slide from right with easeOutCubic
- **Android:** Fade + scale with easeOutCubic

```dart
SmoothPageRoute(
  builder: (context) => NextScreen(),
  duration: Duration(milliseconds: 400),
)
```

### Component Animations
- FAB scale animation on press
- Card elevation on hover (web/desktop)
- Ripple effects on interactive surfaces
- Shimmer loading placeholders
- Progress indicator animations

## 📐 Spacing System

Based on 4px grid:
```dart
spacingXS   = 4.0   // Tight spacing
spacingS    = 8.0   // Small spacing
spacingM    = 16.0  // Medium spacing (default)
spacingL    = 24.0  // Large spacing
spacingXL   = 32.0  // Extra large spacing
spacingXXL  = 48.0  // Section spacing
```

## 🔤 Typography Scale

Material 3 type system with Inter font:
- **Display Large:** 57px / Bold - Hero titles
- **Display Medium:** 45px / Bold - Major headings
- **Display Small:** 36px / Bold - Section headings
- **Headline Large:** 32px / Regular - Page titles
- **Headline Medium:** 28px / Regular - Card titles
- **Headline Small:** 24px / Regular - List headers
- **Title Large:** 22px / Regular - Toolbar
- **Title Medium:** 16px / Medium - List items
- **Title Small:** 14px / Medium - Subtitles
- **Body Large:** 16px / Regular - Main content
- **Body Medium:** 14px / Regular - Secondary content
- **Body Small:** 12px / Regular - Captions
- **Label Large:** 14px / Medium - Buttons
- **Label Medium:** 12px / Medium - Chips
- **Label Small:** 11px / Medium - Small labels

## 🎨 Color Palette

### Primary (Green - Eco Theme)
- **Primary:** `#006D1D` (light) / `#5DD472` (dark)
- **On Primary:** `#FFFFFF` (light) / `#00390B` (dark)
- **Primary Container:** `#7AF18D` (light) / `#005316` (dark)
- **On Primary Container:** `#002204` (light) / `#7AF18D` (dark)

### Secondary (Supporting Green)
- **Secondary:** `#52634F` (light) / `#B9CCB4` (dark)
- **On Secondary:** `#FFFFFF` (light) / `#243424` (dark)
- **Secondary Container:** `#D5E8CF` (light) / `#3A4B39` (dark)
- **On Secondary Container:** `#101F0F` (light) / `#D5E8CF` (dark)

### Tertiary (Accent Teal/Blue)
- **Tertiary:** `#006874` (light) / `#4FD8EB` (dark)
- **On Tertiary:** `#FFFFFF` (light) / `#00363D` (dark)
- **Tertiary Container:** `#9DF0FF` (light) / `#004F58` (dark)
- **On Tertiary Container:** `#001F24` (light) / `#97F0FF` (dark)

### Surface Containers (M3 Tonal System)
- **Surface Container Lowest:** Lightest surface
- **Surface Container Low:** Slightly elevated
- **Surface Container:** Default cards
- **Surface Container High:** Elevated cards
- **Surface Container Highest:** Highest elevation

## ♿ Accessibility Features

1. **High Contrast Modes**
   - Increased color contrast ratios
   - Bolder outline weights
   - Enhanced focus indicators

2. **Touch Targets**
   - Minimum 48x48dp touch targets
   - Adequate spacing between interactive elements
   - Visual density: standard

3. **Screen Reader Support**
   - Semantic labels on all interactive elements
   - Tooltip descriptions
   - Proper heading hierarchy

4. **Keyboard Navigation**
   - Focus management
   - Tab order optimization
   - Keyboard shortcuts

## 🔧 Implementation Guidelines

### Using Theme Colors
```dart
// Access theme colors
final theme = Theme.of(context);
final colorScheme = theme.colorScheme;

// Primary actions
color: colorScheme.primary
onColor: colorScheme.onPrimary

// Surface elements
color: colorScheme.surface
onColor: colorScheme.onSurface

// Containers
color: colorScheme.primaryContainer
onColor: colorScheme.onPrimaryContainer
```

### Creating Custom Cards
```dart
Card(
  elevation: 1, // M3 uses minimal elevation
  color: theme.colorScheme.surfaceContainerLow,
  surfaceTintColor: theme.colorScheme.surfaceTint,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: // Card content
  ),
)
```

### Implementing Glass Effects
```dart
GlassCard(
  blur: 20.0,        // Blur strength
  opacity: 0.15,     // Glass opacity
  borderRadius: 20,  // Corner radius
  color: isDark ? Colors.white : Colors.white,
  child: // Content
)
```

## 📱 Platform Adaptation

### iOS-specific
- Corner Radius: 10-28px (rounded)
- Blur Effects: Heavy backdrop filters
- Transitions: Slide animations
- Typography: San Francisco fallback

### Android-specific
- Corner Radius: 12-32px (more rounded)
- Material You: Dynamic color extraction
- Transitions: Fade + scale
- Typography: Roboto fallback

## 🚀 Performance Considerations

1. **Backdrop Filters**
   - Use sparingly for glass effects
   - Cache filter layers when possible
   - Avoid nested backdrop filters

2. **Animations**
   - Use `RepaintBoundary` for animated widgets
   - Dispose animation controllers properly
   - Use `const` constructors where possible

3. **Image Loading**
   - Implement proper image caching
   - Use placeholder shimmer effects
   - Lazy load images in lists

4. **Theme Updates**
   - Use `Consumer` or `context.watch` for theme changes
   - Avoid rebuilding entire widget tree
   - Cache theme-dependent values

## 📚 Resources

- [Material Design 3](https://m3.material.io/)
- [Flutter Material 3](https://docs.flutter.dev/ui/design/material)
- [dynamic_color package](https://pub.dev/packages/dynamic_color)
- [Google Fonts package](https://pub.dev/packages/google_fonts)

## ✅ Checklist

- [x] Material 3 NavigationBar
- [x] FilledButton, OutlinedButton, TextButton
- [x] Material 3 TextFormField
- [x] Surface tonal elevation system
- [x] Glass morphism effects
- [x] Dark mode support
- [x] High contrast accessibility themes
- [x] Dynamic color on Android 12+
- [x] Proper typography hierarchy
- [x] Semantic color usage
- [x] Shimmer loading states
- [x] Platform-adaptive transitions
- [x] Comprehensive component theming

## 🎉 Conclusion

The Waste Wise app features a complete Material 3 design implementation with glass morphism effects, creating a modern, accessible, and visually stunning user experience that adapts to user preferences and system settings.

All screens follow consistent design patterns, use semantic colors, and provide smooth animations for an premium feel across the entire application.
