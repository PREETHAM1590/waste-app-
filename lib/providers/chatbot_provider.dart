import 'package:flutter/material.dart';

/// Provider managing the global floating chatbot widget state and visibility
class ChatbotProvider with ChangeNotifier {
  bool _isVisible = true;
  bool _isExpanded = false;
  Offset _position = const Offset(0.85, 0.75); // Relative position (0-1)
  
  // Screen names where chatbot should be hidden
  final Set<String> _hiddenScreens = {
    'WiseBotScreen',
    'ChatScreen', 
    'ConversationScreen',
  };
  
  // Current screen name for visibility control
  String _currentScreen = '';
  
  /// Whether the floating chatbot is currently visible
  bool get isVisible => _isVisible && !_hiddenScreens.contains(_currentScreen);
  
  /// Whether the chatbot is in expanded state
  bool get isExpanded => _isExpanded;
  
  /// Current position of the floating widget (relative coordinates)
  Offset get position => _position;
  
  /// Current screen name
  String get currentScreen => _currentScreen;
  
  /// Update current screen and adjust visibility
  void setCurrentScreen(String screenName) {
    _currentScreen = screenName;
    notifyListeners();
  }
  
  /// Show the floating chatbot
  void show() {
    _isVisible = true;
    notifyListeners();
  }
  
  /// Hide the floating chatbot
  void hide() {
    _isVisible = false;
    notifyListeners();
  }
  
  /// Toggle chatbot visibility
  void toggleVisibility() {
    _isVisible = !_isVisible;
    notifyListeners();
  }
  
  /// Expand the chatbot (show preview or quick actions)
  void expand() {
    _isExpanded = true;
    notifyListeners();
  }
  
  /// Collapse the chatbot to minimal state
  void collapse() {
    _isExpanded = false;
    notifyListeners();
  }
  
  /// Toggle expanded state
  void toggleExpansion() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }
  
  /// Update position of the floating widget
  void updatePosition(Offset newPosition) {
    _position = newPosition;
    notifyListeners();
  }
  
  /// Snap position to edges for better UX
  void snapToEdge(Size screenSize) {
    final x = _position.dx < 0.5 ? 0.05 : 0.85; // Snap to left or right edge
    final y = _position.dy.clamp(0.15, 0.85); // Keep within safe area
    
    _position = Offset(x, y);
    notifyListeners();
  }
}
