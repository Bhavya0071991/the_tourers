class HomeBanner {
  final String id;
  final String imageUrl;
  final String title;
  final String subtitle;
  final String? linkTarget;
  final bool isActive;
  final int orderIndex;
  final DateTime createdAt;

  HomeBanner({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    this.linkTarget,
    this.isActive = true,
    this.orderIndex = 0,
    required this.createdAt,
  });

  factory HomeBanner.fromJson(Map<String, dynamic> json) {
    return HomeBanner(
      id: json['id'] as String,
      imageUrl: json['image_url'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      linkTarget: json['link_target'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      orderIndex: json['order_index'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'image_url': imageUrl,
      'title': title,
      'subtitle': subtitle,
      'link_target': linkTarget,
      'is_active': isActive,
      'order_index': orderIndex,
      'created_at': createdAt.toIso8601String(),
    };
    
    if (id.isNotEmpty) {
      map['id'] = id;
    }
    
    return map;
  }

  HomeBanner copyWith({
    String? id,
    String? imageUrl,
    String? title,
    String? subtitle,
    String? linkTarget,
    bool? isActive,
    int? orderIndex,
    DateTime? createdAt,
  }) {
    return HomeBanner(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      linkTarget: linkTarget ?? this.linkTarget,
      isActive: isActive ?? this.isActive,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
