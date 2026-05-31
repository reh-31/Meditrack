import 'package:hive_flutter/hive_flutter.dart';
import '../models/medicine.dart';
import '../models/medicine_history.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// HiveService
/// Single source of truth for all Hive database operations.
/// Call [HiveService.init()] once in main() before runApp().
/// ─────────────────────────────────────────────────────────────────────────────
class HiveService {
  HiveService._();

  static const String _medicineBoxName = 'medicines';
  static const String _historyBoxName = 'medicine_history';

  static late Box<Medicine> _medicineBox;
  static late Box<MedicineHistory> _historyBox;

  /// Initialize Hive: register adapters and open boxes.
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register TypeAdapters (generated)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MedicineAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(MedicineHistoryAdapter());
    }

    _medicineBox = await Hive.openBox<Medicine>(_medicineBoxName);
    _historyBox = await Hive.openBox<MedicineHistory>(_historyBoxName);
  }

  // ──────────────────────────── Medicine CRUD ────────────────────────────────

  /// Return all medicines sorted by creation date (newest first).
  static List<Medicine> getAllMedicines() {
    final medicines = _medicineBox.values.toList();
    medicines.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return medicines;
  }

  /// Add a new medicine and return it.
  static Future<void> addMedicine(Medicine medicine) async {
    await _medicineBox.put(medicine.id, medicine);
  }

  /// Update an existing medicine in place.
  static Future<void> updateMedicine(Medicine medicine) async {
    await _medicineBox.put(medicine.id, medicine);
  }

  /// Delete a medicine by its unique ID.
  static Future<void> deleteMedicine(String id) async {
    await _medicineBox.delete(id);
  }

  /// Get a medicine by ID. Returns null if not found.
  static Medicine? getMedicineById(String id) {
    return _medicineBox.get(id);
  }

  // ──────────────────────────── History CRUD ────────────────────────────────

  /// Return all history records sorted by most recent first.
  static List<MedicineHistory> getAllHistory() {
    final history = _historyBox.values.toList();
    history.sort((a, b) => b.takenAt.compareTo(a.takenAt));
    return history;
  }

  /// Add a history entry.
  static Future<void> addHistory(MedicineHistory entry) async {
    await _historyBox.put(entry.id, entry);
  }

  /// Delete a history entry by ID.
  static Future<void> deleteHistory(String id) async {
    await _historyBox.delete(id);
  }

  /// Return history filtered to a specific date.
  static List<MedicineHistory> getHistoryForDate(DateTime date) {
    return _historyBox.values.where((h) {
      return h.takenAt.year == date.year &&
          h.takenAt.month == date.month &&
          h.takenAt.day == date.day;
    }).toList()
      ..sort((a, b) => b.takenAt.compareTo(a.takenAt));
  }

  /// Count doses taken this week (Mon–Sun).
  static int getWeeklyDoseCount() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek =
        DateTime(monday.year, monday.month, monday.day);
    return _historyBox.values
        .where((h) => h.takenAt.isAfter(startOfWeek))
        .length;
  }

  /// Count doses taken today.
  static int getTodayDoseCount() {
    final now = DateTime.now();
    return _historyBox.values
        .where((h) =>
            h.takenAt.year == now.year &&
            h.takenAt.month == now.month &&
            h.takenAt.day == now.day)
        .length;
  }

  /// Close all open boxes (call on app dispose).
  static Future<void> closeAll() async {
    await _medicineBox.close();
    await _historyBox.close();
  }
}
