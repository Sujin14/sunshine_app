import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../models/sunshine_provider.dart';

class VisualizationWidget extends StatelessWidget {
  const VisualizationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SunshineProvider>(context);
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white.withOpacity(0.95),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: provider.isLoading
            ? Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.viewMode == 'Hourly'
                        ? '🌞 Hourly Sunshine'
                        : '📅 Daily Sunshine',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 300,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 12,
                        barTouchData: BarTouchData(
                          touchCallback: (event, response) {
                            if (response != null &&
                                response.spot != null &&
                                provider.viewMode == 'Hourly') {
                              provider.updateSelectedHour(
                                response.spot!.touchedBarGroupIndex,
                              );
                            }
                          },
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                "${provider.data[groupIndex].sunshineHours.toStringAsFixed(2)} h",
                                const TextStyle(color: Colors.white),
                              );
                            },
                          ),
                        ),
                        barGroups: provider.data.asMap().entries.map((entry) {
                          final index = entry.key;
                          final data = entry.value;
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: data.sunshineHours,
                                color: const Color(0xFFFFD700),
                                width: 14,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) =>
                                  Text("${value.toInt()}h"),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) => Text(
                                provider.viewMode == 'Hourly'
                                    ? "${value.toInt()}:00"
                                    : provider.data[value.toInt()].date
                                          .split('-')
                                          .last,
                              ),
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: false),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
