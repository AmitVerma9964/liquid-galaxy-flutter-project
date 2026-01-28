import 'package:flutter/material.dart';
import 'package:amti_fluttter_task1/services/lg_service.dart';
import 'package:amti_fluttter_task1/utils/kml_helper.dart';

/// Pyramid Debug Screen - Use this to test pyramid functionality
class PyramidDebugScreen extends StatefulWidget {
  const PyramidDebugScreen({super.key});

  @override
  State<PyramidDebugScreen> createState() => _PyramidDebugScreenState();
}

class _PyramidDebugScreenState extends State<PyramidDebugScreen> {
  final LGService _lgService = lgService;
  List<String> debugLogs = [];
  bool isLoading = false;

  void addLog(String message) {
    setState(() {
      debugLogs.add('[${DateTime.now().toIso8601String()}] $message');
    });
    print(message);
  }

  Future<void> testConnection() async {
    setState(() {
      isLoading = true;
      debugLogs.clear();
    });

    addLog('Testing connection...');
    
    if (!_lgService.isConnected) {
      addLog('❌ Not connected to LG');
      addLog('Please connect first from the settings');
      setState(() => isLoading = false);
      return;
    }
    
    addLog('✅ Connected to LG');
    addLog('Host: ${_lgService.host}');
    addLog('Port: ${_lgService.port}');
    
    setState(() => isLoading = false);
  }

  Future<void> sendTestPyramid() async {
    setState(() {
      isLoading = true;
      debugLogs.clear();
    });

    addLog('=== Starting Pyramid Test ===');
    
    if (!_lgService.isConnected) {
      addLog('❌ ERROR: Not connected to LG');
      setState(() => isLoading = false);
      return;
    }
    
    addLog('✅ Connection verified');
    
    try {
      addLog('Sending pyramid to Indore, India');
      addLog('Coordinates: 22.7196°N, 75.8577°E');
      addLog('Height: 100 meters');
      
      final pyramidKml = KMLHelper.generatePyramidKML(
        latitude: 22.7196,
        longitude: 75.8577,
        altitude: 100,
      );
      final result = await _lgService.sendPyramid(
        pyramidKml: pyramidKml,
      );
      
      addLog('Result: $result');
      
      if (result.contains('successfully')) {
        addLog('✅ SUCCESS! Check Google Earth');
        addLog('');
        addLog('What to look for:');
        addLog('- A colorful pyramid at Indore');
        addLog('- Red (North), Green (East), Blue (South), Yellow (West)');
        addLog('- Magenta base');
        addLog('- Camera should fly to the location');
      } else {
        addLog('⚠️ Result unclear, check manually');
      }
      
    } catch (e) {
      addLog('❌ ERROR: $e');
      addLog('Stack trace available in console');
    }
    
    setState(() => isLoading = false);
    addLog('=== Test Complete ===');
  }

  Future<void> testSimpleCommand() async {
    setState(() {
      isLoading = true;
      debugLogs.clear();
    });

    addLog('Testing simple SSH command...');
    
    try {
      final result = await _lgService.executeCommand('echo "Hello from Flutter"');
      addLog('Command result: $result');
      addLog(result.contains('Hello') ? '✅ SSH working' : '⚠️ Unexpected result');
    } catch (e) {
      addLog('❌ SSH command failed: $e');
    }
    
    setState(() => isLoading = false);
  }

  Future<void> checkFiles() async {
    setState(() {
      isLoading = true;
      debugLogs.clear();
    });

    addLog('Checking LG files...');
    
    try {
      // Check if pyramid.kml exists
      final kmlCheck = await _lgService.executeCommand('ls -lh /var/www/html/pyramid.kml 2>&1');
      addLog('Pyramid KML: $kmlCheck');
      
      // Check kmls.txt content
      final kmlsContent = await _lgService.executeCommand('cat /var/www/html/kmls.txt 2>&1');
      addLog('kmls.txt content: $kmlsContent');
      
      // Check if web server is accessible
      final webCheck = await _lgService.executeCommand('curl -I http://lg1:81/pyramid.kml 2>&1 | head -1');
      addLog('Web access: $webCheck');
      
    } catch (e) {
      addLog('❌ Error checking files: $e');
    }
    
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pyramid Debug Tool'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // Control Panel
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.deepPurple.shade50,
            child: Column(
              children: [
                const Text(
                  'Pyramid Testing & Debugging',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : testConnection,
                      icon: const Icon(Icons.wifi),
                      label: const Text('Test Connection'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : sendTestPyramid,
                      icon: const Icon(Icons.send),
                      label: const Text('Send Pyramid'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : testSimpleCommand,
                      icon: const Icon(Icons.terminal),
                      label: const Text('Test SSH'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : checkFiles,
                      icon: const Icon(Icons.folder_open),
                      label: const Text('Check Files'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Loading indicator
          if (isLoading)
            const LinearProgressIndicator(),
          
          // Debug logs
          Expanded(
            child: Container(
              color: Colors.black,
              child: debugLogs.isEmpty
                  ? const Center(
                      child: Text(
                        'Press a button to start testing',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: debugLogs.length,
                      itemBuilder: (context, index) {
                        final log = debugLogs[index];
                        Color color = Colors.white;
                        if (log.contains('✅')) color = Colors.greenAccent;
                        if (log.contains('❌')) color = Colors.redAccent;
                        if (log.contains('⚠️')) color = Colors.orangeAccent;
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            log,
                            style: TextStyle(
                              color: color,
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
