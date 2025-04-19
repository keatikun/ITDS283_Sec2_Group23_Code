import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _controllerMap = <String, TextEditingController>{};

  String uid = '';
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          uid = user.uid;
          userData = doc.data()!;
          // กำหนด controller ให้กับทุก field
          userData.forEach((key, value) {
            _controllerMap[key] = TextEditingController(text: value?.toString() ?? '');
          });
        });
      }
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final updates = <String, dynamic>{};
    _controllerMap.forEach((key, controller) {
      updates[key] = controller.text;
    });

    await FirebaseFirestore.instance.collection('users').doc(uid).update(updates);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('บันทึกข้อมูลเรียบร้อยแล้ว')),
    );
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacementNamed(context, '/login');
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
    if (userData.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Setting'), backgroundColor: Colors.orangeAccent),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Setting'),
        backgroundColor: Colors.orangeAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveChanges,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    userData['profileImageUrl'] ?? 'https://via.placeholder.com/150',
                  ),
                ),
              ),
              SizedBox(height: 20),
              ..._buildEditableFields(['displayName', 'birthday', 'phone', 'firstName', 'lastName']),
              SizedBox(height: 20),
              ListTile(
                title: Text('Logout', style: TextStyle(color: Colors.red)),
                trailing: Icon(Icons.logout, color: Colors.red),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildEditableFields(List<String> fields) {
  return fields.map((field) {
    final controller = _controllerMap[field];
    final isBirthday = field == 'birthday';

    return TextFormField(
      controller: controller,
      readOnly: isBirthday,
      onTap: isBirthday
          ? () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: controller!.text.isNotEmpty
                    ? DateTime.tryParse(controller.text) ?? DateTime.now()
                    : DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                controller.text = picked.toIso8601String().split('T')[0]; // yyyy-MM-dd
              }
            }
          : null,
      decoration: InputDecoration(
        labelText: field[0].toUpperCase() + field.substring(1),
        suffixIcon: isBirthday ? Icon(Icons.calendar_today) : null,
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'กรุณากรอก $field' : null,
    );
  }).toList();
}

}
