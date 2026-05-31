import 'package:hive/hive.dart';

part 'medicine_history.g.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// MedicineHistory Model
/// Records every time a medicine was marked as taken.
/// ─────────────────────────────────────────────────────────────────────────────
@HiveType(typeId: 1)
class MedicineHistory extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String medicineId;

  @HiveField(2)
  late String medicineName;

  @HiveField(3)
  late String medicineDosage;

  @HiveField(4)
  late String medicineType;

  @HiveField(5)
  late DateTime takenAt;

  @HiveField(6)
  late String notes;

  MedicineHistory({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.medicineDosage,
    required this.medicineType,
    DateTime? takenAt,
    this.notes = '',
  }) : takenAt = takenAt ?? DateTime.now();

  @override
  String toString() =>
      'MedicineHistory(id: $id, medicineName: $medicineName, takenAt: $takenAt)';
}
