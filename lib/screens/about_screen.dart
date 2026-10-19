import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const AppDrawer(current: AppDrawerSection.sobreNos),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF4F8F63),
        centerTitle: true,
        title: const Text(
          'RADAR CIVIL',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
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