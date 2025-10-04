// File: lib/widgets/customer/chat_widgets/menu_preview.dart
import 'package:flutter/material.dart';
import 'package:jpmfood/data/config/app_colors.dart';
import 'package:provider/provider.dart';
import '../../../data/models/restaurant_data_model.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/favorites_provider.dart';

class MenuPreview extends StatelessWidget {
  final RestaurantData shop;
  final VoidCallback onResetChat;
  final Function(MenuItemModel) onAddToCart;

  const MenuPreview({
    Key? key,
    required this.shop,
    required this.onResetChat,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<MenuItemModel> items = shop.menuItems;

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.restaurant_menu, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  '${shop.adminName} Menu',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onResetChat,
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('Back'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return _MenuItemCard(item: item, onAddToCart: onAddToCart);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItemModel item;
  final Function(MenuItemModel) onAddToCart;

  const _MenuItemCard({Key? key, required this.item, required this.onAddToCart})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.isAvailable ? () => onAddToCart(item) : null,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.isAvailable
                ? AppColors.primary.withOpacity(0.3)
                : Colors.grey[200]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // 🔑 Prevent overflow
          children: [
            // Item Image
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: item.isAvailable
                    ? AppColors.primaryLight
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: item.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.fastfood,
                            color: item.isAvailable
                                ? AppColors.primary
                                : Colors.grey,
                            size: 28,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.fastfood,
                      color: item.isAvailable ? AppColors.primary : Colors.grey,
                      size: 28,
                    ),
            ),
            const SizedBox(height: 8),

            // Item Name
            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),

            // Item Description
            Text(
              item.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                height: 1.3,
              ),
            ),

            // Price and Actions Row
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (item.preparationTimeMinutes > 0)
                      Text(
                        '${item.preparationTimeMinutes} min',
                        style: TextStyle(color: Colors.grey[500], fontSize: 10),
                      ),
                  ],
                ),
                const Spacer(),

                // Action Buttons Column
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final authProvider = context.read<AuthProvider>();
                        if (authProvider.currentUser != null) {
                          final favoritesProvider = context
                              .read<FavoritesProvider>();
                          await favoritesProvider.toggleFavorite(item);
                        }
                      },
                      child: Consumer<FavoritesProvider>(
                        builder: (context, favoritesProvider, child) {
                          return FutureBuilder<bool>(
                            future: favoritesProvider.isItemInFavorites(
                              item.id,
                            ),
                            builder: (context, snapshot) {
                              final isFavorite = snapshot.data ?? false;
                              return Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.grey,
                                size: 16,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 4),

                    if (item.isAvailable)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add_shopping_cart,
                          color: Colors.green,
                          size: 16,
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'N/A',
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // Tags
            if (item.isVegetarian ||
                item.isVegan ||
                item.isGlutenFree ||
                item.isSpicy)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  spacing: 2,
                  children: [
                    if (item.isVegetarian) _buildTag('Veg', Colors.green),
                    if (item.isVegan) _buildTag('Vegan', Colors.green),
                    if (item.isGlutenFree) _buildTag('GF', Colors.blue),
                    if (item.isSpicy) _buildTag('Spicy', Colors.red),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
