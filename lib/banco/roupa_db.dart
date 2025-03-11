import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doa_roupa/modelo/atividade.dart';
import 'package:doa_roupa/modelo/doacao.dart';
import 'package:doa_roupa/modelo/usuario.dart';

class RoupaDatabase {
  final SupabaseClient client = Supabase.instance.client;

  // ---------- Autenticação ----------
  Future<String?> signUp(String email, String senha, String nome, String papel,
      String genero, int idade, String? profileUrl) async {
    final response = await client.auth.signUp(email: email, password: senha);
    if (response.user != null) {
      await client.from('usuarios').insert({
        'id': response.user!.id,
        'nome': nome,
        'email': email,
        'papel': papel,
        'genero': genero,
        'idade': idade,
        'profile_url': profileUrl,
      });
    }
    return response.user?.id;
  }

  // ---------- Usuários ----------
  Future<Usuario?> getUsuario(String id) async {
    final response =
        await client.from('usuarios').select('*').eq('id', id).single();
    return Usuario.fromMap(response);
  }

  Future<void> atualizarUsuario(Usuario usuario) async {
    await client.from('usuarios').update(usuario.toMap()).eq('id', usuario.id);
  }

  // ---------- Atividades ----------
  Future<List<Atividade>> getTodasAtividades() async {
    final response = await client
        .from('atividades')
        .select('*')
        .order('data_inicio', ascending: false);
    return (response as List)
        .map((atividade) => Atividade.fromMap(atividade))
        .toList();
  }

  Future<List<Atividade>> getAtividadesAtivas() async {
    // Obtém todas as atividades
    final all = await getTodasAtividades();
    final now = DateTime.now();

    // Atualiza no banco as atividades cujo dataFim é anterior à data atual
    for (final atividade in all) {
      if (atividade.status == 'em andamento' &&
          atividade.dataFim.isBefore(now)) {
        await client
            .from('atividades')
            .update({'status': 'concluída'}).eq('id', atividade.id!);
      }
    }
    // Recarrega as atividades após a atualização
    final updated = await getTodasAtividades();
    // Retorna apenas as atividades que ainda estão em andamento
    return updated
        .where((atividade) => atividade.status == 'em andamento')
        .toList();
  }

  // Atualizar atividade (edição)
  Future<void> atualizarAtividade(Atividade atividade) async {
    await client
        .from('atividades')
        .update(atividade.toMap())
        .eq('id', atividade.id!);
  }

  Future<void> finalizarAtividade(String id) async {
    await client
        .from('atividades')
        .update({'status': 'finalizada'}).eq('id', id);
  }

  Future<List<String>> obterContribuintes(String atividadeId) async {
    final response = await client
        .from('doacoes')
        .select('doador_id, usuarios(nome)')
        .eq('atividade_id', atividadeId)
        .eq('status', 'confirmada')
        .eq('anonimo', false);
    List<String> nomes = [];
    for (final item in response) {
      if (item['usuarios'] != null && item['usuarios']['nome'] != null) {
        nomes.add(item['usuarios']['nome']);
      }
    }
    return nomes.toSet().toList();
  }

  Future<bool> usuarioContribuiu(String atividadeId, String userId) async {
    final response = await client
        .from('doacoes')
        .select('*')
        .eq('atividade_id', atividadeId)
        .eq('doador_id', userId)
        .eq('status', 'confirmada')
        .eq('anonimo', false);
    return (response as List).isNotEmpty;
  }

  // ---------- Doações ----------
  Future<void> confirmarDoacaoComExcedente(String id) async {
    final doacaoResponse =
        await client.from('doacoes').select('*').eq('id', id).single();
    final doacao = Doacao.fromMap(doacaoResponse);

    if (doacao.atividadeId != null) {
      final atividadeResponse = await client
          .from('atividades')
          .select('itens')
          .eq('id', doacao.atividadeId!)
          .single();
      List<dynamic> itensAtividade = atividadeResponse['itens'];
      bool itemEncontrado = false;
      for (int i = 0; i < itensAtividade.length; i++) {
        final item = itensAtividade[i];
        if (item['tipo_roupa'] == doacao.tipoRoupa &&
            item['genero'] == doacao.genero &&
            item['tamanho'] == doacao.tamanho) {
          itemEncontrado = true;
          int quantidadeRestante = item['quantidade'] as int;
          if (doacao.quantidade >= quantidadeRestante) {
            int excedente = doacao.quantidade - quantidadeRestante;
            itensAtividade[i] = {...item, 'quantidade': 0};
            if (excedente > 0) {
              await _atualizarEstoque(
                tipo: doacao.tipoRoupa,
                genero: doacao.genero,
                tamanho: doacao.tamanho,
                quantidade: excedente,
              );
            }
          } else {
            itensAtividade[i] = {
              ...item,
              'quantidade': quantidadeRestante - doacao.quantidade
            };
          }
          await client
              .from('doacoes')
              .update({'status': 'confirmada'}).eq('id', id);
          await client
              .from('atividades')
              .update({'itens': itensAtividade}).eq('id', doacao.atividadeId!);
          break;
        }
      }
      if (!itemEncontrado) {
        await client
            .from('doacoes')
            .update({'status': 'rejeitada'}).eq('id', id);
      } else {
        bool todosZerados =
            itensAtividade.every((item) => (item['quantidade'] as int) == 0);
        if (todosZerados) {
          await client
              .from('atividades')
              .update({'status': 'concluída'}).eq('id', doacao.atividadeId!);
        }
      }
    } else {
      await client
          .from('doacoes')
          .update({'status': 'confirmada'}).eq('id', id);
      await _atualizarEstoque(
        tipo: doacao.tipoRoupa,
        genero: doacao.genero,
        tamanho: doacao.tamanho,
        quantidade: doacao.quantidade,
      );
    }
  }

  Future<void> _atualizarEstoque({
    required String tipo,
    required String genero,
    required String tamanho,
    required int quantidade,
  }) async {
    final response = await client
        .from('estoque')
        .select('quantidade')
        .eq('tipo_roupa', tipo)
        .eq('genero', genero)
        .eq('tamanho', tamanho)
        .maybeSingle();
    if (response != null) {
      await client
          .from('estoque')
          .update({'quantidade': (response['quantidade'] as int) + quantidade})
          .eq('tipo_roupa', tipo)
          .eq('genero', genero)
          .eq('tamanho', tamanho);
    } else {
      await client.from('estoque').insert({
        'tipo_roupa': tipo,
        'genero': genero,
        'tamanho': tamanho,
        'quantidade': quantidade,
      });
    }
  }

  Future<void> rejeitarDoacao(String id) async {
    await client.from('doacoes').update({'status': 'rejeitada'}).eq('id', id);
  }
}
