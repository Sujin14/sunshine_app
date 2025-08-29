// lib/views/visualization_widget.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/sunshine_provider.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

enum ChartMode { bar, line }

class VisualizationWidget extends StatefulWidget {
  const VisualizationWidget({Key? key}) : super(key: key);

  @override
  State<VisualizationWidget> createState() => _VisualizationWidgetState();
}

class _VisualizationWidgetState extends State<VisualizationWidget> {
  ChartMode mode = ChartMode.bar;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SunshineProvider>(context);

    if (provider.isLoading) {
      return const GlassCard(
        child: SizedBox(
          height: 340,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (provider.error.isNotEmpty) {
      return GlassCard(
        child: SizedBox(
          height: 120,
          child: Center(
            child: Text(
              provider.error,
              style: TextStyle(color: AppColors.errorRed),
            ),
          ),
        ),
      );
    }

    final barsCount = provider.data.length;
    final minChartWidth = MediaQuery.of(context).size.width - 72;
    final perBar = 44.0;
    final totalWidth = max(barsCount * perBar, minChartWidth);

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ header + mode toggle (responsive fix applied)
            Row(
              children: [
                Expanded(
                  child: Text(
                    _title(provider.viewMode),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                    overflow: TextOverflow.ellipsis, // prevent overflow
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: ToggleButtons(
                    isSelected: [
                      mode == ChartMode.bar,
                      mode == ChartMode.line,
                    ],
                    onPressed: (i) => setState(
                      () => mode = i == 0 ? ChartMode.bar : ChartMode.line,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    fillColor: Colors.white.withOpacity(0.08),
                    selectedBorderColor: Colors.white.withOpacity(0.06),
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.bar_chart, size: 20),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.show_chart, size: 20),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ✅ scrollable chart (horizontal when needed)
            SizedBox(
              height: provider.data.isEmpty ? 120 : 280,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: totalWidth,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: mode == ChartMode.bar
                        ? _buildBarChart(provider)
                        : _buildLineChart(provider),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(SunshineProvider provider) {
    final barsCount = provider.data.length;
    return BarChart(
      BarChartData(
        maxY: provider.computeMaxY(),
        alignment: BarChartAlignment.spaceEvenly,
        barTouchData: BarTouchData(
          enabled: true,
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
              return BarTooltipItem(
                "${v.toStringAsFixed(2)} h",
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        barGroups: List.generate(barsCount, (i) {
          final d = provider.data[i];
          final isSelected =
              provider.viewMode == 'Hourly' && i == provider.selectedHour;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: d.sunshineHours,
                color: isSelected
                    ? AppColors.sunshineAmber
                    : AppColors.sunshineYellow,
                width: isSelected ? 20 : 14,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          );
        }),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (v, meta) => Text("${v.toInt()}h"),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    provider.xLabelForIndex(i),
                    style: const TextStyle(fontSize: 11),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
      ),
    );
  }

  Widget _buildLineChart(SunshineProvider provider) {
    final spots = provider.data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.sunshineHours))
        .toList();
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            color: AppColors.sunshineYellow,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.sunshineYellow.withOpacity(0.15),
            ),
          ),
        ],
        minY: 0,
        maxY: provider.computeMaxY(),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (v, meta) => Text("${v.toInt()}h"),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    provider.xLabelForIndex(i),
                    style: const TextStyle(fontSize: 11),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(show: false),
      ),
    );
  }

  String _title(String mode) {
    switch (mode) {
      case 'Hourly':
        return '🌞 Hourly Sunshine';
      case 'Daily':
        return '📅 Daily Sunshine';
      case 'Weekly':
        return '🗓️ Weekly Sunshine';
      case 'Monthly':
        return '📆 Monthly Sunshine';
      case 'Yearly':
        return '📈 Yearly Sunshine';
      default:
        return 'Sunshine';
    }
  }
}
