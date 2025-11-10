import 'package:cloud_firestore/cloud_firestore.dart';

class VideoData {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;
  final DateTime timestamp;

  VideoData({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.timestamp,
  });

  factory VideoData.fromMap(Map<String, dynamic> map, String id) {
    return VideoData(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'timestamp': timestamp,
    };
  }
}
