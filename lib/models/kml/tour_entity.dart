import 'package:amti_fluttter_task1/models/kml/look_at_entity.dart';

/// Class that defines the `Tour` entity, which contains its properties and
/// methods.
class TourEntity {
  /// Property that defines the tour `name`.
  String name;

  /// Property that defines the tour `playlist` of LookAt entities.
  List<LookAtEntity> playlist;

  /// Property that defines the duration between tour stops in seconds.
  double duration;

  TourEntity({
    required this.name,
    required this.playlist,
    this.duration = 3.0,
  });

  /// Property that defines the Tour `tag` according to its current
  /// properties.
  String get tag {
    final playlistItems = playlist.map((lookAt) => '''
      <gx:FlyTo>
        <gx:duration>$duration</gx:duration>
        <gx:flyToMode>smooth</gx:flyToMode>
        ${lookAt.tag}
      </gx:FlyTo>
    ''').join('\n');

    return '''
    <gx:Tour>
      <name>$name</name>
      <gx:Playlist>
        $playlistItems
      </gx:Playlist>
    </gx:Tour>
  ''';
  }

  /// Returns a [Map] from the current [TourEntity].
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'playlist': playlist.map((e) => e.toMap()).toList(),
      'duration': duration,
    };
  }

  /// Returns a [TourEntity] from the given [map].
  factory TourEntity.fromMap(Map<String, dynamic> map) {
    return TourEntity(
      name: map['name'],
      playlist: List<LookAtEntity>.from(
        map['playlist'].map((x) => LookAtEntity.fromMap(x)),
      ),
      duration: map['duration'] ?? 3.0,
    );
  }
}
