import   'dart:math';
import 'package:flutter/material.dart';
import 'package:amti_fluttter_task1/services/lg_service.dart';
import 'package:amti_fluttter_task1/utils/kml_helper.dart';
import 'package:amti_fluttter_task1/models/kml/screen_overlay_entity.dart';

void main() {
  runApp(const LgApp());
}

/// Root widget of the Liquid Galaxy controller application
class LgApp extends StatelessWidget {
  const LgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.indigo,
        scaffoldBackgroundColor: Colors.indigo.shade900,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          elevation: 4,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyanAccent.shade400,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

/// Home screen with Earth orbit animation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Orbital Earth – LG Controller 🌍',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade900, Colors.black87],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Card(
            elevation: 12,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            shadowColor: Colors.cyanAccent.withValues(alpha: 0.5),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🌍 Space / Orbit / Visualization 🛰️',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Liquid Galaxy Controller Interface',
                    style: TextStyle(fontSize: 20, color: Colors.black87),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (_, child) {
                        final angle = _controller.value * 2 * pi;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            const Text('🌍', style: TextStyle(fontSize: 48)),
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.cyanAccent.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            Transform.translate(
                              offset: Offset(cos(angle) * 80, sin(angle) * 80),
                              child: const Text('🛰️',
                                  style: TextStyle(fontSize: 26)),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LGMenuScreen()),
                      );
                    },
                    icon: const Icon(Icons.menu),
                    label: const Text('MENU 🌍'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


/// LG Menu Screen with ssh
class LGMenuScreen extends StatefulWidget {
  const LGMenuScreen({super.key});

  @override
  State<LGMenuScreen> createState() => _LGMenuScreenState();
}

class _LGMenuScreenState extends State<LGMenuScreen> {
  final LGService _lgService = LGService();
  String sshOutput = 'Not connected';

  // ssh Connection details
  String ip = '192.168.1.12';
  int port = 22;
  String username = 'lg';
  String password = '123';

  /// Connect ssh
  Future<void> connectSSH() async {
    try {
      _lgService.updateConnectionDetails(
        host: ip,
        port: port,
        username: username,
        password: password,
      );
      final result = await _lgService.connect();
      setState(() {
        sshOutput = result;
      });
    } catch (e) {
      setState(() {
        sshOutput = 'Connection failed ❌\n$e';
      });
    }
  }

  /// Disconnect ssh
  void disconnectSSH() {
    _lgService.disconnect();
    setState(() {
      sshOutput = 'ssh Disconnected ❌';
    });
  }

  /// Send LG Logo
  Future<void> sendLogo() async {
    if (!_lgService.isConnected) {
      setState(() {
        sshOutput = 'Not connected ❌ Please connect first!';
      });
      return;
    }
    final logoUrl = KMLHelper.getLGLogoURL();
    final result = await _lgService.sendLogo(logoUrl);
    setState(() {
      sshOutput = result;
    });
  }

  /// Send Logo using ScreenOverlayEntity
  Future<void> sendLogoWithEntity() async {
    if (!_lgService.isConnected) {
      setState(() {
        sshOutput = 'Not connected ❌ Please connect first!';
      });
      return;
    }
    // Use the factory method to create logo overlay
    final overlay = ScreenOverlayEntity.logos();
    final result = await _lgService.sendScreenOverlay(overlay, screen: 1);
    setState(() {
      sshOutput = result;
    });
  }

  /// Send 3D Pyramid KML with FlyTo animation
  Future<void> send3DPyramid() async {
    if (!_lgService.isConnected) {
      setState(() {
        sshOutput = 'Not connected ❌ Please connect first!';
      });
      return;
    }

    setState(() {
      sshOutput = 'Generating 3D Pyramid KML with FlyTo...';
    });

    try {
      // Coordinates for New York City
      final latitude = 40.7128;
      final longitude = -74.0060;
      final altitude = 100.0;
      
      // Use KMLHelper to generate pyramid KML with FlyTo tour
      final pyramidKML = KMLHelper.generatePyramidKML(
        latitude: latitude,
        longitude: longitude,
        altitude: altitude,
      );

      setState(() {
        sshOutput = 'Flying to New York City...';
      });

      // Step 1: Fly to the location first (this works reliably)
      await _lgService.flyTo(
        latitude: latitude,
        longitude: longitude,
        altitude: 0,
        range: 1000,  // 1km range for good view
        tilt: 60,     // Good angle to see 3D
        heading: 0,
      );

      // Wait for camera to arrive
      await Future.delayed(const Duration(seconds: 3));

      setState(() {
        sshOutput = 'Loading 3D Pyramid KML...';
      });

      // Step 2: Send the pyramid KML
      final escapedKml = pyramidKML.replaceAll("'", "'\\''");
      await _lgService.executeCommand('mkdir -p /var/www/html/kml');
      await _lgService.executeCommand("echo '$escapedKml' > /var/www/html/kml/pyramid.kml");
      
      // Step 3: Load the KML via query.txt
      await _lgService.executeCommand('echo "http://lg1:81/kml/pyramid.kml" > /tmp/query.txt');

      setState(() {
        sshOutput = '✅ Success! 3D Pyramid displayed!\n\n'
            'Location: New York City (40.7128°N, 74.0060°W)\n'
            'Height: 100 meters\n\n'
            '🔴 Red Face (North)\n'
            '🟢 Green Face (East)\n'
            '🔵 Blue Face (South)\n'
            '🟡 Yellow Face (West)\n'
            '🟣 Magenta Base\n\n'
            'FlyTo animation completed!';
      });
    } catch (e) {
      setState(() {
        sshOutput = '❌ Error: $e';
      });
    }
  }

  /// Fly to Home City (Indore)
  Future<void> flyToHome() async {
    if (!_lgService.isConnected) {
      setState(() {
        sshOutput = 'Not connected ❌ Please connect first!';
      });
      return;
    }
    final result = await _lgService.flyTo(
      latitude: 22.7196,
      longitude: 75.8577,
      altitude: 0,
      range: 5000,
      tilt: 60,
      heading: 0,
    );
    setState(() {
      sshOutput = result;
    });
  }

  /// Clean Logos
  Future<void> cleanLogos() async {
    if (!_lgService.isConnected) {
      setState(() {
        sshOutput = 'Not connected ❌ Please connect first!';
      });
      return;
    }
    final result = await _lgService.cleanLogos();
    setState(() {
      sshOutput = result;
    });
  }

  /// Clean KMLs
  Future<void> cleanKMLs() async {
    if (!_lgService.isConnected) {
      setState(() {
        sshOutput = 'Not connected ❌ Please connect first!';
      });
      return;
    }
    final result = await _lgService.cleanKMLs();
    setState(() {
      sshOutput = result;
    });
  }

  /// Dialog to edit ssh details
  void showSSHDialog() {
    final ipController = TextEditingController(text: ip);
    final portController = TextEditingController(text: port.toString());
    final userController = TextEditingController(text: username);
    final passController = TextEditingController(text: password);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ssh Connection Details'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: ipController,
                decoration: const InputDecoration(labelText: 'IP Address'),
              ),
              TextField(
                controller: portController,
                decoration: const InputDecoration(labelText: 'Port'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: userController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: passController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                ip = ipController.text;
                port = int.tryParse(portController.text) ?? 22;
                username = userController.text;
                password = passController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _lgService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LG Controller Menu 🌍'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') showSSHDialog();
              if (value == 'connect') connectSSH();
              if (value == 'disconnect') disconnectSSH();
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit ssh Details')),
              const PopupMenuItem(value: 'connect', child: Text('Connect ssh')),
              const PopupMenuItem(value: 'disconnect', child: Text('Disconnect ssh')),
            ],
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade800, Colors.black87],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.shade700,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'NOTE: MOST OF THIS FUNCTIONALITIES needed here, and code, '
                    'ARE CLEARLY EXPLAINED IN 2025 Lucia\'s project.\n\n'
                    'You have to create a basic LG app, where the user can select from a simple window with a button for each action, the following activities:',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  const Text(
                    'Actions:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: sendLogo,
                    icon: const Icon(Icons.image),
                    label: const Text('Send LG Logo to Left Screen'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: sendLogoWithEntity,
                    icon: const Icon(Icons.image_outlined),
                    label: const Text('Send Logo (ScreenOverlay Entity)'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: send3DPyramid,
                    icon: const Icon(Icons.map),
                    label: const Text('Send 3D KML (Coloured Pyramid)'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: flyToHome,
                    icon: const Icon(Icons.flight_takeoff),
                    label: const Text('Fly to Home City'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: cleanLogos,
                    icon: const Icon(Icons.cleaning_services),
                    label: const Text('Clean Logos'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: cleanKMLs,
                    icon: const Icon(Icons.delete),
                    label: const Text('Clean KMLs'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                    style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'ssh Output:\n$sshOutput',
                      style: const TextStyle(color: Colors.cyanAccent),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
