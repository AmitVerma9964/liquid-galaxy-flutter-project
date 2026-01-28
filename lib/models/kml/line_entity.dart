/// Class that defines the `line` entity, which contains its properties and
/// methods.
class LineEntity {
  /// Property that defines the line `coordinates`.
  List<Map<String, double>> coordinates;

  LineEntity({
    required this.coordinates,
  });

  /// Property that defines the line `tag` according to its current
  /// properties.
  String get tag {
    final coordinatesString = coordinates
        .map((coord) =>
            '${coord['longitude']},${coord['latitude']},${coord['altitude'] ?? 0}')
        .join(' ');

    return '''
    <LineString>
      <coordinates>$coordinatesString</coordinates>
      <altitudeMode>relativeToGround</altitudeMode>
    </LineString>
  ''';
  }

  /// Returns a [Map] from the current [LineEntity].
  Map<String, dynamic> toMap() {
    return {
      'coordinates': coordinates,
    };
  }

  /// Returns a [LineEntity] from the given [map].
  factory LineEntity.fromMap(Map<String, dynamic> map) {
    return LineEntity(
      coordinates: List<Map<String, double>>.from(
        map['coordinates'].map((coord) => Map<String, double>.from(coord)),
      ),
    );
  }
}
