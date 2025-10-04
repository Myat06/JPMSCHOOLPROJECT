import 'package:flutter/material.dart';
import 'package:jpmfood/data/models/menu_item_model.dart';
import 'package:jpmfood/providers/auth_provider.dart';
import 'package:jpmfood/providers/cart_provider.dart';
import 'package:jpmfood/providers/customer_provider.dart';
import 'package:jpmfood/widgets/customer/home_widgets/category_filter.dart';
import 'package:jpmfood/widgets/customer/home_widgets/home_app_bar.dart';
import 'package:jpmfood/widgets/customer/home_widgets/menu_item_card.dart';
import 'package:jpmfood/widgets/customer/home_widgets/search_bar.dart';
import 'package:jpmfood/widgets/customer/home_widgets/menu_item_slider.dart'; // 👈 add slider
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class HomePanel extends StatefulWidget {
  const HomePanel({Key? key}) : super(key: key);

  @override
  State<HomePanel> createState() => _HomePanelState();
}

class _HomePanelState extends State<HomePanel> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().loadRestaurants();
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        context.read<CartProvider>().loadCartItems(
          authProvider.currentUser!.uid,
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      context.read<CustomerProvider>().clearSearch();
    } else {
      context.read<CustomerProvider>().searchMenuItems(query);
    }
  }

  void _navigateToCart() => context.go('/customer/cart');

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerProvider>(
      builder: (context, customerProvider, child) {
        return CustomScrollView(
          slivers: [
            HomeAppBar(onCartTap: _navigateToCart),
            SearchBarWidget(
              controller: _searchController,
              onChanged: _onSearchChanged,
            ),

            // === Add slider here ===
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                child: SizedBox(
                  height: 200, // slider height
                  child: MenuItemSlider(), // 👈 your slider widget
                ),
              ),
            ),

            if (customerProvider.allCategories.isNotEmpty)
              CategoryFilter(
                categories: customerProvider.allCategories,
                selected: _selectedCategory,
                onSelect: (c) => setState(() => _selectedCategory = c),
              ),
            if (customerProvider.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
            if (!customerProvider.isLoading &&
                customerProvider.searchQuery.isNotEmpty)
              _buildItems(customerProvider.searchResults),
            if (!customerProvider.isLoading &&
                customerProvider.searchQuery.isEmpty &&
                _selectedCategory == 'All')
              _buildItems([
                for (var r in customerProvider.restaurants) ...r.menuItems,
              ]),
            if (!customerProvider.isLoading &&
                customerProvider.searchQuery.isEmpty &&
                _selectedCategory != 'All')
              _buildItems(
                customerProvider.getMenuItemsByCategory(_selectedCategory),
              ),
          ],
        );
      },
    );
  }

  Widget _buildItems(List<MenuItemModel> items) {
    if (items.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No items found')),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) =>
              MenuItemCard(item: items[index], onCartTap: _navigateToCart),
          childCount: items.length,
        ),
      ),
    );
  }
}
