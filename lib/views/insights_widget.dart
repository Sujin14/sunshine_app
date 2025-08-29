import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../models/sunshine_provider.dart';

class InsightsWidget extends StatelessWidget {
  const InsightsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SunshineProvider>(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: provider.isLoading
          ? Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                children: List.generate(
                  3,
                  (_) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            )
          : provider.error.isNotEmpty
              ? Center(
                  child: Text(
                    provider.error,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : Column(
                  children: [
                    _buildCard(
                      title: "☀️ Average Sunshine",
                      value:
                          "${provider.data.isNotEmpty ? (provider.data.map((d) => d.sunshineHours).reduce((a, b) => a + b) / provider.data.length).toStringAsFixed(2) : '0.00'} hours",
                    ),
                    _buildCard(
                      title: "📊 Peak Hour/Day",
                      value: provider.data.isNotEmpty
                          ? "${provider.data.reduce((a, b) => a.sunshineHours > b.sunshineHours ? a : b).sunshineHours.toStringAsFixed(2)} hours at ${provider.data.reduce((a, b) => a.sunshineHours > b.sunshineHours ? a : b).timestamp.split(' ').last}"
                          : "N/A",
                    ),
                    FutureBuilder<double>(
                      future: provider.fetchHistoricalAverage(),
                      builder: (context, snapshot) {
                        return _buildCard(
                          title: "📉 Historical Average",
                          value: snapshot.hasData
                              ? "${snapshot.data!.toStringAsFixed(2)} hours"
                              : "Loading...",
                        );
                      },
                    ),
                  ],
                ),
    );
  }

  Widget _buildCard({required String title, required String value}) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white.withOpacity(0.9),
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ),
    );
  }
}
