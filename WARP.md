# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Development Commands

### Flutter App (Root Directory)

**Essential Commands:**
```bash
flutter pub get                    # Install Flutter dependencies
flutter run                       # Run the app on connected device/emulator
flutter build apk --release       # Build Android APK
flutter build appbundle           # Build Android App Bundle for Play Store
flutter test                      # Run all tests
flutter analyze                   # Static code analysis
flutter clean && flutter pub get  # Clean and reinstall dependencies
```

**Testing & Quality:**
```bash
flutter test test/                 # Run specific test directory
flutter test --coverage           # Run tests with coverage report
flutter analyze --no-fatal-infos  # Analyze without treating infos as fatal
dart format lib/                   # Format Dart code
```

**Device & Platform Specific:**
```bash
flutter devices                   # List available devices
flutter run -d chrome             # Run on Chrome browser
flutter run -d windows            # Run on Windows desktop
flutter run --hot                 # Enable hot reload (default)
flutter run --profile             # Run in profile mode for performance testing
```

### Backend API (backend-api/ Directory)

**Development Commands:**
```bash
cd backend-api
npm install                       # Install Node.js dependencies
npm run dev                      # Start development server with nodemon
npm start                        # Start production server
npm test                         # Run Jest tests
npm run lint                     # Run ESLint
```

**Database Operations:**
```bash
npm run migrate                  # Run database migrations
npm run seed                     # Seed database with initial data
```

## Architecture Overview

### Flutter App Structure

**Core Architecture:**
- **Provider Pattern**: State management using `flutter_provider` package
- **GoRouter**: Declarative routing with shell routes for bottom navigation
- **Service Locator**: Dependency injection using `get_it` for services
- **Material 3**: Modern UI design system with dynamic theming

**Key Directories:**
```
lib/
├── core/                        # Core app configuration
│   ├── app_router.dart         # GoRouter configuration
│   ├── service_locator.dart    # Dependency injection setup
│   └── design_tokens.dart      # Material 3 design system
├── providers/                   # State management
│   ├── app_state_provider.dart # Global app state
│   ├── theme_provider.dart     # Theme and UI state
│   └── chatbot_provider.dart   # AI chatbot state
├── services/                    # Business logic layer
│   ├── classification_service.dart  # ML waste classification
│   ├── firebase_service.dart       # Firebase integration
│   ├── web3auth_solana_service.dart # Web3 wallet integration
│   └── camera_service.dart         # Camera handling
├── screens/                     # UI screens organized by feature
├── models/                      # Data models
└── wallet/                      # Web3 wallet functionality
```

**Service Architecture:**
- **Firebase Services**: Authentication, Firestore, Crashlytics
- **ML Classification**: TensorFlow Lite model for waste identification
- **Web3 Integration**: Web3Auth + Solana blockchain for token rewards
- **Camera Service**: Handles camera permissions and image capture

### Backend API Structure

**Node.js/Express Architecture:**
```
backend-api/
├── src/
│   └── server.js               # Express server with middleware setup
├── services/                   # Business logic services
│   ├── blockchainService.js    # Blockchain interactions
│   ├── solanaBlockchainService.js  # Solana-specific operations
│   └── tokenRewardService.js   # Token reward distribution
└── routes/                     # API route definitions
```

**API Design:**
- RESTful endpoints under `/api/rewards/`
- Rate limiting (1000 requests/15min per IP)
- CORS enabled for Flutter app domains
- Comprehensive error handling and logging

### Key Integrations

**Machine Learning:**
- TensorFlow Lite model (`assets/model.tflite`) for waste classification
- Labels file (`assets/labels.txt`) for classification categories
- Camera-based real-time inference

**Blockchain Integration:**
- Web3Auth for social login and wallet creation
- Solana devnet for token distribution
- Reward system based on recycling activities

**Firebase Stack:**
- Authentication (Google Sign-in, Email/Password)
- Firestore for user data and app state
- Crashlytics for error reporting

## Development Notes

### Performance Considerations
- Camera resolution set to `ResolutionPreset.low` for performance
- Async initialization prevents UI blocking on app startup
- Service initialization happens in background with timeout protection

### State Management Pattern
```dart
// Provider pattern with multiple providers
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => AppStateProvider()),
    // ...
  ],
  child: MyApp(),
)
```

### Navigation Structure
- Shell routes for bottom navigation (home, stats, community)
- Full-screen routes for features like camera, profile, wallet
- Deep linking support for Web3Auth callback handling

### Error Handling Strategy
- Global error boundary with `runZonedGuarded`
- Firebase Crashlytics for production error tracking
- Graceful degradation when services fail to initialize

### Testing Strategy
- Widget tests for UI components
- Service tests for business logic
- Integration tests for critical user flows
- CI/CD pipeline with GitHub Actions

### Hot Reload Considerations
- Service locator handles "already registered" errors during hot reload
- Providers maintain state across hot reloads
- Asset loading is optimized for development workflow

## Environment Setup

**Required Tools:**
- Flutter SDK >=3.5.3
- Node.js >=16.0.0 (for backend API)
- Firebase CLI for Firebase operations
- Android Studio or VS Code with Flutter extensions

**Key Configuration Files:**
- `pubspec.yaml`: Flutter dependencies and asset definitions
- `firebase_options.dart`: Firebase configuration
- `backend-api/.env`: Backend environment variables
- `analysis_options.yaml`: Dart static analysis rules