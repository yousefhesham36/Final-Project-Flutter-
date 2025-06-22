import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../constants/app_colors.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String category;

  const CategoryProductsScreen({required this.category, super.key});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  final List<Map<String, dynamic>> productData = [
    {
      "id": 1,
      "name": "Laptop Pro",
      "category": "Computers",
      "description":
          "A powerful laptop with a high-performance processor and long battery life.",
      "price": 2500,
      "discount": 15,
      "image":
          "https://i5.walmartimages.com/seo/Restored-Apple-MacBook-Pro-Laptop-13-Retina-Display-Touch-Bar-Intel-Core-i5-16GB-RAM-512GB-SSD-Mac-OSx-Catalina-Space-Gray-MLH12LL-A-Refurbished_8d770d2d-c4b7-4883-9daa-677661f07fcb.707fc395e032c29b06d02561d220156a.jpeg",
    },
    {
      "id": 2,
      "name": "Smartphone Ultra",
      "category": "Mobiles",
      "description":
          "A flagship smartphone with an amazing camera and fast charging.",
      "price": 1200,
      "discount": 10,
      "image":
          "https://ennap.com/cdn/shop/files/01_E3_TitaniumViolet_Lockup_1600x1200_d6a6ab64-dbf9-430a-a627-969400f99fc4.jpg?v=1705602276",
    },
    {
      "id": 3,
      "name": "Wireless Headphones",
      "category": "Audio",
      "description":
          "Noise-canceling wireless headphones with 30 hours of battery life.",
      "price": 300,
      "discount": 5,
      "image":
          "https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/MQTR3?wid=1144&hei=1144&fmt=jpeg&qlt=90&.v=1687660671097",
    },
    {
      "id": 4,
      "name": "Gaming Mouse",
      "category": "Accessories",
      "description":
          "High-precision gaming mouse with RGB lighting and extra buttons.",
      "price": 80,
      "discount": 20,
      "image": "https://m.media-amazon.com/images/I/71fEUcsDDEL.jpg",
    },
    {
      "id": 5,
      "name": "Tablet Max",
      "category": "Tablets",
      "description": "A tablet perfect for work and play, with stylus support.",
      "price": 900,
      "discount": 12,
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSwyLLMoVsJ_7YRPNrThu1D43ajBTUXU66E1A&s",
    },
    {
      "id": 6,
      "name": "4K Smart TV",
      "category": "TVs",
      "description": "Large 4K smart TV with HDR and streaming apps built-in.",
      "price": 1500,
      "discount": 18,
      "image":
          "https://api-rayashop.freetls.fastly.net/media/catalog/product/cache/4e49ac3a70c0b98a165f3fa6633ffee1/g/u/gu43-du7179-uxzg-007-r-perspective2-black_i2th4jjfhimyezo1.jpg",
    },
    {
      "id": 7,
      "name": "Bluetooth Speaker",
      "category": "Audio",
      "description": "Portable speaker with deep bass and waterproof design.",
      "price": 150,
      "discount": 8,
      "image":
          "https://images.pexels.com/photos/31748137/pexels-photo-31748137/free-photo-of-portable-black-speaker-with-handle-on-table.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
    },
    {
      "id": 8,
      "name": "DSLR Camera",
      "category": "Cameras",
      "description": "Professional DSLR camera for high-quality photography.",
      "price": 1800,
      "discount": 22,
      "image":
          "https://media.gettyimages.com/id/185278433/photo/black-digital-slr-camera-in-a-white-background.jpg?s=612x612&w=gi&k=20&c=0L7vA3lq5Xy30FwCIBRAsW7Ud1i12z36vzPZ16pdeL4=",
    },
    {
      "id": 9,
      "name": "Smartwatch Gen 5",
      "category": "Wearables",
      "description":
          "Smartwatch with fitness tracking, GPS, and notifications.",
      "price": 400,
      "discount": 10,
      "image":
          "https://image.made-in-china.com/2f0j00QHybdVzjYauf/GS500-GPS-LED-Flashlight-Health-Monitoring-Fitness-Tracking-Notifications-Voice-Assistans-Wearable-Technology-Men-Man-1-43inch-Smartwatch.jpg",
    },
    {
      "id": 10,
      "name": "External Hard Drive",
      "category": "Accessories",
      "description": "2TB external hard drive for backup and file storage.",
      "price": 120,
      "discount": 15,
      "image": "https://i.ebayimg.com/images/g/hdkAAOSwyGpmjOdM/s-l400.jpg",
    },
  ];

  late List<Product> allProducts;

  @override
  void initState() {
    super.initState();
    allProducts = productData.map((item) {
      // print("++++ $item");
      return Product.fromJson(item);
    }).toList();
    _loadProducts();
  }

  void _loadProducts() {
    try {
      // Filter products from allProducts based on the category
      final filteredProducts = allProducts
          .where((product) => product.category == widget.category)
          .toList();
      setState(() {
        _products = filteredProducts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load products: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category,
          style: const TextStyle(color: AppColors.primaryBlue),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          return ProductCard(product: _products[index]);
        },
      ),
    );
  }
}
