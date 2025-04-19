import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart'; // นำเข้า chat_screen.dart

// Wrapper เพื่อใช้ใน MainScreen โดยไม่ต้องส่งพารามิเตอร์
class ChatScreenWrapper extends StatelessWidget {
  const ChatScreenWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6EDFF6),
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
      body: const ChatPage(), // ใช้ ChatPage เพื่อแสดงรายการแชท
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final currentUser = FirebaseAuth.instance.currentUser;

  // ฟังก์ชันสำหรับแปลง Timestamp เป็น String
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final dateTime = timestamp.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return 'Today';
    } else {
      // แสดงเป็นชื่อวัน (เช่น "Thursday")
      final daysOfWeek = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ];
      return daysOfWeek[dateTime.weekday - 1];
    }
  }

  // ฟังก์ชันจำลองจำนวนข้อความใหม่ (ตามภาพ)
  String _getMessageCount(int index) {
    // จำลองตัวเลขตามภาพ
    final counts = ['3', '5', '1', '2', '5', '7', '8'];
    return counts[index % counts.length];
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(child: Text('Error: User not logged in'));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.hasError) {
          print('Error fetching user data: ${userSnapshot.error}');
          return const Center(child: Text('Error loading user data'));
        }

        if (!userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
        if (userData == null) {
          print('User data is null for user: ${currentUser!.uid}');
          return const Center(child: Text('No user data found'));
        }

        // แก้ไขการจัดการ chats เพื่อรองรับทั้ง String และ List
        final chatIdsRaw = userData['chats'];
        final List<String> chatIds;
        if (chatIdsRaw is String) {
          chatIds = [chatIdsRaw];
        } else if (chatIdsRaw is Iterable) {
          chatIds = List<String>.from(chatIdsRaw);
        } else {
          chatIds = [];
        }

        print('Fetched chatIds: $chatIds');

        if (chatIds.isEmpty) {
          return const Center(child: Text('No chats available'));
        }

        // แบ่ง chatIds ออกเป็นกลุ่มย่อย (สูงสุด 10 รายการต่อกลุ่ม) เพื่อหลีกเลี่ยงข้อจำกัดของ whereIn
        const int batchSize = 10;
        final List<List<String>> chatIdBatches = [];
        for (int i = 0; i < chatIds.length; i += batchSize) {
          chatIdBatches.add(
            chatIds.sublist(
              i,
              i + batchSize > chatIds.length ? chatIds.length : i + batchSize,
            ),
          );
        }

        return ListView.builder(
          itemCount: chatIdBatches.length,
          itemBuilder: (context, batchIndex) {
            final batch = chatIdBatches[batchIndex];
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where(FieldPath.documentId, whereIn: batch)
                  .orderBy('lastTimestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print(
                      'Error fetching chats for batch $batch: ${snapshot.error}');
                  return const Center(child: Text('Error loading chats'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final chats = snapshot.data!.docs;
                if (chats.isEmpty) {
                  print('No chats found for batch: $batch');
                  return const SizedBox.shrink();
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final users = List<String>.from(chat['users'] ?? []);
                    final otherUserId = users.firstWhere(
                      (id) => id != currentUser!.uid,
                      orElse: () => '',
                    );
                    final userInfo =
                        Map<String, dynamic>.from(chat['userInfo'] ?? {});
                    final otherUser =
                        Map<String, dynamic>.from(userInfo[otherUserId] ?? {});

                    final name = (otherUser['name'] ?? '').toString().isNotEmpty
                        ? otherUser['name']
                        : 'Unknown';

                    // ดึง profileImageUrl จาก users collection ของ otherUserId
                    return StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(otherUserId)
                          .snapshots(),
                      builder: (context, otherUserSnapshot) {
                        if (otherUserSnapshot.hasError) {
                          print(
                              'Error fetching other user data for $otherUserId: ${otherUserSnapshot.error}');
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.grey[300],
                                  child: const Icon(Icons.person,
                                      color: Colors.white),
                                ),
                                title: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                subtitle: Text(
                                  chat['lastMessage'] ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _formatTimestamp(chat['lastTimestamp']),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.orange,
                                      ),
                                      child: Center(
                                        child: Text(
                                          _getMessageCount(index),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatScreen(
                                        userId: otherUserId,
                                        name: name,
                                        imageUrl: '',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }

                        if (!otherUserSnapshot.hasData) {
                          print('Loading data for otherUserId: $otherUserId');
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.grey[300],
                                  child: const Icon(Icons.person,
                                      color: Colors.white),
                                ),
                                title: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                subtitle: Text(
                                  chat['lastMessage'] ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _formatTimestamp(chat['lastTimestamp']),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.orange,
                                      ),
                                      child: Center(
                                        child: Text(
                                          _getMessageCount(index),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatScreen(
                                        userId: otherUserId,
                                        name: name,
                                        imageUrl: '',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }

                        final otherUserData = otherUserSnapshot.data!.data()
                            as Map<String, dynamic>?;
                        final imageUrl =
                            (otherUserData?['profileImageUrl'] ?? '')
                                .toString();
                        print('Fetched imageUrl for $otherUserId: $imageUrl');

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundImage: imageUrl.isNotEmpty
                                    ? NetworkImage(imageUrl)
                                    : const AssetImage(
                                            'assets/default_profile.png')
                                        as ImageProvider,
                                backgroundColor: Colors.grey[300],
                              ),
                              title: Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              subtitle: Text(
                                chat['lastMessage'] ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _formatTimestamp(chat['lastTimestamp']),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.orange,
                                    ),
                                    child: Center(
                                      child: Text(
                                        _getMessageCount(index),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      userId: otherUserId,
                                      name: name,
                                      imageUrl: imageUrl,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
