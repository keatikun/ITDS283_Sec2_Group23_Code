import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AnnouncementScreen extends StatefulWidget {
  @override
  _AnnouncementScreenState createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String announcementTitle = '';
  String announcementDescription = '';
  File? _imageFile;

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<String?> _uploadToImgur(File imageFile) async {
    final clientId = '89df1b81c1baa77'; // เปลี่ยนเป็น Client-ID ของคุณถ้าจำเป็น
    final url = Uri.parse('https://api.imgur.com/3/image');

    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Client-ID $clientId',
        },
        body: {
          'image': base64Image,
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return data['data']['link'];
      } else {
        print('Imgur upload failed: ${data['data']['error']}');
        return null;
      }
    } catch (e) {
      print('Imgur upload error: $e');
      return null;
    }
  }

  Future<void> _uploadAnnouncement() async {
    String? imageUrl;

    if (_imageFile != null) {
      imageUrl = await _uploadToImgur(_imageFile!);
      if (imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ไม่สามารถอัปโหลดรูปภาพได้")),
        );
        return;
      }
    }

    final timestamp = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    await FirebaseFirestore.instance.collection('announcements').add({
      'title': announcementTitle,
      'description': announcementDescription,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("ประกาศถูกอัปโหลดเรียบร้อย")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Announcement'), backgroundColor: Colors.orangeAccent),
      body: Container(
        color: Colors.lightBlueAccent[100],
        padding: EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: Text("${selectedDate.toLocal()}".split(' ')[0], textAlign: TextAlign.center),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectTime(context),
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: Text("${selectedTime.format(context)}", textAlign: TextAlign.center),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(labelText: 'Announcement title', filled: true, fillColor: Colors.white),
              onChanged: (value) => setState(() => announcementTitle = value),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                child: Center(
                  child: _imageFile == null
                      ? Text('แตะเพื่อเลือกรูปภาพ')
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                child: TextField(
                  decoration: InputDecoration(hintText: 'Add description', border: InputBorder.none),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  onChanged: (value) => setState(() => announcementDescription = value),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.lightBlueAccent[100],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(icon: Icon(Icons.upload_file), onPressed: _uploadAnnouncement),
          ],
        ),
      ),
    );
  }
}
