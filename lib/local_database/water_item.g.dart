// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WaterItemAdapter extends TypeAdapter<WaterItem> {
  @override
  final int typeId = 1;

  @override
  WaterItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WaterItem(
      fields[0] as String,
      fields[1] as int,
      fields[2] as int,
      (fields[3] as List).cast<WaterContainer>(),
    );
  }

  @override
  void write(BinaryWriter writer, WaterItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.userName)
      ..writeByte(1)
      ..write(obj.goal)
      ..writeByte(2)
      ..write(obj.userWeight)
      ..writeByte(3)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WaterItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
