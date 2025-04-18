import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'search_screen.dart';
import 'chat_setting_screen.dart';

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

    final timestamp = FieldValue.serverTimestamp();

    // ส่งข้อความไปยัง messages subcollection
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': currentUserId,
      'text': text,
      'timestamp': timestamp,
    });

    // ดึงชื่อและรูปของผู้ใช้ปัจจุบัน (กรณี login ใหม่แล้วไม่มีใน Firestore)
    final currentUserName = _auth.currentUser?.displayName ?? 'ไม่ระบุชื่อ';
    final currentUserPhoto = _auth.currentUser?.photoURL ?? '';

    // บันทึกหรืออัปเดตข้อมูลหลักของแชท
    await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
      'users': [currentUserId, widget.userId],
      'lastMessage': text,
      'lastTimestamp': timestamp,
      'userInfo': {
        currentUserId!: {
          'name': currentUserName,
          'imageUrl': currentUserPhoto,
        },
        widget.userId: {
          'name': widget.name,
          'imageUrl': widget.imageUrl,
        },
      },
    }, SetOptions(merge: true));
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
      backgroundColor: const Color(0xFF6EDFF6),
      appBar: AppBar(
        title: Text(widget.name),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
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
            icon: const Icon(Icons.menu),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatSettingScreen(),
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
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['senderId'] == currentUserId;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment:
                            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          if (!isMe)
                            const CircleAvatar(radius: 16, child: Icon(Icons.person)),
                          if (!isMe) const SizedBox(width: 8),
                          Container(
                            constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.7),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.orange : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20),
                                topRight: const Radius.circular(20),
                                bottomLeft:
                                    isMe ? const Radius.circular(20) : const Radius.circular(0),
                                bottomRight:
                                    isMe ? const Radius.circular(0) : const Radius.circular(20),
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
                                const SizedBox(height: 4),
                                Text(
                                  _formatTimestamp(msg['timestamp']),
                                  style:
                                      TextStyle(fontSize: 10, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                          if (isMe) const SizedBox(width: 8),
                          if (isMe)
                            const CircleAvatar(radius: 16, child: Icon(Icons.person)),
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
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: Text(label, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
              ),
            ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.attach_file), onPressed: () {}),
                IconButton(icon: const Icon(Icons.camera_alt), onPressed: () {}),
                IconButton(icon: const Icon(Icons.photo), onPressed: () {}),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'พิมพ์ข้อความ...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
                    icon: const Icon(Icons.more_vert), onPressed: _toggleQuickReply),
                IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => _sendMessage(null)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
