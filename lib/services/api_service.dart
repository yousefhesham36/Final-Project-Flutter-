import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/product.dart';

class ApiService {
  static const String baseUrl = 'https://ib.jamalmoallart.com/api/v1';

  Future<List<Category>> getCategories() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/all/categories'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Empty response from server');
        }
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Category.fromJson(item)).toList();
      } else {
        throw Exception(
          'Failed to load categories: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error fetching categories: $e');
      throw Exception('Error fetching categories: $e');
    }
  }

  Future<List<Product>> getProducts() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/all/products'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Empty response from server');
        }
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load products: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Error fetching products: $e');
    }
  }

  Future<List<Product>> getCategoryProducts(String category) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/products/category/$category'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Empty response from server');
        }
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load category products: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error fetching category products: $e');
      throw Exception('Error fetching category products: $e');
    }
  }
}
