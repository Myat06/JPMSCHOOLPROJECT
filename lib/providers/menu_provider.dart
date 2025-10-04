import 'package:flutter/foundation.dart';
import '../data/models/category_model.dart';
import '../data/models/menu_item_model.dart';
import '../data/services/category_service.dart';
import '../data/services/menu_service.dart';

class MenuProvider with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  final MenuService _menuService = MenuService();

  List<CategoryModel> _categories = [];
  List<MenuItemModel> _menuItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentAdminId;

  // Getters
  List<CategoryModel> get categories => _categories;
  List<MenuItemModel> get menuItems => _menuItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentAdminId => _currentAdminId;

  // Set current admin ID
  void setAdminId(String adminId) {
    _currentAdminId = adminId;
    loadCategories();
    loadMenuItems();
  }

  // Load categories for current restaurant
  Future<void> loadCategories() async {
    _setLoading(true);
    _clearError();

    try {
      // Categories are globally visible to admins (but still carry creator adminId for audit)
      _categories = await _categoryService.getAllActiveCategories();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load categories: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load menu items for current restaurant
  Future<void> loadMenuItems() async {
    if (_currentAdminId == null) return;

    _setLoading(true);
    _clearError();

    try {
      _menuItems = await _menuService.getMenuItemsByAdmin(_currentAdminId!);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load menu items: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create category
  Future<bool> createCategory(CategoryModel category) async {
    try {
      _setLoading(true);
      _clearError();

      if (_currentAdminId == null) {
        throw Exception('No authenticated admin');
      }

      final DateTime now = DateTime.now();
      final CategoryModel categoryToSave = category.copyWith(
        adminId: _currentAdminId,
        createdAt: category.createdAt,
        updatedAt: now,
      );

      await _categoryService.createCategory(categoryToSave);
      await loadCategories(); // Reload categories
      return true;
    } catch (e) {
      _setError('Failed to create category: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update category
  Future<bool> updateCategory(CategoryModel category) async {
    try {
      _setLoading(true);
      _clearError();

      if (_currentAdminId == null) {
        throw Exception('No authenticated admin');
      }

      final CategoryModel categoryToUpdate = category.copyWith(
        adminId: _currentAdminId,
        updatedAt: DateTime.now(),
      );

      await _categoryService.updateCategory(category.id, categoryToUpdate);
      await loadCategories(); // Reload categories
      return true;
    } catch (e) {
      _setError('Failed to update category: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete category
  Future<bool> deleteCategory(String categoryId) async {
    try {
      _setLoading(true);
      _clearError();

      await _categoryService.deleteCategory(categoryId);
      await loadCategories(); // Reload categories
      return true;
    } catch (e) {
      _setError('Failed to delete category: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Create menu item
  Future<bool> createMenuItem(MenuItemModel menuItem) async {
    try {
      _setLoading(true);
      _clearError();

      if (_currentAdminId == null) {
        throw Exception('No authenticated admin');
      }

      final DateTime now = DateTime.now();
      final MenuItemModel itemToSave = menuItem.copyWith(
        adminId: _currentAdminId,
        createdAt: menuItem.createdAt,
        updatedAt: now,
      );

      await _menuService.createMenuItem(itemToSave);
      await loadMenuItems(); // Reload menu items
      return true;
    } catch (e) {
      _setError('Failed to create menu item: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update menu item
  Future<bool> updateMenuItem(MenuItemModel menuItem) async {
    try {
      _setLoading(true);
      _clearError();

      if (_currentAdminId == null) {
        throw Exception('No authenticated admin');
      }

      final MenuItemModel itemToUpdate = menuItem.copyWith(
        adminId: _currentAdminId,
        updatedAt: DateTime.now(),
      );

      await _menuService.updateMenuItem(menuItem.id, itemToUpdate);
      await loadMenuItems(); // Reload menu items
      return true;
    } catch (e) {
      _setError('Failed to update menu item: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete menu item
  Future<bool> deleteMenuItem(String menuItemId) async {
    try {
      _setLoading(true);
      _clearError();

      await _menuService.deleteMenuItem(menuItemId);
      await loadMenuItems(); // Reload menu items
      return true;
    } catch (e) {
      _setError('Failed to delete menu item: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Toggle menu item availability
  Future<bool> toggleMenuItemAvailability(String menuItemId, bool isAvailable) async {
    try {
      _setLoading(true);
      _clearError();

      await _menuService.toggleMenuItemAvailability(menuItemId, isAvailable);
      await loadMenuItems(); // Reload menu items
      return true;
    } catch (e) {
      _setError('Failed to toggle menu item availability: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get menu items by category
  List<MenuItemModel> getMenuItemsByCategory(String category) {
    return _menuItems.where((item) => item.category == category).toList();
  }

  // Search menu items
  Future<List<MenuItemModel>> searchMenuItems(String query) async {
    if (_currentAdminId == null) return [];

    try {
      return await _menuService.searchMenuItems(_currentAdminId!, query);
    } catch (e) {
      _setError('Failed to search menu items: $e');
      return [];
    }
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
