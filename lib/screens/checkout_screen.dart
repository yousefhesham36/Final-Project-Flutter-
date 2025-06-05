import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../constants/app_colors.dart';
import 'orders_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;

  const CheckoutScreen({required this.cartItems, super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  String _paymentMethod = 'Cash on Delivery';
  bool _isLoading = false;

  Future<void> _placeOrder() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final prefs = await SharedPreferences.getInstance();
        final ordersJson = prefs.getString('orders') ?? '[]';
        print('Loaded orders JSON: $ordersJson'); // Debug print

        // Migration logic for old orders
        final orders = <Order>[];
        final decodedOrders = jsonDecode(ordersJson) as List;
        for (var item in decodedOrders) {
          try {
            orders.add(Order.fromJson(item as Map<String, dynamic>));
          } catch (e) {
            print('Error migrating order: $e'); // Debug print
            // Skip invalid orders
            continue;
          }
        }

        final totalPrice = widget.cartItems.fold(
          0.0,
          (sum, item) => sum + (item.product.price * item.quantity),
        );
        final newOrder = Order(
          id: orders.isEmpty ? 1 : orders.length + 1,
          items: widget.cartItems,
          totalPrice: totalPrice,
          date: DateTime.now().toIso8601String(),
        );
        orders.add(newOrder);

        final newOrdersJson = jsonEncode(
          orders.map((order) => order.toJson()).toList(),
        );
        await prefs.setString('orders', newOrdersJson);
        print('Saved orders JSON: $newOrdersJson'); // Debug print

        await prefs.remove('cart');
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OrdersScreen()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order placed successfully')),
          );
        }
      } catch (e) {
        print('Error placing order: $e'); // Debug print
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error placing order: $e')));
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.cartItems.fold(
      0.0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(color: AppColors.white)),
        backgroundColor: AppColors.primaryBlue,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Shipping Address',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter your shipping address',
                    fillColor: AppColors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(
                        color: AppColors.grey.withOpacity(0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(
                        color: AppColors.primaryBlue,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Address is required' : null,
                ),
                const SizedBox(height: 28),
                const Text(
                  'Payment Method',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _paymentMethod,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(
                        color: AppColors.grey.withOpacity(0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(
                        color: AppColors.primaryBlue,
                        width: 2,
                      ),
                    ),
                  ),
                  items: ['Cash on Delivery', 'Credit Card', 'PayPal']
                      .map(
                        (method) => DropdownMenuItem(
                          value: method,
                          child: Text(
                            method,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _paymentMethod = value!),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(color: AppColors.grey.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.grey.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.cartItems.length,
                    separatorBuilder: (context, index) => Divider(
                      color: AppColors.grey.withOpacity(0.3),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final item = widget.cartItems[index];
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        leading: Image.network(
                          item.product.effectiveImage, // Use effectiveImage
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const CircularProgressIndicator(
                              color: AppColors.primaryBlue,
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.broken_image,
                                color: AppColors.red,
                                size: 50,
                              ),
                        ),
                        title: Text(
                          item.product.name,
                          style: const TextStyle(
                            fontSize: 17,
                            color: AppColors.black87,
                          ),
                        ),
                        subtitle: Text(
                          '\$${item.product.price.toStringAsFixed(2)} x ${item.quantity}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: Text(
                          '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    Text(
                      '\$${totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Center(
                  child: SizedBox(
                    width: 220,
                    height: 48,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: AppColors.primaryBlue,
                            strokeWidth: 3,
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            onPressed: _placeOrder,
                            child: const Text(
                              'Place Order',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
