class Category {
  final String name;

  Category({required this.name});

  factory Category.fromJson(dynamic json) {
    if (json is String) {
      return Category(name: json);
    } else if (json is Map<String, dynamic>) {
      return Category(name: json['name'] as String? ?? 'Unknown');
    }
    throw Exception('Invalid category format: $json');
  }

  Map<String, dynamic> toJson() => {'name': name};
}
