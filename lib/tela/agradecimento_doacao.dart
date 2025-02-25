import 'package:flutter/material.dart';

class Agradecimento extends StatelessWidget {
  final String nomeDoador;
  final int quantidade;
  final String tipoRoupa;

  const Agradecimento({
    super.key,
    required this.nomeDoador,
    required this.quantidade,
    required this.tipoRoupa,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Doação Registrada ✅',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone de confirmação
              Icon(
                Icons.check_circle,
                size: 100,
                color: Colors.green.shade600,
              ),
              const SizedBox(height: 30),

              // Mensagem principal
              Text(
                '$quantidade $tipoRoupa doados com sucesso!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),

              // Mensagem de agradecimento
              Text(
                'Obrigado, ${nomeDoador.isEmpty ? 'Anônimo' : nomeDoador}!',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),

              // Botão para voltar ao início
              ElevatedButton.icon(
                icon: const Icon(Icons.home, size: 24),
                label: const Text(
                  'Voltar para Início',
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
