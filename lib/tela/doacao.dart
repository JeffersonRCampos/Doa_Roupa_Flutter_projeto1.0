import 'package:doa_roupa/tela/agradecimento_doacao.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doa_roupa/modelo/doacao.dart';
import 'package:doa_roupa/banco/roupa_db.dart';

class NovaDoacao extends StatefulWidget {
  final String? atividadeId;
  const NovaDoacao({super.key, this.atividadeId});

  @override
  State<NovaDoacao> createState() => _NovaDoacaoState();
}

class _NovaDoacaoState extends State<NovaDoacao> {
  final _tipoController = TextEditingController();
  final _generoController = TextEditingController();
  final _tamanhoController = TextEditingController();
  final _quantidadeController = TextEditingController();
  bool _anonimo = false;
  final RoupaDatabase _database = RoupaDatabase();

  Future<void> _registrarDoacao() async {
    if (_tipoController.text.isEmpty ||
        _generoController.text.isEmpty ||
        _tamanhoController.text.isEmpty ||
        _quantidadeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos.')),
      );
      return;
    }
    final doacao = Doacao(
      doadorId: Supabase.instance.client.auth.currentUser?.id ?? '',
      atividadeId: widget.atividadeId,
      tipoRoupa: _tipoController.text,
      genero: _generoController.text,
      tamanho: _tamanhoController.text,
      quantidade: int.parse(_quantidadeController.text),
      anonimo: _anonimo,
      status: 'pendente',
    );
    try {
      await Supabase.instance.client.from('doacoes').insert(doacao.toMap());
      String nomeDoador = 'Usuário';
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser != null) {
        final usuario = await _database.getUsuario(currentUser.id);
        if (usuario != null) {
          nomeDoador = usuario.nome;
        }
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Agradecimento(
            nomeDoador: _anonimo ? 'Anônimo' : nomeDoador,
            quantidade: doacao.quantidade,
            tipoRoupa: doacao.tipoRoupa,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao registrar doação: $e')),
      );
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
            // Campo Tipo de Roupa
            TextFormField(
              controller: _tipoController,
              decoration: InputDecoration(
                labelText: 'Tipo de Roupa',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 16),

            // Campo Gênero
            TextFormField(
              controller: _generoController,
              decoration: InputDecoration(
                labelText: 'Gênero',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 16),

            // Campo Tamanho
            TextFormField(
              controller: _tamanhoController,
              decoration: InputDecoration(
                labelText: 'Tamanho',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 16),

            // Campo Quantidade
            TextFormField(
              controller: _quantidadeController,
              decoration: InputDecoration(
                labelText: 'Quantidade',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Checkbox para Doação Anônima
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
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),

            // Botão Enviar Doação
            ElevatedButton(
              onPressed: _registrarDoacao,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Enviar Doação',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
