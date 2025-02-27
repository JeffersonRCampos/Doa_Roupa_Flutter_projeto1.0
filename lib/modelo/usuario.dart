class Usuario {
  final String id;
  final String nome;
  final String email;
  final String papel;
  final String? genero; // Pode ser null
  final int? idade; // Pode ser null
  final String? profileUrl; // Nova imagem de perfil (URL)

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.papel,
    this.genero,
    this.idade,
    this.profileUrl,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      papel: map['papel'] ?? 'doador',
      genero: map['genero'],
      idade: map['idade'],
      profileUrl: map['profile_url'], // coluna no banco: profile_url
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'papel': papel,
      'genero': genero,
      'idade': idade,
      'profile_url': profileUrl,
    };
  }
}
