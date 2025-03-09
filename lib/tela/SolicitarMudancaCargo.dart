import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AprovarMudancaCargo extends StatefulWidget {
  const AprovarMudancaCargo({super.key});

  @override
  State<AprovarMudancaCargo> createState() => _AprovarMudancaCargoState();
}

class _AprovarMudancaCargoState extends State<AprovarMudancaCargo> {
  final SupabaseClient client = Supabase.instance.client;
  List<Map<String, dynamic>> solicitacoes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarSolicitacoes();
  }

  Future<void> _carregarSolicitacoes() async {
    try {
      final response = await client
          .from('usuarios')
          .select()
          .eq('mudanca_cargo', 'pendente');
      setState(() {
        solicitacoes = (response as List).cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar solicitações: $error')));
    }
  }

  Future<void> _aprovarSolicitacao(String userId) async {
    try {
      await client.from('usuarios').update({
        'papel': 'admin',
        'mudanca_cargo': 'aprovado',
      }).eq('id', userId);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Solicitação aprovada!')));
      await _carregarSolicitacoes();
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro ao aprovar: $error')));
    }
  }

  Future<void> _rejeitarSolicitacao(String userId) async {
    try {
      await client.from('usuarios').update({
        'mudanca_cargo': 'rejeitado',
      }).eq('id', userId);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitação rejeitada!')));
      await _carregarSolicitacoes();
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro ao rejeitar: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aprovar Mudança de Cargo',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : solicitacoes.isEmpty
              ? const Center(child: Text('Nenhuma solicitação pendente.'))
              : ListView.builder(
                  itemCount: solicitacoes.length,
                  itemBuilder: (context, index) {
                    final user = solicitacoes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      child: ListTile(
                        title: Text(user['nome'] ?? 'Sem nome'),
                        subtitle: Text(user['email'] ?? 'Sem e-mail'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.check, color: Colors.green),
                              onPressed: () => _aprovarSolicitacao(user['id']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _rejeitarSolicitacao(user['id']),
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
