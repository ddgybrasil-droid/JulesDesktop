import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _proxyUrlController;
  late TextEditingController _apiKeyController;

  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _proxyUrlController = TextEditingController(text: settingsProvider.proxyUrl);
    _apiKeyController = TextEditingController(text: settingsProvider.apiKey);
  }

  @override
  void dispose() {
    _proxyUrlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    settingsProvider.setProxyUrl(_proxyUrlController.text);
    settingsProvider.setApiKey(_apiKeyController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Configuration',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _proxyUrlController,
              decoration: const InputDecoration(
                labelText: 'Cloudflare Worker Proxy URL',
                border: OutlineInputBorder(),
                hintText: 'https://your-worker.workers.dev',
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _apiKeyController,
              decoration: InputDecoration(
                labelText: 'Google AI Studio API Key',
                border: const OutlineInputBorder(),
                hintText: 'AIza...',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureApiKey ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureApiKey = !_obscureApiKey;
                    });
                  },
                ),
              ),
              obscureText: _obscureApiKey,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
