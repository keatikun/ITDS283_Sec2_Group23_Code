import 'package:flutter/material.dart';

class ChatSettingScreen extends StatelessWidget {
  const ChatSettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // สีพื้นหลังขาว
      appBar: AppBar(
        title: Text("การตั้งค่าแชท"),
        backgroundColor: Colors.orange, // สี Navbar ส้ม
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.insert_drive_file, color: Colors.orange),
            title: Text("ดูไฟล์"),
            onTap: () {
              // ทำอะไรบางอย่าง เช่น เปิดหน้ารายการไฟล์
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('ยังไม่ได้เชื่อมกับระบบดูไฟล์')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.photo_library, color: Colors.orange),
            title: Text("รูปภาพ"),
            onTap: () {
              // ทำอะไรบางอย่าง เช่น เปิดหน้ารูปภาพในแชท
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('ยังไม่ได้เชื่อมกับระบบรูปภาพ')),
              );
            },
          ),
        ],
      ),
    );
  }
}
