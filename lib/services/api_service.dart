import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class ApiService {

  Future<String> getChatResponse(List<ChatMessage> history) async {
    try {
      final url = Uri.parse('https://julissa-supersignificant-onie.ngrok-free.dev/chat');

      // Chỉ gửi tin nhắn cuối cùng làm câu hỏi
      final question = history.last.text;

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "question": question,
        }),
      ).timeout(const Duration(seconds: 200));

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        // Server có thể trả về key là 'response' hoặc 'response_j'
        return data['response'] ?? data['response_j'] ?? "Không có phản hồi từ AI";
      } else {
        final decodedBody = utf8.decode(response.bodyBytes);
        try {
          final errorData = jsonDecode(decodedBody);
          return "Lỗi server: ${response.statusCode} - ${errorData['message'] ?? decodedBody}";
        } catch (e) {
          return "Lỗi server: ${response.statusCode} - $decodedBody";
        }
      }
    } on TimeoutException {
      return "Lỗi: Máy chủ AI phản hồi quá lâu (Timeout).";
    } catch (e) {
      return "Lỗi kết nối: ${e.toString()}";
    }
  }
}
