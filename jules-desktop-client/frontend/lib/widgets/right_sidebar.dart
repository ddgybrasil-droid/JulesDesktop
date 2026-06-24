import 'package:flutter/material.dart';
import 'dart:ui';

class RightSidebar extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onToggle;

  const RightSidebar({
    Key? key,
    required this.isCollapsed,
    required this.onToggle,
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
                left: BorderSide(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.0,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                if (!isCollapsed)
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      children: [
                        _buildFileItem('frontend/lib/main.dart', isModified: true),
                        _buildFileItem('frontend/lib/widgets/left_sidebar.dart', isNew: true),
                        _buildFileItem('frontend/lib/widgets/right_sidebar.dart', isNew: true),
                        _buildFileItem('backend/src/tools_hub.rs', isNew: true),
                        _buildFileItem('backend/src/main.rs', isModified: true),
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            icon: Icon(
              isCollapsed ? Icons.folder : Icons.chevron_right,
              color: Colors.white,
            ),
            onPressed: onToggle,
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 8.0),
            const Text(
              'WORKSPACE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
                letterSpacing: 1.2,
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildFileItem(String path, {bool isNew = false, bool isModified = false}) {
    Color indicatorColor = Colors.transparent;
    if (isNew) indicatorColor = Colors.greenAccent;
    if (isModified) indicatorColor = Colors.orangeAccent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Row(
        children: [
          Icon(Icons.insert_drive_file, size: 16.0, color: Colors.white70),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              path,
              style: TextStyle(
                color: indicatorColor != Colors.transparent ? indicatorColor : Colors.white70,
                fontSize: 12.0,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (indicatorColor != Colors.transparent)
            Container(
              width: 8.0,
              height: 8.0,
              decoration: BoxDecoration(
                color: indicatorColor,
                shape: BoxShape.circle,
              ),
            )
        ],
      ),
    );
  }
}
