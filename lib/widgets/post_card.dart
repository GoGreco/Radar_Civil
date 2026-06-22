import 'package:flutter/material.dart';
import '../models/post.dart';
import '../screens/detail_screen.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard(this.post, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 12,
            decoration: const BoxDecoration(
              color: Color(0xFF4F8F63),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor:
                          Color(0xFF4F8F63),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        post.author,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Text(
                  post.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  post.description,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 16),

                Wrap(
                  spacing: 8,
                  children: [
                    Chip(
                      backgroundColor:
                          Colors.green.shade50,
                      label: Text(post.tipo),
                    ),
                    Chip(
                      backgroundColor:
                          Colors.green.shade50,
                      label: Text(post.ano),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        post.date.isEmpty
                            ? "Sem data"
                            : post.date,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFE3C34B),
                        foregroundColor:
                            Colors.black,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DetailScreen(post),
                          ),
                        );
                      },
                      child:
                          const Text("Ler mais"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}