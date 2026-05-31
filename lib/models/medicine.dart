import 'package:hive/hive.dart';

part 'medicine.g.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Medicine Model
/// Hive TypeAdapter with typeId 0. Stores all medicine details and schedule.
/// ─────────────────────────────────────────────────────────────────────────────
@HiveType(typeId: 0)
class Medicine extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String dosage;

  @HiveField(3)
  late String type; // Tablet | Capsule | Syrup | Injection | Drops | Cream | Other

  @HiveField(4)
  late String reminderTime; // Stored as "HH:mm" 24-hour string

  @HiveField(5)
  late String frequency; // daily | twice_daily | thrice_daily | weekly

  @HiveField(6)
  late String notes;

  @HiveField(7)
  late bool isActive;

  @HiveField(8)
  late DateTime createdAt;

  @HiveField(9)
  late DateTime? lastTakenAt;

  /// Constructor for creating a new Medicine instance.
  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.type,
    required this.reminderTime,
    required this.frequency,
    this.notes = '',
    this.isActive = true,
    DateTime? createdAt,
    this.lastTakenAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Returns a copy of this medicine with given fields replaced.
  Medicine copyWith({
    String? id,
    String? name,
    String? dosage,
    String? type,
    String? reminderTime,
    String? frequency,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastTakenAt,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      type: type ?? this.type,
      reminderTime: reminderTime ?? this.reminderTime,
      frequency: frequency ?? this.frequency,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastTakenAt: lastTakenAt ?? this.lastTakenAt,
    );
  }

  /// Convert reminderTime string "HH:mm" to hour and minute ints.
  Map<String, int> get timeComponents {
    final parts = reminderTime.split(':');
    return {
      'hour': int.tryParse(parts[0]) ?? 8,
      'minute': int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    };
  }

  /// Human-readable frequency label.
  String get frequencyLabel {
    switch (frequency) {
      case 'twice_daily':
        return 'Twice Daily';
      case 'thrice_daily':
        return 'Thrice Daily';
      case 'weekly':
        return 'Weekly';
      default:
        return 'Once Daily';
    }
  }

  /// Whether this medicine was taken today.
  bool get takenToday {
    if (lastTakenAt == null) return false;
    final now = DateTime.now();
    return lastTakenAt!.year == now.year &&
        lastTakenAt!.month == now.month &&
        lastTakenAt!.day == now.day;
  }

  @override
  String toString() =>
      'Medicine(id: $id, name: $name, dosage: $dosage, type: $type)';
}
