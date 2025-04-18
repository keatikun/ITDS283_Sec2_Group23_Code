import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchScreen extends StatefulWidget {
  final String chatId;

  const SearchScreen({Key? key, required this.chatId}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<QueryDocumentSnapshot> _searchResults = [];

  void _searchMessages() async {
    if (_searchController.text.trim().isEmpty) return;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .where('text', isGreaterThanOrEqualTo: _searchController.text.trim())
        .where('text', isLessThanOrEqualTo: _searchController.text.trim() + '\uf8ff')
        .get();

    setState(() {
      _searchResults = querySnapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ค้นหาข้อความ'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ค้นหาข้อความ...',
                border: OutlineInputBorder(),
              ),
              onChanged: (text) => _searchMessages(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final msg = _searchResults[index];
                return ListTile(
                  title: Text(msg['text']),
                  subtitle: Text('เวลา: ${_formatTimestamp(msg['timestamp'])}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final dateTime = timestamp.toDate();
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
