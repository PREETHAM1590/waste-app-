import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/chatbot_provider.dart';
import '../screens/main_screen.dart';
import '../screens/home_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/education_screen.dart';
import '../screens/community_challenges_screen.dart';
import '../screens/marketplace_screen.dart';
import '../screens/wisebot_screen.dart';
import '../screens/classification_screen.dart'; // Use ClassificationScreen instead
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/unified_login_screen.dart';
import '../screens/create_account_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/report_issue_screen.dart';
import '../screens/recycling_centers_screen.dart';
import '../screens/carbon_footprint_screen.dart';
import '../screens/gamification_screen.dart';
import '../screens/badges_screen.dart';
import '../screens/challenges_screen.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/notification_settings_screen.dart';
import '../screens/social_screen.dart';
import '../screens/tips_screen.dart';
import '../screens/guidelines_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/web3auth_demo_screen.dart';
import '../screens/web3auth_debug_screen.dart';
import '../screens/web3_wallet_screen.dart';
import '../screens/auth_wrapper_screen.dart';
import '../screens/wallet_section_screen.dart';
import '../screens/edit_profile_screen.dart';
// New wallet screens
import '../wallet/screens/wallet_home_screen.dart';
import '../wallet/screens/wallet_send_screen.dart';

/// Route names as constants for type safety
class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String createAccount = '/create-account';
  static const String main = '/main';
  static const String home = '/main/home';
  static const String stats = '/main/stats';
  static const String learn = '/main/learn';
  static const String community = '/main/community';
  static const String marketplace = '/main/marketplace';
  static const String wisebot = '/wisebot';
  static const String scan = '/scan'; // Keep the route name for now, but point to ClassificationScreen
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String reportIssue = '/report-issue';
  static const String recyclingCenters = '/recycling-centers';
  static const String carbonFootprint = '/carbon-footprint';
  static const String gamification = '/gamification';
  static const String badges = '/badges';
  static const String challenges = '/challenges';
  static const String leaderboard = '/leaderboard';
  static const String wallet = '/wallet';
  static const String notifications = '/notifications';
  static const String social = '/social';
  static const String tips = '/tips';
  static const String guidelines = '/guidelines';
  static const String forgotPassword = '/forgot-password';
  static const String web3authDemo = '/web3auth-demo';
  static const String web3authDebug = '/web3auth-debug';
  static const String walletConnect = '/wallet-connect';
  static const String web3Wallet = '/web3-wallet';
}

/// Main app router configuration
class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter() {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppRoutes.splash,
      debugLogDiagnostics: true,
      routes: [
        // Auth & Onboarding Routes
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          builder: (context, state) => const AuthWrapperScreen(),
        ),
        GoRoute(
          path: '/auth',
          name: 'auth',
          builder: (context, state) {
            final String? deepLink = state.uri.toString();
            return AuthWrapperScreen(
              deepLink: deepLink,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.welcome,
          name: 'welcome',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          name: 'onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          builder: (context, state) => const UnifiedLoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.createAccount,
          name: 'createAccount',
          builder: (context, state) => const CreateAccountScreen(),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          name: 'forgotPassword',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        
        // Main App Shell with Bottom Navigation
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return Consumer<ChatbotProvider>(
              builder: (context, chatbotProvider, _) {
                return ChatbotScreenWrapper(
                  child: MainScreen(child: child),
                );
              },
            );
          },
          routes: [
            GoRoute(
              path: '/main',
              redirect: (context, state) => '/main/home', // Redirect /main to /main/home
            ),
            GoRoute(
              path: '/main/home',
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/main/stats',
              name: 'stats',
              builder: (context, state) => const StatisticsScreen(),
            ),
            GoRoute(
              path: '/main/community',
              name: 'community',
              builder: (context, state) => const CommunityChallengesScreen(),
            ),
          ],
        ),

        // Full Screen Routes (without bottom nav)
        GoRoute(
          path: AppRoutes.learn,
          name: 'learn',
          builder: (context, state) => const EducationScreen(),
        ),
        GoRoute(
          path: AppRoutes.marketplace,
          name: 'marketplace',
          builder: (context, state) => const MarketplaceScreen(),
        ),
        GoRoute(
          path: AppRoutes.wisebot,
          name: 'wisebot',
          builder: (context, state) => const WiseBotScreen(),
        ),
        GoRoute(
          path: AppRoutes.scan,
          name: 'scan',
          builder: (context, state) => const ClassificationScreen(), // Point to ClassificationScreen
        ),
        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/edit-profile',
          name: 'editProfile',
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: AppRoutes.settings,
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: AppRoutes.reportIssue,
          name: 'reportIssue',
          builder: (context, state) => const ReportIssueScreen(),
        ),
        GoRoute(
          path: AppRoutes.recyclingCenters,
          name: 'recyclingCenters',
          builder: (context, state) => const RecyclingCentersScreen(),
        ),
        GoRoute(
          path: AppRoutes.carbonFootprint,
          name: 'carbonFootprint',
          builder: (context, state) => const CarbonFootprintScreen(),
        ),
        GoRoute(
          path: AppRoutes.gamification,
          name: 'gamification',
          builder: (context, state) => const GamificationScreen(),
        ),
        GoRoute(
          path: AppRoutes.badges,
          name: 'badges',
          builder: (context, state) => const BadgesScreen(),
        ),
        GoRoute(
          path: AppRoutes.challenges,
          name: 'challenges',
          builder: (context, state) => const ChallengesScreen(),
        ),
        GoRoute(
          path: AppRoutes.leaderboard,
          name: 'leaderboard',
          builder: (context, state) => const LeaderboardScreen(),
        ),
        GoRoute(
          path: AppRoutes.wallet,
          name: 'wallet',
          builder: (context, state) => const WalletHomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.notifications,
          name: 'notifications',
          builder: (context, state) => const NotificationSettingsScreen(),
        ),
        GoRoute(
          path: AppRoutes.social,
          name: 'social',
          builder: (context, state) => const SocialScreen(),
        ),
        GoRoute(
          path: AppRoutes.tips,
          name: 'tips',
          builder: (context, state) => const TipsScreen(),
        ),
        GoRoute(
          path: AppRoutes.guidelines,
          name: 'guidelines',
          builder: (context, state) => const GuidelinesScreen(),
        ),
        GoRoute(
          path: AppRoutes.web3authDemo,
          name: 'web3authDemo',
          builder: (context, state) => const Web3AuthDemoScreen(),
        ),
        GoRoute(
          path: AppRoutes.web3authDebug,
          name: 'web3authDebug',
          builder: (context, state) => const Web3AuthDebugScreen(),
        ),
        GoRoute(
          path: AppRoutes.walletConnect,
          name: 'walletConnect',
          builder: (context, state) => const UnifiedLoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.web3Wallet,
          name: 'web3Wallet',
          builder: (context, state) => const Web3WalletScreen(),
        ),
        // Dedicated Wallet Section
        GoRoute(
          path: '/wallet-section',
          name: 'walletSection',
          builder: (context, state) => const WalletSectionScreen(),
        ),
        // New Web3Auth Wallet Routes
        GoRoute(
          path: '/wallet-login',
          name: 'walletLogin',
          builder: (context, state) => const UnifiedLoginScreen(),
        ),
        GoRoute(
          path: '/wallet-home',
          name: 'walletHome',
          builder: (context, state) => const WalletHomeScreen(),
        ),
        GoRoute(
          path: '/wallet-send',
          name: 'walletSend',
          builder: (context, state) => const WalletSendScreen(),
        ),
      ],
    );
  }
}


/// Wrapper to handle chatbot visibility based on current route
class ChatbotScreenWrapper extends StatelessWidget {
  final Widget child;

  const ChatbotScreenWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatbotProvider>(
      builder: (context, chatbotProvider, _) {
        final currentRoute = GoRouterState.of(context).matchedLocation;
        
        // Hide chatbot on WiseBot and scan screens
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (currentRoute == AppRoutes.wisebot || currentRoute == AppRoutes.scan) {
            chatbotProvider.hide();
          } else {
            chatbotProvider.show();
          }
        });

        return child;
      },
    );
  }
}
