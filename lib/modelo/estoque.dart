class Estoque {
  final String id;
  final String tipoRoupa;
  final String genero;
  final String tamanho;
  final int quantidade;

  Estoque({
    required this.id,
    required this.tipoRoupa,
    required this.genero,
    required this.tamanho,
    required this.quantidade,
  });

  factory Estoque.fromMap(Map<String, dynamic> map) {
    return Estoque(
      id: map['id'] ?? '',
      tipoRoupa: map['tipo_roupa'] ?? '',
      genero: map['genero'] ?? '',
      tamanho: map['tamanho'] ?? '',
      quantidade: map['quantidade'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo_roupa': tipoRoupa,
      'genero': genero,
      'tamanho': tamanho,
      'quantidade': quantidade,
    };
  }
}
