// lib/frontend/notification.dart
import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  final weatherData = [
    {'day': 'Today', 'temp': '37°', 'icon': Icons.wb_sunny},
    {'day': 'Monday', 'temp': '30°', 'icon': Icons.cloud},
    {'day': 'Tuesday', 'temp': '25°', 'icon': Icons.water_drop},
    {'day': 'Wednesday', 'temp': '27°', 'icon': Icons.cloud},
    {'day': 'Thursday', 'temp': '29°', 'icon': Icons.wb_sunny},
  ];

  final todayNews = [
    {'img': 'https://randomuser.me/api/portraits/men/1.jpg', 'text': 'การจราจรติดขัดแถวพระราม2'},
    {'img': 'https://randomuser.me/api/portraits/men/2.jpg', 'text': 'หน้าเดอะมอลบางแคมีการทำท่อ'},
    {'img': 'https://randomuser.me/api/portraits/women/3.jpg', 'text': 'ศาลายาฝนตกหนักระวังถนนลื่น'},
  ];

  final yesterdayNews = [
    {'img': 'https://randomuser.me/api/portraits/women/4.jpg', 'text': 'เทพารักษ์รถติดหนักมาก'},
    {'img': 'https://randomuser.me/api/portraits/women/5.jpg', 'text': 'ซอยตั้งสินน้ำท่วมหลีกเลี่ยงการใช้เส้นทางนี้'},
    {'img': 'https://randomuser.me/api/portraits/women/6.jpg', 'text': 'มีอุบัติเหตุแถวถนนอักษะ'},
  ];

  Widget buildWeatherCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: weatherData.map((item) {
            return ListTile(
              leading: Icon(item['icon'] as IconData),
              title: Text(item['day'] as String),
              subtitle: Text("Bangkok"),
              trailing: Text(item['temp'] as String, style: TextStyle(fontSize: 22)),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildNewsSection(String title, List<Map<String, String>> newsList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: newsList.map((item) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(item['img']!),
                ),
                title: Text(item['text']!),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent[100],
      appBar: AppBar(
        title: Text("Notification"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text("Weather", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            buildWeatherCard(),
            const SizedBox(height: 20),
            buildNewsSection("Today", todayNews),
            const SizedBox(height: 20),
            buildNewsSection("Yesterday", yesterdayNews),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   items: [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.chat_bubble_outline),
      //       label: 'Chat',
      //     ),
      //     BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
      //   ],
      //   onTap: (index) {
      //     if (index == 1) {
      //       // ไปหน้า ChatScreen เมื่อกดไอคอน Chat
      //       Navigator.pushNamed(context, '/chat');
      //     } else if (index == 0) {
      //       // ไปหน้า NotificationScreen เมื่อกดไอคอน Notifications
      //       Navigator.pushNamed(context, '/');
      //     }
      //   },
      // ),
    );
  }
}
