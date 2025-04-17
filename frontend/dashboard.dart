import 'package:flutter/material.dart';
import 'announcement.dart';
import 'settingpage.dart';
import 'friendpage.dart'; // เพิ่ม import friendpage.dart

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.orangeAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.campaign),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AnnouncementScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.lightBlueAccent[100],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Keatikun Komkeng',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  CircleAvatar(
                    backgroundImage: NetworkImage('https://via.placeholder.com/50'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.favorite_border, size: 30),
            ),
            UserTile(name: 'Sutarnthip Luangthip', imageUrl: 'https://via.placeholder.com/50', onTap: (name, imageUrl) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FriendPage(name: name, imageUrl: imageUrl)),
              );
            }),
            UserTile(name: 'Siradanai Ektananjit', imageUrl: 'https://via.placeholder.com/50'),
            UserTile(name: 'Kittisak Yamdee', imageUrl: 'https://via.placeholder.com/50'),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.group, size: 30),
            ),
            UserTile(name: 'Kornwisarut Supataravanich', imageUrl: 'https://via.placeholder.com/50'),
            UserTile(name: 'Pornpawee Pathompornwiwat', imageUrl: 'https://via.placeholder.com/50'),
            UserTile(name: 'Yurikurami Puttachat', imageUrl: 'https://via.placeholder.com/50'),
          ],
        ),
      ),
    );
  }
}

class UserTile extends StatelessWidget {
  final String name;
  final String imageUrl;
  final Function(String, String)? onTap; // เพิ่ม onTap function

  UserTile({required this.name, required this.imageUrl, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
          ),
          title: Text(name),
          onTap: () {
            if (onTap != null) {
              onTap!(name, imageUrl); // เรียก onTap function เมื่อ UserTile ถูกคลิก
            }
          },
        ),
      ),
    );
  }
}