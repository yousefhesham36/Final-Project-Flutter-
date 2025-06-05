import 'package:flutter/foundation.dart';

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image'] as String? ?? '',
      category: json['category'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': imageUrl,
      'category': category,
    };
  }

  static const Map<String, String> _productImageMap = {
    'tablet': 'https://images.unsplash.com/photo-1517147177326-b37599372b8b',
    'smartphone':
        'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9',
    'bluetooth': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e',
    // Add other products if needed
  };

  String get effectiveImage {
    if (imageUrl.isNotEmpty && _isValidUrl(imageUrl)) {
      return imageUrl;
    }
    return _productImageMap[name.toLowerCase()] ??
        'https://via.placeholder.com/150';
  }

  bool _isValidUrl(String url) {
    return Uri.tryParse(url)?.hasAbsolutePath ?? false;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
