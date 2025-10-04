// lib/features/customer/home/widgets/home_app_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/config/app_colors.dart';
import '../../../providers/cart_provider.dart';

class HomeAppBar extends StatelessWidget {
  final VoidCallback onCartTap;
  const HomeAppBar({super.key, required this.onCartTap});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      actions: [
        Consumer<CartProvider>(
          builder: (context, cartProvider, _) => Stack(
            children: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                  ),
                  onPressed: onCartTap,
                ),
              ),
              if (cartProvider.cartItemsCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: _badge('${cartProvider.cartItemsCount}'),
                ),
            ],
          ),
        ),
      ],
      flexibleSpace: const FlexibleSpaceBar(
        title: Text(
          'JPM Food',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        background: _HeaderBackground(),
      ),
    );
  }

  Widget _badge(String count) => Container(
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
    child: Text(
      count,
      style: TextStyle(
        color: AppColors.primary,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    ),
  );
}

class _HeaderBackground extends StatelessWidget {
  const _HeaderBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back!',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          SizedBox(height: 4),
          Text(
            'What would you like to eat today?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
