import 'package:flutter/material.dart';
import 'package:jpmfood/data/config/app_colors.dart';
import 'package:provider/provider.dart';
import '../../data/models/menu_item_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/auth_provider.dart';

class MenuItemBottomSheet extends StatefulWidget {
  final MenuItemModel menuItem;

  const MenuItemBottomSheet({Key? key, required this.menuItem}) : super(key: key);

  @override
  State<MenuItemBottomSheet> createState() => _MenuItemBottomSheetState();
}

class _MenuItemBottomSheetState extends State<MenuItemBottomSheet> {
  bool isFavorite = false;
  bool isAddingToCart = false;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final authProvider = context.read<AuthProvider>();
    final favoritesProvider = context.read<FavoritesProvider>();

    if (authProvider.currentUser != null) {
      final isFav = await favoritesProvider.isItemInFavorites(widget.menuItem.id);
      if (mounted) {
        setState(() {
          isFavorite = isFav;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.86,
      maxChildSize: 0.96,
      minChildSize: 0.60,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImage(),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.menuItem.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: widget.menuItem.isAvailable ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    widget.menuItem.isAvailable ? 'Available' : 'Unavailable',
                                    style: TextStyle(
                                      color: widget.menuItem.isAvailable ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    widget.menuItem.category,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '\$${widget.menuItem.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (widget.menuItem.description.isNotEmpty) ...[
                              const Text(
                                'Description',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.menuItem.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  height: 1.4,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            if (widget.menuItem.preparationTimeMinutes > 0)
                              Row(
                                children: [
                                  Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${widget.menuItem.preparationTimeMinutes} minutes prep time',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 12),
                            if (widget.menuItem.isVegetarian || widget.menuItem.isVegan || widget.menuItem.isGlutenFree || widget.menuItem.isSpicy)
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  if (widget.menuItem.isVegetarian) _dietTag('Veg', AppColors.success),
                                  if (widget.menuItem.isVegan) _dietTag('Vegan', AppColors.success),
                                  if (widget.menuItem.isGlutenFree) _dietTag('Gluten Free', Colors.blue),
                                  if (widget.menuItem.isSpicy) _dietTag('Spicy', Colors.red),
                                ],
                              ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.menuItem.isAvailable)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Quantity: ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
                                  icon: const Icon(Icons.remove, size: 18),
                                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                  color: AppColors.primary,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('$quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                                IconButton(
                                  onPressed: () => setState(() => quantity++),
                                  icon: const Icon(Icons.add, size: 18),
                                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    if (widget.menuItem.isAvailable) const SizedBox(height: 12),
                    Row(
                      children: [
                        Consumer2<FavoritesProvider, AuthProvider>(
                          builder: (context, favoritesProvider, authProvider, child) {
                            return Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _toggleFavorite(favoritesProvider, authProvider),
                                icon: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : Colors.grey.shade600,
                                  size: 20,
                                ),
                                label: Text(
                                  isFavorite ? 'Favorited' : 'Favorite',
                                  style: TextStyle(
                                    color: isFavorite ? Colors.red : Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: isFavorite ? Colors.red : Colors.grey.shade300),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        Consumer2<CartProvider, AuthProvider>(
                          builder: (context, cartProvider, authProvider, child) {
                            return Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                onPressed: widget.menuItem.isAvailable && !isAddingToCart ? () => _addToCart(cartProvider, authProvider) : null,
                                icon: isAddingToCart
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Icon(Icons.add_shopping_cart, size: 20),
                                label: Text(
                                  widget.menuItem.isAvailable
                                      ? (isAddingToCart ? 'Adding...' : 'Add to cart')
                                      : 'Unavailable',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: widget.menuItem.isAvailable ? AppColors.primary : Colors.grey,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImage() {
    return Container(
      width: double.infinity,
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: widget.menuItem.imageUrl != null
            ? Image.network(
                widget.menuItem.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _placeholder();
                },
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade100, Colors.orange.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.fastfood, size: 60, color: Colors.orange),
      ),
    );
  }

  Widget _dietTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(
    FavoritesProvider favoritesProvider,
    AuthProvider authProvider,
  ) async {
    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to add favorites'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await favoritesProvider.toggleFavorite(widget.menuItem);
      setState(() {
        isFavorite = !isFavorite;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFavorite
                  ? '${widget.menuItem.name} added to favorites'
                  : '${widget.menuItem.name} removed from favorites',
            ),
            backgroundColor: isFavorite ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorites: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addToCart(
    CartProvider cartProvider,
    AuthProvider authProvider,
  ) async {
    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to add items to cart'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isAddingToCart = true;
    });

    try {
      final success = await cartProvider.addToCart(
        widget.menuItem,
        quantity: quantity,
        userId: authProvider.currentUser!.uid,
      );

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.menuItem.name} x$quantity added to cart'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to cart: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isAddingToCart = false;
        });
      }
    }
  }
}


