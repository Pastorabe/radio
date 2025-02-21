
class RadioStation {
  final String id;
  final String name;
  final String streamUrl;
  final String logo;
  final String slide1;
  final String slide2;
  final String slide3;
  final String description;
  final String category;
  final bool isActive;

  RadioStation({
    required this.id,
    required this.name,
    required this.streamUrl,
    required this.logo,
    required this.slide1,
    required this.slide2,
    required this.slide3,
    required this.description,
    required this.category,
    this.isActive = true,
  });

  factory RadioStation.fromJson(Map<String, dynamic> json) {
    return RadioStation(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      streamUrl: json['streamUrl'] ?? '',
      logo: json['logo'] ?? '',
      slide1: json['slide1'] ?? '',
      slide2: json['slide2'] ?? '',
      slide3: json['slide3'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'streamUrl': streamUrl,
      'logo': logo,
      'slide1': slide1,
      'slide2': slide2,
      'slide3': slide3,
      'description': description,
      'category': category,
      'isActive': isActive,
    };
  }

  RadioStation copyWith({
    String? id,
    String? name,
    String? streamUrl,
    String? logo,
    String? slide1,
    String? slide2,
    String? slide3,
    String? description,
    String? category,
    bool? isActive,
  }) {
    return RadioStation(
      id: id ?? this.id,
      name: name ?? this.name,
      streamUrl: streamUrl ?? this.streamUrl,
      logo: logo ?? this.logo,
      slide1: slide1 ?? this.slide1,
      slide2: slide2 ?? this.slide2,
      slide3: slide3 ?? this.slide3,
      description: description ?? this.description,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
    );
  }
}
