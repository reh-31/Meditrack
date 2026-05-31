import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/medicine.dart';
import '../models/medicine_history.dart';
import '../database/hive_service.dart';
import '../services/notification_service.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// MedicineProvider
/// Central state manager for all medicine data and operations.
/// Uses ChangeNotifier (Provider) for reactive UI updates.
/// ─────────────────────────────────────────────────────────────────────────────
class MedicineProvider extends ChangeNotifier {
  final Uuid _uuid = const Uuid();

  // ───────────────────────────── State ─────────────────────────────────────

  List<Medicine> _medicines = [];
  List<MedicineHistory> _history = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  // ───────────────────────────── Getters ───────────────────────────────────

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  /// All medicines, optionally filtered by search query.
  List<Medicine> get medicines {
    if (_searchQuery.isEmpty) return List.unmodifiable(_medicines);
    final query = _searchQuery.toLowerCase();
    return _medicines
        .where((m) =>
            m.name.toLowerCase().contains(query) ||
            m.type.toLowerCase().contains(query) ||
            m.dosage.toLowerCase().contains(query))
        .toList();
  }

  /// All history records.
  List<MedicineHistory> get history => List.unmodifiable(_history);

  /// History filtered by a specific date.
  List<MedicineHistory> historyForDate(DateTime date) {
    return _history
        .where((h) =>
            h.takenAt.year == date.year &&
            h.takenAt.month == date.month &&
            h.takenAt.day == date.day)
        .toList();
  }

  /// Count of doses taken today.
  int get todayDoseCount => HiveService.getTodayDoseCount();

  /// Count of doses taken this week.
  int get weeklyDoseCount => HiveService.getWeeklyDoseCount();

  /// Total all-time doses.
  int get totalDoseCount => _history.length;

  // ───────────────────────────── Initialization ─────────────────────────────

  /// Load all data from Hive on startup.
  Future<void> loadData() async {
    _setLoading(true);
    try {
      _medicines = HiveService.getAllMedicines();
      _history = HiveService.getAllHistory();
      _error = null;
    } catch (e) {
      _error = 'Failed to load medicines: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  // ───────────────────────────── Medicine CRUD ──────────────────────────────

  /// Add a new medicine and schedule its notification.
  Future<void> addMedicine({
    required String name,
    required String dosage,
    required String type,
    required String reminderTime,
    required String frequency,
    String notes = '',
  }) async {
    try {
      final medicine = Medicine(
        id: _uuid.v4(),
        name: name.trim(),
        dosage: dosage.trim(),
        type: type,
        reminderTime: reminderTime,
        frequency: frequency,
        notes: notes.trim(),
      );

      await HiveService.addMedicine(medicine);
      await NotificationService.scheduleMedicineReminder(medicine);

      _medicines.insert(0, medicine);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add medicine: $e';
      debugPrint(_error);
      rethrow;
    }
  }

  /// Update an existing medicine and reschedule its notification.
  Future<void> updateMedicine(Medicine updated) async {
    try {
      await HiveService.updateMedicine(updated);
      await NotificationService.scheduleMedicineReminder(updated);

      final index = _medicines.indexWhere((m) => m.id == updated.id);
      if (index != -1) {
        _medicines[index] = updated;
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update medicine: $e';
      debugPrint(_error);
      rethrow;
    }
  }

  /// Delete a medicine and cancel its notification.
  Future<void> deleteMedicine(String id) async {
    try {
      await HiveService.deleteMedicine(id);
      await NotificationService.cancelMedicineReminder(id);

      _medicines.removeWhere((m) => m.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete medicine: $e';
      debugPrint(_error);
      rethrow;
    }
  }

  // ───────────────────────────── Mark as Taken ─────────────────────────────

  /// Record that a medicine was taken right now.
  Future<void> markAsTaken(Medicine medicine) async {
    try {
      final history = MedicineHistory(
        id: _uuid.v4(),
        medicineId: medicine.id,
        medicineName: medicine.name,
        medicineDosage: medicine.dosage,
        medicineType: medicine.type,
        takenAt: DateTime.now(),
      );

      await HiveService.addHistory(history);

      // Update lastTakenAt on medicine
      final updated = medicine.copyWith(lastTakenAt: DateTime.now());
      await HiveService.updateMedicine(updated);

      final index = _medicines.indexWhere((m) => m.id == medicine.id);
      if (index != -1) _medicines[index] = updated;

      _history.insert(0, history);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to mark as taken: $e';
      debugPrint(_error);
      rethrow;
    }
  }

  // ───────────────────────────── Search ────────────────────────────────────

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // ───────────────────────────── Private ───────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
