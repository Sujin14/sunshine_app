import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sunshine_provider.dart';
import 'controls_widget.dart';
import 'header_widget.dart';
import 'visualization_widget.dart';
import 'insights_widget.dart';
import 'sky_background_painter.dart';

class SunshinePage extends StatelessWidget {
  const SunshinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SunshineProvider>(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            child: CustomPaint(
              size: Size.infinite,
              painter: SkyBackgroundPainter(provider.selectedHour),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  bool isMobile = constraints.maxWidth < 600;
                  return isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            HeaderWidget(),
                            SizedBox(height: 20),
                            ControlsWidget(),
                            SizedBox(height: 20),
                            VisualizationWidget(),
                            SizedBox(height: 20),
                            InsightsWidget(),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 250,
                              child: Column(
                                children: const [
                                  HeaderWidget(),
                                  SizedBox(height: 20),
                                  ControlsWidget(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 3,
                              child: VisualizationWidget(),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 2,
                              child: InsightsWidget(),
                            ),
                          ],
                        );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
