/// Class that defines the `LookAt` entity, which contains its properties and
/// methods.
class LookAtEntity {
  /// Property that defines the look at `latitude`.
  double latitude;

  /// Property that defines the look at `longitude`.
  double longitude;

  /// Property that defines the look at `altitude`.
  double altitude;

  /// Property that defines the look at `range`.
  double range;

  /// Property that defines the look at `tilt`.
  double tilt;

  /// Property that defines the look at `heading`.
  double heading;

  /// Property that defines the altitude mode.
  String altitudeMode;

  LookAtEntity({
    required this.latitude,
    required this.longitude,
    this.altitude = 0,
    this.range = 5000,
    this.tilt = 60,
    this.heading = 0,
    this.altitudeMode = 'relativeToGround',
  });

  /// Property that defines the LookAt `tag` according to its current
  /// properties.
  String get tag => '''
    <LookAt>
      <longitude>$longitude</longitude>
      <latitude>$latitude</latitude>
      <altitude>$altitude</altitude>
      <heading>$heading</heading>
      <tilt>$tilt</tilt>
      <range>$range</range>
      <gx:altitudeMode>$altitudeMode</gx:altitudeMode>
    </LookAt>
  ''';

  /// Returns a [Map] from the current [LookAtEntity].
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'range': range,
      'tilt': tilt,
      'heading': heading,
      'altitudeMode': altitudeMode,
    };
  }

  /// Returns a [LookAtEntity] from the given [map].
  factory LookAtEntity.fromMap(Map<String, dynamic> map) {
    return LookAtEntity(
      latitude: map['latitude'],
      longitude: map['longitude'],
      altitude: map['altitude'] ?? 0,
      range: map['range'] ?? 5000,
      tilt: map['tilt'] ?? 60,
      heading: map['heading'] ?? 0,
      altitudeMode: map['altitudeMode'] ?? 'relativeToGround',
    );
  }
}
