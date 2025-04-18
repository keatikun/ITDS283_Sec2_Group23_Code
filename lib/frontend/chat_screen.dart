import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'search_screen.dart';
import 'chat_setting_screen.dart'; // ✅ import หน้า ChatSetting

class ChatScreen extends StatefulWidget {
  final String userId;
  final String name;
  final String imageUrl;

  const ChatScreen({
    Key? key,
    required this.userId,
    required this.name,
    required this.imageUrl,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? currentUserId;
  late String chatId;
  bool _showQuickReply = false;

  @override
  void initState() {
    super.initState();
    currentUserId = _auth.currentUser?.uid;
    if (currentUserId != null) {
      final ids = [currentUserId!, widget.userId]..sort();
      chatId = ids.join('_');
    }
  }

  void _sendMessage(String? messageText) async {
    final text = messageText ?? _messageController.text.trim();
    if (text.isEmpty || currentUserId == null) return;
    _messageController.clear();

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': currentUserId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final dateTime = timestamp.toDate();
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _toggleQuickReply() {
    setState(() {
      _showQuickReply = !_showQuickReply;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF6EDFF6),
      appBar: AppBar(
        title: Text(widget.name),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SearchScreen(chatId: chatId),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatSettingScreen(), // ✅ เปิดหน้า ChatSetting
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['senderId'] == currentUserId;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6.0, horizontal: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!isMe)
                            CircleAvatar(radius: 16, child: Icon(Icons.person)),
                          if (!isMe) SizedBox(width: 8),
                          Container(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.7),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.orange : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                                bottomLeft: isMe
                                    ? Radius.circular(20)
                                    : Radius.circular(0),
                                bottomRight: isMe
                                    ? Radius.circular(0)
                                    : Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg['text'],
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _formatTimestamp(msg['timestamp']),
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                          if (isMe) SizedBox(width: 8),
                          if (isMe)
                            CircleAvatar(radius: 16, child: Icon(Icons.person)),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_showQuickReply)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'เริ่มส่งของ',
                  'ส่งของเสร็จแล้ว',
                  'กำลังส่งของ',
                  'รถเสีย',
                  'พัก',
                  'รถติด'
                ].map((label) {
                  return ElevatedButton(
                    onPressed: () => _sendMessage(label),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                    child: Text(label, style: TextStyle(color: Colors.white)),
                  );
                }).toList(),
              ),
            ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                IconButton(icon: Icon(Icons.attach_file), onPressed: () {}),
                IconButton(icon: Icon(Icons.camera_alt), onPressed: () {}),
                IconButton(icon: Icon(Icons.photo), onPressed: () {}),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'พิมพ์ข้อความ...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                IconButton(
                    icon: Icon(Icons.more_vert), onPressed: _toggleQuickReply),
                IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () => _sendMessage(null)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
