import 'package:http/http.dart' as http;
import 'dart:convert';
import 'sunshine_data.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000';

  Future<List<SunshineData>> fetchHourlyData(String date) async {
    final response = await http.get(Uri.parse('$baseUrl/sunshine/hourly?date=$date'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => SunshineData.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load hourly data');
    }
  }

  Future<List<SunshineData>> fetchDailyData(String month) async {
    final response = await http.get(Uri.parse('$baseUrl/sunshine/daily?month=$month'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => SunshineData.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load daily data');
    }
  }

  Future<List<SunshineData>> fetchHistoricalData(String year) async {
    final response = await http.get(Uri.parse('$baseUrl/sunshine/historical?year=$year'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => SunshineData.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load historical data');
    }
  }
}