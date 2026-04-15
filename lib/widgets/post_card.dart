import 'package:flutter/material.dart';
import '../models/post.dart';
import '../screens/detail_screen.dart';

class PostCard extends StatelessWidget {
  final Post post;

  PostCard(this.post);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.author, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text(post.title, style: TextStyle(fontSize: 16)),
            SizedBox(height: 5),
            Text(post.description, maxLines: 3, overflow: TextOverflow.ellipsis),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(post.date),
                TextButton(
                  child: Text("Ler mais"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(post),
                      ),
                    );
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}