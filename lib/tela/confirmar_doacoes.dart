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

  // Carrega as doações pendentes do banco de dados
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

  // Confirma uma doação e verifica se a atividade foi concluída
  Future<void> _confirmarDoacao(String id) async {
    await _database.confirmarDoacaoComExcedente(id);
    // Após confirmar a doação, verifica se a atividade vinculada foi concluída
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
      // Se a atividade foi concluída e o popup ainda não foi mostrado, dispara o popup
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

  // Rejeita uma doação e atualiza a lista
  Future<void> _rejeitarDoacao(String id) async {
    await _database.client
        .from('doacoes')
        .update({'status': 'rejeitada'}).eq('id', id);
    _carregarDoacoesPendentes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título da doação (quantidade e tipo de roupa)
                        Text(
                          '${doacao.quantidade}x ${doacao.tipoRoupa}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Detalhes da doação (tamanho, gênero e destino)
                        Text(
                          'Tamanho: ${doacao.tamanho} | Gênero: ${doacao.genero}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Destino: ${doacao.atividadeId ?? "Estoque Geral"}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (doacao.anonimo)
                          const Text(
                            'Doação Anônima',
                            style: TextStyle(
                                fontSize: 14, fontStyle: FontStyle.italic),
                          ),
                        const SizedBox(height: 16),
                        // Botões de confirmação e rejeição
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () => _confirmarDoacao(doacao.id!),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
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
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Rejeitar',
                                style: TextStyle(color: Colors.white),
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
