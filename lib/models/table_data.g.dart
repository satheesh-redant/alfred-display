// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TableDataAdapter extends TypeAdapter<TableData> {
  @override
  final int typeId = 0;

  @override
  TableData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TableData(
      tableNumber: (fields[0] as num).toInt(),
      posX: (fields[1] as num).toDouble(),
      posY: (fields[2] as num).toDouble(),
      orientation: (fields[3] as num).toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, TableData obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.tableNumber)
      ..writeByte(1)
      ..write(obj.posX)
      ..writeByte(2)
      ..write(obj.posY)
      ..writeByte(3)
      ..write(obj.orientation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
