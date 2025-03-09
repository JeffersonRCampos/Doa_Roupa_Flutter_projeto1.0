import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:doa_roupa/banco/roupa_db.dart';
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

  // Variável para armazenar o cargo atual do usuário
  String _cargo = '';

  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      try {
        final usuario = await _database.getUsuario(currentUser.id);
        if (usuario != null) {
          setState(() {
            _nomeController.text = usuario.nome;
            _generoController.text = usuario.genero ?? '';
            _idadeController.text = usuario.idade?.toString() ?? '';
            _profileUrlController.text = usuario.profileUrl ?? '';
            _cargo = usuario.papel;
          });
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $error')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _imageBytes = bytes;
          });
        } else {
          setState(() {
            _imageFile = File(pickedFile.path);
          });
        }
        String? uploadedUrl = await _uploadImage(pickedFile);
        if (uploadedUrl != null) {
          setState(() {
            _profileUrlController.text = uploadedUrl;
          });
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar imagem: $error')),
      );
    }
  }

  Future<String?> _uploadImage(XFile pickedFile) async {
    try {
      final fileName =
          'profile-images/${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        await Supabase.instance.client.storage
            .from('profile-images')
            .uploadBinary(fileName, bytes,
                fileOptions: FileOptions(contentType: 'image/png'));
      } else {
        await Supabase.instance.client.storage
            .from('profile-images')
            .upload(fileName, File(pickedFile.path));
      }
      final publicUrl = Supabase.instance.client.storage
          .from('profile-images')
          .getPublicUrl(fileName);
      return publicUrl;
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro no upload: $error')),
      );
      return null;
    }
  }

  Future<void> _salvarAlteracoes() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      try {
        final usuario = await _database.getUsuario(currentUser.id);
        if (usuario != null) {
          final novoUsuario = usuario.copyWith(
            nome: _nomeController.text,
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
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar alterações: $error')),
        );
      }
    }
  }

  /// Solicita a mudança de cargo atualizando o campo 'mudanca_cargo' para 'pendente'
  Future<void> _solicitarMudancaCargo() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await Supabase.instance.client
          .from('usuarios')
          .update({'mudanca_cargo': 'pendente'}).eq('id', userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Solicitação enviada. Aguarde a aprovação!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (_profileUrlController.text.isNotEmpty) {
      imageProvider = NetworkImage(_profileUrlController.text);
    } else if (kIsWeb && _imageBytes != null) {
      imageProvider = MemoryImage(_imageBytes!);
    } else if (!kIsWeb && _imageFile != null) {
      imageProvider = FileImage(_imageFile!);
    }

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Editar Perfil', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
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
                  backgroundImage: imageProvider,
                  child: imageProvider == null
                      ? const Icon(Icons.camera_alt,
                          size: 40, color: Colors.white)
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
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _salvarAlteracoes,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child:
                  const Text('Salvar', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            // Exibe o botão para solicitar mudança de cargo somente se o usuário não for admin.
            if (_cargo.toLowerCase() != 'admin')
              ElevatedButton(
                onPressed: _solicitarMudancaCargo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: const Text('Solicitar Mudança de Cargo',
                    style: TextStyle(color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }
}
