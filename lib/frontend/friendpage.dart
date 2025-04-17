import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendPage extends StatelessWidget {
  final String name;
  final String imageUrl;

  FriendPage({required this.name, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.orangeAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('favorites').add({
                'name': name,
                'imageUrl': imageUrl,
              });
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$name added to favorites')));
            },
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              backgroundImage: NetworkImage(imageUrl),
              radius: 50,
            ),
            SizedBox(height: 20),
            Text(
              name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('25 September 2004'), // แทนที่ด้วยข้อมูลวันเกิดจริง
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: เพิ่มโค้ด chat
              },
              icon: Icon(Icons.chat_bubble),
              label: Text('Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
