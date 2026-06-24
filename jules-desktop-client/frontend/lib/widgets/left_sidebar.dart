import 'package:flutter/material.dart';
import 'dart:ui';

class LeftSidebar extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onToggle;

  final Function(String) onNavSelected;

  const LeftSidebar({
    Key? key,
    required this.isCollapsed,
    required this.onToggle,
    required this.onNavSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isCollapsed ? 60.0 : 250.0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              border: Border(
                right: BorderSide(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.0,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    children: [
                      _buildNavItem(Icons.hub, 'Sessions Hub'),
                      _buildNavItem(Icons.build_circle, 'Skills & Tools Hub'),
                      _buildNavItem(Icons.account_tree, 'Artifacts/PR Matrix'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!isCollapsed)
            const Text(
              'JULES',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                letterSpacing: 2.0,
              ),
            ),
          IconButton(
            icon: Icon(
              isCollapsed ? Icons.menu : Icons.chevron_left,
              color: Colors.white,
            ),
            onPressed: onToggle,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label) {
    return InkWell(
      onTap: () => onNavSelected(label),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 24.0),
            if (!isCollapsed) ...[
              const SizedBox(width: 16.0),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
