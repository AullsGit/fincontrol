import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'gasto.g.dart';

@HiveType(typeId: 0)
class Gasto extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String uid; // user id

  @HiveField(2)
  final double valor;

  @HiveField(3)
  final String categoria;

  @HiveField(4)
  final String descricao;

  @HiveField(5)
  final DateTime data;

  @HiveField(6)
  final bool ehDespesa; // true = despesa, false = rendimento

  @HiveField(7)
  final String? fonte; // para rendimentos

  @HiveField(8)
  bool sincronizado;

  Gasto({
    String? id,
    required this.uid,
    required this.valor,
    required this.categoria,
    required this.descricao,
    required this.data,
    required this.ehDespesa,
    this.fonte,
    this.sincronizado = false,
  }) : id = id ?? const Uuid().v4();

  factory Gasto.fromMap(Map<String, dynamic> map) {
    return Gasto(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      valor: (map['valor'] as num).toDouble(),
      categoria: map['categoria'] ?? '',
      descricao: map['descricao'] ?? '',
      data: DateTime.fromMillisecondsSinceEpoch(map['data']),
      ehDespesa: map['ehDespesa'] ?? true,
      fonte: map['fonte'],
      sincronizado: true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'valor': valor,
      'categoria': categoria,
      'descricao': descricao,
      'data': data.millisecondsSinceEpoch,
      'ehDespesa': ehDespesa,
      'fonte': fonte,
    };
  }

  Gasto copyWith({bool? sincronizado}) {
    return Gasto(
      id: id,
      uid: uid,
      valor: valor,
      categoria: categoria,
      descricao: descricao,
      data: data,
      ehDespesa: ehDespesa,
      fonte: fonte,
      sincronizado: sincronizado ?? this.sincronizado,
    );
  }
}