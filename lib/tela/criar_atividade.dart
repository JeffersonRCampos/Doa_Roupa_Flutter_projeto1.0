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
  // Lista de itens solicitados
  final List<Map<String, dynamic>> _itens = [];

  /// Exibe um diálogo para coletar informações.
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

  /// Adiciona um novo item à lista.
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
        int q = int.tryParse(quantidade) ?? 0;
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

  /// Remove um item da lista.
  void _removerItem(int index) {
    setState(() {
      _itens.removeAt(index);
    });
  }

  /// Cria a atividade e insere no banco de dados.
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

    // Valida datas: data fim deve ser posterior à data início e à data atual
    if (dataInicio == null ||
        dataFim == null ||
        dataInicio.isAfter(dataFim) ||
        dataFim.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Datas inválidas. A data fim deve ser posterior à data início e à data atual.')),
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

  /// Converte uma string no formato 'dd/MM/yyyy' para DateTime.
  DateTime? _parseData(String data) {
    try {
      return DateFormat('dd/MM/yyyy').parse(data);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campos para os dados da atividade
            TextFormField(
              controller: _tipoController,
              decoration: InputDecoration(
                labelText: 'Tipo',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tituloController,
              decoration: InputDecoration(
                labelText: 'Título',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descricaoController,
              decoration: InputDecoration(
                labelText: 'Descrição',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dataInicioController,
              decoration: InputDecoration(
                labelText: 'Data Início (DD/MM/YYYY)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dataFimController,
              decoration: InputDecoration(
                labelText: 'Data Fim (DD/MM/YYYY)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Itens Solicitados:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Lista de itens com opção de editar e remover
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
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              await _editarItem(index);
                            },
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
            // Botões para adicionar item e criar atividade
            ElevatedButton(
              onPressed: _adicionarItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Adicionar Item',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _criarAtividade,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Criar Atividade',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Permite editar um item já adicionado.
  Future<void> _editarItem(int index) async {
    final currentItem = _itens[index];
    final tipoController =
        TextEditingController(text: currentItem['tipo_roupa']);
    final generoController = TextEditingController(text: currentItem['genero']);
    final tamanhoController =
        TextEditingController(text: currentItem['tamanho']);
    final quantidadeController =
        TextEditingController(text: currentItem['quantidade'].toString());

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tipoController,
              decoration: const InputDecoration(labelText: 'Tipo de Roupa'),
            ),
            TextField(
              controller: generoController,
              decoration: const InputDecoration(labelText: 'Gênero'),
            ),
            TextField(
              controller: tamanhoController,
              decoration: const InputDecoration(labelText: 'Tamanho'),
            ),
            TextField(
              controller: quantidadeController,
              decoration: const InputDecoration(labelText: 'Quantidade'),
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
        int q = int.tryParse(quantidadeController.text) ?? 0;
        _itens[index] = {
          'tipo_roupa': tipoController.text,
          'genero': generoController.text,
          'tamanho': tamanhoController.text,
          'quantidade': q,
          'quantidade_total': q,
        };
      });
    }
  }
}
