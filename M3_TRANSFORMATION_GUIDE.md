# Complete Material 3 Transformation Guide

## 🎯 Overview
This guide covers the comprehensive Material 3 transformation for every screen in the Waste Wise app, including animations, loading states, and modern UI components optimized for Android 16.

## ✅ Completed Transformations

### 1. ✨ Navigation System
- **Material 3 NavigationBar** with rounded top corners (24px)
- **Smooth animations** (300ms duration)
- **Modern indicator** design with secondary container color
- **Enhanced FAB** with Hero animation and dual shadow layers
- **Dark mode support** with adaptive shadows

### 2. 🧩 Reusable M3 Components Created
All components are in `lib/widgets/m3_components.dart`:

- **M3LoadingIndicator** - Modern circular progress with optional message
- **M3ShimmerLoading** - Skeleton loading animation
- **M3Card** - Enhanced cards with elevation and rounded corners
- **M3Badge** - Info badges with icons
- **M3StatCard** - Stat display with icons and values
- **M3ActionButton** - Primary and secondary buttons with loading states
- **M3EmptyState** - Empty state screens with icons and messages
- **M3SectionHeader** - Section headers with optional actions
- **M3ListTile** - Modern list tiles with icons
- **M3Snackbar** - Helper for Material 3 snackbars
- **M3Dialog** - Helper for confirmation dialogs
- **M3BottomSheet** - Helper for bottom sheets

## 📋 Implementation Checklist

### Home Screen (`home_screen.dart`)
**Status**: ⏳ Needs implementation
**Changes needed**:
```dart
// Replace custom cards with M3Card
M3Card(
  child: Column(
    children: [
      // Your content
    ],
  ),
)

// Use M3StatCard for statistics
M3StatCard(
  title: 'Items Scanned',
  value: '150',
  icon: Icons.qr_code_scanner_rounded,
)

// Add M3SectionHeader for sections
M3SectionHeader(
  title: 'Recent Activity',
  trailing: TextButton(
    onPressed: () {},
    child: Text('See All'),
  ),
)

// Use M3ShimmerLoading while loading
if (isLoading) M3ShimmerLoading(width: double.infinity, height: 100)
```

### Camera/Scanner Screen (`classification_screen.dart`)
**Status**: ⏳ Needs implementation
**Changes needed**:
```dart
// Modern overlay with Material 3 styling
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.black.withOpacity(0.6),
        Colors.transparent,
      ],
    ),
  ),
)

// M3 Capture Button
FilledButton.icon(
  onPressed: () {},
  icon: Icon(Icons.camera_alt_rounded),
  label: Text('Capture'),
  style: FilledButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(28),
    ),
  ),
)

// Add M3LoadingIndicator during classification
if (isClassifying)
  M3LoadingIndicator(message: 'Analyzing image...')
```

### Profile/Settings Screen (`settings_screen.dart`)
**Status**: ⏳ Needs implementation
**Changes needed**:
```dart
// Use M3ListTile for settings
M3ListTile(
  leadingIcon: Icons.notifications_rounded,
  title: 'Notifications',
  subtitle: 'Manage notification preferences',
  trailing: Switch.adaptive(
    value: notificationsEnabled,
    onChanged: (value) {},
  ),
  onTap: () {},
)

// Use M3SectionHeader for grouping
M3SectionHeader(
  title: 'Account',
  subtitle: 'Manage your account settings',
)

// Modern profile header
Container(
  padding: EdgeInsets.all(24),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Theme.of(context).colorScheme.primaryContainer,
        Theme.of(context).colorScheme.secondaryContainer,
      ],
    ),
    borderRadius: BorderRadius.circular(24),
  ),
  child: Row(
    children: [
      CircleAvatar(
        radius: 40,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Text('U', style: TextStyle(fontSize: 32)),
      ),
      SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Name',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'user@example.com',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    ],
  ),
)
```

### WiseBot Chat Screen (`wisebot_screen.dart`)
**Status**: ⏳ Needs implementation
**Changes needed**:
```dart
// M3 Message Bubble (User)
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.primaryContainer,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(4),
    ),
  ),
  child: Text(
    message,
    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: Theme.of(context).colorScheme.onPrimaryContainer,
    ),
  ),
)

// M3 Message Bubble (Bot)
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surfaceContainerHigh,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
      bottomLeft: Radius.circular(4),
      bottomRight: Radius.circular(20),
    ),
  ),
  child: Text(
    message,
    style: Theme.of(context).textTheme.bodyLarge,
  ),
)

// M3 Input Field
TextField(
  decoration: InputDecoration(
    hintText: 'Ask WiseBot...',
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(28),
      borderSide: BorderSide.none,
    ),
    suffixIcon: IconButton(
      icon: Icon(Icons.send_rounded),
      onPressed: () {},
    ),
  ),
)
```

### Wallet Screen (`wallet_section_screen.dart`)
**Status**: ⏳ Needs implementation
**Changes needed**:
```dart
// Balance Card with M3 styling
M3Card(
  padding: EdgeInsets.all(24),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Total Balance',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      SizedBox(height: 8),
      Text(
        '0.00 SOL',
        style: Theme.of(context).textTheme.displayMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: () {},
              icon: Icon(Icons.arrow_upward_rounded),
              label: Text('Send'),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: FilledButton.tonalIcon(
              onPressed: () {},
              icon: Icon(Icons.arrow_downward_rounded),
              label: Text('Receive'),
            ),
          ),
        ],
      ),
    ],
  ),
)

// Transaction List with M3ListTile
M3ListTile(
  leadingIcon: Icons.swap_horiz_rounded,
  title: 'Transaction',
  subtitle: '0.01 SOL • 2 hours ago',
  trailing: M3Badge(
    label: 'Completed',
    icon: Icons.check_circle_rounded,
  ),
)
```

### Authentication Screens
**Status**: ⏳ Needs implementation
**Changes needed**:

#### Login Screen
```dart
Scaffold(
  body: SafeArea(
    child: SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 40),
          Icon(
            Icons.recycling_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: 16),
          Text(
            'Welcome Back',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Sign in to continue',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 48),
          TextField(
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_rounded),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_rounded),
            ),
          ),
          SizedBox(height: 24),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text('Sign In'),
          ),
          SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text('Create Account'),
          ),
        ],
      ),
    ),
  ),
)
```

## 🎨 Animation Guidelines

### 1. Page Transitions
Use Material 3 page transitions:
```dart
// In app_router.dart
PageRouteBuilder(
  pageBuilder: (context, animation, secondaryAnimation) => NextScreen(),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    return SharedAxisTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      transitionType: SharedAxisTransitionType.horizontal,
      child: child,
    );
  },
)
```

### 2. List Item Animations
Add staggered animations:
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(1, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.1,
            1.0,
            curve: Curves.easeOut,
          ),
        ),
      ),
      child: M3ListTile(...),
    );
  },
)
```

### 3. Loading States
Use shimmer for skeleton screens:
```dart
ListView.separated(
  itemCount: 5,
  separatorBuilder: (_, __) => SizedBox(height: 12),
  itemBuilder: (context, index) {
    return M3ShimmerLoading(
      width: double.infinity,
      height: 80,
      borderRadius: BorderRadius.circular(16),
    );
  },
)
```

### 4. Hero Animations
Add hero transitions for images:
```dart
// Source screen
Hero(
  tag: 'item_${item.id}',
  child: Image.network(item.imageUrl),
)

// Destination screen
Hero(
  tag: 'item_${item.id}',
  child: Image.network(item.imageUrl),
)
```

## 🌈 Color Usage Guide

### Primary Actions
```dart
FilledButton(...) // Primary color background
```

### Secondary Actions
```dart
FilledButton.tonal(...) // Secondary container background
```

### Tertiary Actions
```dart
OutlinedButton(...) // Outline with primary color
```

### Low Emphasis Actions
```dart
TextButton(...) // No background, primary color text
```

### Surface Levels
```dart
// For cards and containers
Container(
  color: colorScheme.surfaceContainer, // Base level
  // or
  color: colorScheme.surfaceContainerLow, // Lower level
  // or
  color: colorScheme.surfaceContainerHigh, // Higher level
  // or
  color: colorScheme.surfaceContainerHighest, // Highest level
)
```

## 📱 Responsive Design

### Breakpoints
```dart
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 840;
  static const double desktop = 1200;
}

// Usage
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < Breakpoints.mobile) {
      return MobileLayout();
    } else if (constraints.maxWidth < Breakpoints.tablet) {
      return TabletLayout();
    } else {
      return DesktopLayout();
    }
  },
)
```

## 🚀 Performance Optimizations

### 1. Use Const Constructors
```dart
const M3Card(...)
const M3Badge(...)
```

### 2. Optimize List Building
```dart
ListView.builder( // Instead of ListView
  itemCount: items.length,
  itemBuilder: (context, index) => ...,
)
```

### 3. Cache Images
```dart
CachedNetworkImage(
  imageUrl: url,
  placeholder: (context, url) => M3ShimmerLoading(...),
)
```

### 4. Use RepaintBoundary
```dart
RepaintBoundary(
  child: ExpensiveWidget(),
)
```

## 🎭 Dark Mode Support

All M3 components automatically support dark mode through `Theme.of(context).colorScheme`.

### Testing Dark Mode
```dart
// In theme provider
ThemeMode.system // Follow system
ThemeMode.light  // Force light
ThemeMode.dark   // Force dark
```

## 🧪 Testing

### Widget Tests
```dart
testWidgets('M3Card displays correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        body: M3Card(
          child: Text('Test'),
        ),
      ),
    ),
  );
  
  expect(find.text('Test'), findsOneWidget);
});
```

## 📚 Additional Resources

- [Material 3 Design](https://m3.material.io/)
- [Flutter Material 3 Guide](https://docs.flutter.dev/ui/design/material)
- [Material Components Catalog](https://flutter.github.io/samples/web/material_3_demo/)

## 🎯 Priority Implementation Order

1. ✅ Navigation Bar (Completed)
2. ✅ M3 Components Library (Completed)
3. ⏳ Home Screen
4. ⏳ Scanner Screen
5. ⏳ Settings Screen
6. ⏳ Chat Screen
7. ⏳ Wallet Screen
8. ⏳ Auth Screens
9. ⏳ All Other Screens

## 🔄 Migration Steps

For each screen:

1. Import M3 components:
   ```dart
   import '../widgets/m3_components.dart';
   ```

2. Replace custom widgets with M3 equivalents

3. Update colors to use `colorScheme`:
   ```dart
   color: Theme.of(context).colorScheme.primary
   ```

4. Add loading states with `M3LoadingIndicator` or `M3ShimmerLoading`

5. Add empty states with `M3EmptyState`

6. Test in both light and dark mode

7. Verify animations and transitions

8. Test on different screen sizes

## 💡 Tips

- Always use `Theme.of(context).colorScheme` for colors
- Prefer `Theme.of(context).textTheme` for text styles
- Use semantic colors (primary, secondary, tertiary, error)
- Add tooltips to icon buttons for accessibility
- Use `Semantics` widgets for screen readers
- Test with TalkBack/VoiceOver enabled

---

**Ready to transform your app to Material 3!** 🚀

Start with high-traffic screens first (Home, Scanner) and gradually migrate others.
