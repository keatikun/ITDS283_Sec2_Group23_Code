import 'package:flutter/material.dart';
import 'announcement.dart';
import 'settingpage.dart';
import 'friendpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String displayName = '';
  String profileImageUrl = '';
  String currentUid = '';

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

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
      body: currentUser == null
          ? Center(child: Text("Not logged in"))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final displayName = data['displayName'] ?? 'User';
                final profileImageUrl =
                    data['profileImageUrl'] ?? 'https://via.placeholder.com/50';

                return Container(
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
                              Text(
                                displayName,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              CircleAvatar(
                                backgroundImage: NetworkImage(profileImageUrl),
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
                        AllUserList(currentUserUid: currentUser.uid),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class UserTile extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String uid;
  final Function(String, String, String)? onTap;

  UserTile(
      {required this.name,
      required this.imageUrl,
      required this.uid,
      this.onTap});

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
              onTap!(name, imageUrl, uid);
            }
          },
        ),
      ),
    );
  }
}

class FavoriteList extends StatefulWidget {
  @override
  State<FavoriteList> createState() => _FavoriteListState();
}

class _FavoriteListState extends State<FavoriteList> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Center(child: Text("Not logged in"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('favorites')
          .where('uid', isEqualTo: currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        final favoriteDocs = snapshot.data!.docs;

        if (favoriteDocs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("No favorites yet."),
          );
        }

        return Column(
          children: favoriteDocs.map((favDoc) {
            final favData = favDoc.data() as Map<String, dynamic>;
            final friendUid = favData['friendUid'];

            // ⚠️ ดึงข้อมูลจาก users ทีละคน
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(friendUid)
                  .get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return ListTile(title: Text("Loading..."));
                }

                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                final name = userData['displayName'] ?? 'No Name';
                final imageUrl = userData['profileImageUrl'] ??
                    'https://via.placeholder.com/50';

                return UserTile(
                  name: name,
                  imageUrl: imageUrl,
                  uid: friendUid,
                  onTap: (name, imageUrl, uid) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FriendPage(
                            name: name, imageUrl: imageUrl, uid: uid),
                      ),
                    );
                  },
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
  final String currentUserUid;

  AllUserList({required this.currentUserUid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        final users = snapshot.data!.docs;

        final filteredUsers =
            users.where((doc) => doc.id != currentUserUid).toList();

        return Column(
          children: filteredUsers.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = data['displayName'] ?? 'No Name';
            final imageUrl =
                data['profileImageUrl'] ?? 'https://via.placeholder.com/50';
            final uid = doc.id;
            return UserTile(
              name: name,
              imageUrl: imageUrl,
              uid: uid,
              onTap: (name, imageUrl, uid) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FriendPage(name: name, imageUrl: imageUrl, uid: uid),
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
