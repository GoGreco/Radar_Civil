import 'package:flutter/material.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';

class HomeScreen extends StatelessWidget {
  final List<Post> posts = [
    Post(
      author: "Kim Namjoon",
      title: "COMISSÃO DE VIAÇÃO E TRANSPORTES",
      description: "Descrição exemplo do post...",
      date: "10 de março de 2020",
    ),
    Post(
      author: "Kim Namjoon",
      title: "COMISSÃO DE SHOWS",
      description: "Outro conteúdo exemplo...",
      date: "10 de março de 2020",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Projeto Consciência")),
      body: ListView(
        children: posts.map((p) => PostCard(p)).toList(),
      ),
    );
  }
}