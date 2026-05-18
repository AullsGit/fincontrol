// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meta.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MetaAdapter extends TypeAdapter<Meta> {
  @override
  final int typeId = 1;

  @override
  Meta read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Meta(
      id: fields[0] as String?,
      uid: fields[1] as String,
      nome: fields[2] as String,
      valorAlvo: fields[3] as double,
      valorActual: fields[4] as double,
      prazo: fields[5] as DateTime,
      criadaEm: fields[6] as DateTime?,
      sincronizado: fields[7] as bool,
      emoji: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Meta obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.uid)
      ..writeByte(2)
      ..write(obj.nome)
      ..writeByte(3)
      ..write(obj.valorAlvo)
      ..writeByte(4)
      ..write(obj.valorActual)
      ..writeByte(5)
      ..write(obj.prazo)
      ..writeByte(6)
      ..write(obj.criadaEm)
      ..writeByte(7)
      ..write(obj.sincronizado)
      ..writeByte(8)
      ..write(obj.emoji);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
