/// Represents a Sol (Martian day) with its associated data
class SolDay {
  /// The Sol number (Martian day number since landing)
  final int sol;

  /// The corresponding Earth date
  final DateTime earthDate;

  /// Total number of photos taken on this Sol
  final int totalPhotos;

  /// List of cameras that took photos on this Sol
  final List<String> cameras;

  SolDay({
    required this.sol,
    required this.earthDate,
    required this.totalPhotos,
    required this.cameras,
  });

  /// Creates a SolDay instance from JSON data
  factory SolDay.fromJson(Map<String, dynamic> json) {
    return SolDay(
      sol: json['sol'] ?? 0,
      earthDate: DateTime.parse(json['earth_date'] ?? DateTime.now().toIso8601String()),
      totalPhotos: json['total_photos'] ?? 0,
      cameras: List<String>.from(json['cameras'] ?? []),
    );
  }

  /// Converts the SolDay instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'sol': sol,
      'earth_date': earthDate.toIso8601String(),
      'total_photos': totalPhotos,
      'cameras': cameras,
    };
  }

  @override
  String toString() {
    return 'SolDay(sol: $sol, earthDate: $earthDate, totalPhotos: $totalPhotos, cameras: $cameras)';
  }
}
