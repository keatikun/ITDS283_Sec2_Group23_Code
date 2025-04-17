import 'package:flutter/material.dart';
import 'search.dart';

class ChatScreen extends StatelessWidget {
  final List<Map<String, dynamic>> chats = [
    {
      'name': 'Sutarnthip Luangthip',
      'message': 'Send Photo',
      'imageUrl': 'https://via.placeholder.com/50',
      'date': 'Today',
      'unread': 3,
    },
    {
      'name': 'Siradanai Ektananjit',
      'message': 'Hi guys',
      'imageUrl': 'https://via.placeholder.com/50',
      'date': 'Thursday',
      'unread': 5,
    },
    {
      'name': 'Kornwisarut Supataravanich',
      'message': 'Send Photo',
      'imageUrl': 'https://via.placeholder.com/50',
      'date': 'Thursday',
      'unread': 1,
    },
    {
      'name': 'Pornpawee Pathompornwiwat',
      'message': 'This time it ain’t just about being fast.',
      'imageUrl': 'https://via.placeholder.com/50',
      'date': 'Thursday',
      'unread': 2,
    },
    {
      'name': 'Kittisak Yamdee',
      'message': 'We talkin’ or we racin’?',
      'imageUrl': 'https://via.placeholder.com/50',
      'date': 'Thursday',
      'unread': 5,
    },
    {
      'name': 'Yurikurami Puttachat',
      'message': 'Ride or die, remember?',
      'imageUrl': 'https://via.placeholder.com/50',
      'date': 'Wednesday',
      'unread': 7,
    },
    {
      'name': 'Dominic Toretto',
      'message': 'I don’t have friends, I got family.',
      'imageUrl': 'https://via.placeholder.com/50',
      'date': 'Wednesday',
      'unread': 8,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        backgroundColor: Colors.orangeAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );},
          ),
        ],
      ),
      body: Container(
        color: Colors.lightBlueAccent[100],
        child: ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            return ChatTile(
              name: chat['name'],
              message: chat['message'],
              imageUrl: chat['imageUrl'],
              date: chat['date'],
              unread: chat['unread'],
            );
          },
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   items: [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.chat_bubble_outline),
      //       label: 'Chat',
      //     ),
      //     BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
      //   ],
      //   onTap: (index) {
      //     if (index == 0) {
      //       // กลับไปหน้า HomeScreen เมื่อกดไอคอน Home
      //       Navigator.pushNamed(context, '/');
      //     } else if (index == 2) {
      //       // ไปหน้า NotificationScreen เมื่อกดไอคอน Notifications
      //       Navigator.pushNamed(context, '/notifications');
      //     }
      //   },
      // ),
    );
  }
}

class ChatTile extends StatelessWidget {
  final String name;
  final String message;
  final String imageUrl;
  final String date;
  final int unread;

  ChatTile({
    required this.name,
    required this.message,
    required this.imageUrl,
    required this.date,
    required this.unread,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
            radius: 25,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(date, style: TextStyle(color: Colors.black54)),
                  ],
                ),
                SizedBox(height: 5),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(message),
                      if (unread > 0)
                        Text(
                          unread.toString(),
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}