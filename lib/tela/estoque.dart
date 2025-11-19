import 'package:doa_roupa/tela/doacao.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EstoqueGeral extends StatefulWidget {
  const EstoqueGeral({super.key});

  @override
  State<EstoqueGeral> createState() => _EstoqueGeralState();
}

class _EstoqueGeralState extends State<EstoqueGeral> {
  final SupabaseClient client = Supabase.instance.client;
  List<Map<String, dynamic>> _estoque = [];

  @override
  void initState() {
    super.initState();
    _carregarEstoque();
  }

  Future<void> _carregarEstoque() async {
    final response = await client.from('estoque').select('*');
    setState(() => _estoque = response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Estoque',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _estoque.isEmpty
          ? const Center(child: Text('Nenhum item no estoque'))
          : Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  color: Colors.grey[200],
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Tipo',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Tamanho',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Gênero',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Qtd',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _estoque.length,
                    itemBuilder: (context, index) {
                      final item = _estoque[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(item['tipo_roupa']),
                              ),
                              Expanded(
                                child: Text(item['tamanho']),
                              ),
                              Expanded(
                                child: Text(item['genero']),
                              ),
                              Expanded(
                                child: Text(item['quantidade'].toString()),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const NovaDoacao(atividadeId: null)),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
