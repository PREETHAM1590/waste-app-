# Waste Classifier Flutter App

A Flutter application for classifying waste using camera and machine learning capabilities. This app helps users identify different types of waste and provides disposal recommendations.

## Features

- **Camera-based waste classification**: Use your device's camera to scan waste items
- **Real-time analysis**: Get instant feedback on waste type and disposal methods
- **Educational content**: Learn about recycling and environmental impact
- **Social features**: Connect with community for environmental challenges
- **Performance tracking**: Monitor your environmental impact over time

## Getting Started

### Prerequisites

- Flutter SDK (>=3.5.3)
- Android Studio or VS Code with Flutter extensions
- Android/iOS device or emulator
- Camera permissions on target device

### Installation

1. Clone the repository:
   ```bash
   git clone [repository-url]
   cd waste_classifier_flutter
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Architecture

The app follows a standard Flutter architecture with:
- **Screens**: UI components for different app sections
- **Models**: Data structures for app entities
- **Providers**: State management using Provider pattern
- **Services**: API calls and external service integration

## Troubleshooting

### Common Issues

#### 1. ClassificationScreen LateInitializationError

**Symptoms**: 
```
LateError was thrown building ClassificationScreen
LateInitializationError: Field '_initializeControllerFuture' has not been initialized.
```

**Solution**: This has been fixed in the latest version. The camera controller now uses nullable types and proper async initialization. If you still encounter this:

1. Update to the latest version
2. Ensure you have camera permissions
3. Try restarting the app

#### 2. Image Decoding Errors

**Symptoms**:
```
Exception: Invalid image data
Image provider: AssetImage(bundle: null, name: "assets/images/avatar.png")
```

**Solution**: 
1. Corrupted image assets have been replaced
2. Run `flutter clean && flutter pub get` to refresh assets
3. If creating new image assets, ensure they are valid PNG/JPEG files

#### 3. Camera Permissions

**Symptoms**: Black screen when opening camera or "No cameras available" error

**Solution**:
1. Grant camera permissions in device settings
2. On Android: Settings > Apps > [App Name] > Permissions > Camera
3. On iOS: Settings > Privacy & Security > Camera > [App Name]

#### 4. Performance Issues (Frame Drops)

**Symptoms**: 
```
I/Choreographer: Skipped frames! The application may be doing too much work on its main thread.
```

**Solution**:
- Camera resolution has been optimized to `ResolutionPreset.low`
- Use `const` constructors where possible
- Avoid heavy computations on the UI thread
- Consider using `compute()` for ML inference

### Performance Optimization

#### Camera Settings
- **Resolution**: Uses `ResolutionPreset.low` for better performance
- **Audio**: Disabled (`enableAudio: false`) to reduce overhead
- **Preview**: Optimized with proper disposal

#### UI Optimizations
- Static widgets use `const` constructors
- Minimal rebuilds with proper state management
- Efficient image loading and caching

#### Testing
Run tests to verify functionality:
```bash
flutter test
```

### Development Guidelines

#### Adding New Features
1. Follow the existing architecture pattern
2. Add appropriate tests
3. Update documentation
4. Consider performance impact

#### Asset Management
- Keep image assets optimized (use tools like `pngcrush` or `imagemin`)
- Test asset loading in widget tests
- Verify assets work on different screen densities

#### Code Quality
- Run `flutter analyze` before committing
- Follow Dart style guidelines
- Add documentation for public APIs

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── screens/                  # UI screens
│   ├── classification_screen.dart
│   ├── home_screen.dart
│   └── ...
├── models/                   # Data models
├── providers/                # State management
└── firebase_options.dart     # Firebase configuration

assets/
├── images/                   # Image assets
├── model.tflite            # ML model
└── labels.txt              # Classification labels

test/
├── classification_screen_test.dart
├── avatar_image_test.dart
└── ...
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Run `flutter test` and `flutter analyze`
6. Create a pull request

## Dependencies

Key dependencies include:
- `camera`: Camera functionality
- `firebase_core` & `firebase_auth`: Authentication
- `provider`: State management
- `fl_chart`: Data visualization
- `google_fonts`: Typography

## Known Issues

- Camera initialization may take a few seconds on first launch
- ML model inference is CPU-intensive on lower-end devices
- Some Android emulators may not support camera preview

## Support

For issues and questions:
1. Check this README's troubleshooting section
2. Run `flutter doctor` to check your development environment
3. Verify device permissions and compatibility
4. Check Flutter and dependency versions

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Changelog

### Latest Version
- ✅ Fixed LateInitializationError in ClassificationScreen
- ✅ Replaced corrupted avatar.png asset
- ✅ Optimized camera performance (low resolution, disabled audio)
- ✅ Added proper error handling and retry mechanisms
- ✅ Improved const constructor usage for better performance
- ✅ Added comprehensive widget tests
- ✅ Enhanced null-safety throughout the app

### Performance Improvements
- Reduced camera resolution from medium to low
- Added const constructors to static widgets
- Optimized image asset loading
- Better resource disposal and memory management
