import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),

      appBar: AppBar(
        backgroundColor: const Color(0xFF4F8F63),
        title: const Text('Sobre Nós'),
      ),

      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Radar Civil',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 20),

            Text(
              'O Radar Civil é uma plataforma desenvolvida para facilitar o acompanhamento das proposições da Câmara dos Deputados, promovendo transparência e acesso à informação para todos os cidadãos.',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),

            SizedBox(height: 20),

            Text(
              'Projeto acadêmico desenvolvido para incentivar a participação cidadã e a fiscalização das atividades legislativas.',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}