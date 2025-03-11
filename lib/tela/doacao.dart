import 'package:doa_roupa/tela/agradecimento_doacao.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doa_roupa/banco/roupa_db.dart';

class NovaDoacao extends StatefulWidget {
  final String? atividadeId;
  const NovaDoacao({super.key, this.atividadeId});

  @override
  State<NovaDoacao> createState() => _NovaDoacaoState();
}

class _NovaDoacaoState extends State<NovaDoacao> {
  final _quantidadeController = TextEditingController();
  bool _anonimo = false;
  final RoupaDatabase _database = RoupaDatabase();

  // Lista de itens pedidos pela atividade
  List<Map<String, dynamic>> _itensAtividade = [];
  // Item selecionado pelo usuário (preenche automaticamente tipo, gênero e tamanho)
  Map<String, dynamic>? _itemSelecionado;

  @override
  void initState() {
    super.initState();
    if (widget.atividadeId != null) {
      _carregarItensAtividade();
    }
  }

  Future<void> _carregarItensAtividade() async {
    try {
      final response = await _database.client
          .from('atividades')
          .select('itens')
          .eq('id', widget.atividadeId!)
          .single();
      final data = response;
      setState(() {
        _itensAtividade = List<Map<String, dynamic>>.from(data['itens'] ?? []);
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar itens: $error')));
    }
  }

  void _selecionarItem(Map<String, dynamic> item) {
    setState(() {
      _itemSelecionado = item;
    });
  }

  Future<void> _registrarDoacao() async {
    if (_itemSelecionado == null || _quantidadeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Selecione um item e informe a quantidade.')));
      return;
    }
    // Cria o mapa de dados da doação
    final Map<String, dynamic> doacaoMap = {
      'doador_id': Supabase.instance.client.auth.currentUser?.id ?? '',
      'tipo_roupa': _itemSelecionado!['tipo_roupa'] ?? '',
      'genero': _itemSelecionado!['genero'] ?? '',
      'tamanho': _itemSelecionado!['tamanho'] ?? '',
      'quantidade': int.parse(_quantidadeController.text),
      'anonimo': _anonimo,
      'status': 'pendente',
    };
    if (widget.atividadeId != null) {
      doacaoMap['atividade_id'] = widget.atividadeId;
    }
    try {
      await _database.client.from('doacoes').insert(doacaoMap);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Agradecimento(
            nomeDoador: _anonimo ? 'Anônimo' : 'Usuário',
            quantidade: int.parse(_quantidadeController.text),
            tipoRoupa: _itemSelecionado!['tipo_roupa'] ?? '',
          ),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao registrar doação: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.atividadeId == null
              ? 'Doar para o Estoque Geral'
              : 'Doar para uma Causa',
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.atividadeId != null && _itensAtividade.isNotEmpty) ...[
              const Text('Selecione o item solicitado:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: _itensAtividade.map((item) {
                    return RadioListTile<Map<String, dynamic>>(
                      title: Text(
                          'Tipo: ${item['tipo_roupa']} - Tamanho: ${item['tamanho']} - Gênero: ${item['genero']}'),
                      subtitle: Text('Qtd solicitada: ${item['quantidade']}'),
                      value: item,
                      groupValue: _itemSelecionado,
                      onChanged: (value) => _selecionarItem(value!),
                    );
                  }).toList(),
                ),
              ),
            ] else ...[
              // Caso não haja atividade associada, os campos podem ser preenchidos manualmente (opcional)
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Tipo de Roupa',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Gênero',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Tamanho',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Campo para informar a quantidade manualmente
            TextFormField(
              controller: _quantidadeController,
              decoration: InputDecoration(
                labelText: 'Quantidade',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Deseja Doar Anonimamente?'),
              value: _anonimo,
              onChanged: (value) {
                setState(() {
                  _anonimo = value ?? false;
                });
              },
              tileColor: Colors.grey[200],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _registrarDoacao,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Enviar Doação',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
