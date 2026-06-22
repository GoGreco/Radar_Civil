import 'package:flutter/material.dart';
import '../models/post.dart';

class DetailScreen extends StatelessWidget {
  final Post post;

  const DetailScreen(this.post, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalhes"),
        backgroundColor: const Color(0xFF4F8F63),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFF4F8F63),
              padding: const EdgeInsets.symmetric(
                vertical: 25,
              ),
              child: const Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xFF4F8F63),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Câmara dos Deputados',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Chip(
                        label: Text(post.tipo),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(post.ano),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Text(
                    post.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          post.date.isEmpty
                              ? "Data não informada"
                              : post.date,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFE3C34B),
                        foregroundColor:
                            Colors.black,
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                      onPressed: () {},
                      icon:
                          const Icon(Icons.language),
                      label: const Text(
                        "Ver Original",
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon:
                          const Icon(Icons.arrow_back),
                      label: const Text("Voltar"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}