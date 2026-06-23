import 'package:flutter/material.dart';

class TechnoMetricHeader extends StatelessWidget {
  final String title;
  final String metric;
  final Color accentColor;

  const TechnoMetricHeader({
    Key? key,
    required this.title,
    required this.metric,
    required this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adjust scaling based on width
        double baseFontSize = constraints.maxWidth > 200 ? 16.0 : 12.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            border: Border.all(color: accentColor, width: 4.0), // Thick bold borders
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.8),
                offset: const Offset(4, 4), // Hard 3D shadow
                blurRadius: 0, // Brutalist hard edge
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Courier', // Monospace high weight style
                      fontWeight: FontWeight.w900,
                      fontSize: baseFontSize * 1.2,
                      letterSpacing: 2.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: accentColor,
                  border: Border.all(color: Colors.white, width: 2.0),
                ),
                child: Text(
                  metric,
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.w900,
                    fontSize: baseFontSize * 1.5,
                    color: Colors.black, // High contrast text on accent color
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
