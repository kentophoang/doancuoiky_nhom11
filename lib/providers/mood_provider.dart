import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood_entry.dart';

class MoodProvider with ChangeNotifier {
  List<MoodEntry> _entries = [];
  bool _isAppLocked = false;
  String? _userId;

  List<MoodEntry> get entries => _entries;
  bool get isAppLocked => _isAppLocked;

  MoodProvider() {
    // Không gọi load ở đây
  }

  void updateUserId(String? newUserId) {
    if (_userId != newUserId) {
      _userId = newUserId;
      _loadData();
    }
  }

  String get _moodKey => _userId != null ? 'mood_entries_$_userId' : 'mood_entries_guest';
  String get _lockKey => _userId != null ? 'app_locked_$_userId' : 'app_locked_guest';

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? entriesJson = prefs.getString(_moodKey);
    if (entriesJson != null) {
      final List<dynamic> decoded = jsonDecode(entriesJson);
      _entries = decoded.map((e) => MoodEntry.fromJson(e)).toList();
    } else {
      _entries = [];
    }
    _isAppLocked = prefs.getBool(_lockKey) ?? false;
    notifyListeners();
  }

  Future<void> addMood(String mood, int value) async {
    final newEntry = MoodEntry(date: DateTime.now(), mood: mood, value: value);
    _entries.add(newEntry);
    notifyListeners();
    _saveData();
  }

  Future<void> toggleAppLock(bool value) async {
    _isAppLocked = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lockKey, value);
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString(_moodKey, encoded);
  }
}
