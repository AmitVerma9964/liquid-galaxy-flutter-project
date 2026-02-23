import 'package:dartssh2/dartssh2.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:amti_fluttter_task1/models/kml/placemark_entity.dart';
import 'package:amti_fluttter_task1/models/kml/point_entity.dart';
import 'package:amti_fluttter_task1/models/kml/line_entity.dart';
import 'package:amti_fluttter_task1/models/kml/screen_overlay_entity.dart';
import 'package:amti_fluttter_task1/utils/kml_makers.dart';
import 'package:amti_fluttter_task1/utils/orbit_kml.dart';

/// Global instance of [LGService] for easy access throughout the app
LGService lgService = LGService();

/// URL for the logos to be displayed on Liquid Galaxy
const String logosUrl = 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgXmdNgBTXup6bdWew5RzgCmC9pPb7rK487CpiscWB2S8OlhwFHmeeACHIIjx4B5-Iv-t95mNUx0JhB_oATG3-Tq1gs8Uj0-Xb9Njye6rHtKKsnJQJlzZqJxMDnj_2TXX3eA5x6VSgc8aw/s320-rw/LOGO+LIQUID+GALAXY-sq1000-+OKnoline.png';

/// Service class to handle all Liquid Galaxy ssh operations
class LGService {
  SSHClient? _client;
  String _host = '192.168.1.100';
  int _port = 22;
  String _username = 'lg';
  String _password = 'lg';
  int _screenAmount = 3;

  bool get isConnected => _client != null;

  String get host => _host;
  int get port => _port;
  String get username => _username;
  String? get password => _password;
  int get screenAmount => _screenAmount;
  
  /// Gets the left screen number
  int get leftScreen => (_screenAmount / 2).floor() + 1;
  
  /// Gets the right screen number
  int get rightScreen => (_screenAmount / 2).floor() + 2;

  /// Update ssh connection details
  void updateConnectionDetails({
    required String host,
    required int port,
    required String username,
    required String password,
    int screenAmount = 3,
  }) {
    _host = host;
    _port = port;
    _username = username;
    _password = password;
    _screenAmount = screenAmount;
  }

  /// Connect to Liquid Galaxy via ssh
  Future<String> connect() async {
    try {
      if (_client != null) {
        return 'Already connected';
      }

      final socket = await SSHSocket.connect(_host, _port);
      _client = SSHClient(
        socket,
        username: _username,
        onPasswordRequest: () => _password,
      );

      // Show logos after successful connection
      await showLogos();

      return 'Connected successfully to $_host';
    } catch (e) {
      return 'Connection failed: $e';
    }
  }

  /// Disconnect from Liquid Galaxy
  Future<void> disconnect() async {
    _client?.close();
    _client = null;
  }

  /// Execute a command on the master
  Future<String> executeCommand(String command) async {
    if (_client == null) {
      return 'Not connected to LG';
    }

    try {
      final result = await _client!.run(command);
      return String.fromCharCodes(result);
    } catch (e) {
      return 'Command failed: $e';
    }
  }

  /// Execute command on a specific screen
  Future<String> executeCommandOnScreen(String command, int screen) async {
    if (_client == null) {
      return 'Not connected to LG';
    }

    try {
      final screenName = 'lg$screen';
      final sshCommand = 'sshpass -p $_password ssh -t $_username@$screenName "$command"';
      final result = await _client!.run(sshCommand);
      return String.fromCharCodes(result);
    } catch (e) {
      return 'Command failed on screen $screen: $e';
    }
  }

  /// Upload local logo image to LG and display it on master screen
  Future<String> sendLocalLogo(Uint8List imageBytes, {int screen = 1}) async {
    if (_client == null) {
      return 'Not connected to LG';
    }

    try {
      // Step 1: Create images directory on LG
      await executeCommand('mkdir -p /var/www/html/images');
      
      // Step 2: Upload image file to LG using base64 encoding
      final base64Image = base64Encode(imageBytes);
      final uploadCommand = "echo '$base64Image' | base64 -d > /var/www/html/images/LIQUIDGALAXYLOGO.png";
      await executeCommand(uploadCommand);
      
      // Step 3: Create KML for screen overlay pointing to the uploaded image
      final imageUrl = 'http://lg1:81/images/LIQUIDGALAXYLOGO.png';
      final kml = '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2">
  <Document>
    <name>LG Logo</name>
    <ScreenOverlay>
      <name>Liquid Galaxy Logo</name>
      <Icon>
        <href>$imageUrl</href>
      </Icon>
      <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
      <screenXY x="0" y="1" xunits="fraction" yunits="fraction"/>
      <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
      <size x="0.2" y="0" xunits="fraction" yunits="fraction"/>
    </ScreenOverlay>
  </Document>
</kml>''';
      
      // Step 4: Write KML file
      final escapedKml = kml.replaceAll("'", "'\\''");
      await executeCommand("echo '$escapedKml' > /var/www/html/kml/logo.kml");
      
      // Step 5: Display on master screen (screen 1 or specified screen)
      await executeCommand("echo 'http://lg1:81/kml/logo.kml' > /tmp/query.txt");
      
      return '✅ Logo uploaded and displayed on LG master screen (Screen $screen)';
    } catch (e) {
      return '❌ Failed to send logo: $e';
    }
  }

  /// Send logo to left screen (screen 1 in a 3-screen setup)
  Future<String> sendLogo(String logoContent) async {
    if (_client == null) {
      return 'Not connected to LG';
    }

    try {
      await sendScreenOverlayImage(logoContent, screen: leftScreen);
      return 'Logo sent successfully to left screen (Screen $leftScreen)';
    } catch (e) {
      return 'Failed to send logo: $e';
    }
  }

  /// Display the logos on LG 2 slave machine (screen 2)
  Future<void> showLogos() async {
    if (_client == null) {
      return;
    }

    await sendScreenOverlayImage(logosUrl, screen: 3);
  }

  /// Send ScreenOverlayEntity to a specific screen
  Future<String> sendScreenOverlay(ScreenOverlayEntity overlay, {int screen = 3}) async {
    if (_client == null) {
      return 'Not connected to LG';
    }

    try {
      // KML for displaying screen overlay
      final kml = '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <name>Image Overlay</name>
    <GroundOverlay>
      <name>Liquid Galaxy Logo</name>
      <Icon>
        <href>https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgXmdNgBTXup6bdWew5RzgCmC9pPb7rK487CpiscWB2S8OlhwFHmeeACHIIjx4B5-Iv-t95mNUx0JhB_oATG3-Tq1gs8Uj0-Xb9Njye6rHtKKsnJQJlzZqJxMDnj_2TXX3eA5x6VSgc8aw/s320-rw/LOGO+LIQUID+GALAXY-sq1000-+OKnoline.png</href>
      </Icon>
      <LatLonBox>
        <north>37.8324</north>
        <south>37.8320</south>
        <east>-122.3730</east>
        <west>-122.3734</west>
        <rotation>0</rotation>
      </LatLonBox>
    </GroundOverlay>
  </Document>
</kml>''';

      // Escape single quotes for shell command
      final escapedKml = kml.replaceAll("'", "'\\''");
      
      // Create kml directory if it doesn't exist
      await executeCommand('mkdir -p /var/www/html/kml');
      
      // Write KML to file on LG
      final writeCommand = "echo '$escapedKml' > /var/www/html/kml/slave_$screen.kml";
      await executeCommand(writeCommand);

      // Query file to load it
      final query = 'echo "http://lg1:81/kml/slave_$screen.kml" > /tmp/query.txt';
      await executeCommand(query);

      return 'Screen overlay "${overlay.name}" sent successfully to screen $screen';
    } catch (e) {
      return 'Failed to send screen overlay: $e';
    }
  }

  /// Send KML to Liquid Galaxy
  Future<String> sendKML(String kmlContent, String fileName) async {
    if (_client == null) {
      return 'Not connected to LG';
    }

    try {
      // Create kml directory if it doesn't exist
      await executeCommand('mkdir -p /var/www/html/kml');
      
      // Write KML file to kml directory
      final escapedKml = kmlContent.replaceAll("'", "'\\''");
      final writeCommand = "echo '$escapedKml' > /var/www/html/kml/$fileName.kml";
      await executeCommand(writeCommand);

      // Add layer to queries.txt so it appears in Google Earth layers
      final layerEntry = 'layers@$fileName@http://lg1:81/kml/$fileName.kml';
      await executeCommand("grep -qxF '$layerEntry' /var/www/html/queries.txt || echo '$layerEntry' >> /var/www/html/queries.txt");

      return 'KML sent successfully: $fileName.kml (Check Google Earth layers)';
    } catch (e) {
      return 'Failed to send KML: $e';
    }
  }

  /// Fly to a specific location
  Future<String> flyTo({
    required double latitude,
    required double longitude,
    double altitude = 0,
    double tilt = 60,
    double heading = 0,
    double range = 5000,
  }) async {
    if (_client == null) {
      return 'Not connected to LG';
    }

    try {
      // Use flytoview command format (verified working with LG)
      final flyToCommand = 'flytoview=<LookAt><longitude>$longitude</longitude><latitude>$latitude</latitude><altitude>$altitude</altitude><heading>$heading</heading><tilt>$tilt</tilt><range>$range</range><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>';
      
      // Send flytoview command to query.txt
      final command = "echo '$flyToCommand' > /tmp/query.txt";
      await executeCommand(command);

      return 'Flying to location (Lat: $latitude, Lon: $longitude)';
    } catch (e) {
      return 'Failed to fly to location: $e';
    }
  }

  /// Fly to a specific location
  Future<String> sendPyramid({
    required String pyramidKml,
  }) async {
    if (_client == null) {
      return 'Not connected to LG';
    }

    try {
      final command = "echo '$pyramidKml' > /tmp/query.txt";
      await executeCommand(command);
      return 'Building a pyramid using KML';
    } catch (e) {
      return 'Failed to fly to location: $e';
    }
  }


  /// Clean all logos
  Future<String> cleanLogos() async {
    if (_client == null) {
      return 'Not connected to LG';
    }

    try {
      // Remove logo KML files from all screens
      for (int i = 1; i <= _screenAmount; i++) {
        await executeCommand('rm -f /var/www/html/kml/slave_$i.kml');
      }

      // Clear the query file
      await executeCommand('echo "" > /tmp/query.txt');

      return 'Logos cleaned successfully';
    } catch (e) {
      return 'Failed to clean logos: $e';
    }
  }

  /// Clean all KMLs
  Future<String> cleanKMLs() async {
    if (_client == null) {
      return 'Not connected to LG';
    }

    try {
      // Remove KML files from kml directory
      await executeCommand('rm -f /var/www/html/kml/*.kml');
      
      // Remove kmls.txt (used for tours)
      await executeCommand('rm -f /var/www/html/kmls.txt');
      
      // Clear query file
      await executeCommand('echo "" > /tmp/query.txt');

      return 'KMLs cleaned successfully';
    } catch (e) {
      return 'Failed to clean KMLs: $e';
    }
  }

  /// Reboot Liquid Galaxy
  Future<String> rebootLG() async {
    if (_client == null || _password.isEmpty) {
      return 'Not connected to LG or password missing';
    }

    try {
      for (int i = _screenAmount; i >= 1; i--) {
        await executeCommand('sshpass -p $_password ssh -t lg$i "echo $_password | sudo -S reboot"');
      }
      return 'Reboot command sent to all screens';
    } catch (e) {
      return 'Failed to reboot: $e';
    }
  }

  /// Shuts down the Liquid Galaxy system
  Future<String> shutdown() async {
    if (_client == null || _password.isEmpty) {
      return 'Not connected to LG or password missing';
    }

    try {
      for (int i = _screenAmount; i >= 1; i--) {
        await executeCommand('sshpass -p $_password ssh -t lg$i "echo $_password | sudo -S poweroff"');
      }
      return 'Shutdown command sent to all screens';
    } catch (e) {
      return 'Failed to shutdown: $e';
    }
  }

  /// Relaunch Google Earth on all screens
  Future<String> relaunchGE() async {
    if (_client == null) {
      return 'Not connected to LG';
    }

    try {
      final command = 'export DISPLAY=:0 && pkill -9 googleearth-bin && (sleep 2; /usr/bin/google-earth-pro) &';
      
      await executeCommand(command);
      return 'Google Earth relaunched';
    } catch (e) {
      return 'Failed to relaunch: $e';
    }
  }

  /// Send PlacemarkEntity to Liquid Galaxy
  Future<String> sendPlacemark(PlacemarkEntity placemark) async {
    if (_client == null) {
      return 'Not connected to LG';
    }

    try {
      // Create complete KML document with placemark
      final kml = '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2">
  <Document>
    <name>${placemark.name}</name>
    ${placemark.tag}
  </Document>
</kml>''';

      // Send KML using existing sendKML method
      return await sendKML(kml, placemark.id);
    } catch (e) {
      return 'Failed to send placemark: $e';
    }
  }

  /// Send multiple placemarks at once
  Future<String> sendMultiplePlacemarks(List<PlacemarkEntity> placemarks) async {
    if (_client == null) {
      return 'Not connected to LG';
    }

    try {
      // Create complete KML document with all placemarks
      final placemarkTags = placemarks.map((p) => p.tag).join('\n');
      
      final kml = '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2">
  <Document>
    <name>Multiple Placemarks</name>
    $placemarkTags
  </Document>
</kml>''';

      // Send KML using existing sendKML method
      return await sendKML(kml, 'multiple_placemarks');
    } catch (e) {
      return 'Failed to send placemarks: $e';
    }
  }

  /// Create and send a simple placemark (point marker)
  Future<String> sendSimplePoint({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    double altitude = 0,
    String? description,
    String? icon,
  }) async {
    if (_client == null) {
      return 'Not connected to LG';
    }

    try {
      final point = PointEntity(
        lat: latitude,
        lng: longitude,
        altitude: altitude,
      );

      final line = LineEntity(coordinates: []); // Empty line for simple point

      final placemark = PlacemarkEntity(
        id: id,
        name: name,
        description: description,
        icon: icon,
        point: point,
        line: line,
        viewOrbit: false, // No orbit for simple point
      );

      return await sendPlacemark(placemark);
    } catch (e) {
      return 'Failed to send simple point: $e';
    }
  }

  /// Dispose and cleanup
  void dispose() {
    disconnect();
  }

  // ==================== KMLMakers Integration ====================

  /// Send screen overlay image using KMLMakers
  Future<String> sendScreenOverlayImage(String imageUrl, {int screen = 1}) async {
    if (_client == null) {
      return 'Not connected to LG';
    }

    try {
      // Generate KML using KMLMakers
      final kml = KMLMakers.screenOverlayImage(imageUrl);

      // Escape single quotes for shell command
      final escapedKml = kml.replaceAll("'", "'\\''");
      
      // Create kml directory if it doesn't exist
      await executeCommand('mkdir -p /var/www/html/kml');
      
      // Write KML to file on LG
      final writeCommand = "echo '$escapedKml' > /var/www/html/kml/slave_$screen.kml";
      await executeCommand(writeCommand);

      // Query file to load it
      final query = 'echo "http://lg1:81/kml/slave_$screen.kml" > /tmp/query.txt';
      await executeCommand(query);

      return 'Screen overlay image sent to screen $screen';
    } catch (e) {
      return 'Failed to send screen overlay image: $e';
    }
  }

  /// Send balloon overlay using KMLMakers
  Future<String> sendBalloonOverlay(String htmlContent) async {
    if (_client == null) {
      return 'Not connected to LG';
    }

    try {
      // Generate KML using KMLMakers
      final kml = KMLMakers.screenOverlayBalloon(htmlContent);

      return await sendKML(kml, 'balloon');
    } catch (e) {
      return 'Failed to send balloon overlay: $e';
    }
  }

  /// Send blank KML using KMLMakers
  Future<String> sendBlankKML(String id) async {
    if (_client == null) {
      return 'Not connected to LG';
    }

    try {
      // Generate blank KML using KMLMakers
      final kml = KMLMakers.generateBlank(id);

      return await sendKML(kml, id);
    } catch (e) {
      return 'Failed to send blank KML: $e';
    }
  }

  /// Fly to location using KMLMakers LookAt
  Future<String> flyToWithKMLMakers({
    required double latitude,
    required double longitude,
    required double zoom,
    required double tilt,
    required double bearing,
    bool instant = false,
  }) async {
    if (_client == null) {
      return 'Not connected to LG';
    }

    try {
      // Generate LookAt using KMLMakers
      String lookAt;
      if (instant) {
        lookAt = KMLMakers.lookAtLinearInstant(latitude, longitude, zoom, tilt, bearing);
      } else {
        lookAt = KMLMakers.lookAtLinear(latitude, longitude, zoom, tilt, bearing);
      }

      // Wrap in a flyTo command
      final kml = '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2">
  <Document>
    <name>FlyTo</name>
    <gx:Tour>
      <name>FlyTo Tour</name>
      <gx:Playlist>
        <gx:FlyTo>
          $lookAt
        </gx:FlyTo>
      </gx:Playlist>
    </gx:Tour>
  </Document>
</kml>''';

      return await sendKML(kml, 'flyto');
    } catch (e) {
      return 'Failed to fly to location: $e';
    }
  }

  /// Start orbit using KMLMakers
  Future<String> startOrbitWithKMLMakers({
    required double latitude,
    required double longitude,
    required double zoom,
    required double tilt,
  }) async {
    if (_client == null) {
      return 'Not connected to LG';
    }

    try {
      // Create orbit playlist
      final playlist = StringBuffer();
      
      for (int i = 0; i <= 360; i += 10) {
        final lookAt = KMLMakers.orbitLookAtLinear(
          latitude,
          longitude,
          zoom,
          tilt,
          i.toDouble(),
        );
        playlist.writeln('<gx:FlyTo>$lookAt</gx:FlyTo>');
      }

      final kml = '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2">
  <Document>
    <name>Orbit</name>
    <gx:Tour>
      <name>Orbit Tour</name>
      <gx:Playlist>
        ${playlist.toString()}
      </gx:Playlist>
    </gx:Tour>
  </Document>
</kml>''';

      return await sendKML(kml, 'orbit');
    } catch (e) {
      return 'Failed to start orbit: $e';
    }
  }

  // ==================== Advanced LG Features ====================

  /// Get SFTP client for file operations
  Future<SftpClient> getSftp() async {
    if (_client == null) {
      throw Exception('Not connected to LG');
    }
    return await _client!.sftp();
  }

  /// Send KML file from the assets folder to the Liquid Galaxy system
  ///
  /// [assetPath] is the path to the KML file in the assets folder
  /// [images] is an optional list of image URLs to include
  Future<String> sendKmlFromAssets(String assetPath, {List<String> images = const []}) async {
    if (_client == null) {
      return 'Not connected to LG';
    }

    try {
      // Load the KML file content from the assets folder
      final kml = await rootBundle.loadString(assetPath);

      // Extract filename from path
      final fileName = assetPath.split('/').last.replaceAll('.kml', '');

      // Send the KML content
      return await sendKML(kml, fileName);
    } catch (e) {
      return 'Failed to send KML from assets: $e';
    }
  }

  /// Relaunches the Liquid Galaxy services
  Future<String> relaunch() async {
    if (_client == null || _password.isEmpty) {
      return 'Not connected to LG or password missing';
    }

    try {
      for (var i = _screenAmount; i >= 1; i--) {
        final relaunchCommand = """RELAUNCH_CMD="\\
if [ -f /etc/init/lxdm.conf ]; then
  export SERVICE=lxdm
elif [ -f /etc/init/lightdm.conf ]; then
  export SERVICE=lightdm
else
  exit 1
fi
if  [[ \\\$(service \\\$SERVICE status) =~ 'stop' ]]; then
  echo $_password | sudo -S service \\\${SERVICE} start
else
  echo $_password | sudo -S service \\\${SERVICE} restart
fi
" && sshpass -p $_password ssh -x -t lg@lg$i "\$RELAUNCH_CMD\"""";
        await executeCommand('"/home/$_username/bin/lg-relaunch" > /home/$_username/log.txt');
        await executeCommand(relaunchCommand);
      }
      return 'Relaunch command sent to all screens';
    } catch (e) {
      return 'Failed to relaunch: $e';
    }
  }

  /// Clears the KML files from the Liquid Galaxy system
  ///
  /// [keepLogos] indicates whether to keep the logo overlays
  Future<String> clearKml({bool keepLogos = false}) async {
    if (_client == null) {
      return 'Not connected to LG';
    }

    try {
      String query = 'echo "exittour=true" > /tmp/query.txt && > /var/www/html/kmls.txt';

      for (var i = 2; i <= _screenAmount; i++) {
        String blankKml = KMLMakers.generateBlank('slave_$i');
        query += " && echo '$blankKml' > /var/www/html/kml/slave_$i.kml";
      }

      await executeCommand(query);

      if (keepLogos) {
        await showLogos();
      }

      return 'KML cleared successfully${keepLogos ? ' (logos kept)' : ''}';
    } catch (e) {
      return 'Failed to clear KML: $e';
    }
  }

  /// Sets the planet to display on the Liquid Galaxy
  ///
  /// The [planet] can be 'earth', 'mars', or 'moon'
  Future<String> setPlanet(String planet) async {
    if (_client == null) {
      return 'Not connected to LG';
    }

    if (planet.isEmpty || (planet != 'earth' && planet != 'mars' && planet != 'moon')) {
      return 'Invalid planet. Use: earth, mars, or moon';
    }

    try {
      await executeCommand('echo \'planet=$planet\' > /tmp/query.txt');
      return 'Planet set to $planet';
    } catch (e) {
      return 'Failed to set planet: $e';
    }
  }

  /// Builds an orbit animation around a specific latitude and longitude
  ///
  /// This method computes an orbit animation based on provided [latitude], [longitude], [zoom] level,
  /// [tilt], and [bearing]
  Future<String> buildOrbit(double latitude, double longitude, double zoom, double tilt, double bearing) async {
    if (_client == null) {
      return 'Not connected to LG';
    }

    try {
      // Build the orbit KML
      final orbit = OrbitKml.buildOrbit(OrbitKml.tag(latitude, longitude, zoom, tilt, bearing));
      
      // Start the orbit
      return await startOrbit(orbit);
    } catch (e) {
      return 'Failed to build orbit: $e';
    }
  }

  /// Starts the orbit animation on the Liquid Galaxy using SFTP
  ///
  /// [tourKml] is the KML content defining the orbit
  Future<String> startOrbit(String tourKml) async {
    if (_client == null) {
      return 'Not connected to LG';
    }

    try {
      const fileName = 'Orbit.kml';

      SftpClient sftp = await getSftp();

      // Open a remote file for writing
      final remoteFile = await sftp.open('/var/www/html/$fileName',
          mode: SftpFileOpenMode.create |
              SftpFileOpenMode.write |
              SftpFileOpenMode.truncate);

      // Convert KML string to a stream
      final kmlStreamBytes = Stream.value(Uint8List.fromList(tourKml.codeUnits));

      // Write the KML content to the remote file
      await remoteFile.write(kmlStreamBytes);

      await remoteFile.close();
      sftp.close();

      // Prepare the orbit
      await executeCommand("echo '\nhttp://lg1:81/$fileName' >> /var/www/html/kmls.txt");

      await Future.delayed(const Duration(seconds: 1));

      // Start the orbit
      await executeCommand('echo "playtour=Orbit" > /tmp/query.txt');

      return 'Orbit started successfully';
    } catch (e) {
      return 'Failed to start orbit: $e';
    }
  }

  /// Stops any currently playing orbit animation on the Liquid Galaxy
  Future<String> stopOrbit() async {
    if (_client == null) {
      return 'Not connected to LG';
    }

    try {
      await executeCommand('echo "exittour=true" > /tmp/query.txt');
      return 'Orbit stopped successfully';
    } catch (e) {
      return 'Failed to stop orbit: $e';
    }
  }

  /// Displays an image on the Liquid Galaxy system using Chromium
  ///
  /// Requires `display_images_service` to be installed on the Liquid Galaxy system
  ///
  /// [imgUrl] is the URL of the image to be displayed
  Future<String> displayImageOnLG(String imgUrl) async {
    if (_client == null || _password.isEmpty) {
      return 'Not connected to LG or password missing';
    }

    try {
      await executeCommand('bash display_images_service/scripts/open.sh $_password $imgUrl $_screenAmount');
      return 'Image displayed on LG: $imgUrl';
    } catch (e) {
      return 'Failed to display image: $e';
    }
  }

  /// Closes the image displayed on the Liquid Galaxy system
  ///
  /// Requires `display_images_service` to be installed on the Liquid Galaxy system
  Future<String> closeImageOnLG() async {
    if (_client == null || _password.isEmpty) {
      return 'Not connected to LG or password missing';
    }

    try {
      await executeCommand('bash display_images_service/scripts/close.sh $_password');
      return 'Image closed on LG';
    } catch (e) {
      return 'Failed to close image: $e';
    }
  }

}

