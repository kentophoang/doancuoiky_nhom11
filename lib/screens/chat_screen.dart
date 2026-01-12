import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/chat_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../models/chat_message.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showScrollButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      final show = _scrollController.offset < _scrollController.position.maxScrollExtent - 200;
      if (show != _showScrollButton) {
        setState(() {
          _showScrollButton = show;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tâm An AI', style: TextStyle(fontWeight: FontWeight.w500)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Chat mới',
            onPressed: () => chatProvider.startNewChat(),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: InkWell(
                  onTap: () {
                    chatProvider.startNewChat();
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 20),
                        SizedBox(width: 8),
                        Text('Cuộc trò chuyện mới', style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Gần đây',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: chatProvider.sessions.length,
                  itemBuilder: (context, index) {
                    final session = chatProvider.sessions[index];
                    final isSelected = chatProvider.currentSession?.id == session.id;
                    
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? (isDark ? Colors.teal.withOpacity(0.2) : Colors.teal.withOpacity(0.1))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        dense: true,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        leading: Icon(
                          Icons.chat_bubble_outline, 
                          size: 18, 
                          color: isSelected ? Colors.teal : (isDark ? Colors.grey[400] : Colors.grey[700])
                        ),
                        title: Text(
                          session.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? Colors.teal : (isDark ? Colors.grey[300] : Colors.black87),
                          ),
                        ),
                        trailing: isSelected ? IconButton(
                          icon: const Icon(Icons.more_vert, size: 18),
                          onPressed: () {
                             _showSessionOptions(context, chatProvider, session.id);
                          },
                        ) : null,
                        onTap: () {
                          chatProvider.switchSession(session.id);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.settings_outlined, size: 22),
                title: const Text('Cài đặt', style: TextStyle(fontSize: 14)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                },
              ),
              if (authProvider.isLoggedIn)
                ListTile(
                  leading: const Icon(Icons.logout, size: 22, color: Colors.redAccent),
                  title: const Text('Đăng xuất', style: TextStyle(fontSize: 14, color: Colors.redAccent)),
                  onTap: () {
                    authProvider.logout();
                  },
                )
              else
                ListTile(
                  leading: const Icon(Icons.login, size: 22, color: Colors.teal),
                  title: const Text('Đăng nhập', style: TextStyle(fontSize: 14, color: Colors.teal)),
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatProvider.messages.isEmpty 
              ? _buildEmptyState(isDark)
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.messages[index];
                    return _ChatBubble(
                      message: message, 
                      fontSize: settings.fontSize,
                      onEdit: (newText) => chatProvider.editMessage(index, newText),
                    );
                  },
                ),
          ),
          if (chatProvider.isTyping)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.teal)),
                    ),
                    SizedBox(width: 12),
                    Text('Tâm An đang suy nghĩ...', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
            ),
          _buildInputArea(chatProvider, isDark),
        ],
      ),
      floatingActionButton: _showScrollButton
          ? FloatingActionButton.small(
              onPressed: _scrollToBottom,
              backgroundColor: isDark ? Colors.grey[800] : Colors.white,
              child: const Icon(Icons.arrow_downward, size: 18),
            )
          : null,
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.psychology_outlined, size: 80, color: Colors.teal.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'Tôi có thể giúp gì cho bạn hôm nay?',
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[700]
            ),
          ),
        ],
      ),
    );
  }

  void _showSessionOptions(BuildContext context, ChatProvider provider, String sessionId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Xóa cuộc trò chuyện', style: TextStyle(color: Colors.red)),
              onTap: () {
                provider.deleteSession(sessionId);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(ChatProvider provider, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.grey[100],
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                maxLines: 5,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSend(provider),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send_rounded, color: _controller.text.isEmpty ? Colors.grey : Colors.teal),
              onPressed: () => _handleSend(provider),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSend(ChatProvider provider) {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      provider.sendMessage(text);
      _controller.clear();
      _scrollToBottom();
    }
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final double fontSize;
  final Function(String) onEdit;

  const _ChatBubble({
    required this.message, 
    required this.fontSize,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isUser ? Colors.blue.shade100 : Colors.teal.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUser ? Icons.person : Icons.auto_awesome, 
              size: 18, 
              color: isUser ? Colors.blue.shade700 : Colors.teal.shade700
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isUser ? 'Bạn' : 'Tâm An AI',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    if (isUser)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
                        onPressed: () => _showEditDialog(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onLongPress: () => _showOptions(context),
                  child: MarkdownBody(
                    data: message.text,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(fontSize: fontSize, height: 1.5, color: isDark ? Colors.grey[200] : Colors.black87),
                      code: TextStyle(
                        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                        fontFamily: 'monospace',
                        fontSize: fontSize - 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm').format(message.timestamp),
                  style: TextStyle(fontSize: 10, color: Colors.grey.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final editController = TextEditingController(text: message.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa tin nhắn'),
        content: TextField(
          controller: editController,
          maxLines: null,
          decoration: const InputDecoration(hintText: "Nhập nội dung mới..."),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (editController.text.trim().isNotEmpty) {
                onEdit(editController.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Lưu & Gửi lại'),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Sao chép tin nhắn'),
            onTap: () {
              Clipboard.setData(ClipboardData(text: message.text));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã sao chép vào bộ nhớ tạm')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Chia sẻ'),
            onTap: () {
              Share.share(message.text);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
