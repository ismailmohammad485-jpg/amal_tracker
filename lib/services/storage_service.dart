import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/day_amal_data.dart';

// SharedPreferences ব্যবহার করে প্রতিটি তারিখের ডেটা লোকালি সেভ/লোড করা হয়
class StorageService {
  static const String _prefix = 'amal_data_';

  static String _dateKey(DateTime date) =>
      '$_prefix${DateFormat('yyyy-MM-dd').format(date)}';

  static Future<DayAmalData> loadDay(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final raw = prefs.getString(_dateKey(date));
    if (raw == null) return DayAmalData.empty(dateStr);
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return DayAmalData.fromJson(dateStr, decoded);
    } catch (_) {
      return DayAmalData.empty(dateStr);
    }
  }

  static Future<void> saveDay(DayAmalData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix${data.date}', jsonEncode(data.toJson()));
  }

  // নির্দিষ্ট মাস ও বছরের সব সেভ করা তথ্য একসাথে লোড করা হয় (মাসিক রিপোর্টের জন্য)
  static Future<List<DayAmalData>> loadMonth(int year, int month) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix));
    final result = <DayAmalData>[];

    for (final k in keys) {
      final dateStr = k.substring(_prefix.length);
      final parts = dateStr.split('-');
      if (parts.length != 3) continue;
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (y == null || m == null) continue;
      if (y == year && m == month) {
        final raw = prefs.getString(k);
        if (raw == null) continue;
        try {
          final decoded = jsonDecode(raw) as Map<String, dynamic>;
          result.add(DayAmalData.fromJson(dateStr, decoded));
        } catch (_) {}
      }
    }
    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }
}
