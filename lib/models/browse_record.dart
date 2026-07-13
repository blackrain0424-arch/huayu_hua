class BrowseRecord {
  final String spotName;
  final List<String> flowers;
  final DateTime timestamp;

  const BrowseRecord({
    required this.spotName,
    required this.flowers,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'spotName': spotName,
        'flowers': flowers,
        'timestamp': timestamp.toIso8601String(),
      };

  factory BrowseRecord.fromJson(Map<String, dynamic> json) => BrowseRecord(
        spotName: json['spotName'] as String,
        flowers: List<String>.from(json['flowers']),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
