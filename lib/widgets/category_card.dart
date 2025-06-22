import 'package:flutter/material.dart';
import '../models/category.dart';
import '../screens/category_products_screen.dart';
import '../constants/app_colors.dart';

class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard({required this.category, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ActionChip(
        label: Text(
          category.name,
          style: const TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.primaryBlue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CategoryProductsScreen(category: category.name),
            ),
          );
        },
      ),
    );
  }
}
