class SunshineData {
  final String timestamp;
  final double sunshineHours;
  final String date;

  SunshineData({
    required this.timestamp,
    required this.sunshineHours,
    required this.date,
  });

  factory SunshineData.fromJson(Map<String, dynamic> json) {
    return SunshineData(
      timestamp: json['timestamp'] as String,
      sunshineHours: (json['sunshine_hours'] as num).toDouble(),
      date: json['date'] as String,
    );
  }
}
