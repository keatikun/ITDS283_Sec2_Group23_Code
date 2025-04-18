import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';


class FriendPage extends StatefulWidget {
  final String name;
  final String imageUrl;
  final String uid; // เพิ่ม uid สำหรับระบุผู้ใช้

  FriendPage({required this.name, required this.imageUrl, required this.uid});

  @override
  _FriendPageState createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  bool isFavorite = false;
  String? favoriteDocId;
  String? currentUserId;
  String birthday = 'กำลังโหลด...';

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null) {
      checkIfFavorite();
    }
    fetchBirthday();
  }

  Future<void> checkIfFavorite() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('favorites')
        .where('uid', isEqualTo: currentUserId)
        .where('friendUid', isEqualTo: widget.uid)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        isFavorite = true;
        favoriteDocId = snapshot.docs.first.id;
      });
    } else {
      setState(() {
        isFavorite = false;
        favoriteDocId = null;
      });
    }
  }

  Future<void> fetchBirthday() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get();

    if (snapshot.exists) {
      final data = snapshot.data();
      setState(() {
        birthday = data?['birthday'] ?? 'ไม่พบข้อมูล';
      });
    } else {
      setState(() {
        birthday = 'ไม่พบข้อมูล';
      });
    }
  }

  Future<void> toggleFavorite() async {
  if (currentUserId == null) return;

  if (isFavorite) {
    if (favoriteDocId != null) {
      await FirebaseFirestore.instance
          .collection('favorites')
          .doc(favoriteDocId)
          .delete();
      setState(() {
        isFavorite = false;
        favoriteDocId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.name} ลบออกจากรายการโปรดแล้ว')),
      );
    }
  } else {
    final docRef = await FirebaseFirestore.instance.collection('favorites').add({
      'uid': currentUserId,
      'friendUid': widget.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      isFavorite = true;
      favoriteDocId = docRef.id;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.name} ถูกเพิ่มในรายการโปรด')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        backgroundColor: Colors.orangeAccent,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: toggleFavorite,
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              backgroundImage: NetworkImage(widget.imageUrl),
              radius: 50,
            ),
            SizedBox(height: 20),
            Text(
              widget.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('วันเกิด: $birthday'),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: เพิ่มโค้ด chat
                Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  userId: widget.uid,
                  name: widget.name,
                  imageUrl: widget.imageUrl,
                ),
              ),
            );
          },
              icon: Icon(Icons.chat_bubble),
              label: Text('Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
