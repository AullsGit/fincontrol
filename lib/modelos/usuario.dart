class Usuario {
  final String uid;
  final String nomeCompleto;
  final String email;
  final String? fotoUrl;
  final String moedaPreferida;
  final DateTime criadoEm;

  const Usuario({
    required this.uid,
    required this.nomeCompleto,
    required this.email,
    this.fotoUrl,
    this.moedaPreferida = 'MZN',
    required this.criadoEm,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      uid: map['uid'] ?? '',
      nomeCompleto: map['nomeCompleto'] ?? '',
      email: map['email'] ?? '',
      fotoUrl: map['fotoUrl'],
      moedaPreferida: map['moedaPreferida'] ?? 'MZN',
      criadoEm: map['criadoEm'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['criadoEm'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nomeCompleto': nomeCompleto,
      'email': email,
      'fotoUrl': fotoUrl,
      'moedaPreferida': moedaPreferida,
      'criadoEm': criadoEm.millisecondsSinceEpoch,
    };
  }

  Usuario copyWith({
    String? nomeCompleto,
    String? fotoUrl,
    String? moedaPreferida,
  }) {
    return Usuario(
      uid: uid,
      nomeCompleto: nomeCompleto ?? this.nomeCompleto,
      email: email,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      moedaPreferida: moedaPreferida ?? this.moedaPreferida,
      criadoEm: criadoEm,
    );
  }
}