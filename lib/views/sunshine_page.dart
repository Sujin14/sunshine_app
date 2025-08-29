import 'package:flutter/material.dart';
import 'controls_widget.dart';
import 'header_widget.dart';
import 'animated_sky_background_painter.dart';
import 'visualization_widget.dart';
import 'insights_widget.dart';

class SunshinePage extends StatelessWidget {
  const SunshinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedSkyBackground(),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  bool isMobile = constraints.maxWidth < 600;

                  if (isMobile) {
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
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 240,
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
                        Expanded(flex: 3, child: VisualizationWidget()),
                        const SizedBox(width: 16),
                        Expanded(flex: 2, child: InsightsWidget()),
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
