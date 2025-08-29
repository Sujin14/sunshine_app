import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'sunshine_data.dart';
import 'api_service.dart';

class SunshineProvider with ChangeNotifier {
  List<SunshineData> data = [];
  bool isLoading = false;
  String error = '';
  String viewMode = 'Hourly';
  DateTime selectedDate = DateTime.now();
  int selectedHour = 12; // Default to noon

  final ApiService apiService = ApiService();

  Future<void> fetchData() async {
    isLoading = true;
    error = '';
    notifyListeners();

    try {
      if (viewMode == 'Hourly') {
        data = await apiService.fetchHourlyData(DateFormat('yyyy-MM-dd').format(selectedDate));
      } else {
        data = await apiService.fetchDailyData(DateFormat('yyyy-MM').format(selectedDate));
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<double> fetchHistoricalAverage() async {
    try {
      final historicalData = await apiService.fetchHistoricalData(DateFormat('yyyy').format(selectedDate));
      return historicalData.map((d) => d.sunshineHours).reduce((a, b) => a + b) / historicalData.length;
    } catch (e) {
      return 0.0;
    }
  }

  void changeViewMode(String mode) {
    viewMode = mode;
    selectedHour = 12; // Reset to noon when changing mode
    fetchData();
  }

  void changeDate(DateTime date) {
    selectedDate = date;
    fetchData();
  }

  void updateSelectedHour(int hour) {
    selectedHour = hour;
    notifyListeners();
  }
}