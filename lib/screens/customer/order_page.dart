import 'package:flutter/material.dart';
import 'package:jpmfood/data/config/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/cart_item_model.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  bool _isProcessing = false;
  String _selectedPaymentMethod = 'Credit Card';

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'Credit Card', 'icon': Icons.credit_card, 'color': AppColors.primary},
    {
      'name': 'Digital Wallet',
      'icon': Icons.account_balance_wallet,
      'color': Colors.green,
    },
    {'name': 'Cash on Delivery', 'icon': Icons.money, 'color': Colors.blue},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Summary'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/customer/cart'),
        ),
      ),
      body: Consumer2<CartProvider, AuthProvider>(
        builder: (context, cartProvider, authProvider, child) {
          if (authProvider.currentUser == null) {
            return const Center(
              child: Text('Please log in to continue with your order'),
            );
          }

          if (cartProvider.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOrderItemsSection(cartProvider),
                      const SizedBox(height: 24),
                      _buildPaymentMethodSection(),
                      const SizedBox(height: 24),
                      _buildOrderSummarySection(cartProvider),
                    ],
                  ),
                ),
              ),
              _buildConfirmOrderButton(cartProvider, authProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderItemsSection(CartProvider cartProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...cartProvider.cartItems.map(
              (cartItem) => _buildOrderItemCard(cartItem),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemCard(CartItemModel cartItem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: cartItem.menuItem.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      cartItem.menuItem.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.fastfood,
                          color: AppColors.primary,
                          size: 24,
                        );
                      },
                    ),
                  )
                : const Icon(Icons.fastfood, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.menuItem.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Qty: ${cartItem.quantity}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            '\$${cartItem.totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._paymentMethods.map((method) => _buildPaymentMethodTile(method)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile(Map<String, dynamic> method) {
    // final isSelected = _selectedPaymentMethod == method['name'];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: RadioListTile<String>(
        title: Row(
          children: [
            Icon(method['icon'], color: method['color'], size: 20),
            const SizedBox(width: 8),
            Text(method['name']),
          ],
        ),
        value: method['name'],
        groupValue: _selectedPaymentMethod,
        onChanged: (value) {
          setState(() {
            _selectedPaymentMethod = value!;
          });
        },
        activeColor: AppColors.primary,
        contentPadding: const EdgeInsets.all(0),
      ),
    );
  }

  Widget _buildOrderSummarySection(CartProvider cartProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Subtotal',
              '\$${cartProvider.subtotal.toStringAsFixed(2)}',
            ),
            _buildSummaryRow('Tax', '\$${cartProvider.tax.toStringAsFixed(2)}'),
            _buildSummaryRow(
              'Delivery Fee',
              cartProvider.deliveryFee == 0
                  ? 'FREE'
                  : '\$${cartProvider.deliveryFee.toStringAsFixed(2)}',
              isDeliveryFee: true,
            ),
            const Divider(height: 20),
            _buildSummaryRow(
              'Total',
              '\$${cartProvider.totalWithTaxAndDelivery.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isDeliveryFee = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal
                  ? AppColors.primary
                  : isDeliveryFee && value == 'FREE'
                  ? Colors.green
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmOrderButton(
    CartProvider cartProvider,
    AuthProvider authProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _isProcessing
              ? null
              : () => _confirmOrder(cartProvider, authProvider),
          icon: _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.check_circle),
          label: Text(
            _isProcessing ? 'Processing...' : 'Confirm Order',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmOrder(
    CartProvider cartProvider,
    AuthProvider authProvider,
  ) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final user = authProvider.currentUser!;
      final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';

      // Prepare order data
      final orderData = {
        'orderId': orderId,
        'userId': user.uid,
        'items': cartProvider.cartItems
            .map(
              (cartItem) => {
                'menuItemId': cartItem.menuItem.id,
                'name': cartItem.menuItem.name,
                'description': cartItem.menuItem.description,
                'price': cartItem.menuItem.price,
                'quantity': cartItem.quantity,
                'totalPrice': cartItem.totalPrice,
                'imageUrl': cartItem.menuItem.imageUrl,
                'category': cartItem.menuItem.category,
                'specialInstructions': cartItem.specialInstructions,
              },
            )
            .toList(),
        'subtotal': cartProvider.subtotal,
        'tax': cartProvider.tax,
        'deliveryFee': cartProvider.deliveryFee,
        'totalPrice': cartProvider.totalWithTaxAndDelivery,
        'paymentMethod': _selectedPaymentMethod,
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Save order to Firebase
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .doc(orderId)
          .set(orderData);

      // Clear cart after successful order
      await cartProvider.clearCart(user.uid);

      if (mounted) {
        // Navigate to receipt page with order data
        context.go('/customer/receipt/$orderId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
