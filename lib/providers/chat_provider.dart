import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';

class ChatSession {
  final String id;
  String title;
  final List<ChatMessage> messages;

  ChatSession({required this.id, required this.title, required this.messages});

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'messages': messages.map((m) => m.toJson()).toList(),
      };

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      title: json['title'],
      messages: (json['messages'] as List)
          .map((m) => ChatMessage.fromJson(m))
          .toList(),
    );
  }
}

class ChatProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<ChatSession> _sessions = [];
  String? _currentSessionId;
  bool _isTyping = false;
  String? _userId;

  List<ChatSession> get sessions => _sessions;
  bool get isTyping => _isTyping;
  bool get isGuest => _userId == null;
  
  ChatSession? get currentSession => 
      _sessions.isEmpty ? null : (_currentSessionId == null ? _sessions.first : _sessions.firstWhere((s) => s.id == _currentSessionId, 
      orElse: () => _sessions.first));

  List<ChatMessage> get messages => currentSession?.messages ?? [];

  String? get _storageKey => _userId != null ? 'chat_sessions_$_userId' : null;

  void updateUserId(String? newUserId) {
    if (_userId != newUserId) {
      _userId = newUserId;
      _loadSessions();
    }
  }

  Future<void> _loadSessions() async {
    if (_storageKey == null) {
      _sessions = [];
      _createNewSession();
      notifyListeners();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getStringList(_storageKey!);
    
    if (sessionsJson != null && sessionsJson.isNotEmpty) {
      _sessions = sessionsJson
          .map((s) => ChatSession.fromJson(jsonDecode(s)))
          .toList();
      _currentSessionId = _sessions.first.id;
    } else {
      _sessions = [];
      _createNewSession();
    }
    notifyListeners();
  }

  Future<void> _saveSessions() async {
    if (_storageKey == null) return;

    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = _sessions.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_storageKey!, sessionsJson);
  }

  void _createNewSession() {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final newSession = ChatSession(
      id: newId,
      title: 'Cuộc trò chuyện mới',
      messages: [],
    );
    
    if (isGuest) {
      _sessions = [newSession];
    } else {
      _sessions.insert(0, newSession);
    }
    
    _currentSessionId = newId;
    _saveSessions();
    notifyListeners();
  }

  void switchSession(String id) {
    _currentSessionId = id;
    notifyListeners();
  }

  void startNewChat() {
    _createNewSession();
  }

  void deleteSession(String id) {
    _sessions.removeWhere((s) => s.id == id);
    if (_sessions.isEmpty) {
      _createNewSession();
    } else {
      if (_currentSessionId == id) {
        _currentSessionId = _sessions.first.id;
      }
    }
    _saveSessions();
    notifyListeners();
  }

  Future<void> editMessage(int index, String newText) async {
    if (currentSession == null || index >= currentSession!.messages.length) return;

    final message = currentSession!.messages[index];
    final isUser = message.role == MessageRole.user;

    // Cập nhật nội dung tin nhắn
    currentSession!.messages[index] = ChatMessage(
      text: newText,
      role: message.role,
      timestamp: message.timestamp,
    );

    // Nếu là tin nhắn đầu tiên, cập nhật lại tiêu đề session
    if (index == 0 && isUser) {
      currentSession!.title = newText.length > 30 ? '${newText.substring(0, 30)}...' : newText;
    }

    // Nếu sửa tin nhắn của user, xóa các tin nhắn AI phía sau và tạo phản hồi mới
    if (isUser) {
      currentSession!.messages.removeRange(index + 1, currentSession!.messages.length);
      notifyListeners();
      
      _isTyping = true;
      notifyListeners();

      try {
        final response = await _apiService.getChatResponse(currentSession!.messages);
        final aiMessage = ChatMessage(
          text: response,
          role: MessageRole.assistant,
          timestamp: DateTime.now(),
        );
        currentSession!.messages.add(aiMessage);
      } catch (e) {
        currentSession!.messages.add(ChatMessage(
          text: 'Lỗi: $e',
          role: MessageRole.assistant,
          timestamp: DateTime.now(),
        ));
      } finally {
        _isTyping = false;
        _saveSessions();
        notifyListeners();
      }
    } else {
      _saveSessions();
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || currentSession == null) return;

    final userMessage = ChatMessage(
      text: text,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    if (currentSession!.messages.isEmpty) {
      currentSession!.title = text.length > 30 ? '${text.substring(0, 30)}...' : text;
    }

    currentSession!.messages.add(userMessage);
    _isTyping = true;
    notifyListeners();
    _saveSessions();

    try {
      final response = await _apiService.getChatResponse(currentSession!.messages);
      
      final aiMessage = ChatMessage(
        text: response,
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
      );
      
      currentSession!.messages.add(aiMessage);
    } catch (e) {
      currentSession!.messages.add(ChatMessage(
        text: 'Lỗi: $e',
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
      ));
    } finally {
      _isTyping = false;
      _saveSessions();
      notifyListeners();
    }
  }

  void clearChat() {
    if (currentSession != null) {
      currentSession!.messages.clear();
      _saveSessions();
      notifyListeners();
    }
  }
}
