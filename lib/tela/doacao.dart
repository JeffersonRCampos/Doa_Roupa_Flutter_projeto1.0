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

  List<Map<String, dynamic>> _itensAtividade = [];
  Map<String, dynamic>? _itemSelecionado;

  final List<String> _tiposRoupa = [
    "Calça",
    "Camisa",
    "Bermuda",
    "Vestido",
    "Casaco",
    "Blusa"
  ];
  final List<String> _tamanhos = ["Infantil", "P", "M", "G", "GG"];
  final List<String> _generos = ["Masculino", "Feminino", "Unissex"];

  String? _tipoRoupaSelecionado;
  String? _tamanhoSelecionado;
  String? _generoSelecionado;

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
      setState(() {
        _itensAtividade =
            List<Map<String, dynamic>>.from(response['itens'] ?? []);
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar itens: $error')));
    }
  }

  void _selecionarItem(Map<String, dynamic> item) {
    setState(() => _itemSelecionado = item);
  }

  Future<void> _registrarDoacao() async {
    if (_itemSelecionado == null &&
        (_tipoRoupaSelecionado == null ||
            _tamanhoSelecionado == null ||
            _generoSelecionado == null)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Selecione um item ou preencha os campos.')));
      return;
    }

    final Map<String, dynamic> doacaoMap = {
      'doador_id': Supabase.instance.client.auth.currentUser?.id ?? '',
      'tipo_roupa': _itemSelecionado?['tipo_roupa'] ?? _tipoRoupaSelecionado,
      'genero': _itemSelecionado?['genero'] ?? _generoSelecionado,
      'tamanho': _itemSelecionado?['tamanho'] ?? _tamanhoSelecionado,
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
            tipoRoupa:
                _itemSelecionado?['tipo_roupa'] ?? _tipoRoupaSelecionado!,
          ),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao registrar doação: $error')));
    }
  }

  InputDecoration campo(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      labelStyle: const TextStyle(color: Colors.black),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.atividadeId == null
              ? 'Doar para o Estoque Geral'
              : 'Doar para uma Causa',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.atividadeId != null && _itensAtividade.isNotEmpty) ...[
              const Text('Selecione o item solicitado:',
                  style: TextStyle(color: Colors.black)),
              Expanded(
                child: ListView(
                  children: _itensAtividade.map((item) {
                    return RadioListTile<Map<String, dynamic>>(
                      title: Text(
                        '${item['tipo_roupa']} - ${item['tamanho']} - ${item['genero']}',
                        style: const TextStyle(color: Colors.black),
                      ),
                      value: item,
                      groupValue: _itemSelecionado,
                      activeColor: Colors.black,
                      onChanged: (value) => _selecionarItem(value!),
                    );
                  }).toList(),
                ),
              ),
            ] else ...[
              DropdownButtonFormField<String>(
                decoration: campo('Tipo de Roupa'),
                items: _tiposRoupa
                    .map(
                      (tipo) =>
                          DropdownMenuItem(value: tipo, child: Text(tipo)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _tipoRoupaSelecionado = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: campo('Tamanho'),
                items: _tamanhos
                    .map(
                      (tam) => DropdownMenuItem(value: tam, child: Text(tam)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _tamanhoSelecionado = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: campo('Gênero'),
                items: _generos
                    .map(
                      (gen) => DropdownMenuItem(value: gen, child: Text(gen)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _generoSelecionado = value),
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _quantidadeController,
              decoration: campo('Quantidade'),
              keyboardType: TextInputType.number,
            ),
            CheckboxListTile(
              title: const Text('Doação Anônima?',
                  style: TextStyle(color: Colors.black)),
              value: _anonimo,
              activeColor: Colors.black,
              checkColor: Colors.white,
              onChanged: (value) => setState(() => _anonimo = value ?? false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              onPressed: _registrarDoacao,
              child: const Text('Enviar Doação'),
            ),
          ],
        ),
      ),
    );
  }
}
