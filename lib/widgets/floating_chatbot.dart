import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../core/design_tokens.dart';
import '../core/theme/app_theme.dart';
import '../providers/chatbot_provider.dart';

/// Global floating chatbot widget that appears on relevant screens
class FloatingChatbot extends StatefulWidget {
  const FloatingChatbot({super.key});

  @override
  State<FloatingChatbot> createState() => _FloatingChatbotState();
}

class _FloatingChatbotState extends State<FloatingChatbot>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Scale animation for tap feedback
    _scaleController = AnimationController(
      duration: DesignTokens.animationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    // Slide animation for expansion
    _slideController = AnimationController(
      duration: DesignTokens.animationNormal,
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onTap() {
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
    
    // Navigate to WiseBot screen
    context.push('/wisebot');
  }

  void _onLongPress() {
    final provider = Provider.of<ChatbotProvider>(context, listen: false);
    provider.toggleExpansion();
    
    if (provider.isExpanded) {
      _slideController.forward();
    } else {
      _slideController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatbotProvider>(
      builder: (context, chatbotProvider, child) {
        if (!chatbotProvider.isVisible) {
          return const SizedBox.shrink();
        }

        final screenSize = MediaQuery.of(context).size;
        final position = Offset(
          chatbotProvider.position.dx * screenSize.width,
          chatbotProvider.position.dy * screenSize.height,
        );

        return Stack(
          children: [
            // Expanded preview (optional quick actions)
            if (chatbotProvider.isExpanded)
              Positioned(
                left: position.dx - 120,
                top: position.dy - 120,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildExpandedPreview(context),
                ),
              ),
            
            // Main floating button
            Positioned(
              left: position.dx - (DesignTokens.fabSize / 2),
              top: position.dy - (DesignTokens.fabSize / 2),
              child: _buildFloatingButton(context, chatbotProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFloatingButton(BuildContext context, ChatbotProvider provider) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onPanUpdate: (details) {
        final screenSize = MediaQuery.of(context).size;
        final newPosition = Offset(
          (details.globalPosition.dx / screenSize.width).clamp(0.0, 1.0),
          (details.globalPosition.dy / screenSize.height).clamp(0.0, 1.0),
        );
        provider.updatePosition(newPosition);
      },
      onPanEnd: (details) {
        provider.snapToEdge(MediaQuery.of(context).size);
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: DesignTokens.fabSize,
              height: DesignTokens.fabSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(DesignTokens.fabSize / 2),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _onTap,
                  onLongPress: _onLongPress,
                  borderRadius: BorderRadius.circular(DesignTokens.fabSize / 2),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Bot icon
                      Icon(
                        Icons.smart_toy_outlined,
                        color: theme.colorScheme.onPrimary,
                        size: DesignTokens.iconMD,
                      ),
                      
                      // Notification dot (optional)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: DesignTokens.accentOrange,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: theme.colorScheme.onPrimary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpandedPreview(BuildContext context) {
    final theme = Theme.of(context);
    
    return ClipRRect(
      borderRadius: DesignTokens.borderRadiusLG,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 240,
          padding: DesignTokens.paddingMD,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.7),
                Colors.white.withOpacity(0.5),
              ],
            ),
            borderRadius: DesignTokens.borderRadiusLG,
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
          // Header
          Row(
            children: [
              Container(
                padding: DesignTokens.paddingXS,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: DesignTokens.borderRadiusSM,
                ),
                child: Icon(
                  Icons.smart_toy_outlined,
                  color: theme.colorScheme.primary,
                  size: DesignTokens.iconSM,
                ),
              ),
              SizedBox(width: DesignTokens.space8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WiseBot',
                      style: GoogleFonts.inter(
                        fontSize: DesignTokens.titleSmall.fontSize,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Online',
                      style: GoogleFonts.inter(
                        fontSize: DesignTokens.bodySmall.fontSize,
                        color: DesignTokens.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: DesignTokens.space12),
          
          // Quick message preview
          Container(
            padding: DesignTokens.paddingSM,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: DesignTokens.borderRadiusSM,
            ),
            child: Text(
              '👋 Hi! I can help you with waste sorting, recycling tips, and environmental questions.',
              style: GoogleFonts.inter(
                fontSize: DesignTokens.bodySmall.fontSize,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          
          SizedBox(height: DesignTokens.space12),
          
          // Quick action buttons
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  context,
                  'Ask Question',
                  Icons.help_outline,
                  () => _onTap(),
                ),
              ),
              SizedBox(width: DesignTokens.space8),
              Expanded(
                child: _buildQuickActionButton(
                  context,
                  'Scan Item',
                  Icons.camera_alt_outlined,
                  () {
                    // Navigate to scan screen
                    context.push('/scan');
                  },
                ),
              ),
            ],
          ),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.space8,
          vertical: DesignTokens.space8,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: DesignTokens.borderRadiusSM,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: DesignTokens.iconSM,
              color: theme.colorScheme.primary,
            ),
            SizedBox(height: DesignTokens.space4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Screen wrapper that automatically manages chatbot visibility based on screen name
class ChatbotScreenWrapper extends StatelessWidget {
  final Widget child;
  final String screenName;

  const ChatbotScreenWrapper({
    super.key,
    required this.child,
    required this.screenName,
  });

  @override
  Widget build(BuildContext context) {
    // Update current screen in provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ChatbotProvider>(context, listen: false);
      provider.setCurrentScreen(screenName);
    });

    return Stack(
      children: [
        child,
        const FloatingChatbot(),
      ],
    );
  }
}
