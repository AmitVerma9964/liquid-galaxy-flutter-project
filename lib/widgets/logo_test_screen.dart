import 'package:flutter/material.dart';
import 'package:amti_fluttter_task1/services/lg_service.dart';

/// Test screen to verify KML logo functionality
class LogoTestScreen extends StatefulWidget {
  const LogoTestScreen({Key? key}) : super(key: key);

  @override
  State<LogoTestScreen> createState() => _LogoTestScreenState();
}

class _LogoTestScreenState extends State<LogoTestScreen> {
  String _status = 'Not connected';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KML Logo Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: lgService.isConnected ? Colors.green.shade100 : Colors.red.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connection Status: ${lgService.isConnected ? "Connected" : "Disconnected"}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Host: ${lgService.host}'),
                    Text('Left Screen: ${lgService.leftScreen}'),
                    Text('Right Screen: ${lgService.rightScreen}'),
                    Text('Total Screens: ${lgService.screenAmount}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status Message
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _status,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Connection Buttons
            if (!lgService.isConnected) ...[
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _connect,
                icon: _isLoading 
                    ? const SizedBox(
                        width: 16, 
                        height: 16, 
                        child: CircularProgressIndicator(strokeWidth: 2)
                      )
                    : const Icon(Icons.wifi),
                label: Text(_isLoading ? 'Connecting...' : 'Connect to LG'),
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _disconnect,
                icon: const Icon(Icons.wifi_off),
                label: const Text('Disconnect'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Logo Tests
            const Text(
              'Logo Tests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Test 1: Show Default Logo
            ElevatedButton.icon(
              onPressed: lgService.isConnected && !_isLoading ? _testShowLogos : null,
              icon: const Icon(Icons.image),
              label: const Text('Test 1: Show Default LG Logo'),
            ),
            const SizedBox(height: 8),

            // Test 2: Custom Logo URL
            ElevatedButton.icon(
              onPressed: lgService.isConnected && !_isLoading ? _testCustomLogo : null,
              icon: const Icon(Icons.wallpaper),
              label: const Text('Test 2: Show Custom Logo'),
            ),
            const SizedBox(height: 8),

            // Test 3: Send to Different Screen
            ElevatedButton.icon(
              onPressed: lgService.isConnected && !_isLoading ? _testDifferentScreen : null,
              icon: const Icon(Icons.tv),
              label: const Text('Test 3: Send to Right Screen'),
            ),
            const SizedBox(height: 8),

            // Test 4: Clear Logos
            ElevatedButton.icon(
              onPressed: lgService.isConnected && !_isLoading ? _clearLogos : null,
              icon: const Icon(Icons.clear),
              label: const Text('Clear All Logos'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),

            const Spacer(),

            // Info
            const Card(
              color: Colors.blue,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'ℹ️ Logo should appear on the left screen after connection.\n'
                  'If it doesn\'t appear, check:\n'
                  '• Network connection to LG\n'
                  '• Google Earth is running\n'
                  '• Port 81 is accessible',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _connect() async {
    setState(() {
      _isLoading = true;
      _status = 'Connecting to Liquid Galaxy...';
    });

    // Update connection details if needed
    lgService.updateConnectionDetails(
      host: '192.168.1.100',
      port: 22,
      username: 'lg',
      password: 'lg',
      screenAmount: 3,
    );

    final result = await lgService.connect();
    
    setState(() {
      _isLoading = false;
      _status = '$result\n\nLogos should now be visible on left screen (Screen ${lgService.leftScreen})';
    });
  }

  Future<void> _disconnect() async {
    await lgService.disconnect();
    setState(() {
      _status = 'Disconnected from Liquid Galaxy';
    });
  }

  Future<void> _testShowLogos() async {
    setState(() {
      _isLoading = true;
      _status = 'Sending default LG logo to left screen...';
    });

    await lgService.showLogos();
    
    setState(() {
      _isLoading = false;
      _status = 'Default logo sent to left screen (Screen ${lgService.leftScreen})\n'
                'Check the leftmost screen for the LG logo.';
    });
  }

  Future<void> _testCustomLogo() async {
    setState(() {
      _isLoading = true;
      _status = 'Sending custom logo...';
    });

    // Test with a different image URL
    const customUrl = 'https://raw.githubusercontent.com/nasa/openmct/master/src/images/logo-nasa.svg';
    final result = await lgService.sendScreenOverlayImage(customUrl, screen: lgService.leftScreen);
    
    setState(() {
      _isLoading = false;
      _status = 'Custom logo test: $result\n'
                'Custom NASA logo should appear on screen ${lgService.leftScreen}';
    });
  }

  Future<void> _testDifferentScreen() async {
    setState(() {
      _isLoading = true;
      _status = 'Sending logo to right screen...';
    });

    final result = await lgService.sendScreenOverlayImage(
      'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png',
      screen: lgService.rightScreen,
    );
    
    setState(() {
      _isLoading = false;
      _status = 'Logo sent to right screen: $result\n'
                'Check screen ${lgService.rightScreen} for Google logo.';
    });
  }

  Future<void> _clearLogos() async {
    setState(() {
      _isLoading = true;
      _status = 'Clearing all logos...';
    });

    final result = await lgService.clearKml(keepLogos: false);
    
    setState(() {
      _isLoading = false;
      _status = 'Clear result: $result\n'
                'All logos should be removed from screens.';
    });
  }
}
