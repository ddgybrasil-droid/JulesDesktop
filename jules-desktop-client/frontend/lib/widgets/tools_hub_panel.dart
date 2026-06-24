import 'package:flutter/material.dart';
import 'dart:ui';

class ToolsHubPanel extends StatelessWidget {
  const ToolsHubPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF121212),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'INTERACTIVE TOOLS HUB',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 24.0),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.5,
              children: [
                _buildToolCard(
                  title: 'Local Sandboxed Test Runner',
                  description: 'Route cloud test logs down to local Docker sub-containers.',
                  icon: Icons.computer,
                  color: Colors.blueAccent,
                ),
                _buildToolCard(
                  title: 'Token Optimizer & AST Trimmer',
                  description: 'Calculate context weight and strip redundant modules.',
                  icon: Icons.compress,
                  color: Colors.purpleAccent,
                ),
                _buildToolCard(
                  title: 'Multi-Agent Route Map',
                  description: 'Interactive visual canvas rendering graph layout of tasks.',
                  icon: Icons.map,
                  color: Colors.orangeAccent,
                ),
                _buildToolCard(
                  title: 'Secure Env Masker',
                  description: 'Sanitize, replace, and reverse secret tokens/keys in stream.',
                  icon: Icons.security,
                  color: Colors.greenAccent,
                ),
                _buildToolCard(
                  title: 'UI/UX Visual Prototyper',
                  description: 'Pass Flutter UI snippets to local webview for preview.',
                  icon: Icons.design_services,
                  color: Colors.pinkAccent,
                ),
                _buildToolCard(
                  title: 'Dependency Conflict Resolver',
                  description: 'Intercept upstream Cargo/Pubspec mismatches before builds.',
                  icon: Icons.handyman,
                  color: Colors.redAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E).withValues(alpha: 0.8),
            border: Border.all(
              color: color.withValues(alpha: 0.5),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 28.0),
                  Switch(
                    value: false, // Stub value
                    onChanged: (bool value) {},
                    activeTrackColor: color.withValues(alpha: 0.5),
                    activeThumbColor: color,
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12.0,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
