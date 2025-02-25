class Usuario {
  final String id;
  final String nome;
  final String email;
  final String papel;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.papel,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      papel: map['papel'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'papel': papel,
    };
  }
}
