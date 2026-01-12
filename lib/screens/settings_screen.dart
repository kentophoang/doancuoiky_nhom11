import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/mood_provider.dart';
import 'mood_tracker_screen.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final moodProvider = Provider.of<MoodProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Giao diện', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('Chế độ tối (Dark Mode)'),
            value: settings.themeMode == ThemeMode.dark,
            onChanged: (value) => settings.toggleTheme(value),
            secondary: Icon(settings.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
          ),
          const Divider(),
          const Text('Sức khỏe & Bảo mật', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ListTile(
            title: const Text('Theo dõi tâm trạng'),
            leading: const Icon(Icons.analytics_outlined, color: Colors.teal),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodTrackerScreen())),
          ),
          SwitchListTile(
            title: const Text('Khóa ứng dụng (PIN/Biometric)'),
            subtitle: const Text('Bảo vệ quyền riêng tư của bạn'),
            value: moodProvider.isAppLocked,
            onChanged: (value) => moodProvider.toggleAppLock(value),
            secondary: const Icon(Icons.lock_outline),
          ),
          const Divider(),
          const Text('Cỡ chữ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Slider(
            value: settings.fontSize,
            min: 12,
            max: 30,
            divisions: 9,
            label: settings.fontSize.round().toString(),
            onChanged: (value) => settings.setFontSize(value),
          ),
          Center(child: Text('Cỡ chữ hiện tại: ${settings.fontSize.round()}', style: TextStyle(fontSize: settings.fontSize))),
          const Divider(height: 40),
          const Text('Tài khoản', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (auth.isLoggedIn)
            ListTile(
              title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
              leading: const Icon(Icons.logout, color: Colors.red),
              onTap: () async {
                await auth.logout();
                if (context.mounted) Navigator.pop(context);
              },
            )
          else
            ListTile(
              title: const Text('Đăng nhập', style: TextStyle(color: Colors.teal)),
              leading: const Icon(Icons.login, color: Colors.teal),
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
        ],
      ),
    );
  }
}
