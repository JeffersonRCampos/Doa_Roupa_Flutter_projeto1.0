class Doacao {
  final String? id;
  final String doadorId;
  final String? atividadeId;
  final String tipoRoupa;
  final String genero;
  final String tamanho;
  final int quantidade;
  final bool anonimo;
  final String status;

  Doacao({
    this.id,
    required this.doadorId,
    this.atividadeId,
    required this.tipoRoupa,
    required this.genero,
    required this.tamanho,
    required this.quantidade,
    this.anonimo = false,
    this.status = 'pendente',
  });

  factory Doacao.fromMap(Map<String, dynamic> map) {
    return Doacao(
      id: map['id'],
      doadorId: map['doador_id'] ?? '',
      atividadeId: map['atividade_id'],
      tipoRoupa: map['tipo_roupa'] ?? '',
      genero: map['genero'] ?? '',
      tamanho: map['tamanho'] ?? '',
      quantidade: map['quantidade'] ?? 0,
      anonimo: map['anonimo'] ?? false,
      status: map['status'] ?? 'pendente',
    );
  }

  Map<String, dynamic> toMap() {
    final data = {
      'doador_id': doadorId,
      'atividade_id': atividadeId,
      'tipo_roupa': tipoRoupa,
      'genero': genero,
      'tamanho': tamanho,
      'quantidade': quantidade,
      'anonimo': anonimo,
      'status': status,
    };
    if (id != null && id!.isNotEmpty) {
      data['id'] = id;
    }
    return data;
  }
}
