import 'package:flutter/foundation.dart';
import '../data/services/favorites_service.dart';
import '../data/models/menu_item_model.dart';

class FavoritesProvider with ChangeNotifier {
  final FavoritesService _favoritesService = FavoritesService();

  List<MenuItemModel> _favoriteItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentUserId;

  // Getters
  List<MenuItemModel> get favoriteItems => _favoriteItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get itemCount => _favoriteItems.length;

  // Set current user ID
  void setUserId(String userId) {
    _currentUserId = userId;
    loadFavoriteItems();
  }

  // Load favorite items
  Future<void> loadFavoriteItems() async {
    if (_currentUserId == null) return;

    _setLoading(true);
    _clearError();

    try {
      _favoriteItems = await _favoritesService.getFavoriteMenuItems(_currentUserId!);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load favorite items: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add item to favorites
  Future<bool> addToFavorites(MenuItemModel menuItem) async {
    if (_currentUserId == null) return false;

    try {
      _setLoading(true);
      _clearError();

      await _favoritesService.addToFavorites(_currentUserId!, menuItem);
      await loadFavoriteItems(); // Reload favorite items
      return true;
    } catch (e) {
      _setError('Failed to add item to favorites: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Remove item from favorites
  Future<bool> removeFromFavorites(String menuItemId) async {
    if (_currentUserId == null) return false;

    try {
      _setLoading(true);
      _clearError();

      await _favoritesService.removeFromFavorites(_currentUserId!, menuItemId);
      await loadFavoriteItems(); // Reload favorite items
      return true;
    } catch (e) {
      _setError('Failed to remove item from favorites: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(MenuItemModel menuItem) async {
    if (_currentUserId == null) return false;

    try {
      _setLoading(true);
      _clearError();

      final isNowFavorite = await _favoritesService.toggleFavorite(_currentUserId!, menuItem);
      await loadFavoriteItems(); // Reload favorite items
      return isNowFavorite;
    } catch (e) {
      _setError('Failed to toggle favorite: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check if item is in favorites
  Future<bool> isItemInFavorites(String menuItemId) async {
    if (_currentUserId == null) return false;
    return await _favoritesService.isItemInFavorites(_currentUserId!, menuItemId);
  }

  // Get favorites count
  Future<int> getFavoritesCount() async {
    if (_currentUserId == null) return 0;
    return await _favoritesService.getFavoritesCount(_currentUserId!);
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
