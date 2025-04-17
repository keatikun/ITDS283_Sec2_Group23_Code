import 'package:flutter/material.dart';
import 'announcement.dart';
import 'settingpage.dart';
import 'friendpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Keatikun Komkeng',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    CircleAvatar(
                      backgroundImage:
                          NetworkImage('https://via.placeholder.com/50'),
                    ),
                  ],
                ),
              ),

              /// Favorite Section
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(Icons.favorite_border, size: 30),
                    SizedBox(width: 8),
                    Text("Favorites", style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
              FavoriteList(),

              /// User List Section
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(Icons.group, size: 30),
                    SizedBox(width: 8),
                    Text("All Users", style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
              AllUserList(),
            ],
          ),
        ),
      ),
    );
  }
}

class UserTile extends StatelessWidget {
  final String name;
  final String imageUrl;
  final Function(String, String)? onTap;

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
              onTap!(name, imageUrl);
            }
          },
        ),
      ),
    );
  }
}

class FavoriteList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('favorites').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        final favoriteDocs = snapshot.data!.docs;
        return Column(
          children: favoriteDocs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return UserTile(
              name: data['name'],
              imageUrl: data['imageUrl'],
              onTap: (name, imageUrl) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FriendPage(name: name, imageUrl: imageUrl),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}

class AllUserList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        final users = snapshot.data!.docs;

        return Column(
          children: users.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = '${data['firstname']} ${data['lastname']}';
            final imageUrl = data['imageUrl'] ?? 'https://via.placeholder.com/50';
            return UserTile(
              name: name,
              imageUrl: imageUrl,
              onTap: (name, imageUrl) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FriendPage(name: name, imageUrl: imageUrl),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
