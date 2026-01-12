import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user;
  bool _isLoading = false;
  bool _isGuest = false;
  bool _isInitialized = false;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  bool get isGuest => _isGuest && _user == null;
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    // Lấy user hiện tại ngay lập tức nếu có
    _user = _auth.currentUser;
    
    // Lắng nghe thay đổi trạng thái đăng nhập
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _isInitialized = true;
      if (user != null) {
        _isGuest = false;
      }
      notifyListeners();
    });

    // Sau 2 giây nếu vẫn chưa initialized (hiếm gặp), tự động set true để tránh kẹt màn hình loading
    Future.delayed(const Duration(seconds: 2), () {
      if (!_isInitialized) {
        _isInitialized = true;
        notifyListeners();
      }
    });
  }

  void setGuestMode(bool value) {
    _isGuest = value;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _isGuest = false;
      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    }
  }

  Future<String?> register(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      _isGuest = false;
      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    }
  }

  Future<String?> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return "Đăng nhập bị hủy";
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      _isGuest = false;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return "Lỗi đăng nhập: ${e.toString()}";
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _isGuest = false;
    } catch (e) {
      debugPrint("Lỗi đăng xuất: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
