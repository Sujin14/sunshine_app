import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sunshine_data.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000';

  Future<List<SunshineData>> fetchHourlyData(String date) async {
    final r = await http.get(Uri.parse('$baseUrl/sunshine/hourly?date=$date'));
    if (r.statusCode != 200) throw Exception('Failed to load hourly data');
    final List list = json.decode(r.body);
    return list.map((e) => SunshineData.fromJson(e)).toList();
  }

  Future<List<SunshineData>> fetchDailyData(String month) async {
    final r = await http.get(Uri.parse('$baseUrl/sunshine/daily?month=$month'));
    if (r.statusCode != 200) throw Exception('Failed to load daily data');
    final List list = json.decode(r.body);
    return list.map((e) => SunshineData.fromJson(e)).toList();
  }

  Future<List<SunshineData>> fetchWeeklyData(String year, String month) async {
    final r = await http.get(Uri.parse('$baseUrl/sunshine/weekly?year=$year&month=$month'));
    if (r.statusCode != 200) throw Exception('Failed to load weekly data');
    final List list = json.decode(r.body);
    return list.map((e) => SunshineData.fromJson(e)).toList();
  }

  Future<List<SunshineData>> fetchMonthlyData(String year) async {
    final r = await http.get(Uri.parse('$baseUrl/sunshine/monthly?year=$year'));
    if (r.statusCode != 200) throw Exception('Failed to load monthly data');
    final List list = json.decode(r.body);
    return list.map((e) => SunshineData.fromJson(e)).toList();
  }

  Future<List<SunshineData>> fetchYearlyData(int startYear, int endYear) async {
    final r = await http.get(Uri.parse('$baseUrl/sunshine/yearly?start_year=$startYear&end_year=$endYear'));
    if (r.statusCode != 200) throw Exception('Failed to load yearly data');
    final List list = json.decode(r.body);
    return list.map((e) => SunshineData.fromJson(e)).toList();
  }

  Future<List<SunshineData>> fetchHistoricalData(String year) async {
    final r = await http.get(Uri.parse('$baseUrl/sunshine/historical?year=$year'));
    if (r.statusCode != 200) throw Exception('Failed to load historical data');
    final List list = json.decode(r.body);
    return list.map((e) => SunshineData.fromJson(e)).toList();
  }
}
