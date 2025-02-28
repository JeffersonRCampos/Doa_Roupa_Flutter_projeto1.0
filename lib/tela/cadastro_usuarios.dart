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
  final _idadeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Variáveis para seleção de gênero e papel
  String _genero = 'Masculino'; // Valor padrão para gênero
  String _papel = 'doador'; // Valor padrão para papel

  // Função para cadastrar o usuário no Supabase
  Future<void> _cadastrar() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Realiza o signUp via Supabase Auth
        final response = await Supabase.instance.client.auth.signUp(
          email: _emailController.text,
          password: _senhaController.text,
        );

        if (response.user != null) {
          // Insere os dados do usuário na tabela 'usuarios'
          await Supabase.instance.client.from('usuarios').insert({
            'id': response.user!.id,
            'nome': _nomeController.text,
            'email': _emailController.text,
            'papel': _papel,
            'genero': _genero,
            'idade': int.parse(_idadeController.text),
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
          child: ListView(
            children: [
              const SizedBox(height: 20),
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

              // Campo Idade
              TextFormField(
                controller: _idadeController,
                decoration: InputDecoration(
                  labelText: 'Idade',
                  hintText: 'Digite sua idade',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  prefixIcon:
                      const Icon(Icons.calendar_today, color: Colors.black),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Idade é obrigatória' : null,
              ),
              const SizedBox(height: 20),

              // Seleção de Gênero (RadioButtons)
              const Text(
                'Gênero:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Column(
                children: [
                  RadioListTile(
                    title: const Text('Masculino'),
                    value: 'Masculino',
                    groupValue: _genero,
                    onChanged: (value) {
                      setState(() {
                        _genero = value.toString();
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('Feminino'),
                    value: 'Feminino',
                    groupValue: _genero,
                    onChanged: (value) {
                      setState(() {
                        _genero = value.toString();
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('Outros'),
                    value: 'Outros',
                    groupValue: _genero,
                    onChanged: (value) {
                      setState(() {
                        _genero = value.toString();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

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
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
