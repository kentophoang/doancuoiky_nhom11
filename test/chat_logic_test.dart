import 'package:flutter_test/flutter_test.dart';
import 'package:doancuoiky_test2/models/chat_message.dart';

void main() {
  group('Chat Message Model Tests', () {
    test('ChatMessage should be initialized correctly', () {
      final now = DateTime.now();
      final message = ChatMessage(
        text: 'Hello',
        role: MessageRole.user,
        timestamp: now,
      );

      expect(message.text, 'Hello');
      expect(message.role, MessageRole.user);
      expect(message.timestamp, now);
    });

    test('ChatMessage toJson returns correct map', () {
      final message = ChatMessage(
        text: 'Hi AI',
        role: MessageRole.user,
        timestamp: DateTime.now(),
      );

      final json = message.toJson();
      expect(json['role'], 'user');
      expect(json['content'], 'Hi AI');
    });
  });
}
