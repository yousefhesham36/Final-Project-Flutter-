import 'cart_item.dart';

class Order {
  final int id;
  final List<CartItem> items;
  final double totalPrice;

  Order({required this.id, required this.items, required this.totalPrice});

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List? ?? [];
    return Order(
      id: json['id'] as int? ?? 0,
      items: itemsJson
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
    };
  }
}
