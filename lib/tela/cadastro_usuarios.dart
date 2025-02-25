import 'package:doa_roupa/tela/login.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CadastroUsuario extends StatefulWidget {
  const CadastroUsuario({super.key});

  @override
  State<CadastroUsuario> createState() => _CadastroUsuarioState();
}

class _CadastroUsuarioState extends State<CadastroUsuario> {
  // Controladores para entrada de dados
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _papel = 'doador'; // Valor padrão para seleção de papel

  // Função para cadastrar o usuário no Supabase
  Future<void> _cadastrar() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await Supabase.instance.client.auth.signUp(
          email: _emailController.text,
          password: _senhaController.text,
        );

        if (response.user != null) {
          await Supabase.instance.client.from('usuarios').insert({
            'id': response.user!.id,
            'nome': _nomeController.text,
            'email': _emailController.text,
            'papel': _papel, // Papel selecionado
          });

          // Redireciona para a tela de login após o cadastro
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Login()),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Cadastro de Usuário',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Título da tela
              const Center(
                child: Text(
                  'Criar Usuário',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    decoration: TextDecoration.underline,
                    decorationThickness: 2,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Campo Nome
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome ou apelido',
                  hintText: 'Digite aqui seu nome',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  prefixIcon: const Icon(Icons.person, color: Colors.black),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Nome é obrigatório' : null,
              ),
              const SizedBox(height: 20),

              // Campo Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  hintText: 'Digite aqui seu email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  prefixIcon: const Icon(Icons.email, color: Colors.black),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'E-mail é obrigatório' : null,
              ),
              const SizedBox(height: 20),

              // Campo Senha
              TextFormField(
                controller: _senhaController,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  hintText: 'Digite sua senha aqui',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  prefixIcon: const Icon(Icons.lock, color: Colors.black),
                ),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Senha é obrigatória' : null,
              ),
              const SizedBox(height: 20),

              // Dropdown de Papel (Doador ou Admin)
              DropdownButtonFormField<String>(
                value: _papel,
                onChanged: (value) {
                  setState(() {
                    _papel = value!;
                  });
                },
                items: ['doador', 'admin']
                    .map((papel) => DropdownMenuItem(
                          value: papel,
                          child: Text(papel),
                        ))
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'Papel',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  prefixIcon: const Icon(Icons.people, color: Colors.black),
                ),
              ),
              const SizedBox(height: 30),

              // Botão Criar Usuário
              ElevatedButton(
                onPressed: _cadastrar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Criar Usuário',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white, // Texto branco
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
