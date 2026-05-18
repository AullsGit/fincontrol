class Dica {
  final String id;
  final String titulo;
  final String descricao;
  final String categoria; // 'poupanca', 'gastos', 'metas', 'geral'
  final String emoji;
  final bool feita;

  const Dica({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.emoji,
    this.feita = false,
  });

  factory Dica.fromMap(Map<String, dynamic> map) {
    return Dica(
      id: map['id'] ?? '',
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'] ?? '',
      categoria: map['categoria'] ?? 'geral',
      emoji: map['emoji'] ?? '💡',
      feita: map['feita'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'categoria': categoria,
      'emoji': emoji,
      'feita': feita,
    };
  }

  Dica copyWith({bool? feita}) {
    return Dica(
      id: id,
      titulo: titulo,
      descricao: descricao,
      categoria: categoria,
      emoji: emoji,
      feita: feita ?? this.feita,
    );
  }
}

// Dicas estáticas padrão
const List<Dica> dicasPadrao = [
  Dica(
    id: 'd1',
    titulo: 'Controle os seus gastos mensais',
    descricao: 'Registe todas as suas despesas diariamente para ter uma visão clara do seu fluxo financeiro.',
    categoria: 'gastos',
    emoji: '📊',
  ),
  Dica(
    id: 'd2',
    titulo: 'Defina metas de poupança',
    descricao: 'Estabeleça objectivos financeiros concretos e monitore o seu progresso regularmente.',
    categoria: 'metas',
    emoji: '🎯',
  ),
  Dica(
    id: 'd3',
    titulo: 'Evite dívidas desnecessárias',
    descricao: 'Antes de fazer uma compra a crédito, pergunte-se se realmente precisa e se pode pagar.',
    categoria: 'gastos',
    emoji: '⚠️',
  ),
  Dica(
    id: 'd4',
    titulo: 'Invista 20% do rendimento',
    descricao: 'Siga a regra 50/30/20: 50% necessidades, 30% desejos e 20% poupança/investimento.',
    categoria: 'poupanca',
    emoji: '📈',
  ),
  Dica(
    id: 'd5',
    titulo: 'Revise o orçamento trimestralmente',
    descricao: 'A cada três meses analise os seus gastos e ajuste o orçamento conforme necessário.',
    categoria: 'geral',
    emoji: '🔄',
  ),
];