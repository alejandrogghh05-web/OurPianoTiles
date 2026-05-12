import 'package:shared_preferences/shared_preferences.dart';

class RecordService {
  static const _prefix = 'record_';
  static const _completedPrefix = 'completed_';

  static Future<int> getRecord(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_prefix$songId') ?? 0;
  }

  static Future<bool> saveIfRecord(String songId, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('$_prefix$songId') ?? 0;
    if (score > current) {
      await prefs.setInt('$_prefix$songId', score);
      return true;
    }
    return false;
  }

  static Future<void> markCompleted(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_completedPrefix$songId', true);
  }

  static Future<bool> isCompleted(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_completedPrefix$songId') ?? false;
  }
}