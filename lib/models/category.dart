class Category {
  final String name;

  Category({required this.name});

  factory Category.fromJson(dynamic json) {
    return Category(name: json.toString());
  }

  Map<String, dynamic> toJson() => {'name': name};
}
