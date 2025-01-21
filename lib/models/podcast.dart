import 'package:cloud_firestore/cloud_firestore.dart';

class Podcast {
  final String id;
  final String title;
  final String description;
  final String audioUrl;
  final String imageUrl;
  final String category;
  final int publishedAt;
  final int duration;
  final bool isActive;

  Podcast({
    required this.id,
    required this.title,
    required this.description,
    required this.audioUrl,
    required this.imageUrl,
    required this.category,
    required this.publishedAt,
    required this.duration,
    required this.isActive,
  });

  factory Podcast.fromJson(Map<String, dynamic> json) {
    try {
      return Podcast(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        audioUrl: json['audioUrl'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
        category: json['category'] ?? '',
        publishedAt: json['publishedAt'] is int 
          ? json['publishedAt'] 
          : int.tryParse(json['publishedAt']?.toString() ?? '') ?? DateTime.now().millisecondsSinceEpoch,
        duration: json['duration'] is int 
          ? json['duration'] 
          : int.tryParse(json['duration']?.toString() ?? '') ?? 0,
        isActive: json['isActive'] is bool 
          ? json['isActive'] 
          : json['isActive']?.toString().toLowerCase() == 'true',
      );
    } catch (e, stackTrace) {
      print('Erreur lors de la conversion du podcast: $json');
      print('Exception: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'category': category,
      'publishedAt': publishedAt,
      'duration': duration,
      'isActive': isActive,
    };
  }

  DateTime get publishedDate => DateTime.fromMillisecondsSinceEpoch(publishedAt);

  String get durationString {
    final minutes = (duration / 60).floor();
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'Podcast{id: $id, title: $title, category: $category, publishedAt: $publishedAt, isActive: $isActive}';
  }

  Podcast copyWith({
    String? id,
    String? title,
    String? description,
    String? audioUrl,
    String? imageUrl,
    String? category,
    int? publishedAt,
    int? duration,
    bool? isActive,
  }) {
    return Podcast(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      publishedAt: publishedAt ?? this.publishedAt,
      duration: duration ?? this.duration,
      isActive: isActive ?? this.isActive,
    );
  }
}
