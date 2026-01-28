import 'package:amti_fluttter_task1/models/kml/placemark_entity.dart';
import 'package:amti_fluttter_task1/models/kml/point_entity.dart';
import 'package:amti_fluttter_task1/models/kml/line_entity.dart';
import 'package:amti_fluttter_task1/models/kml/look_at_entity.dart';
import 'package:amti_fluttter_task1/models/kml/tour_entity.dart';
import 'package:amti_fluttter_task1/models/kml/screen_overlay_entity.dart';

class KMLHelper {
  /// Generate a 3D colored pyramid KML with FlyTo tour
  /// Center coordinates: Indore, India (for demonstration)
  static String generatePyramidKML({
    double latitude = 22.7196,
    double longitude = 75.8577,
    double altitude = 100,
  }) {
    // Calculate the base corners (approx 100m x 100m base)
    final double baseOffset = 0.0005; // Approximately 50 meters
    
    // Base corners
    final double lon1 = longitude - baseOffset; // West
    final double lon2 = longitude + baseOffset; // East
    final double lat1 = latitude - baseOffset;  // South
    final double lat2 = latitude + baseOffset;  // North
    
    return '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2">
  <Document>
    <name>3D Colored Pyramid with FlyTo</name>
    <description>A stunning 3D pyramid with colored faces and FlyTo animation</description>
    
    <!-- FlyTo Tour to show the pyramid -->
    <gx:Tour>
      <name>Fly to Pyramid</name>
      <gx:Playlist>
        <gx:FlyTo>
          <gx:duration>4.0</gx:duration>
          <gx:flyToMode>smooth</gx:flyToMode>
          <LookAt>
            <longitude>$longitude</longitude>
            <latitude>$latitude</latitude>
            <altitude>0</altitude>
            <heading>0</heading>
            <tilt>60</tilt>
            <range>1000</range>
            <gx:altitudeMode>relativeToGround</gx:altitudeMode>
          </LookAt>
        </gx:FlyTo>
      </gx:Playlist>
    </gx:Tour>
    
    <Style id="redFace">
      <PolyStyle>
        <color>990000ff</color>
        <fill>1</fill>
        <outline>1</outline>
      </PolyStyle>
      <LineStyle>
        <color>ff000000</color>
        <width>3</width>
      </LineStyle>
    </Style>
    
    <Style id="greenFace">
      <PolyStyle>
        <color>9900ff00</color>
        <fill>1</fill>
        <outline>1</outline>
      </PolyStyle>
      <LineStyle>
        <color>ff000000</color>
        <width>3</width>
      </LineStyle>
    </Style>
    
    <Style id="blueFace">
      <PolyStyle>
        <color>99ff0000</color>
        <fill>1</fill>
        <outline>1</outline>
      </PolyStyle>
      <LineStyle>
        <color>ff000000</color>
        <width>3</width>
      </LineStyle>
    </Style>
    
    <Style id="yellowFace">
      <PolyStyle>
        <color>9900ffff</color>
        <fill>1</fill>
        <outline>1</outline>
      </PolyStyle>
      <LineStyle>
        <color>ff000000</color>
        <width>3</width>
      </LineStyle>
    </Style>
    
    <Style id="baseFace">
      <PolyStyle>
        <color>99ff00ff</color>
        <fill>1</fill>
        <outline>1</outline>
      </PolyStyle>
      <LineStyle>
        <color>ff000000</color>
        <width>3</width>
      </LineStyle>
    </Style>
    
    <Folder>
      <name>Colored Pyramid</name>
      <open>1</open>
      
      <Placemark>
        <name>Base (Magenta)</name>
        <styleUrl>#baseFace</styleUrl>
        <Polygon>
          <extrude>0</extrude>
          <altitudeMode>relativeToGround</altitudeMode>
          <outerBoundaryIs>
            <LinearRing>
              <coordinates>
                $lon1,$lat1,0
                $lon2,$lat1,0
                $lon2,$lat2,0
                $lon1,$lat2,0
                $lon1,$lat1,0
              </coordinates>
            </LinearRing>
          </outerBoundaryIs>
        </Polygon>
      </Placemark>
      
      <Placemark>
        <name>North Face (Red)</name>
        <styleUrl>#redFace</styleUrl>
        <Polygon>
          <extrude>0</extrude>
          <altitudeMode>relativeToGround</altitudeMode>
          <outerBoundaryIs>
            <LinearRing>
              <coordinates>
                $lon1,$lat2,0
                $lon2,$lat2,0
                $longitude,$latitude,$altitude
                $lon1,$lat2,0
              </coordinates>
            </LinearRing>
          </outerBoundaryIs>
        </Polygon>
      </Placemark>
      
      <Placemark>
        <name>East Face (Green)</name>
        <styleUrl>#greenFace</styleUrl>
        <Polygon>
          <extrude>0</extrude>
          <altitudeMode>relativeToGround</altitudeMode>
          <outerBoundaryIs>
            <LinearRing>
              <coordinates>
                $lon2,$lat2,0
                $lon2,$lat1,0
                $longitude,$latitude,$altitude
                $lon2,$lat2,0
              </coordinates>
            </LinearRing>
          </outerBoundaryIs>
        </Polygon>
      </Placemark>
      
      <Placemark>
        <name>South Face (Blue)</name>
        <styleUrl>#blueFace</styleUrl>
        <Polygon>
          <extrude>0</extrude>
          <altitudeMode>relativeToGround</altitudeMode>
          <outerBoundaryIs>
            <LinearRing>
              <coordinates>
                $lon2,$lat1,0
                $lon1,$lat1,0
                $longitude,$latitude,$altitude
                $lon2,$lat1,0
              </coordinates>
            </LinearRing>
          </outerBoundaryIs>
        </Polygon>
      </Placemark>
      
      <Placemark>
        <name>West Face (Yellow)</name>
        <styleUrl>#yellowFace</styleUrl>
        <Polygon>
          <extrude>0</extrude>
          <altitudeMode>relativeToGround</altitudeMode>
          <outerBoundaryIs>
            <LinearRing>
              <coordinates>
                $lon1,$lat1,0
                $lon1,$lat2,0
                $longitude,$latitude,$altitude
                $lon1,$lat1,0
              </coordinates>
            </LinearRing>
          </outerBoundaryIs>
        </Polygon>
      </Placemark>
      
      <Placemark>
        <name>Apex Point</name>
        <Point>
          <altitudeMode>relativeToGround</altitudeMode>
          <coordinates>$longitude,$latitude,$altitude</coordinates>
        </Point>
      </Placemark>
      
    </Folder>
  </Document>
</kml>''';
  }

  /// Generate LG logo URL (using Liquid Galaxy's official logo from web)
  static String getLGLogoURL() {
    // Using official LG logo from their GitHub
    return 'https://raw.githubusercontent.com/LiquidGalaxyLAB/liquid-galaxy/master/gnu_linux/home/lg/tools/earth/Image_lg.jpg';
  }

  /// Create a satellite orbit placemark with orbital path
  static PlacemarkEntity createSatellitePlacemark({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    required List<Map<String, double>> orbitCoordinates,
    String? description,
    String? icon,
    double altitude = 400000, // Default satellite altitude
  }) {
    final point = PointEntity(
      lat: latitude,
      lng: longitude,
      altitude: altitude,
    );

    final line = LineEntity(coordinates: orbitCoordinates);

    final lookAt = LookAtEntity(
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      range: altitude * 2,
      tilt: 60,
      heading: 0,
    );

    return PlacemarkEntity(
      id: id,
      name: name,
      description: description ?? 'Satellite: $name',
      icon: icon ?? 'satellite_icon.png',
      point: point,
      line: line,
      lookAt: lookAt,
      viewOrbit: true,
      scale: 3.0,
      balloonContent: '''
        <h2>$name</h2>
        <p>$description</p>
        <p>Altitude: ${altitude}m</p>
        <p>Latitude: $latitude°</p>
        <p>Longitude: $longitude°</p>
      ''',
    );
  }

  /// Create a city marker placemark
  static PlacemarkEntity createCityMarker({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    String? description,
    String? icon,
  }) {
    final point = PointEntity(
      lat: latitude,
      lng: longitude,
      altitude: 0,
    );

    final line = LineEntity(coordinates: []); // No orbit line

    final lookAt = LookAtEntity(
      latitude: latitude,
      longitude: longitude,
      altitude: 0,
      range: 10000,
      tilt: 60,
      heading: 0,
    );

    return PlacemarkEntity(
      id: id,
      name: name,
      description: description ?? 'City: $name',
      icon: icon ?? 'city_icon.png',
      point: point,
      line: line,
      lookAt: lookAt,
      viewOrbit: false,
      scale: 2.0,
      balloonContent: '''
        <h2>$name</h2>
        <p>${description ?? 'City location'}</p>
        <p>Coordinates: $latitude°, $longitude°</p>
      ''',
    );
  }

  /// Create a tour visiting multiple locations
  static TourEntity createTour({
    required String name,
    required List<LookAtEntity> locations,
    double duration = 3.0,
  }) {
    return TourEntity(
      name: name,
      playlist: locations,
      duration: duration,
    );
  }

  /// Generate orbital coordinates for a circular orbit
  static List<Map<String, double>> generateOrbitCoordinates({
    required double centerLat,
    required double centerLon,
    required double altitude,
    double radius = 1.0, // In degrees
    int points = 50,
  }) {
    List<Map<String, double>> coordinates = [];
    
    for (int i = 0; i <= points; i++) {
      final angle = (i * 2 * 3.14159) / points;
      final lat = centerLat + (radius * (angle / 3.14159 - 1));
      final lon = centerLon + (radius * (1 - angle / 3.14159));
      
      coordinates.add({
        'latitude': lat,
        'longitude': lon,
        'altitude': altitude,
      });
    }
    
    return coordinates;
  }

  /// Create a default LG logo screen overlay
  static ScreenOverlayEntity createLogoOverlay({
    String? customIcon,
    double screenX = 0.02,
    double screenY = 0.95,
    double sizeX = 250,
    double sizeY = 250,
  }) {
    return ScreenOverlayEntity(
      name: 'LG Logo',
      icon: customIcon ?? getLGLogoURL(),
      overlayX: 0,
      overlayY: 1,
      screenX: screenX,
      screenY: screenY,
      sizeX: sizeX,
      sizeY: sizeY,
    );
  }

  /// Create a custom screen overlay
  static ScreenOverlayEntity createCustomOverlay({
    required String name,
    required String iconUrl,
    double overlayX = 0,
    double overlayY = 1,
    double screenX = 0.5,
    double screenY = 0.5,
    double sizeX = 200,
    double sizeY = 200,
  }) {
    return ScreenOverlayEntity(
      name: name,
      icon: iconUrl,
      overlayX: overlayX,
      overlayY: overlayY,
      screenX: screenX,
      screenY: screenY,
      sizeX: sizeX,
      sizeY: sizeY,
    );
  }
}
