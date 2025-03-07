import 'package:doa_roupa/tela/agradecimento.dart';
import 'package:doa_roupa/tela/doacao.dart';
import 'package:doa_roupa/tela/login.dart';
import 'package:doa_roupa/tela/EditarPerfil.dart';
import 'package:doa_roupa/tela/Acoeshome.dart';
import 'package:doa_roupa/banco/roupa_db.dart';
import 'package:doa_roupa/modelo/atividade.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doa_roupa/main.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with RouteAware {
  final SupabaseClient client = Supabase.instance.client;
  final RoupaDatabase _database = RoupaDatabase();
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute? route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Quando a Home voltar ao foco, recarrega as atividades
    _carregarAtividades();
  }

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
          SnackBar(content: Text('Erro ao carregar atividades: $e')));
    }
  }

  Future<void> _checkConcludedActivities() async {
    final todasAtividades = await _database.getTodasAtividades();
    final concluidas =
        todasAtividades.where((a) => a.status == 'concluída').toList();
    if (concluidas.isEmpty || userId == null) return;
    concluidas.sort((a, b) => b.dataFim.compareTo(a.dataFim));
    final ultimaAtividade = concluidas.first;
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
    final atividadesAtivas =
        atividades.where((a) => a.status == 'em andamento').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de Doações',
            style: TextStyle(color: Colors.white, fontSize: 24)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () async {
            await client.auth.signOut();
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const Login()));
          },
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const EditarPerfil()));
            },
            icon: const Icon(Icons.person, color: Colors.white),
            label: const Text('Editar Perfil',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          HomeActions(
            papelUsuario: papelUsuario,
            onAtualizar: _carregarAtividades,
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Atividades de Doação',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
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
                                      NovaDoacao(atividadeId: atividade.id)),
                            );
                            _carregarAtividades();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(atividade.titulo,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text(atividade.descricao,
                                    style: const TextStyle(fontSize: 16)),
                                const SizedBox(height: 16),
                                ...atividade.itens.map((item) {
                                  final int totalPedido =
                                      item['quantidade_total'] ??
                                          item['quantidade'];
                                  final int restante = item['quantidade'];
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
                                          style: const TextStyle(fontSize: 14)),
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
                                      Text('$doado/$totalPedido doados',
                                          style: const TextStyle(fontSize: 12)),
                                      const SizedBox(height: 12),
                                    ],
                                  );
                                }).toList(),
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
