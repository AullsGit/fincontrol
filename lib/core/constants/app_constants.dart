class AppConstants {
  // Firebase Collections
  static const String usersCollection = 'utilizadores';
  static const String gastosCollection = 'gastos';
  static const String metasCollection = 'metas';
  static const String dicasCollection = 'dicas';

  // Hive Boxes
  static const String gastosBox = 'gastos_box';
  static const String metasBox = 'metas_box';
  static const String pendingBox = 'pending_sync_box';

  // Currency
  static const String currency = 'MZN';
  static const String currencySymbol = 'MT';

  // Categorias de Despesas
  static const List<String> categoriasDespesas = [
    'Mercearia',
    'Renda',
    'Serviços',
    'Transporte',
    'Lazer',
    'Saúde',
    'Educação',
    'Restaurante',
    'Roupa',
    'Outros',
  ];

  static const List<String> fontesRendimento = [
    'Salário',
    'Freelance',
    'Negócio',
    'Investimento',
    'Presente',
    'Outros',
  ];

  // Category Icons mapping
  static const Map<String, String> categoryEmojis = {
    'Mercearia': '🛒',
    'Renda': '🏠',
    'Serviços': '⚡',
    'Transporte': '🚌',
    'Lazer': '🎉',
    'Saúde': '💊',
    'Educação': '📚',
    'Restaurante': '🍽️',
    'Roupa': '👗',
    'Outros': '📦',
    'Salário': '💼',
    'Freelance': '💻',
    'Negócio': '🏪',
    'Investimento': '📈',
    'Presente': '🎁',
  };
}