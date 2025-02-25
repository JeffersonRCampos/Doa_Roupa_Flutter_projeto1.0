class Roupa {
  final int? id;
  String tipoRoupa;
  String genero;
  String tamanho;
  DateTime dataRecebimento;
  String condicao;

  Roupa({
    this.id,
    required this.tipoRoupa,
    required this.genero,
    required this.tamanho,
    required this.dataRecebimento,
    required this.condicao,
  });

  // Função para converter a Roupa em um mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipoRoupa': tipoRoupa,
      'genero': genero,
      'tamanho': tamanho,
      'dataRecebimento': dataRecebimento.toIso8601String(),
      'condicao': condicao,
    };
  }

  // Função para criar uma Roupa a partir de um mapa
  factory Roupa.fromMap(Map<String, dynamic> map) {
    return Roupa(
      id: map['id'],
      tipoRoupa: map['tipoRoupa'],
      genero: map['genero'],
      tamanho: map['tamanho'],
      dataRecebimento: DateTime.parse(map['dataRecebimento']),
      condicao: map['condicao'],
    );
  }
}
