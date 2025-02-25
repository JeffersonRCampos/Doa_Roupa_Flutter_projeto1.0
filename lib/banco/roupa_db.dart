import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doa_roupa/modelo/atividade.dart';
import 'package:doa_roupa/modelo/doacao.dart';
import 'package:doa_roupa/modelo/usuario.dart';

class RoupaDatabase {
  final SupabaseClient client = Supabase.instance.client;

  // -------------------- Autenticação --------------------
  Future<String?> signUp(
      String email, String senha, String nome, String papel) async {
    final response = await client.auth.signUp(email: email, password: senha);
    if (response.user != null) {
      await client.from('usuarios').insert({
        'id': response.user!.id,
        'nome': nome,
        'email': email,
        'papel': papel,
      });
    }
    return response.user?.id;
  }

  // -------------------- Usuários --------------------
  Future<Usuario?> getUsuario(String id) async {
    final response =
        await client.from('usuarios').select('*').eq('id', id).single();
    return Usuario.fromMap(response);
  }

  Future<void> atualizarUsuario(Usuario usuario) async {
    await client.from('usuarios').update(usuario.toMap()).eq('id', usuario.id);
  }

  // -------------------- Atividades --------------------
  // Retorna todas as atividades (independente do status)
  Future<List<Atividade>> getTodasAtividades() async {
    final response = await client
        .from('atividades')
        .select('*')
        .order('data_inicio', ascending: false);
    return (response as List)
        .map((atividade) => Atividade.fromMap(atividade))
        .toList();
  }

  // Retorna apenas as atividades com status "em andamento"
  Future<List<Atividade>> getAtividadesAtivas() async {
    final all = await getTodasAtividades();
    return all
        .where((atividade) => atividade.status == 'em andamento')
        .toList();
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
    // Remove duplicatas:
    return nomes.toSet().toList();
  }

  // Verifica se um usuário (não anônimo) contribuiu para uma atividade
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

  // -------------------- Doações --------------------
  Future<void> confirmarDoacaoComExcedente(String id) async {
    // Busca a doação pelo id
    final doacaoResponse =
        await client.from('doacoes').select('*').eq('id', id).single();
    final doacao = Doacao.fromMap(doacaoResponse);

    if (doacao.atividadeId != null) {
      // Doação vinculada a uma atividade: busca os itens da atividade
      final atividadeResponse = await client
          .from('atividades')
          .select('itens')
          .eq('id', doacao.atividadeId!)
          .single();
      List<dynamic> itens = atividadeResponse['itens'];
      bool itemEncontrado = false;

      // Procura o item correspondente (baseado em tipo, gênero e tamanho)
      for (int i = 0; i < itens.length; i++) {
        final item = itens[i];
        if (item['tipo_roupa'] == doacao.tipoRoupa &&
            item['genero'] == doacao.genero &&
            item['tamanho'] == doacao.tamanho) {
          itemEncontrado = true;
          // Obter o valor restante e o valor total solicitado
          int quantidadeRestante = item['quantidade'] as int;
          if (doacao.quantidade >= quantidadeRestante) {
            int excedente = doacao.quantidade - quantidadeRestante;
            // Atualiza o item para indicar que a necessidade foi atendida (quantidade zerada)
            itens[i] = {
              ...item,
              'quantidade': 0,
              // Mantém 'quantidade_total' inalterada
            };
            if (excedente > 0) {
              // Se houve excedente, o direciona para o estoque
              await _atualizarEstoque(
                tipo: doacao.tipoRoupa,
                genero: doacao.genero,
                tamanho: doacao.tamanho,
                quantidade: excedente,
              );
            }
          } else {
            // Doação parcial: subtrai a quantidade doada do valor restante
            itens[i] = {
              ...item,
              'quantidade': quantidadeRestante - doacao.quantidade,
            };
          }
          // Atualiza o status da doação para confirmada
          await client
              .from('doacoes')
              .update({'status': 'confirmada'}).eq('id', id);
          // Atualiza os itens da atividade
          await client
              .from('atividades')
              .update({'itens': itens}).eq('id', doacao.atividadeId!);
          break;
        }
      }
      if (!itemEncontrado) {
        // Se não encontrou um item correspondente, rejeita a doação
        await client
            .from('doacoes')
            .update({'status': 'rejeitada'}).eq('id', id);
      } else {
        // Se todos os itens da atividade foram atendidos (quantidade == 0), marca a atividade como concluída
        bool todosZerados =
            itens.every((item) => (item['quantidade'] as int) == 0);
        if (todosZerados) {
          await client
              .from('atividades')
              .update({'status': 'concluída'}).eq('id', doacao.atividadeId!);
        }
      }
    } else {
      // Doação para o estoque geral (não vinculada a uma atividade)
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

  // Atualiza o estoque geral: se o item já existe, soma a quantidade; senão, insere um novo registro
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
