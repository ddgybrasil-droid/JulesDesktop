import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isTestRunnerEnabled = false;

  @override
  Widget build(BuildContext context) {
    // 2026 techno-brutalist Bento Grid framework
    return Scaffold(
      backgroundColor: Colors.transparent, // Let base app theme show through
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent, // Let base app theme show through
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Skills & Tools',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              // Bento Grid Container
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF121212), // Deep dark background
                  border: Border.all(color: Colors.white, width: 1), // 1px solid white border
                  borderRadius: BorderRadius.circular(12), // Individual border radiuses
                ),
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Local Sandboxed Test Runner',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Enables the tool to execute test scripts (e.g., cargo test, flutter test) in a local sandboxed environment via IPC.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16), // Uniform gap
                    Switch(
                      value: _isTestRunnerEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          _isTestRunnerEnabled = value;
                        });
                      },
                      activeThumbColor: Colors.white,
                      activeTrackColor: Colors.grey[700],
                      inactiveThumbColor: Colors.grey[400],
                      inactiveTrackColor: Colors.black,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
