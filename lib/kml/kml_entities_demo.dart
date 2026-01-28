import 'package:flutter/material.dart';
import 'package:amti_fluttter_task1/models/kml/placemark_entity.dart';
import 'package:amti_fluttter_task1/models/kml/point_entity.dart';
import 'package:amti_fluttter_task1/models/kml/line_entity.dart';
import 'package:amti_fluttter_task1/models/kml/look_at_entity.dart';
import 'package:amti_fluttter_task1/models/kml/tour_entity.dart';
import 'package:amti_fluttter_task1/services/lg_service.dart';
import 'package:amti_fluttter_task1/utils/kml_helper.dart';

/// Demo screen showing how to use PlacemarkEntity and KML entities
class KMLEntitiesDemo extends StatefulWidget {
  const KMLEntitiesDemo({super.key});

  @override
  State<KMLEntitiesDemo> createState() => _KMLEntitiesDemoState();
}

class _KMLEntitiesDemoState extends State<KMLEntitiesDemo> {
  final LGService _lgService = LGService();
  String _statusMessage = 'Ready to send KML entities';

  @override
  void dispose() {
    _lgService.dispose();
    super.dispose();
  }

  void _updateStatus(String message) {
    setState(() {
      _statusMessage = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Example 1: Create and send a simple point placemark
  Future<void> _sendSimplePoint() async {
    if (!_lgService.isConnected) {
      _updateStatus('Connect to LG first');
      return;
    }

    // Create a simple point entity
    final point = PointEntity(
      lat: 22.7196,
      lng: 75.8577,
      altitude: 0,
    );

    // Create an empty line entity (no orbit)
    final line = LineEntity(coordinates: []);

    // Create placemark
    final placemark = PlacemarkEntity(
      id: 'simple-point',
      name: 'Indore City',
      description: 'Simple point marker',
      point: point,
      line: line,
      viewOrbit: false,
    );

    final result = await _lgService.sendPlacemark(placemark);
    _updateStatus(result);
  }

  /// Example 2: Create and send a placemark with orbit line
  Future<void> _sendPlacemarkWithOrbit() async {
    if (!_lgService.isConnected) {
      _updateStatus('Connect to LG first');
      return;
    }

    // Create point for satellite position
    final point = PointEntity(
      lat: 22.7196,
      lng: 75.8577,
      altitude: 500000, // 500km altitude
    );

    // Create orbit line coordinates
    final orbitCoords = KMLHelper.generateOrbitCoordinates(
      centerLat: 22.7196,
      centerLon: 75.8577,
      altitude: 500000,
      radius: 2.0,
      points: 50,
    );

    final line = LineEntity(coordinates: orbitCoords);

    // Create LookAt to view the satellite
    final lookAt = LookAtEntity(
      latitude: 22.7196,
      longitude: 75.8577,
      altitude: 500000,
      range: 1000000,
      tilt: 60,
      heading: 0,
    );

    // Create placemark with orbit
    final placemark = PlacemarkEntity(
      id: 'satellite-with-orbit',
      name: 'Demo Satellite',
      description: 'Satellite with orbital path',
      point: point,
      line: line,
      lookAt: lookAt,
      viewOrbit: true,
      scale: 3.0,
      balloonContent: '''
        <h2>Demo Satellite</h2>
        <p>Orbiting at 500km altitude</p>
        <p>Location: Indore, India</p>
      ''',
    );

    final result = await _lgService.sendPlacemark(placemark);
    _updateStatus(result);
  }

  /// Example 3: Create and send multiple placemarks
  Future<void> _sendMultiplePlacemarks() async {
    if (!_lgService.isConnected) {
      _updateStatus('Connect to LG first');
      return;
    }

    List<PlacemarkEntity> placemarks = [];

    // Create placemark for Indore
    placemarks.add(KMLHelper.createCityMarker(
      id: 'indore',
      name: 'Indore',
      latitude: 22.7196,
      longitude: 75.8577,
      description: 'Indore, Madhya Pradesh',
    ));

    // Create placemark for Delhi
    placemarks.add(KMLHelper.createCityMarker(
      id: 'delhi',
      name: 'Delhi',
      latitude: 28.6139,
      longitude: 77.2090,
      description: 'Delhi, Capital of India',
    ));

    // Create placemark for Mumbai
    placemarks.add(KMLHelper.createCityMarker(
      id: 'mumbai',
      name: 'Mumbai',
      latitude: 19.0760,
      longitude: 72.8777,
      description: 'Mumbai, Maharashtra',
    ));

    final result = await _lgService.sendMultiplePlacemarks(placemarks);
    _updateStatus(result);
  }

  /// Example 4: Create a tour visiting multiple locations
  Future<void> _sendTourExample() async {
    if (!_lgService.isConnected) {
      _updateStatus('Connect to LG first');
      return;
    }

    // Create LookAt entities for different locations
    List<LookAtEntity> tourStops = [
      LookAtEntity(
        latitude: 22.7196,
        longitude: 75.8577,
        range: 10000,
        tilt: 60,
        heading: 0,
      ),
      LookAtEntity(
        latitude: 28.6139,
        longitude: 77.2090,
        range: 10000,
        tilt: 60,
        heading: 45,
      ),
      LookAtEntity(
        latitude: 19.0760,
        longitude: 72.8777,
        range: 10000,
        tilt: 60,
        heading: 90,
      ),
    ];

    // Create tour
    final tour = TourEntity(
      name: 'India Cities Tour',
      playlist: tourStops,
      duration: 4.0,
    );

    // Create a placemark with the tour
    final point = PointEntity(
      lat: 22.7196,
      lng: 75.8577,
      altitude: 0,
    );

    final line = LineEntity(coordinates: []);

    final placemark = PlacemarkEntity(
      id: 'cities-tour',
      name: 'India Cities Tour',
      description: 'Automated tour of Indian cities',
      point: point,
      line: line,
      tour: tour,
      viewOrbit: false,
    );

    final result = await _lgService.sendPlacemark(placemark);
    _updateStatus(result);
  }

  /// Example 5: Using KMLHelper utilities
  Future<void> _sendUsingHelper() async {
    if (!_lgService.isConnected) {
      _updateStatus('Connect to LG first');
      return;
    }

    // Use KMLHelper to create a satellite placemark
    final orbitCoords = KMLHelper.generateOrbitCoordinates(
      centerLat: 20.0,
      centerLon: 77.0,
      altitude: 400000,
      radius: 3.0,
      points: 60,
    );

    final satellite = KMLHelper.createSatellitePlacemark(
      id: 'helper-satellite',
      name: 'ISS-Like Satellite',
      latitude: 20.0,
      longitude: 77.0,
      orbitCoordinates: orbitCoords,
      description: 'Created using KMLHelper',
      altitude: 400000,
    );

    final result = await _lgService.sendPlacemark(satellite);
    _updateStatus(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KML Entities Demo'),
        backgroundColor: Colors.indigo,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade800, Colors.black87],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'KML Entities Demonstration',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage,
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildDemoCard(
              title: '1. Simple Point Placemark',
              description: 'Send a simple point marker to Indore',
              icon: Icons.location_on,
              onPressed: _sendSimplePoint,
            ),
            _buildDemoCard(
              title: '2. Placemark with Orbit',
              description: 'Send a satellite with orbital path',
              icon: Icons.satellite_alt,
              onPressed: _sendPlacemarkWithOrbit,
            ),
            _buildDemoCard(
              title: '3. Multiple Placemarks',
              description: 'Send markers for Indore, Delhi, Mumbai',
              icon: Icons.place,
              onPressed: _sendMultiplePlacemarks,
            ),
            _buildDemoCard(
              title: '4. Tour Example',
              description: 'Create automated tour of cities',
              icon: Icons.tour,
              onPressed: _sendTourExample,
            ),
            _buildDemoCard(
              title: '5. Using KMLHelper',
              description: 'Generate satellite using helper utilities',
              icon: Icons.build,
              onPressed: _sendUsingHelper,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.indigo, size: 32),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyanAccent.shade400,
            foregroundColor: Colors.black,
          ),
          child: const Text('Send'),
        ),
      ),
    );
  }
}
