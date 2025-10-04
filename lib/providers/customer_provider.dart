import 'package:flutter/foundation.dart';
import '../data/services/restaurant_service.dart';
import '../data/models/menu_item_model.dart';
import '../data/models/restaurant_data_model.dart';

class CustomerProvider with ChangeNotifier {
  final RestaurantService _restaurantService = RestaurantService();

  List<RestaurantData> _restaurants = [];
  List<MenuItemModel> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  // Getters
  List<RestaurantData> get restaurants => _restaurants;
  List<MenuItemModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  // Load all restaurants with their menu data
  Future<void> loadRestaurants() async {
    _setLoading(true);
    _clearError();

    try {
      _restaurants = await _restaurantService.getAllRestaurantsWithMenu();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load restaurants: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Search menu items
  Future<void> searchMenuItems(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _searchQuery = '';
      notifyListeners();
      return;
    }

    _setLoading(true);
    _clearError();
    _searchQuery = query;

    try {
      _searchResults = await _restaurantService.searchMenuItems(query);
      notifyListeners();
    } catch (e) {
      _setError('Failed to search menu items: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Clear search
  void clearSearch() {
    _searchResults = [];
    _searchQuery = '';
    notifyListeners();
  }

  // Get all unique categories across all restaurants
  List<String> get allCategories {
    Set<String> categories = {};
    for (var restaurant in _restaurants) {
      for (var category in restaurant.categories) {
        categories.add(category.name);
      }
    }
    return categories.toList()..sort();
  }

  // Get restaurants by category
  List<RestaurantData> getRestaurantsByCategory(String categoryName) {
    return _restaurants.where((restaurant) {
      return restaurant.categories.any(
        (category) => category.name == categoryName,
      );
    }).toList();
  }

  // Get menu items by category across all restaurants
  List<MenuItemModel> getMenuItemsByCategory(String categoryName) {
    List<MenuItemModel> items = [];
    for (var restaurant in _restaurants) {
      items.addAll(
        restaurant.menuItems.where((item) => item.category == categoryName),
      );
    }
    return items;
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
