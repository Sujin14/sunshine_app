import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';
import 'sunshine_data.dart';

class SunshineProvider with ChangeNotifier {
  final ApiService apiService = ApiService();

  List<SunshineData> data = [];
  bool isLoading = false;
  String error = '';

  // Modes: Hourly, Daily, Weekly, Monthly, Yearly
  String viewMode = 'Hourly';

  DateTime selectedDate = DateTime.now();
  int selectedHour = 12; // Noon default for sun position

  Future<void> fetchData() async {
    isLoading = true;
    error = '';
    notifyListeners();

    try {
      if (viewMode == 'Hourly') {
        data = await apiService.fetchHourlyData(
          DateFormat('yyyy-MM-dd').format(selectedDate),
        );
      } else if (viewMode == 'Daily') {
        data = await apiService.fetchDailyData(
          DateFormat('yyyy-MM').format(selectedDate),
        );
      } else if (viewMode == 'Weekly') {
        data = await apiService.fetchWeeklyData(
          DateFormat('yyyy').format(selectedDate),
          DateFormat('MM').format(selectedDate),
        );
      } else if (viewMode == 'Monthly') {
        data = await apiService.fetchMonthlyData(
          DateFormat('yyyy').format(selectedDate),
        );
      } else if (viewMode == 'Yearly') {
        data = await apiService.fetchYearlyData(
          selectedDate.year - 10,
          selectedDate.year,
        );
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
      final historical = await apiService.fetchHistoricalData(
        DateFormat('yyyy').format(selectedDate),
      );
      if (historical.isEmpty) return 0.0;
      final total = historical
          .map((d) => d.sunshineHours)
          .reduce((a, b) => a + b);
      return total / historical.length;
    } catch (_) {
      return 0.0;
    }
  }

  void changeViewMode(String mode) {
    viewMode = mode;
    selectedHour = 12;
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

  // Helpers for chart rendering
  double computeMaxY() {
    if (data.isEmpty) return 12;
    final maxVal = data
        .map((e) => e.sunshineHours)
        .reduce((a, b) => a > b ? a : b);
    // Hourly caps at 12h, others can be large – scale with headroom
    if (viewMode == 'Hourly') return 12;
    return (maxVal * 1.2).clamp(12.0, 99999.0);
  }

  String xLabelForIndex(int i) {
    if (data.isEmpty || i < 0 || i >= data.length) return '';
    switch (viewMode) {
      case 'Hourly':
        return '$i:00';
      case 'Daily':
        // yyyy-MM-dd -> day
        return data[i].date.split('-').last;
      case 'Weekly':
        // e.g., W1..W4
        return 'W${i + 1}';
      case 'Monthly':
        // yyyy-MM -> month short
        final parts = data[i].date.split('-');
        final m = int.tryParse(parts.last) ?? (i + 1);
        return DateFormat('MMM').format(DateTime(2000, m, 1));
      case 'Yearly':
        return data[i].date;
      default:
        return '';
    }
  }
}
