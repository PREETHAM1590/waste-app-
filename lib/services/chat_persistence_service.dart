import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';

class ChatPersistenceService {
  static const String _chatHistoryKey = 'wisebot_chat_history';
  static const int _maxStoredMessages = 100; // Limit to prevent storage bloat

  Future<void> saveChatHistory(List<ChatMessage> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Keep only the most recent messages to prevent storage issues
      final messagesToSave = messages.length > _maxStoredMessages 
          ? messages.sublist(messages.length - _maxStoredMessages)
          : messages;
      
      final jsonMessages = messagesToSave.map((message) => {
        'id': message.id,
        'text': message.text,
        'isUser': message.isUser,
        'timestamp': message.timestamp.millisecondsSinceEpoch,
        'quickActions': message.quickActions,
      }).toList();
      
      await prefs.setString(_chatHistoryKey, json.encode(jsonMessages));
    } catch (e) {
      // Fail silently for persistence issues
      // In production, you might want to log this
    }
  }

  Future<List<ChatMessage>> loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_chatHistoryKey);
      
      if (historyJson == null) return [];
      
      final List<dynamic> messagesList = json.decode(historyJson);
      return messagesList.map((msgJson) => ChatMessage(
        id: msgJson['id'],
        text: msgJson['text'],
        isUser: msgJson['isUser'],
        timestamp: DateTime.fromMillisecondsSinceEpoch(msgJson['timestamp']),
        quickActions: msgJson['quickActions']?.cast<String>(),
      )).toList();
    } catch (e) {
      // If loading fails, return empty list
      return [];
    }
  }

  Future<void> clearChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chatHistoryKey);
    } catch (e) {
      // Fail silently
    }
  }

  Future<void> addMessage(ChatMessage message) async {
    final currentHistory = await loadChatHistory();
    currentHistory.add(message);
    await saveChatHistory(currentHistory);
  }
}
