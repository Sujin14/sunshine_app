import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/sunshine_provider.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class ControlsWidget extends StatelessWidget {
  const ControlsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SunshineProvider>(context);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButton<String>(
            value: provider.viewMode,
            items: const [
              DropdownMenuItem(value: 'Hourly', child: Text('Hourly')),
              DropdownMenuItem(value: 'Daily', child: Text('Daily')),
              DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
              DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
              DropdownMenuItem(value: 'Yearly', child: Text('Yearly')),
            ],
            onChanged: (val) {
              if (val != null) provider.changeViewMode(val);
            },
            dropdownColor: Colors.white,
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.sunshineYellow),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            icon: const Icon(Icons.calendar_today, color: AppColors.sunshineYellow),
            label: Text(
              DateFormat('yyyy-MM-dd').format(provider.selectedDate),
              style: const TextStyle(color: AppColors.textDark),
            ),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: provider.selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) provider.changeDate(picked);
            },
          ),
        ],
      ),
    );
  }
}
