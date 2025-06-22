import 'package:flutter/material.dart';
import '../models/product.dart';
import '../screens/product_details_screen.dart';
import '../constants/app_colors.dart';

class ProductSearchDelegate extends SearchDelegate<Product?> {
  final List<Product> products;

  ProductSearchDelegate(this.products);

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(
      icon: const Icon(Icons.clear, color: AppColors.grey),
      onPressed: () => query = '',
    ),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back, color: AppColors.grey),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) =>
      _buildProductList(context, _filterResults());

  @override
  Widget buildSuggestions(BuildContext context) =>
      _buildProductList(context, _filterResults(), isSuggestion: true);

  List<Product> _filterResults() {
    final lowerQuery = query.toLowerCase();
    return products
        .where((p) => p.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  Widget _buildProductList(
    BuildContext context,
    List<Product> items, {
    bool isSuggestion = false,
  }) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final product = items[index];
        return ListTile(
          leading: Image.network(
            product.imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                const Icon(Icons.error, color: AppColors.red),
          ),
          title: Text(
            product.name,
            style: TextStyle(
              color: isSuggestion ? AppColors.white : AppColors.black87,
            ),
          ),
          subtitle: isSuggestion
              ? null
              : Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(color: AppColors.green),
                ),
          onTap: () {
            close(context, product);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailsScreen(product: product),
              ),
            );
          },
        );
      },
    );
  }
}
