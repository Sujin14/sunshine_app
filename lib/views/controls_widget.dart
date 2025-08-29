import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/sunshine_provider.dart';

class ControlsWidget extends StatelessWidget {
  const ControlsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SunshineProvider>(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Segmented Button with horizontal scroll to avoid overflow
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Hourly', label: Text('Hourly')),
                ButtonSegment(value: 'Daily', label: Text('Daily')),
                ButtonSegment(value: 'Weekly', label: Text('Weekly')),
                ButtonSegment(value: 'Monthly', label: Text('Monthly')),
                ButtonSegment(value: 'Yearly', label: Text('Yearly')),
              ],
              selected: {provider.viewMode},
              onSelectionChanged: (values) {
                provider.changeViewMode(values.first);
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(const Color(0xFFFFD700)),
                foregroundColor: WidgetStateProperty.all(const Color(0xFF333333)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          /// Date Picker
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.calendar_today, color: Color(0xFFFFD700)),
              label: Text(
                DateFormat('yyyy-MM-dd').format(provider.selectedDate),
                style: const TextStyle(color: Color(0xFF333333)),
              ),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: provider.selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  provider.changeDate(picked);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
