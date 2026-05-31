// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicineHistoryAdapter extends TypeAdapter<MedicineHistory> {
  @override
  final int typeId = 1;

  @override
  MedicineHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicineHistory(
      id: fields[0] as String,
      medicineId: fields[1] as String,
      medicineName: fields[2] as String,
      medicineDosage: fields[3] as String,
      medicineType: fields[4] as String,
      takenAt: fields[5] as DateTime,
      notes: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MedicineHistory obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.medicineId)
      ..writeByte(2)
      ..write(obj.medicineName)
      ..writeByte(3)
      ..write(obj.medicineDosage)
      ..writeByte(4)
      ..write(obj.medicineType)
      ..writeByte(5)
      ..write(obj.takenAt)
      ..writeByte(6)
      ..write(obj.notes);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
