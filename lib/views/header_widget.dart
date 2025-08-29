import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '☀️ Sunshine Insights',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF333333),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Mock Weather API',
                    style: TextStyle(fontSize: 14, color: Color(0xFF777777)),
                  ),
                ],
              ),
            ),
            Text(
              'Updated: ${DateFormat('MMM dd, yyyy').format(DateTime.now())}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }
}
