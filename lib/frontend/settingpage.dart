import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingPage extends StatelessWidget {
  // ฟังก์ชันสำหรับล็อกเอาท์
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ล็อกเอาท์สำเร็จ')),
      );
      // นำทางไปยังหน้า Login และแทนที่กองซ้อนการนำทางทั้งหมด
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการล็อกเอาท์: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setting'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Stack(
                children: <Widget>[
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.edit, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildSettingItem('Name', 'U6687001'),
            _buildSettingItem('Email', 'Keatikun.komkeng@student.mahidol.ac.th'),
            _buildSettingItem('Phone', '0825204864'),
            _buildSettingItem('First Name', 'Keatikun'),
            _buildSettingItem('Last Name', 'Komkeng'),
            SizedBox(height: 20),
            ListTile(
              title: Text('Logout', style: TextStyle(color: Colors.red)),
              trailing: Icon(Icons.logout, color: Colors.red),
              onTap: () => _logout(context), // เรียกฟังก์ชันล็อกเอาท์
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(String title, String value) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value),
      trailing: Icon(Icons.edit),
      onTap: () {
        // TODO: เพิ่มโค้ดแก้ไขข้อมูล
      },
    );
  }
}