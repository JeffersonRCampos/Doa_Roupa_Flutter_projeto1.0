import 'dart:io';
import 'package:flutter/material.dart';
import 'package:doa_roupa/banco/roupa_db.dart';
import 'package:doa_roupa/modelo/usuario.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class EditarPerfil extends StatefulWidget {
  const EditarPerfil({super.key});

  @override
  State<EditarPerfil> createState() => _EditarPerfilState();
}

class _EditarPerfilState extends State<EditarPerfil> {
  final RoupaDatabase _database = RoupaDatabase();
  final _nomeController = TextEditingController();
  final _generoController = TextEditingController();
  final _idadeController = TextEditingController();
  final _profileUrlController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      final usuario = await _database.getUsuario(currentUser.id);
      if (usuario != null) {
        setState(() {
          _nomeController.text = usuario.nome;
          _generoController.text = usuario.genero ?? '';
          _idadeController.text = usuario.idade?.toString() ?? '';
          _profileUrlController.text = usuario.profileUrl ?? '';
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        String? uploadedUrl = await _uploadImage(File(pickedFile.path));
        if (uploadedUrl != null) {
          setState(() {
            _profileUrlController.text = uploadedUrl;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar imagem: $e')),
      );
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      // Realiza o upload (não precisamos armazenar o resultado se não for necessário)
      await Supabase.instance.client.storage
          .from('profile-images')
          .upload(fileName, imageFile);
      // Obtém a URL pública
      final publicUrl = Supabase.instance.client.storage
          .from('profile-images')
          .getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro no upload: $e')),
      );
      return null;
    }
  }

  Future<void> _salvarAlteracoes() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      final usuario = await _database.getUsuario(currentUser.id);
      if (usuario != null) {
        final novoUsuario = Usuario(
          id: usuario.id,
          nome: _nomeController.text,
          email: usuario.email,
          papel: usuario.papel,
          genero: _generoController.text,
          idade: int.tryParse(_idadeController.text),
          profileUrl: _profileUrlController.text.isNotEmpty
              ? _profileUrlController.text
              : null,
        );
        await _database.atualizarUsuario(novoUsuario);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _profileUrlController.text.isNotEmpty
                      ? NetworkImage(_profileUrlController.text)
                      : _imageFile != null
                          ? FileImage(_imageFile!) as ImageProvider
                          : null,
                  child:
                      (_profileUrlController.text.isEmpty && _imageFile == null)
                          ? const Icon(Icons.camera_alt,
                              size: 40, color: Colors.black54)
                          : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _generoController,
              decoration: const InputDecoration(labelText: 'Gênero'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _idadeController,
              decoration: const InputDecoration(labelText: 'Idade'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _profileUrlController,
              decoration: const InputDecoration(
                  labelText: 'URL da Imagem de Perfil (opcional)'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _salvarAlteracoes,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
