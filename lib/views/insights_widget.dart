import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../models/sunshine_provider.dart';
import '../theme/app_theme.dart';

class InsightsWidget extends StatelessWidget {
  const InsightsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SunshineProvider>(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: provider.isLoading
          ? Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                children: List.generate(
                  3,
                  (_) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    height: 96,
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
                style: const TextStyle(color: AppColors.errorRed),
              ),
            )
          : Column(
              children: [
                _card(
                  "☀️ Average Sunshine",
                  provider.data.isNotEmpty
                      ? "${(provider.data.map((d) => d.sunshineHours).reduce((a, b) => a + b) / provider.data.length).toStringAsFixed(2)} hours"
                      : "0.00 hours",
                ),
                _card(
                  "📊 Peak",
                  provider.data.isNotEmpty
                      ? "${provider.data.reduce((a, b) => a.sunshineHours > b.sunshineHours ? a : b).sunshineHours.toStringAsFixed(2)} h at ${provider.data.reduce((a, b) => a.sunshineHours > b.sunshineHours ? a : b).timestamp}"
                      : "N/A",
                ),
                FutureBuilder<double>(
                  future: provider.fetchHistoricalAverage(),
                  builder: (context, snap) {
                    final txt = snap.hasData
                        ? "${snap.data!.toStringAsFixed(2)} hours"
                        : "Loading...";
                    return _card("📉 Historical Average", txt);
                  },
                ),
              ],
            ),
    );
  }

  Widget _card(String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 14, color: AppColors.textLight),
        ),
      ),
    );
  }
}
