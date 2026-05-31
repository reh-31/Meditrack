import 'package:intl/intl.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Date/Time Utilities
/// ─────────────────────────────────────────────────────────────────────────────
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('MMM dd, yyyy • hh:mm a');
  static final DateFormat _dayFormat = DateFormat('EEEE');
  static final DateFormat _shortDateFormat = DateFormat('dd MMM');

  /// Format a time string "HH:mm" to "08:30 AM".
  static String formatTimeString(String timeString) {
    try {
      final parts = timeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts.length > 1 ? parts[1] : '0');
      final dt = DateTime(2000, 1, 1, hour, minute);
      return _timeFormat.format(dt);
    } catch (_) {
      return timeString;
    }
  }

  /// Format a DateTime to "08:30 AM".
  static String formatTime(DateTime dt) => _timeFormat.format(dt);

  /// Format a DateTime to "May 31, 2026".
  static String formatDate(DateTime dt) => _dateFormat.format(dt);

  /// Format a DateTime to "May 31, 2026 • 08:30 AM".
  static String formatDateTime(DateTime dt) => _dateTimeFormat.format(dt);

  /// Format a DateTime to "Monday".
  static String formatDay(DateTime dt) => _dayFormat.format(dt);

  /// Format a DateTime to "31 May".
  static String formatShortDate(DateTime dt) => _shortDateFormat.format(dt);

  /// Returns "Today", "Yesterday", or a formatted date.
  static String smartDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final check = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(check).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return formatDate(dt);
  }

  /// Convert a TimeOfDay-like object to a "HH:mm" string.
  static String toTimeString(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Whether two DateTimes fall on the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Group a list of items by date key.
  static Map<String, List<T>> groupByDate<T>(
    List<T> items,
    DateTime Function(T) getDate,
  ) {
    final Map<String, List<T>> grouped = {};
    for (final item in items) {
      final key = smartDate(getDate(item));
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return grouped;
  }
}
