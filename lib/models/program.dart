import 'package:cloud_firestore/cloud_firestore.dart';

class RadioProgram {
  final String id;
  final String title;
  final String description;
  final String host;
  final String imageUrl;
  final DateTime startTime;
  final DateTime endTime;
  final String streamUrl;
  final bool isLive;
  final bool isPodcast;

  RadioProgram({
    required this.id,
    required this.title,
    required this.description,
    required this.host,
    required this.imageUrl,
    required this.startTime,
    required this.endTime,
    required this.streamUrl,
    required this.isLive,
    required this.isPodcast,
  });

  factory RadioProgram.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return RadioProgram(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      host: data['host'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      streamUrl: data['streamUrl'] ?? '',
      isLive: data['isLive'] ?? false,
      isPodcast: data['isPodcast'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'host': host,
      'imageUrl': imageUrl,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'streamUrl': streamUrl,
      'isLive': isLive,
      'isPodcast': isPodcast,
    };
  }
}
