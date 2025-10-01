import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/design_tokens.dart';
import '../core/theme/app_theme.dart';
import '../models/chat_message.dart';
import '../services/chat_persistence_service.dart';
import '../widgets/shared/glass_card.dart' as glass;

// Mock chat service for demonstration
class ChatService {
  Future<Map<String, dynamic>> sendMessage(String message) async {
    await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
    
    // Simple mock responses
    final responses = {
      'plastic': 'Plastic recycling is important! Most plastic containers marked with recycling symbols 1, 2, and 5 are widely accepted. Clean them thoroughly before recycling.',
      'recycle': 'Here are some local recycling centers near you... You can also check with your municipal waste management for pickup schedules.',
      'compost': 'Composting is great for organic waste! Start with fruit peels, vegetable scraps, coffee grounds, and eggshells. Avoid meat and dairy.',
    };
    
    String response = "I'm here to help with waste management and recycling questions! Try asking about plastic recycling, composting, or finding recycling centers.";
    List<String> quickActions = [
      'How to recycle plastic?',
      'Composting basics',
      'Find recycling centers',
      'Reduce waste tips',
    ];
    
    for (String key in responses.keys) {
      if (message.toLowerCase().contains(key)) {
        response = responses[key]!;
        if (key == 'plastic') {
          quickActions = ['Types of plastic', 'Cleaning tips', 'Where to recycle'];
        } else if (key == 'recycle') {
          quickActions = ['Center locations', 'Accepted materials', 'Drop-off times'];
        } else if (key == 'compost') {
          quickActions = ['What to compost', 'Compost bin setup', 'Troubleshooting'];
        }
        break;
      }
    }
    
    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'response': response,
      'timestamp': DateTime.now(),
      'quickActions': quickActions,
    };
  }
}

class WiseBotScreen extends StatefulWidget {
  const WiseBotScreen({super.key});

  @override
  State<WiseBotScreen> createState() => _WiseBotScreenState();
}

class _WiseBotScreenState extends State<WiseBotScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocus = FocusNode();
  final ChatService _chatService = ChatService();
  final ChatPersistenceService _persistenceService = ChatPersistenceService();
  
  late AnimationController _typingAnimationController;
  late AnimationController _messageAnimationController;
  late Animation<double> _typingAnimation;
  
  bool _isTyping = false;
  bool _isLoading = true;
  
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      duration: DesignTokens.animationNormal,
      vsync: this,
    );
    _messageAnimationController = AnimationController(
      duration: DesignTokens.animationNormal,
      vsync: this,
    );
    _typingAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(_typingAnimationController);
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    final history = await _persistenceService.loadChatHistory();
    
    setState(() {
      if (history.isEmpty) {
        // Add welcome message if no history exists
        _messages = [
          ChatMessage(
            id: 'welcome',
            text: '👋 Hello! I\'m WiseBot, your eco-friendly assistant. How can I help you make better waste management decisions today?',
            isUser: false,
            timestamp: DateTime.now(),
            quickActions: [
              'How to recycle plastic?',
              'Find recycling centers',
              'Environmental tips',
              'Composting guide',
            ],
          ),
        ];
      } else {
        _messages = history;
      }
      _isLoading = false;
    });
    
    _scrollToBottom();
  }

  Future<void> _saveChatHistory() async {
    await _persistenceService.saveChatHistory(_messages);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    _typingAnimationController.dispose();
    _messageAnimationController.dispose();
    super.dispose();
  }

  void _sendQuickAction(String action) {
    _messageController.text = action;
    _sendMessage();
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _messageController.clear();
      _isTyping = true;
    });

    // Save user message immediately
    await _saveChatHistory();
    _scrollToBottom();
    _typingAnimationController.repeat();

    try {
      final response = await _chatService.sendMessage(text);
      final botMessage = ChatMessage(
        id: response['id'],
        text: response['response'],
        isUser: false,
        timestamp: response['timestamp'],
        quickActions: response['quickActions']?.cast<String>(),
      );

      setState(() {
        _messages.add(botMessage);
        _isTyping = false;
      });
      
      // Save bot response
      await _saveChatHistory();
      _typingAnimationController.stop();
      _scrollToBottom();
      
      // Haptic feedback for successful response
      HapticFeedback.lightImpact();
    } catch (e) {
      setState(() => _isTyping = false);
      _typingAnimationController.stop();
      
      // Show error message
      final errorMessage = ChatMessage(
        id: 'error_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Sorry, I\'m having trouble responding right now. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      
      setState(() {
        _messages.add(errorMessage);
      });
      
      await _saveChatHistory();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: DesignTokens.animationNormal,
          curve: DesignTokens.curveStandard,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryBlue.withOpacity(0.05),
              AppTheme.primaryPurple.withOpacity(0.03),
              const Color(0xFFF2F2F7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildGlassAppBar(theme),
              _isLoading 
                  ? const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: DesignTokens.paddingMD,
                        itemCount: _messages.length + (_isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _messages.length) {
                            return _buildTypingIndicator(theme);
                          }
                          return _buildMessageBubble(_messages[index], theme);
                        },
                      ),
                    ),
              _buildGlassInputArea(theme),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildGlassAppBar(ThemeData theme) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.85),
                Colors.white.withOpacity(0.75),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => GoRouter.of(context).pop(),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryBlue, AppTheme.primaryPurple],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.smart_toy,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WiseBot',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Your eco-assistant',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
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

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => GoRouter.of(context).pop(),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.smart_toy,
              color: theme.colorScheme.onPrimaryContainer,
              size: 24,
            ),
          ),
          DesignTokens.space12.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WiseBot',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Your eco-assistant',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, top: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.primaryPurple],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.smart_toy,
                size: 18,
                color: Colors.white,
              ),
            ),
          ],
          Flexible(
            child: glass.GlassCard(
              padding: const EdgeInsets.all(12),
              borderRadius: 16,
              blur: message.isUser ? 8 : 12,
              opacity: message.isUser ? 0.3 : 0.25,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (message.quickActions?.isNotEmpty == true) ...[
                    DesignTokens.space12.height,
                    Wrap(
                      spacing: DesignTokens.space8,
                      runSpacing: DesignTokens.space4,
                      children: message.quickActions!.map((action) {
                        return ActionChip(
                          label: Text(action),
                          onPressed: () => _sendQuickAction(action),
                          backgroundColor: theme.colorScheme.primaryContainer,
                          labelStyle: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.successGreen, AppTheme.successGreen.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                size: 18,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: DesignTokens.space4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            margin: EdgeInsets.only(right: DesignTokens.space8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.smart_toy,
              size: 18,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          Container(
            padding: DesignTokens.paddingMD,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
            ),
            child: AnimatedBuilder(
              animation: _typingAnimation,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDot(0, theme),
                    DesignTokens.space4.width,
                    _buildDot(1, theme),
                    DesignTokens.space4.width,
                    _buildDot(2, theme),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index, ThemeData theme) {
    final delay = index * 0.2;
    return AnimatedBuilder(
      animation: _typingAnimation,
      builder: (context, child) {
        final value = (_typingAnimation.value - delay).clamp(0.0, 1.0);
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Color.lerp(
              theme.colorScheme.onSurface.withValues(alpha: 0.3),
              theme.colorScheme.onSurface,
              value,
            ),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      },
    );
  }

  Widget _buildGlassInputArea(ThemeData theme) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.85),
                Colors.white.withOpacity(0.75),
              ],
            ),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  focusNode: _inputFocus,
                  decoration: InputDecoration(
                    hintText: 'Ask me anything about waste...',
                    hintStyle: GoogleFonts.inter(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: AppTheme.primaryBlue.withOpacity(0.5)),
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryBlue, AppTheme.primaryPurple],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInputArea(ThemeData theme) {
    return Container(
      padding: DesignTokens.paddingMD,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                focusNode: _inputFocus,
                decoration: InputDecoration(
                  hintText: 'Ask WiseBot anything...',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  contentPadding: DesignTokens.paddingMD,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusXXL),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            DesignTokens.space8.width,
            FloatingActionButton.small(
              onPressed: _sendMessage,
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              child: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
