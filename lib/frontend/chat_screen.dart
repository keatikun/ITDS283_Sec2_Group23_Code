import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'search_screen.dart';
import 'chat_setting_screen.dart';
import 'chatpage.dart';

class ChatScreen extends StatefulWidget {
  final String? userId;
  final String? name;
  final String? imageUrl;

  const ChatScreen({
    Key? key,
    this.userId,
    this.name,
    this.imageUrl,
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
  String? currentUserPhoto;
  String? otherUserPhoto;
  String? displayName;
  String? currentUserName;

  @override
  void initState() {
    super.initState();
    currentUserId = _auth.currentUser?.uid;
    if (currentUserId != null) {
      if (widget.userId != null) {
        final ids = [currentUserId!, widget.userId!]..sort();
        chatId = ids.join('_');
        print('Generated chatId: $chatId');
        print('currentUserId: $currentUserId, otherUserId: ${widget.userId}');
        _fetchUserPhotos();
        displayName = widget.name;
      } else {
        print('No userId provided, chatId not generated');
      }
      _fetchCurrentUserName(); // ดึงชื่อผู้ใช้ปัจจุบันจาก Firestore
    } else {
      print('Error: currentUserId is null');
    }
  }

  // ดึงชื่อผู้ใช้ปัจจุบันจาก Firestore
  Future<void> _fetchCurrentUserName() async {
    try {
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();
      if (currentUserDoc.exists) {
        final currentUserData = currentUserDoc.data();
        setState(() {
          currentUserName = currentUserData?['displayName']?.toString() ?? 'ไม่ระบุชื่อ';
        });
        print('Current user name from Firestore: $currentUserName');
      } else {
        print('Current user document does not exist: $currentUserId');
        setState(() {
          currentUserName = 'ไม่ระบุชื่อ';
        });
      }
    } catch (e) {
      print('Error fetching current user name: $e');
      setState(() {
        currentUserName = 'ไม่ระบุชื่อ';
      });
    }
  }

  // ดึง profileImageUrl จาก users collection
  Future<void> _fetchUserPhotos() async {
    try {
      // ดึง profileImageUrl ของผู้ใช้ปัจจุบัน
      print('Fetching profileImageUrl for currentUserId: $currentUserId');
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();
      if (!currentUserDoc.exists) {
        print('Current user document does not exist: $currentUserId');
        currentUserPhoto = '';
      } else {
        final currentUserData = currentUserDoc.data();
        currentUserPhoto = currentUserData?['profileImageUrl']?.toString() ?? '';
        print('Current user profileImageUrl: $currentUserPhoto');
      }

      // ดึง profileImageUrl และชื่อของผู้ใช้ที่แชทด้วย
      if (widget.userId != null) {
        print('Fetching profileImageUrl for otherUserId: ${widget.userId}');
        final otherUserDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .get();
        if (!otherUserDoc.exists) {
          print('Other user document does not exist: ${widget.userId}');
          otherUserPhoto = '';
          displayName = 'Unknown';
        } else {
          final otherUserData = otherUserDoc.data();
          otherUserPhoto = otherUserData?['profileImageUrl']?.toString() ?? '';
          displayName = widget.name ?? otherUserData?['displayName']?.toString() ?? 'Unknown';
          print('Other user data: $otherUserData');
          print('Other user profileImageUrl: $otherUserPhoto');
          print('Display name: $displayName');
        }
      }

      setState(() {});
    } catch (e) {
      print('Error fetching user photos: $e');
      setState(() {
        currentUserPhoto = '';
        otherUserPhoto = '';
        displayName = widget.name ?? 'Unknown';
      });
    }
  }

  void _sendMessage(String? messageText) async {
    if (widget.userId == null || chatId == null) {
      print('Cannot send message: userId or chatId is null');
      return;
    }

    final text = messageText ?? _messageController.text.trim();
    if (text.isEmpty || currentUserId == null) return;
    _messageController.clear();

    final timestamp = FieldValue.serverTimestamp();

    try {
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
      print('Message sent successfully to chats/$chatId/messages');

      // ใช้ currentUserName ที่ดึงจาก Firestore
      await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
        'users': [currentUserId, widget.userId],
        'lastMessage': text,
        'lastTimestamp': timestamp,
        'userInfo': {
          currentUserId!: {
            'name': currentUserName ?? 'ไม่ระบุชื่อ',
            'imageUrl': currentUserPhoto ?? '',
          },
          widget.userId!: {
            'name': displayName,
            'imageUrl': otherUserPhoto ?? '',
          },
        },
      }, SetOptions(merge: true));
      print('Updated chats/$chatId successfully');

      await FirebaseFirestore.instance.collection('users').doc(currentUserId).set({
        'chats': FieldValue.arrayUnion([chatId]),
      }, SetOptions(merge: true));
      print('Updated users/$currentUserId chats field');

      await FirebaseFirestore.instance.collection('users').doc(widget.userId).set({
        'chats': FieldValue.arrayUnion([chatId]),
      }, SetOptions(merge: true));
      print('Updated users/${widget.userId} chats field');
    } catch (e) {
      print('Error sending message: $e');
    }
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
    if (currentUserId == null) {
      return const Scaffold(
        body: Center(child: Text('Error: User not logged in')),
      );
    }

    if (widget.userId == null || chatId == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF6EDFF6),
        appBar: AppBar(
          title: const Text('Chat'),
          backgroundColor: Colors.orange,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatPage()),
                );
              },
            ),
          ],
        ),
        body: const Center(
          child: Text('Please select a chat to start messaging'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF6EDFF6),
      appBar: AppBar(
        title: Text(displayName ?? 'Chat'),
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
                if (snapshot.hasError) {
                  print('Error fetching messages: ${snapshot.error}');
                  return const Center(child: Text('Error loading messages'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;
                if (messages.isEmpty) {
                  print('No messages found in chats/$chatId/messages');
                  return const Center(child: Text('No messages yet'));
                }

                print('Loaded ${messages.length} messages');
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
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: otherUserPhoto != null && otherUserPhoto!.isNotEmpty
                                  ? NetworkImage(otherUserPhoto!)
                                  : const AssetImage('assets/default_profile.png') as ImageProvider,
                            ),
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
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: currentUserPhoto != null && currentUserPhoto!.isNotEmpty
                                  ? NetworkImage(currentUserPhoto!)
                                  : const AssetImage('assets/default_profile.png') as ImageProvider,
                            ),
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