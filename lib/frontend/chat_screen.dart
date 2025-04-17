import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // รายการข้อความ (Dynamic)
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hello',
      'isMe': false,
      'time': '23:30',
      'image': null,
    },
    {
      'text': 'Hello',
      'isMe': true,
      'time': '23:31',
      'image': null,
    },
    {
      'text': 'Where are you ?',
      'isMe': false,
      'time': '23:32',
      'image': null,
    },
    {
      'text': null,
      'isMe': true,
      'time': '23:33',
      'image':
          'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcQUXtQBmOKisSZxB68gPyrYzvjFgkgXKXew7gNdGTrIukqwlGJ9rVN4d5r01fwir3S7ifEgWWIkIBZ-yoiBAag6WQ', // Placeholder สำหรับรูปภาพ
    },
  ];

  final TextEditingController _messageController = TextEditingController();

  // ฟังก์ชันสำหรับส่งข้อความ
  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        _messages.add({
          'text': _messageController.text,
          'isMe': true,
          'time': '23:${DateTime.now().minute}', // เวลาแบบจำลอง
          'image': null,
        });
        _messageController.clear(); // ล้างช่องพิมพ์หลังส่ง
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Sutarnthip Luangthip'),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              // เพิ่มการทำงานของปุ่มเมนูตรงนี้
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ส่วนแชท
          Expanded(
            child: Container(
              color: Colors.cyan[100], // พื้นหลังสีฟ้าอ่อน
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isMe = message['isMe'] as bool;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!isMe) // รูปโปรไฟล์ (ซ้าย) สำหรับผู้ใช้คนอื่น
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[300],
                            child: Icon(Icons.person, color: Colors.grey[600]),
                          ),
                        if (!isMe) SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (message['text'] != null) // แสดงข้อความถ้ามี
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isMe ? Colors.orange : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  message['text'],
                                  style: TextStyle(
                                      color:
                                          isMe ? Colors.white : Colors.black),
                                ),
                              ),
                            if (message['image'] != null) // แสดงรูปภาพถ้ามี
                              Container(
                                margin: EdgeInsets.only(top: 8),
                                child: Image.network(
                                  message['image'],
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            SizedBox(height: 4),
                            Text(
                              message['time'],
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        if (isMe) SizedBox(width: 8),
                        if (isMe) // รูปโปรไฟล์ (ขวา) สำหรับผู้ใช้ปัจจุบัน
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[300],
                            child: Icon(Icons.person, color: Colors.grey[600]),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          // ช่องพิมพ์ข้อความ
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.attach_file),
                  onPressed: () {
                    // เพิ่มการทำงานของปุ่มแนบไฟล์ตรงนี้
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage, // เรียกฟังก์ชันส่งข้อความ
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}