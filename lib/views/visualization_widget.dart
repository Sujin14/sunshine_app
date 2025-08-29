import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/sunshine_provider.dart';

class VisualizationWidget extends StatelessWidget {
  const VisualizationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SunshineProvider>(context);

    if (provider.isLoading) {
      return Card(
        child: Container(
          height: 340,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        ),
      );
    }

    if (provider.error.isNotEmpty) {
      return Card(
        child: SizedBox(
          height: 120,
          child: Center(child: Text(provider.error, style: const TextStyle(color: Colors.red))),
        ),
      );
    }

    final barsCount = provider.data.length;
    final minChartWidth = MediaQuery.of(context).size.width - 72; // padding-aware
    // Give each bar healthy space; clamp so desktop doesn’t explode
    final perBar = 44.0;
    final totalWidth = max(barsCount * perBar, minChartWidth);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _title(provider.viewMode),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 300,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: totalWidth,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceEvenly,
                      maxY: provider.computeMaxY(),
                      barTouchData: BarTouchData(
                        touchCallback: (event, response) {
                          if (response != null &&
                              response.spot != null &&
                              provider.viewMode == 'Hourly') {
                            provider.updateSelectedHour(response.spot!.touchedBarGroupIndex);
                          }
                        },
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final v = provider.data[groupIndex].sunshineHours;
                            return BarTooltipItem("${v.toStringAsFixed(2)} h", const TextStyle(color: Colors.white));
                          },
                        ),
                      ),
                      barGroups: List.generate(barsCount, (i) {
                        final d = provider.data[i];
                        final isSelected = provider.viewMode == 'Hourly' && i == provider.selectedHour;
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: d.sunshineHours,
                              color: isSelected ? const Color(0xFFFFC107) : const Color(0xFFFFD700),
                              width: isSelected ? 18 : 14,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ],
                        );
                      }),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) => Text("${value.toInt()}h", style: const TextStyle(fontSize: 12)),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  provider.xLabelForIndex(i),
                                  style: const TextStyle(fontSize: 11),
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: false),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _title(String mode) {
    switch (mode) {
      case 'Hourly':  return '🌞 Hourly Sunshine';
      case 'Daily':   return '📅 Daily Sunshine';
      case 'Weekly':  return '🗓️ Weekly Sunshine';
      case 'Monthly': return '📆 Monthly Sunshine';
      case 'Yearly':  return '📈 Yearly Sunshine';
      default:        return 'Sunshine';
    }
  }
}
