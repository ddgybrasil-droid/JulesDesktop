import 'package:flutter/material.dart';

class ProStatusWidget extends StatelessWidget {
  const ProStatusWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E), // Dark industrial base
            border: Border.all(
              color: Colors.greenAccent, // Neon tech accent
              width: 4.0, // Brutalist thick border
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.greenAccent.withValues(alpha: 0.8),
                offset: const Offset(6, 6), // Hard raw 3D shadow
                blurRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '15 / 100',
                  style: TextStyle(
                    fontFamily: 'Courier', // Monospace high weight
                    fontWeight: FontWeight.w900,
                    fontSize: 24.0,
                    letterSpacing: 2.0,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  color: Colors.greenAccent,
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.w900,
                      fontSize: 18.0,
                      letterSpacing: 4.0,
                      color: Colors.black, // High contrast text inside neon box
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
