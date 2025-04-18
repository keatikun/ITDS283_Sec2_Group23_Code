import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateUserScreen extends StatefulWidget {
  @override
  _CreateUserScreenState createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();

  File? _profileImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      emailController.text = user.email ?? '';
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        birthdayController.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  bool _isEmailValid(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _isPhoneValid(String phone) {
    final phoneRegex = RegExp(r'^[0-9]{9,15}$'); // ตัวเลข 9-15 หลัก
    return phoneRegex.hasMatch(phone);
  }

  Future<String?> _uploadProfileImage(File imageFile, String uid) async {
  try {
    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child('$uid.jpg');

    final uploadTask = await ref.putFile(imageFile);
    final url = await ref.getDownloadURL();
    print("Download URL: $url"); // 👈 log เพื่อตรวจสอบ
    return url;
  } catch (e) {
    print('Upload error: $e');
    return null;
  }
}

  Future<void> _submitData() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final phone = phoneController.text.trim();
    final birthday = birthdayController.text.trim();
    

    if (name.isEmpty ||
        email.isEmpty ||
        firstName.isEmpty ||
        lastName.isEmpty ||
        phone.isEmpty ||
        birthday.isEmpty ||
        _profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบและเลือกรูปภาพ')),
      );
      return;
    }

    if (!_isEmailValid(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('รูปแบบอีเมลไม่ถูกต้อง')),
      );
      return;
    }

    if (!_isPhoneValid(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณาใส่เบอร์โทรศัพท์ให้ถูกต้อง (เฉพาะตัวเลข 9-15 หลัก)')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('User not signed in');

      String? profileImageUrl = await _uploadProfileImage(_profileImage!, uid);

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'displayName': name,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'birthday': birthday,
        'profileImageUrl': profileImageUrl,
        'createdAt': Timestamp.now(),
      });

      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print('Error saving user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create User'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile image + name
                  Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : null,
                            backgroundColor: Colors.grey[300],
                            child: _profileImage == null
                                ? Icon(Icons.person,
                                    size: 40, color: Colors.grey[600])
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.blue,
                                child: Icon(Icons.edit,
                                    size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: nameController,
                          decoration:
                              InputDecoration(labelText: 'Chat Display Name'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: birthdayController,
                    readOnly: true,
                    onTap: _pickDate,
                    decoration: InputDecoration(
                      labelText: 'Birthday (YYYY-MM-DD)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submitData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        Text('Create', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
    );
  }
}
