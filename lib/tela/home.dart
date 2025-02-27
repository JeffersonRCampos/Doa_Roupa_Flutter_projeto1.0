import 'package:doa_roupa/tela/agradecimento.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doa_roupa/modelo/atividade.dart';
import 'package:doa_roupa/tela/criar_atividade.dart';
import 'package:doa_roupa/tela/doacao.dart';
import 'package:doa_roupa/tela/estoque.dart';
import 'package:doa_roupa/tela/confirmar_doacoes.dart';
import 'package:doa_roupa/banco/roupa_db.dart';
import 'package:doa_roupa/tela/login.dart';
import 'package:doa_roupa/tela/EditarPerfil.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final SupabaseClient client = Supabase.instance.client;
  final RoupaDatabase _database = RoupaDatabase();

  // Lista de atividades (todos os registros)
  List<Atividade> atividades = [];
  String? papelUsuario;
  String? userId;
  bool _popupShown = false;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
    _carregarAtividades();
  }

  // Carrega os dados do usuário logado (ID e papel)
  Future<void> _carregarDadosUsuario() async {
    final currentUser = client.auth.currentUser;
    if (currentUser != null) {
      userId = currentUser.id;
      final response = await client
          .from('usuarios')
          .select('papel')
          .eq('id', userId!)
          .single();
      setState(() {
        papelUsuario = response['papel'] as String?;
      });
    }
  }

  // Carrega as atividades com status "em andamento"
  Future<void> _carregarAtividades() async {
    try {
      final response = await _database.getAtividadesAtivas();
      setState(() {
        atividades = response;
        _popupShown = false;
      });
      _checkConcludedActivities();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar atividades: $e')),
      );
    }
  }

  // Verifica as atividades concluídas e exibe o pop-up para a última atividade em que o usuário contribuiu
  Future<void> _checkConcludedActivities() async {
    final todasAtividades = await _database.getTodasAtividades();
    // Filtra atividades concluídas
    final concluidas = todasAtividades
        .where((atividade) => atividade.status == 'concluída')
        .toList();
    if (concluidas.isEmpty || userId == null) return;

    // Ordena as atividades concluídas pela dataFim (mais recente primeiro)
    concluidas.sort((a, b) => b.dataFim.compareTo(a.dataFim));
    final ultimaAtividade = concluidas.first;

    // Verifica se o usuário contribuiu (não anônimo) nessa atividade
    bool contribuiu =
        await _database.usuarioContribuiu(ultimaAtividade.id!, userId!);
    if (contribuiu && !_popupShown) {
      final nomes = await _database.obterContribuintes(ultimaAtividade.id!);
      if (nomes.isNotEmpty) {
        _popupShown = true;
        showDialog(
          context: context,
          builder: (_) => AgradecimentoAtividadePopup(
            atividadeTitulo: ultimaAtividade.titulo,
            nomesContribuintes: nomes,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtra para exibir somente atividades com status "em andamento"
    final atividadesAtivas =
        atividades.where((a) => a.status == 'em andamento').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sistema de Doações',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            await client.auth.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Login()),
            );
          },
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditarPerfil()),
              );
            },
            icon: const Icon(Icons.person, color: Colors.white),
            label: const Text(
              'Editar Perfil',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra superior preta com botões de ação
          Container(
            width: double.infinity,
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                // Botão para doar para o estoque geral
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NovaDoacao(atividadeId: null),
                      ),
                    );
                    _carregarAtividades();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  child: const Text(
                    'Doar para o estoque',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                // Botões disponíveis para usuários admin
                if (papelUsuario == 'admin') ...[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EstoqueGeral()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                    ),
                    child: const Text(
                      'Ver Estoque',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ConfirmarDoacoes()),
                      );
                      _carregarAtividades();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                    ),
                    child: const Text(
                      'Confirmar Doações',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CriarAtividade()),
                      );
                      if (result == true) {
                        _carregarAtividades();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                    ),
                    child: const Text(
                      'Criar Atividade',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Título da lista de atividades
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Atividades de Doação',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          // Lista das atividades "em andamento"
          Expanded(
            child: atividadesAtivas.isEmpty
                ? const Center(child: Text('Nenhuma atividade disponível.'))
                : ListView.builder(
                    itemCount: atividadesAtivas.length,
                    itemBuilder: (context, index) {
                      final atividade = atividadesAtivas[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    NovaDoacao(atividadeId: atividade.id),
                              ),
                            );
                            _carregarAtividades();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Título e descrição da atividade
                                Text(
                                  atividade.titulo,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  atividade.descricao,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 16),
                                // Exibe a lista de itens com barra de progresso
                                ...atividade.itens.map((item) {
                                  // Define totalPedido: se o item possuir "quantidade_total", usa-o; caso contrário, assume o valor atual de "quantidade"
                                  final int totalPedido =
                                      item.containsKey('quantidade_total') &&
                                              item['quantidade_total'] != null
                                          ? item['quantidade_total'] as int
                                          : item['quantidade'] as int;
                                  final int restante =
                                      item['quantidade'] as int;
                                  final int doado = totalPedido - restante;
                                  final double progress = totalPedido > 0
                                      ? doado / totalPedido
                                      : 0.0;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tipo: ${item['tipo_roupa']} - Tamanho: ${item['tamanho']} - Gênero: ${item['genero']}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      LinearProgressIndicator(
                                        value: progress,
                                        backgroundColor: Colors.grey[300],
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          progress >= 1.0
                                              ? Colors.green
                                              : Colors.blue,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$doado/$totalPedido doados',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
