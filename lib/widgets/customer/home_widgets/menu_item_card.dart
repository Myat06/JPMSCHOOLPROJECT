// lib/features/customer/home/widgets/menu_item_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/config/app_colors.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/models/menu_item_model.dart';
import '../menu_item_bottom_sheet.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItemModel item;
  final VoidCallback onCartTap;

  const MenuItemCard({super.key, required this.item, required this.onCartTap});

  void _openBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MenuItemBottomSheet(menuItem: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openBottomSheet(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildImage(),
              const SizedBox(width: 12),
              Expanded(child: _buildDetails()),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  // === IMAGE ===
  Widget _buildImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: item.isAvailable
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: item.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.imageUrl!,
                fit: BoxFit.cover,
                width: 60,
                height: 60,
                errorBuilder: (_, __, ___) => _fallbackIcon(),
              ),
            )
          : _fallbackIcon(),
    );
  }

  Widget _fallbackIcon() => Icon(
    Icons.fastfood,
    color: item.isAvailable ? Colors.green : Colors.red,
    size: 28,
  );

  // === DETAILS ===
  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          item.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '\$${item.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            if (item.preparationTimeMinutes > 0)
              _tag('${item.preparationTimeMinutes} min', Colors.grey),
          ],
        ),
        if (item.isVegetarian ||
            item.isVegan ||
            item.isGlutenFree ||
            item.isSpicy)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                if (item.isVegetarian) _tag('Veg', Colors.green),
                if (item.isVegan) _tag('Vegan', Colors.green),
                if (item.isGlutenFree) _tag('GF', Colors.blue),
                if (item.isSpicy) _tag('Spicy', Colors.red),
              ],
            ),
          ),
      ],
    );
  }

  Widget _tag(String label, Color color) => Container(
    margin: const EdgeInsets.only(right: 4),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500),
    ),
  );

  // === ACTIONS ===
  Widget _buildActions(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _favoriteButton(context),
        item.isAvailable ? _cartButton(context) : _unavailableLabel(),
      ],
    );
  }

  Widget _favoriteButton(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (_, favs, __) => FutureBuilder<bool>(
        future: favs.isItemInFavorites(item.id),
        builder: (_, snap) {
          final isFav = snap.data ?? false;
          return IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : Colors.grey,
              size: 20,
            ),
            onPressed: () async {
              final auth = context.read<AuthProvider>();
              if (auth.currentUser != null) {
                await favs.toggleFavorite(item);
              } else {
                _snack(context, 'Please log in to add favorites', Colors.red);
              }
            },
          );
        },
      ),
    );
  }

  Widget _cartButton(BuildContext context) {
    return Consumer2<CartProvider, AuthProvider>(
      builder: (_, cart, auth, __) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            onTap: () async {
              if (auth.currentUser == null) {
                _snack(
                  context,
                  'Please log in to add items to cart',
                  Colors.red,
                );
                return;
              }
              final uid = auth.currentUser!.uid;
              if (cart.isItemInCart(item.id)) {
                final cItem = cart.getCartItemByMenuId(item.id);
                if (cItem != null) {
                  final qty = cart.getItemQuantity(item.id);
                  await cart.updateItemQuantity(
                    userId: uid,
                    cartItemId: cItem.id,
                    quantity: qty + 1,
                  );
                }
              } else {
                await cart.addToCart(item, userId: uid);
              }
              if (context.mounted) {
                _snack(
                  context,
                  '${item.name} added to cart',
                  Colors.green,
                  action: SnackBarAction(
                    label: 'View Cart',
                    textColor: Colors.white,
                    onPressed: onCartTap,
                  ),
                );
              }
            },
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.add_shopping_cart,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _unavailableLabel() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.red.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Text(
      'Unavailable',
      style: TextStyle(
        color: Colors.red,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  void _snack(
    BuildContext context,
    String msg,
    Color color, {
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        action: action,
      ),
    );
  }
}
