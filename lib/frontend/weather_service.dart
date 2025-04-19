import 'dart:convert';
import 'package:http/http.dart' as http;
import 'weather.dart';

class WeatherService {
  static const String apiKey = '0c5dda34cf8cde9e1b5f10f30fb2d427'; // ใช้ API Key จากภาพ
  static const String city = 'Bangkok';
  static const String url =
      'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric';

  Future<List<Weather>> getWeatherForecast() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> list = data['list'];

      // ดึงข้อมูล 5 วัน (เลือกข้อมูลวันละ 1 ช่วงเวลา เช่น 12:00)
      List<Weather> weatherList = [];
      List<String> days = ['Today', 'Monday', 'Tuesday', 'Wednesday', 'Thursday'];
      int dayIndex = 0;

      for (var i = 0; i < list.length && dayIndex < 5; i++) {
        if (list[i]['dt_txt'].contains('12:00:00')) {
          weatherList.add(Weather.fromJson(list[i], days[dayIndex]));
          dayIndex++;
        }
      }
      return weatherList;
    } else {
      throw Exception('Failed to load weather data: ${response.statusCode}');
    }
  }
}