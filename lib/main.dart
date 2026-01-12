import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:local_auth/local_auth.dart';
import 'screens/chat_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'providers/chat_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/mood_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, MoodProvider>(
          create: (_) => MoodProvider(),
          update: (_, auth, mood) {
            mood!.updateUserId(auth.user?.uid);
            return mood;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ChatProvider>(
          create: (_) => ChatProvider(),
          update: (_, auth, chat) {
            chat!.updateUserId(auth.user?.uid);
            return chat;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'Tâm An AI',
          debugShowCheckedModeBanner: false,
          themeMode: settings.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepOrange,
              brightness: Brightness.light,
              surface: const Color(0xFFFFF8F1),
            ),
            scaffoldBackgroundColor: const Color(0xFFFFF8F1),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFFFF8F1),
              elevation: 0,
              centerTitle: true,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepOrange,
              brightness: Brightness.dark,
              surface: const Color(0xFF1C1B17),
            ),
            scaffoldBackgroundColor: const Color(0xFF1C1B17),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1C1B17),
              elevation: 0,
              centerTitle: true,
            ),
          ),
          home: const AppLockWrapper(),
        );
      },
    );
  }
}

class AppLockWrapper extends StatefulWidget {
  const AppLockWrapper({super.key});

  @override
  State<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends State<AppLockWrapper> {
  bool _isAuthenticated = false;
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _checkLock();
  }

  Future<void> _checkLock() async {
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    if (moodProvider.isAppLocked) {
      try {
        final bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Vui lòng xác thực để mở khóa ứng dụng',
          options: const AuthenticationOptions(biometricOnly: false),
        );
        setState(() {
          _isAuthenticated = didAuthenticate;
        });
      } catch (e) {
        setState(() {
          _isAuthenticated = true; 
        });
      }
    } else {
      setState(() {
        _isAuthenticated = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Consumer2<AuthProvider, SettingsProvider>(
      builder: (context, auth, settings, _) {
        if (!auth.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!settings.isOnboardingComplete) {
          return const OnboardingScreen();
        }

        if (auth.isLoggedIn || auth.isGuest) {
          return const ChatScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
