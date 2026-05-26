class AppConstants {
  
  static const String usersCollection = 'utilizadores';
  static const String gastosCollection = 'gastos';
  static const String metasCollection = 'metas';
  static const String dicasCollection = 'dicas';

  
  static const String gastosBox = 'gastos_box';
  static const String metasBox = 'metas_box';
  static const String pendingBox = 'pending_sync_box';

  
  static const String currency = 'MZN';
  static const String currencySymbol = 'MT';

  
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
