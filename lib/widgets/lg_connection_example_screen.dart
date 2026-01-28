import 'package:flutter/material.dart';
import 'package:amti_fluttter_task1/services/lg_service.dart';

/// Example screen demonstrating LG Connection integration
class LGConnectionExampleScreen extends StatefulWidget {
  const LGConnectionExampleScreen({Key? key}) : super(key: key);

  @override
  State<LGConnectionExampleScreen> createState() => _LGConnectionExampleScreenState();
}

class _LGConnectionExampleScreenState extends State<LGConnectionExampleScreen> {
  String _status = 'Not connected';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LG Connection Example'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Status: $_status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Connection Management
            const Text('Connection', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _connect,
              child: const Text('Connect (Shows Logos Automatically)'),
            ),
            ElevatedButton(
              onPressed: _disconnect,
              child: const Text('Disconnect'),
            ),
            const SizedBox(height: 16),

            // KML Operations
            const Text('KML Operations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _showLogos,
              child: const Text('Show Logos'),
            ),
            ElevatedButton(
              onPressed: _clearKmlKeepLogos,
              child: const Text('Clear KML (Keep Logos)'),
            ),
            ElevatedButton(
              onPressed: _clearKml,
              child: const Text('Clear All KML'),
            ),
            const SizedBox(height: 16),

            // Orbit Controls
            const Text('Orbit Animation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _startOrbit,
              child: const Text('Start Orbit (NYC)'),
            ),
            ElevatedButton(
              onPressed: _stopOrbit,
              child: const Text('Stop Orbit'),
            ),
            const SizedBox(height: 16),

            // Planet Selection
            const Text('Planet View', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _setPlanet('earth'),
                    child: const Text('Earth'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _setPlanet('mars'),
                    child: const Text('Mars'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _setPlanet('moon'),
                    child: const Text('Moon'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // System Management
            const Text('System Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _relaunch,
              child: const Text('Relaunch Services'),
            ),
            ElevatedButton(
              onPressed: _reboot,
              child: const Text('Reboot'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
            ElevatedButton(
              onPressed: _shutdown,
              child: const Text('Shutdown'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _connect() async {
    final result = await lgService.connect();
    setState(() => _status = result);
  }

  Future<void> _disconnect() async {
    await lgService.disconnect();
    setState(() => _status = 'Disconnected');
  }

  Future<void> _showLogos() async {
    await lgService.showLogos();
    setState(() => _status = 'Logos displayed');
  }

  Future<void> _clearKmlKeepLogos() async {
    final result = await lgService.clearKml(keepLogos: true);
    setState(() => _status = result);
  }

  Future<void> _clearKml() async {
    final result = await lgService.clearKml(keepLogos: false);
    setState(() => _status = result);
  }

  Future<void> _startOrbit() async {
    // NYC coordinates
    final result = await lgService.buildOrbit(
      40.7128,  // latitude
      -74.0060, // longitude
      1000.0,   // zoom
      60.0,     // tilt
      0.0,      // bearing
    );
    setState(() => _status = result);
  }

  Future<void> _stopOrbit() async {
    final result = await lgService.stopOrbit();
    setState(() => _status = result);
  }

  Future<void> _setPlanet(String planet) async {
    final result = await lgService.setPlanet(planet);
    setState(() => _status = result);
  }

  Future<void> _relaunch() async {
    final result = await lgService.relaunch();
    setState(() => _status = result);
  }

  Future<void> _reboot() async {
    final confirmed = await _showConfirmDialog('Reboot', 'Are you sure you want to reboot all screens?');
    if (confirmed) {
      final result = await lgService.rebootLG();
      setState(() => _status = result);
    }
  }

  Future<void> _shutdown() async {
    final confirmed = await _showConfirmDialog('Shutdown', 'Are you sure you want to shutdown all screens?');
    if (confirmed) {
      final result = await lgService.shutdown();
      setState(() => _status = result);
    }
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    ) ?? false;
  }
}
