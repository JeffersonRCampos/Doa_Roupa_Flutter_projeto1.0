import 'package:flutter/material.dart';
import 'package:doa_roupa/modelo/atividade.dart';
import 'package:doa_roupa/banco/roupa_db.dart';
import 'package:doa_roupa/tela/Editaratividade.dart';

class VerTodasAtividades extends StatefulWidget {
  const VerTodasAtividades({super.key});
  @override
  State<VerTodasAtividades> createState() => _VerTodasAtividadesState();
}

class _VerTodasAtividadesState extends State<VerTodasAtividades> {
  final RoupaDatabase _database = RoupaDatabase();
  List<Atividade> atividades = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarAtividades();
  }

  Future<void> _carregarAtividades() async {
    try {
      final todas = await _database.getTodasAtividades();
      final filtradas = todas.where((atividade) {
        return atividade.itens.any((item) => (item['quantidade'] as int) > 0);
      }).toList();
      filtradas.sort((a, b) => a.dataInicio.compareTo(b.dataInicio));
      setState(() {
        atividades = filtradas;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar atividades: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Todas as Atividades',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : atividades.isEmpty
              ? const Center(child: Text('Nenhuma atividade encontrada.'))
              : ListView.builder(
                  itemCount: atividades.length,
                  itemBuilder: (context, index) {
                    final atividade = atividades[index];
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(
                          atividade.titulo,
                          style: const TextStyle(color: Colors.black),
                        ),
                        subtitle: Text(
                          atividade.descricao,
                          style: const TextStyle(color: Colors.black54),
                        ),
                        trailing: const Icon(Icons.edit, color: Colors.black),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditarAtividade(
                                atividadeId: atividade.id!,
                              ),
                            ),
                          );
                          if (result == true) _carregarAtividades();
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
