import 'package:flutter/material.dart';
import 'package:doa_roupa/banco/roupa_db.dart';
import 'package:doa_roupa/modelo/doacao.dart';
import 'package:doa_roupa/tela/agradecimento.dart';

class ConfirmarDoacoes extends StatefulWidget {
  const ConfirmarDoacoes({super.key});

  @override
  State<ConfirmarDoacoes> createState() => _ConfirmarDoacoesState();
}

class _ConfirmarDoacoesState extends State<ConfirmarDoacoes> {
  final RoupaDatabase _database = RoupaDatabase();
  List<Doacao> doacoesPendentes = [];
  bool _popupShown = false;

  @override
  void initState() {
    super.initState();
    _carregarDoacoesPendentes();
  }

  Future<void> _carregarDoacoesPendentes() async {
    final response = await _database.client
        .from('doacoes')
        .select('*')
        .eq('status', 'pendente');
    setState(() {
      doacoesPendentes =
          (response as List).map((d) => Doacao.fromMap(d)).toList();
    });
  }

  Future<void> _confirmarDoacao(String id) async {
    await _database.confirmarDoacaoComExcedente(id);
    final doacaoResponse = await _database.client
        .from('doacoes')
        .select('*')
        .eq('id', id)
        .single();
    final doacao = Doacao.fromMap(doacaoResponse);

    if (doacao.atividadeId != null) {
      final atividadeResponse = await _database.client
          .from('atividades')
          .select('status, titulo')
          .eq('id', doacao.atividadeId!)
          .single();

      if (atividadeResponse['status'] == 'concluída' && !_popupShown) {
        final contribuintes =
            await _database.obterContribuintes(doacao.atividadeId!);
        if (contribuintes.isNotEmpty) {
          _popupShown = true;
          showDialog(
            context: context,
            builder: (_) => AgradecimentoAtividadePopup(
              atividadeTitulo: atividadeResponse['titulo'],
              nomesContribuintes: contribuintes,
            ),
          );
        }
      }
    }
    _carregarDoacoesPendentes();
  }

  Future<void> _rejeitarDoacao(String id) async {
    await _database.client
        .from('doacoes')
        .update({'status': 'rejeitada'}).eq('id', id);
    _carregarDoacoesPendentes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Confirmar Doações',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: doacoesPendentes.isEmpty
          ? const Center(child: Text('Nenhuma doação pendente.'))
          : ListView.builder(
              itemCount: doacoesPendentes.length,
              itemBuilder: (context, index) {
                final doacao = doacoesPendentes[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  shadowColor: Colors.black,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${doacao.quantidade}x ${doacao.tipoRoupa}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tamanho: ${doacao.tamanho} | Gênero: ${doacao.genero}',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                        ),
                        Text(
                          'Destino: ${doacao.atividadeId ?? "Estoque Geral"}',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                        ),
                        if (doacao.anonimo)
                          const Text(
                            'Doação Anônima',
                            style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.black),
                          ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () => _confirmarDoacao(doacao.id!),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Confirmar',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () => _rejeitarDoacao(doacao.id!),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Rejeitar',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
