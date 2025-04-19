import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationScreen extends StatelessWidget {
  Widget buildAnnouncementList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('announcements')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) return Text("No announcements yet.");

        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final title = data['title'] ?? '';
            final description = data['description'] ?? '';
            final imageUrl = data['imageUrl'];
            final timestamp = (data['timestamp'] as Timestamp).toDate();

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: imageUrl != null
                    ? CircleAvatar(backgroundImage: NetworkImage(imageUrl))
                    : CircleAvatar(child: Icon(Icons.campaign)),
                title: Text(title),
                subtitle: Text(
                  "${timestamp.toLocal().toString().split('.')[0]}\n$description",
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent[100],
      appBar: AppBar(title: Text("Notification"), backgroundColor: Colors.orangeAccent),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(children: [
          Text("ประกาศทั้งหมด", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          buildAnnouncementList(),
        ]),
      ),
    );
  }
}
