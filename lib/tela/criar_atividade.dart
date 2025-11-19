import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doa_roupa/modelo/atividade.dart';

class CriarAtividade extends StatefulWidget {
  const CriarAtividade({super.key});

  @override
  State<CriarAtividade> createState() => _CriarAtividadeState();
}

class _CriarAtividadeState extends State<CriarAtividade> {
  final _tipoController = TextEditingController();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _dataInicioController = TextEditingController();
  final _dataFimController = TextEditingController();

  final List<Map<String, dynamic>> _itens = [];

  Future<String?> _mostrarDialogoItem(String titulo) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: TextField(
          controller: controller,
          keyboardType: titulo == 'Quantidade'
              ? TextInputType.number
              : TextInputType.text,
          inputFormatters: titulo == 'Quantidade'
              ? [FilteringTextInputFormatter.digitsOnly]
              : [],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  Future<void> _adicionarItem() async {
    final tipo = await _mostrarDialogoItem('Tipo de Roupa');
    final genero = await _mostrarDialogoItem('Gênero');
    final tamanho = await _mostrarDialogoItem('Tamanho');
    final quantidade = await _mostrarDialogoItem('Quantidade');

    if (tipo != null &&
        genero != null &&
        tamanho != null &&
        quantidade != null &&
        quantidade.isNotEmpty) {
      setState(() {
        final q = int.tryParse(quantidade) ?? 0;
        _itens.add({
          'tipo_roupa': tipo,
          'genero': genero,
          'tamanho': tamanho,
          'quantidade': q,
          'quantidade_total': q,
        });
      });
    }
  }

  void _removerItem(int index) {
    setState(() {
      _itens.removeAt(index);
    });
  }

  Future<void> _criarAtividade() async {
    if (_tipoController.text.isEmpty ||
        _tituloController.text.isEmpty ||
        _descricaoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
      );
      return;
    }

    final dataInicio = _parseData(_dataInicioController.text);
    final dataFim = _parseData(_dataFimController.text);

    if (dataInicio == null ||
        dataFim == null ||
        dataInicio.isAfter(dataFim) ||
        dataFim.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Datas inválidas. A data fim deve ser posterior à data início e à data atual.',
          ),
        ),
      );
      return;
    }

    final atividade = Atividade(
      tipo: _tipoController.text,
      titulo: _tituloController.text,
      descricao: _descricaoController.text,
      itens: _itens,
      dataInicio: dataInicio,
      dataFim: dataFim,
      status: 'em andamento',
    );

    try {
      await Supabase.instance.client
          .from('atividades')
          .insert(atividade.toMap());
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar atividade: $e')),
      );
    }
  }

  DateTime? _parseData(String data) {
    try {
      return DateFormat('dd/MM/yyyy').parse(data);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Criar Atividade',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _campo(_tipoController, 'Tipo'),
            const SizedBox(height: 16),
            _campo(_tituloController, 'Título'),
            const SizedBox(height: 16),
            _campo(_descricaoController, 'Descrição'),
            const SizedBox(height: 16),
            _campo(_dataInicioController, 'Data Início (DD/MM/YYYY)'),
            const SizedBox(height: 16),
            _campo(_dataFimController, 'Data Fim (DD/MM/YYYY)'),
            const SizedBox(height: 20),
            const Text(
              'Itens Solicitados:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _itens.length,
                itemBuilder: (context, index) {
                  final item = _itens[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                    child: ListTile(
                      title: Text(
                        '${item['quantidade']} ${item['tipo_roupa']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Tamanho: ${item['tamanho']}, Gênero: ${item['genero']}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.blueAccent),
                            onPressed: () => _editarItem(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removerItem(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _botao('Adicionar Item', _adicionarItem),
            const SizedBox(height: 16),
            _botao('Criar Atividade', _criarAtividade),
          ],
        ),
      ),
    );
  }

  Widget _campo(TextEditingController c, String label) {
    return TextFormField(
      controller: c,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _botao(String texto, Function() acao) {
    return ElevatedButton(
      onPressed: acao,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        texto,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  Future<void> _editarItem(int index) async {
    final current = _itens[index];

    final tipo = TextEditingController(text: current['tipo_roupa']);
    final genero = TextEditingController(text: current['genero']);
    final tamanho = TextEditingController(text: current['tamanho']);
    final quantidade =
        TextEditingController(text: current['quantidade'].toString());

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                decoration: const InputDecoration(labelText: 'Tipo'),
                controller: tipo),
            TextField(
                decoration: const InputDecoration(labelText: 'Gênero'),
                controller: genero),
            TextField(
                decoration: const InputDecoration(labelText: 'Tamanho'),
                controller: tamanho),
            TextField(
              decoration: const InputDecoration(labelText: 'Quantidade'),
              controller: quantidade,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Salvar')),
        ],
      ),
    );

    if (result == true) {
      setState(() {
        final q = int.tryParse(quantidade.text) ?? 0;
        _itens[index] = {
          'tipo_roupa': tipo.text,
          'genero': genero.text,
          'tamanho': tamanho.text,
          'quantidade': q,
          'quantidade_total': q,
        };
      });
    }
  }
}
