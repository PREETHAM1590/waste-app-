# Material 3 Theme Implementation Guide

## Overview
The Waste Wise app has been fully upgraded to Material Design 3 (M3), Google's latest design system that provides a more personalized, accessible, and expressive user interface.

## What's New in Material 3

### 1. **Dynamic Color System**
- The app automatically adapts to device's wallpaper colors on Android 12+ devices
- Fallback to custom green-themed color scheme on older devices
- Full support for both light and dark modes

### 2. **Enhanced Color Schemes**

#### Light Theme
- **Primary**: `#4CAF50` (Green)
- **Secondary**: Derived shades for consistency
- **Tertiary**: `#006874` (Teal accent)
- **Surface Variants**: Multiple container levels for depth
- **Error**: Standard Material error colors

#### Dark Theme
- **Primary**: `#5DD472` (Lighter green for contrast)
- **Surface**: `#121212` (True black background)
- **Multiple Surface Containers**: For layered UI elements
- **Enhanced contrast** for better readability

### 3. **Typography System**
All text styles use **Inter** font with proper Material 3 specifications:

- **Display Large/Medium/Small**: For hero text
- **Headline Large/Medium/Small**: For section headers
- **Title Large/Medium/Small**: For card and dialog titles
- **Body Large/Medium/Small**: For body text
- **Label Large/Medium/Small**: For buttons and labels

### 4. **Component Themes**

#### Buttons
- **FilledButton**: Primary actions (solid background)
- **ElevatedButton**: Important secondary actions
- **OutlinedButton**: Tertiary actions with border
- **TextButton**: Low-emphasis actions

All buttons feature:
- Rounded corners (full radius)
- Proper padding and minimum sizes
- State layers for interaction feedback

#### Cards
- Material 3 elevation system
- Surface tint colors for depth
- Rounded corners (12px by default)
- Proper shadow and elevation

#### Navigation
- **NavigationBar**: Bottom navigation with indicator pill
- **NavigationRail**: Side navigation for larger screens
- **NavigationDrawer**: Drawer with proper styling

#### Input Fields
- Filled text fields by default
- Rounded corners (28px)
- Proper focus states
- Error states with helper text

#### Dialogs & Sheets
- **Dialog**: Rounded corners (28px)
- **BottomSheet**: Rounded top corners (28px)
- **Drawer**: Rounded right side (16px)

#### Interactive Components
- **Switch**: Material 3 track and thumb design
- **Checkbox**: Rounded square design
- **Radio**: Proper states and colors
- **Slider**: Updated track and thumb
- **ProgressIndicator**: New styling

### 5. **Additional Features**

#### SearchBar & SearchView
- Modern search UI with rounded design
- Proper placeholder and active states

#### Lists & Tiles
- **ListTile**: Selected state with secondary container
- Rounded corners on selection
- Proper icon and text colors

#### Menus & Tooltips
- **PopupMenu**: Modern elevated design
- **Tooltip**: Inverse surface colors
- Proper elevation and shadows

#### Badges
- Error color background
- Small, compact design
- Proper text styling

## Usage Examples

### Using Theme Colors
```dart
// Access theme colors
final colorScheme = Theme.of(context).colorScheme;

Container(
  color: colorScheme.primaryContainer,
  child: Text(
    'Hello',
    style: TextStyle(color: colorScheme.onPrimaryContainer),
  ),
)
```

### Using Text Styles
```dart
Text(
  'Headline',
  style: Theme.of(context).textTheme.headlineMedium,
)
```

### Using Buttons
```dart
// Primary action
FilledButton(
  onPressed: () {},
  child: Text('Continue'),
)

// Secondary action
ElevatedButton(
  onPressed: () {},
  child: Text('Learn More'),
)

// Tertiary action
OutlinedButton(
  onPressed: () {},
  child: Text('Cancel'),
)
```

### Using Cards
```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text('Card Content'),
  ),
)
```

### Using Navigation
```dart
NavigationBar(
  destinations: [
    NavigationDestination(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    // More destinations...
  ],
  selectedIndex: _selectedIndex,
  onDestinationSelected: (index) {
    setState(() => _selectedIndex = index);
  },
)
```

## Color System Reference

### Surface Levels
- **surfaceContainerLowest**: Lowest elevation
- **surfaceContainerLow**: Low elevation
- **surfaceContainer**: Base container
- **surfaceContainerHigh**: High elevation
- **surfaceContainerHighest**: Highest elevation

Use these for creating visual hierarchy and depth.

### Semantic Colors
- **primary**: Main brand color
- **secondary**: Complementary color
- **tertiary**: Accent color
- **error**: Error states
- **surface**: Background surfaces
- **outline**: Borders and dividers

Each has corresponding `on*` colors for text/icons on that background.

## Accessibility

The Material 3 theme includes:
- **High contrast mode** support (toggle in ThemeProvider)
- **Proper color contrast ratios** (WCAG AA compliant)
- **Sufficient touch target sizes** (minimum 48x48)
- **Clear focus indicators**
- **Screen reader support**

## Dynamic Color

The app uses the `dynamic_color` package to extract colors from the device wallpaper on Android 12+:

```dart
DynamicColorBuilder(
  builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
    return MaterialApp(
      theme: lightDynamic != null 
        ? ThemeData.from(colorScheme: lightDynamic)
        : fallbackTheme,
    );
  },
)
```

## Performance Considerations

- **Lightweight animations**: Material 3 uses efficient state layer animations
- **Optimized rendering**: Surface tints reduce overdraw
- **Proper elevation**: Uses elevation instead of heavy shadows

## Migration Checklist

✅ Updated `useMaterial3: true` in theme
✅ Implemented comprehensive color schemes for light/dark modes
✅ Added all Material 3 component themes
✅ Updated typography to use Inter font with M3 specs
✅ Implemented navigation components (NavigationBar, etc.)
✅ Added input field styling
✅ Configured dialogs and bottom sheets
✅ Added interactive component themes (Switch, Checkbox, etc.)
✅ Implemented search components
✅ Added list and menu styling
✅ Configured badges and tooltips
✅ Set up dynamic color support

## Testing

Test the theme by:
1. Running on Android 12+ device to see dynamic colors
2. Switching between light and dark modes
3. Testing all interactive components
4. Verifying accessibility with screen readers
5. Checking contrast ratios
6. Testing on different screen sizes

## Resources

- [Material 3 Design System](https://m3.material.io/)
- [Flutter Material 3 Guide](https://docs.flutter.dev/ui/design/material)
- [Dynamic Color Package](https://pub.dev/packages/dynamic_color)
- [Material Theme Builder](https://m3.material.io/theme-builder)

## Future Enhancements

- [ ] Add custom motion curves
- [ ] Implement Material You adaptive layouts
- [ ] Add more color scheme variants
- [ ] Create theme customization UI
- [ ] Add seasonal theme variations
