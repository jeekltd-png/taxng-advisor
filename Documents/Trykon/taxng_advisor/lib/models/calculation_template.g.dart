// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calculation_template.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CalculationTemplateAdapter extends TypeAdapter<CalculationTemplate> {
  @override
  final int typeId = 10;

  @override
  CalculationTemplate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CalculationTemplate(
      id: fields[0] as String,
      name: fields[1] as String,
      taxType: fields[2] as String,
      templateData: (fields[3] as Map).cast<String, dynamic>(),
      category: fields[4] as String,
      description: fields[5] as String?,
      createdAt: fields[6] as DateTime,
      lastUsedAt: fields[7] as DateTime?,
      usageCount: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CalculationTemplate obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.taxType)
      ..writeByte(3)
      ..write(obj.templateData)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.lastUsedAt)
      ..writeByte(8)
      ..write(obj.usageCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalculationTemplateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
