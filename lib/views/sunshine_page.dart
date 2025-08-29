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
      body: Stack(
        children: [
          /// Dynamic sky + sun + clouds
          AnimatedSkyBackground(selectedHour: provider.selectedHour),

          /// Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  bool isMobile = constraints.maxWidth < 600;

                  if (isMobile) {
                    /// ✅ Mobile → Scrollable column
                    return ListView(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      children: const [
                        HeaderWidget(),
                        SizedBox(height: 16),
                        ControlsWidget(),
                        SizedBox(height: 16),
                        VisualizationWidget(),
                        SizedBox(height: 16),
                        InsightsWidget(),
                      ],
                    );
                  } else {
                    /// ✅ Web/Desktop → Row with side controls
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 220,
                          child: ListView(
                            shrinkWrap: true,
                            children: const [
                              HeaderWidget(),
                              SizedBox(height: 16),
                              ControlsWidget(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(flex: 3, child: const VisualizationWidget()),
                        const SizedBox(width: 16),
                        Expanded(flex: 2, child: const InsightsWidget()),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
