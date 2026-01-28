import 'package:flutter/material.dart';
import 'package:amti_fluttter_task1/services/lg_service.dart';

/// A screen to demonstrate KMLMakers functionality
class KMLMakersDemoScreen extends StatefulWidget {
  final LGService lgService;

  const KMLMakersDemoScreen({Key? key, required this.lgService}) : super(key: key);

  @override
  State<KMLMakersDemoScreen> createState() => _KMLMakersDemoScreenState();
}

class _KMLMakersDemoScreenState extends State<KMLMakersDemoScreen> {
  String _statusMessage = 'Ready to send KML';
  bool _isLoading = false;

  // Demo logo URL
  final String _logoUrl = 'https://raw.githubusercontent.com/LiquidGalaxyLAB/liquid-galaxy/master/gnu_linux/home/lg/tools/earth/Image_lg.jpg';

  Future<void> _sendLogoOverlay() async {
    setState(() => _isLoading = true);

    final result = await widget.lgService.sendScreenOverlayImage(_logoUrl, screen: 1);

    setState(() {
      _statusMessage = result;
      _isLoading = false;
    });
  }

  Future<void> _sendBalloonOverlay() async {
    setState(() => _isLoading = true);

    const htmlContent = '''
      <h1 style="color: #2196F3;">Space Visualizations</h1>
      <p style="font-size: 16px;">Welcome to Liquid Galaxy!</p>
      <ul>
        <li>Explore Mars</li>
        <li>View Space Images</li>
        <li>Interactive Tours</li>
      </ul>
    ''';

    final result = await widget.lgService.sendBalloonOverlay(htmlContent);

    setState(() {
      _statusMessage = result;
      _isLoading = false;
    });
  }

  Future<void> _sendBlankKML() async {
    setState(() => _isLoading = true);

    final result = await widget.lgService.sendBlankKML('blank_demo');

    setState(() {
      _statusMessage = result;
      _isLoading = false;
    });
  }

  Future<void> _flyToLocation() async {
    setState(() => _isLoading = true);

    final result = await widget.lgService.flyToWithKMLMakers(
      latitude: 28.6139,
      longitude: 77.2090,
      zoom: 10000,
      tilt: 60,
      bearing: 0,
      instant: false,
    );

    setState(() {
      _statusMessage = 'Flying to Delhi, India';
      _isLoading = false;
    });
  }

  Future<void> _flyToInstant() async {
    setState(() => _isLoading = true);

    final result = await widget.lgService.flyToWithKMLMakers(
      latitude: 19.0760,
      longitude: 72.8777,
      zoom: 10000,
      tilt: 60,
      bearing: 0,
      instant: true,
    );

    setState(() {
      _statusMessage = 'Instant fly to Mumbai, India';
      _isLoading = false;
    });
  }

  Future<void> _startOrbit() async {
    setState(() => _isLoading = true);

    final result = await widget.lgService.startOrbitWithKMLMakers(
      latitude: 22.7196,
      longitude: 75.8577,
      zoom: 10000,
      tilt: 60,
    );

    setState(() {
      _statusMessage = 'Started orbit around Indore';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KMLMakers Demo'),
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status Card
                  Card(
                    color: widget.lgService.isConnected ? Colors.green[50] : Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            widget.lgService.isConnected ? Icons.check_circle : Icons.error,
                            color: widget.lgService.isConnected ? Colors.green : Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _statusMessage,
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (!widget.lgService.isConnected) ...[
                    const Card(
                      color: Colors.orange,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Please connect to Liquid Galaxy first',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],

                  if (widget.lgService.isConnected) ...[
                    const Text(
                      'Screen Overlay Demos',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    _buildDemoButton(
                      icon: Icons.image,
                      label: 'Send Logo Overlay',
                      subtitle: 'Display LG logo using screenOverlayImage',
                      onPressed: _sendLogoOverlay,
                    ),

                    _buildDemoButton(
                      icon: Icons.chat_bubble,
                      label: 'Send Balloon Overlay',
                      subtitle: 'Display HTML balloon using screenOverlayBalloon',
                      onPressed: _sendBalloonOverlay,
                    ),

                    _buildDemoButton(
                      icon: Icons.delete_outline,
                      label: 'Send Blank KML',
                      subtitle: 'Clear screen with generateBlank',
                      onPressed: _sendBlankKML,
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      'LookAt Demos',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    _buildDemoButton(
                      icon: Icons.flight_takeoff,
                      label: 'Fly To (Smooth)',
                      subtitle: 'Smooth fly to Delhi using lookAtLinear',
                      onPressed: _flyToLocation,
                    ),

                    _buildDemoButton(
                      icon: Icons.flash_on,
                      label: 'Fly To (Instant)',
                      subtitle: 'Instant fly to Mumbai using lookAtLinearInstant',
                      onPressed: _flyToInstant,
                    ),

                    _buildDemoButton(
                      icon: Icons.rotate_right,
                      label: 'Start Orbit',
                      subtitle: 'Orbit around location using orbitLookAtLinear',
                      onPressed: _startOrbit,
                    ),

                    const SizedBox(height: 20),
                    const Card(
                      color: Colors.blue,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'About KMLMakers',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'KMLMakers is a utility class that generates KML code for various Liquid Galaxy operations:',
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '• screenOverlayImage - Display images on screen\n'
                              '• screenOverlayBalloon - Show HTML balloons\n'
                              '• generateBlank - Clear KML content\n'
                              '• lookAtLinear - Smooth camera movements\n'
                              '• lookAtLinearInstant - Quick camera jumps\n'
                              '• orbitLookAtLinear - Orbiting animations',
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildDemoButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue, size: 32),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onPressed,
      ),
    );
  }
}
