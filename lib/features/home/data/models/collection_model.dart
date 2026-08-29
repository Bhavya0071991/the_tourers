class CollectionModel {
  final String id;
  final String title;
  final String subtitle;
  final String count;
  final String imageUrl;
  final int sortOrder;

  const CollectionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.imageUrl,
    required this.sortOrder,
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      count: json['count'] as String,
      imageUrl: json['image_url'] as String,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'title': title,
      'subtitle': subtitle,
      'count': count,
      'image_url': imageUrl,
      'sort_order': sortOrder,
    };
  }

  CollectionModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? count,
    String? imageUrl,
    int? sortOrder,
  }) {
    return CollectionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      count: count ?? this.count,
      imageUrl: imageUrl ?? this.imageUrl,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
