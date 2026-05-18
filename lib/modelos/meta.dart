import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'meta.g.dart';

@HiveType(typeId: 1)
class Meta extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String uid;

  @HiveField(2)
  final String nome;

  @HiveField(3)
  final double valorAlvo;

  @HiveField(4)
  double valorActual;

  @HiveField(5)
  final DateTime prazo;

  @HiveField(6)
  final DateTime criadaEm;

  @HiveField(7)
  bool sincronizado;

  @HiveField(8)
  final String? emoji;

  Meta({
    String? id,
    required this.uid,
    required this.nome,
    required this.valorAlvo,
    this.valorActual = 0,
    required this.prazo,
    DateTime? criadaEm,
    this.sincronizado = false,
    this.emoji,
  })  : id = id ?? const Uuid().v4(),
        criadaEm = criadaEm ?? DateTime.now();

  double get progresso =>
      valorAlvo > 0 ? (valorActual / valorAlvo).clamp(0.0, 1.0) : 0;

  double get percentagem => progresso * 100;

  int get diasRestantes => prazo.difference(DateTime.now()).inDays;

  double get valorDiarioNecessario {
    if (diasRestantes <= 0) return 0;
    final restante = valorAlvo - valorActual;
    if (restante <= 0) return 0;
    return restante / diasRestantes;
  }

  bool get concluida => valorActual >= valorAlvo;

  factory Meta.fromMap(Map<String, dynamic> map) {
    return Meta(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      nome: map['nome'] ?? '',
      valorAlvo: (map['valorAlvo'] as num).toDouble(),
      valorActual: (map['valorActual'] as num? ?? 0).toDouble(),
      prazo: DateTime.fromMillisecondsSinceEpoch(map['prazo']),
      criadaEm: map['criadaEm'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['criadaEm'])
          : DateTime.now(),
      sincronizado: true,
      emoji: map['emoji'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'nome': nome,
      'valorAlvo': valorAlvo,
      'valorActual': valorActual,
      'prazo': prazo.millisecondsSinceEpoch,
      'criadaEm': criadaEm.millisecondsSinceEpoch,
      'emoji': emoji,
    };
  }
}
