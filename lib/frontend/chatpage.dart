import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent[100],
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .orderBy('lastTimestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final users = List<String>.from(chat['users'] ?? []);
              final otherUserId = users
                  .firstWhere((id) => id != currentUser!.uid, orElse: () => '');
              final userInfo =
                  Map<String, dynamic>.from(chat['userInfo'] ?? {});
              final otherUser =
                  Map<String, dynamic>.from(userInfo[otherUserId] ?? {});

              final name = (otherUser['name'] ?? '').toString().isNotEmpty
                  ? otherUser['name']
                  : 'Unknown';
              final imageUrl = (otherUser['imageUrl'] ?? '').toString();

              return ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: imageUrl.isNotEmpty
                      ? NetworkImage(imageUrl)
                      : const AssetImage('assets/default_profile.png')
                          as ImageProvider,
                ),
                title: Text(name),
                subtitle: Text(chat['lastMessage'] ?? ''),
                onTap: () {
                  // ไปหน้าแชทจริง
                },
              );
            },
          );
        },
      ),
    );
  }
}
