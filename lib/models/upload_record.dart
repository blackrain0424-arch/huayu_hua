class UploadRecord {
  final String imagePath;
  final String title;
  final String description;
  final String location;
  final double? latitude;
  final double? longitude;
  final DateTime timestamp;

  const UploadRecord({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.location,
    this.latitude,
    this.longitude,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'imagePath': imagePath,
        'title': title,
        'description': description,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp.toIso8601String(),
      };

  factory UploadRecord.fromJson(Map<String, dynamic> json) => UploadRecord(
        imagePath: json['imagePath'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        location: json['location'] as String,
        latitude: json['latitude'] as double?,
        longitude: json['longitude'] as double?,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
