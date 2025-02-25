class Contribuicao {
  final String id;
  final String doadorId;
  final String? atividadeId;
  final int valor;
  final DateTime dataContribuicao;

  Contribuicao({
    required this.id,
    required this.doadorId,
    this.atividadeId,
    required this.valor,
    required this.dataContribuicao,
  });

  factory Contribuicao.fromMap(Map<String, dynamic> map) {
    return Contribuicao(
      id: map['id'] ?? '',
      doadorId: map['doador_id'] ?? '',
      atividadeId: map['atividade_id'],
      valor: map['valor'] ?? 0,
      dataContribuicao: DateTime.parse(map['data_contribuicao']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doador_id': doadorId,
      'atividade_id': atividadeId as Object?, // Cast para evitar erros
      'valor': valor,
      'data_contribuicao': dataContribuicao.toIso8601String(),
    };
  }
}
