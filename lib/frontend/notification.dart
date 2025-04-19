import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'weather.dart';
import 'weather_service.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String formatTimestamp(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  List<Weather> weatherList = [];
  bool isLoadingWeather = true;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      final weatherService = WeatherService();
      final weatherData = await weatherService.getWeatherForecast();
      setState(() {
        weatherList = weatherData;
        isLoadingWeather = false;
      });
    } catch (e) {
      setState(() {
        isLoadingWeather = false;
      });
      print('Error fetching weather: $e');
    }
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วนสภาพอากาศ
            Text("Weather", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            isLoadingWeather
                ? Center(child: CircularProgressIndicator())
                : weatherList.isEmpty
                    ? Text("Unable to load weather data")
                    : Container(
                        height: 150,
                        child: ListView.builder(
                          itemCount: weatherList.length,
                          itemBuilder: (context, index) {
                            final weather = weatherList[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: Icon(
                                  weather.condition.contains('Clear')
                                      ? Icons.wb_sunny
                                      : weather.condition.contains('Cloud')
                                          ? Icons.cloud
                                          : Icons.wb_cloudy,
                                ),
                                title: Text(weather.day),
                                subtitle: Text('Bangkok'),
                                trailing: Text('${weather.temperature.toStringAsFixed(0)}°'),
                              ),
                            );
                          },
                        ),
                      ),
            SizedBox(height: 20),

            // ส่วนประกาศ
            Text("ประกาศทั้งหมด", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('announcements')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator());

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                    return Center(child: Text("ยังไม่มีประกาศ", style: TextStyle(fontSize: 18)));

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final title = data['title'] ?? '';
                      final description = data['description'] ?? '';
                      final imageUrl = data['imageUrl'];
                      final timestamp = (data['timestamp'] as Timestamp).toDate();

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: ListTile(
                          leading: imageUrl != null
                              ? CircleAvatar(backgroundImage: NetworkImage(imageUrl))
                              : CircleAvatar(child: Icon(Icons.campaign)),
                          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(formatTimestamp(timestamp), style: TextStyle(fontSize: 12)),
                                SizedBox(height: 4),
                                Text(
                                  description,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}