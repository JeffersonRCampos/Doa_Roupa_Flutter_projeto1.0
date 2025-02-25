import 'package:intl/intl.dart';

class Atividade {
  final String? id;
  final String tipo;
  final String titulo;
  final String descricao;
  final List<Map<String, dynamic>> itens;
  final DateTime dataInicio;
  final DateTime dataFim;
  final String status;

  Atividade({
    this.id,
    required this.tipo,
    required this.titulo,
    required this.descricao,
    required this.itens,
    required this.dataInicio,
    required this.dataFim,
    this.status = 'em andamento',
  });

  factory Atividade.fromMap(Map<String, dynamic> map) {
    return Atividade(
      id: map['id'] ?? '',
      tipo: map['tipo'] ?? '',
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'] ?? '',
      itens: List<Map<String, dynamic>>.from(map['itens'] ?? []),
      dataInicio: DateTime.parse(map['data_inicio']),
      dataFim: DateTime.parse(map['data_fim']),
      status: map['status'] ?? 'em andamento',
    );
  }

  Map<String, dynamic> toMap() {
    final dbDateFormat = DateFormat('yyyy-MM-dd');
    return {
      'tipo': tipo,
      'titulo': titulo,
      'descricao': descricao,
      'itens': itens,
      'data_inicio': dbDateFormat.format(dataInicio),
      'data_fim': dbDateFormat.format(dataFim),
      'status': status,
    };
  }
}
