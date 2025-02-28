class Usuario {
  final String id;
  final String nome;
  final String email;
  final String papel;
  final String? genero;
  final int? idade;
  final String? profileUrl; // URL da imagem armazenada no Supabase Storage

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
      profileUrl: map['profile_url'],
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

  // Método para criar um novo objeto com campos atualizados
  Usuario copyWith({
    String? nome,
    String? genero,
    int? idade,
    String? profileUrl,
  }) {
    return Usuario(
      id: id,
      nome: nome ?? this.nome,
      email: email,
      papel: papel,
      genero: genero ?? this.genero,
      idade: idade ?? this.idade,
      profileUrl: profileUrl ?? this.profileUrl,
    );
  }
}
