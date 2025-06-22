import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../utils/product_search.dart';
import '../widgets/category_card.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import '../constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  List<Category> _categories = [];
  List<Product> _products = [];
  String _userName = 'Guest';
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

  @override
  void initState() {
    super.initState();
    _products = productData.map((item) => Product.fromJson(item)).toList();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      // Load user data
      final user = await _authService.getUser();
      setState(() {
        if (user != null) {
          _userName = '${user.firstName} ${user.lastName}';
        }
      });

      // Load categories
      final categories = await _apiService.getCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
        if (_categories.isEmpty && _products.isEmpty) {
          _errorMessage = 'Failed to load data. Please try again.';
        }
      });
    } catch (e) {
      setState(() {
        _categories = [];
        _isLoading = false;
        _errorMessage = 'Failed to load data. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text(
          'Welcome $_userName',
          style: const TextStyle(color: AppColors.white, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.black87),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(_products),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.black87),
            onPressed: () async {
              try {
                await _authService.logout();
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error logging out: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 450,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      viewportFraction: 0.9,
                    ),
                    items: _products.take(8).map((product) {
                      return Builder(
                        builder: (context) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.grey.withOpacity(0.3),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) =>
                                    const Icon(Icons.broken_image, size: 50),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  if (_categories.isNotEmpty)
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) =>
                            CategoryCard(category: _categories[index]),
                      ),
                    ),
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'New Arrivals',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 12, 168, 59),
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                    itemCount: _products.length,
                    itemBuilder: (context, index) =>
                        ProductCard(product: _products[index]),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.black87,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrdersScreen()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
              break;
          }
        },
      ),
    );
  }
}
