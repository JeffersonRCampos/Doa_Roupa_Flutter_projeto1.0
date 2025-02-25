import 'package:flutter/material.dart';

class AgradecimentoAtividadePopup extends StatelessWidget {
  final String atividadeTitulo;
  final List<String> nomesContribuintes;

  const AgradecimentoAtividadePopup({
    super.key,
    required this.atividadeTitulo,
    required this.nomesContribuintes,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 50,
              color: Colors.green.shade600,
            ),
            const SizedBox(height: 15),
            const Text(
              'Atividade Concluída!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '"$atividadeTitulo"',
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Contribuidores:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: nomesContribuintes.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: nomesContribuintes.length,
                            itemBuilder: (context, index) => Text(
                              '• ${nomesContribuintes[index]}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          )
                        : const Text(
                            'Nenhum contribuinte registrado',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Fechar'),
            ),
          ],
        ),
      ),
    );
  }
}
