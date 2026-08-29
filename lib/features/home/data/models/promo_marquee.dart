class PromoMarquee {
  final String text;
  final bool isActive;

  PromoMarquee({
    required this.text,
    required this.isActive,
  });

  factory PromoMarquee.fromJson(Map<String, dynamic> json) {
    return PromoMarquee(
      text: json['text'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'is_active': isActive,
    };
  }

  PromoMarquee copyWith({
    String? text,
    bool? isActive,
  }) {
    return PromoMarquee(
      text: text ?? this.text,
      isActive: isActive ?? this.isActive,
    );
  }
}
