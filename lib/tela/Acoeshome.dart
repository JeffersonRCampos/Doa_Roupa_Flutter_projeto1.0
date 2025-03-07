import 'package:flutter/material.dart';
import 'package:doa_roupa/tela/criar_atividade.dart';
import 'package:doa_roupa/tela/estoque.dart';
import 'package:doa_roupa/tela/confirmar_doacoes.dart';
import 'package:doa_roupa/tela/doacao.dart';
import 'package:doa_roupa/tela/Vertodasatividades.dart';

class HomeActions extends StatelessWidget {
  final String? papelUsuario;
  final VoidCallback onAtualizar;

  const HomeActions({Key? key, this.papelUsuario, required this.onAtualizar})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          ElevatedButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const NovaDoacao(atividadeId: null)),
              );
              onAtualizar();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            child: const Text('Doar para o estoque',
                style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
          if (papelUsuario == 'admin') ...[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EstoqueGeral()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('Ver Estoque',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ConfirmarDoacoes()),
                );
                onAtualizar();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('Confirmar Doações',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CriarAtividade()),
                );
                if (result == true) {
                  onAtualizar();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('Criar Atividade',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VerTodasAtividades()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('Ver Todas atividades',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ],
        ],
      ),
    );
  }
}
