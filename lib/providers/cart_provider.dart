import 'package:flutter/foundation.dart';
import '../data/models/cart_item_model.dart';
import '../data/models/menu_item_model.dart';
import '../data/services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();

  List<CartItemModel> _cartItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _cartItemsCount = 0;
  double _cartTotal = 0.0;

  // Getters
  List<CartItemModel> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get cartItemsCount => _cartItemsCount;
  double get cartTotal => _cartTotal;
  bool get isEmpty => _cartItems.isEmpty;

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Set error
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Add item to cart
  Future<bool> addToCart(
    MenuItemModel menuItem, {
    int quantity = 1,
    String? specialInstructions,
    required String userId,
  }) async {
    try {
      _setLoading(true);
      clearError();

      await _cartService.addToCart(
        userId: userId,
        menuItem: menuItem,
        quantity: quantity,
        specialInstructions: specialInstructions,
      );

      // Refresh cart data
      await loadCartItems(userId);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load cart items
  Future<void> loadCartItems(String userId) async {
    try {
      _setLoading(true);
      clearError();

      _cartItems = await _cartService.getCartItems(userId);
      _cartItemsCount = await _cartService.getCartItemsCount(userId);
      _cartTotal = await _cartService.getCartTotal(userId);

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Update item quantity
  Future<bool> updateItemQuantity({
    required String userId,
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      clearError();

      await _cartService.updateCartItemQuantity(
        userId: userId,
        cartItemId: cartItemId,
        quantity: quantity,
      );

      // Update local data
      if (quantity <= 0) {
        _cartItems.removeWhere((item) => item.id == cartItemId);
      } else {
        int index = _cartItems.indexWhere((item) => item.id == cartItemId);
        if (index != -1) {
          _cartItems[index] = _cartItems[index].copyWith(quantity: quantity);
        }
      }

      // Recalculate totals
      _cartItemsCount = _cartItems.fold(0, (sum, item) => sum + item.quantity);
      _cartTotal = _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Remove item from cart
  Future<bool> removeFromCart({
    required String userId,
    required String cartItemId,
  }) async {
    try {
      clearError();

      await _cartService.removeFromCart(userId: userId, cartItemId: cartItemId);

      // Update local data
      _cartItems.removeWhere((item) => item.id == cartItemId);
      _cartItemsCount = _cartItems.fold(0, (sum, item) => sum + item.quantity);
      _cartTotal = _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Clear entire cart
  Future<bool> clearCart(String userId) async {
    try {
      _setLoading(true);
      clearError();

      await _cartService.clearCart(userId);

      // Clear local data
      _cartItems.clear();
      _cartItemsCount = 0;
      _cartTotal = 0.0;

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get item by menu item ID
  CartItemModel? getCartItemByMenuId(String menuItemId) {
    try {
      return _cartItems.firstWhere((item) => item.menuItem.id == menuItemId);
    } catch (e) {
      return null;
    }
  }

  // Check if item is in cart
  bool isItemInCart(String menuItemId) {
    return _cartItems.any((item) => item.menuItem.id == menuItemId);
  }

  // Get quantity for specific menu item
  int getItemQuantity(String menuItemId) {
    CartItemModel? cartItem = getCartItemByMenuId(menuItemId);
    return cartItem?.quantity ?? 0;
  }

  // Calculate subtotal (without tax, delivery fee, etc.)
  double get subtotal {
    return _cartTotal;
  }

  // Calculate tax (you can customize this)
  double get tax {
    return _cartTotal * 0.08; // 8% tax
  }

  // Calculate delivery fee (you can make this dynamic)
  double get deliveryFee {
    return _cartTotal > 25.0 ? 0.0 : 2.99;
  }

  // Calculate total with tax and delivery
  double get totalWithTaxAndDelivery {
    return _cartTotal + tax + deliveryFee;
  }

  // Group items by admin (restaurant owner)
  Map<String, List<CartItemModel>> get itemsByAdmin {
    Map<String, List<CartItemModel>> grouped = {};

    for (CartItemModel item in _cartItems) {
      String adminId = item.menuItem.adminId;
      if (grouped.containsKey(adminId)) {
        grouped[adminId]!.add(item);
      } else {
        grouped[adminId] = [item];
      }
    }

    return grouped;
  }

  // Get items by specific admin
  List<CartItemModel> getItemsByAdminId(String adminId) {
    return _cartItems
        .where((item) => item.menuItem.adminId == adminId)
        .toList();
  }

  // Listen to real-time cart updates
  Stream<List<CartItemModel>> cartStream(String userId) {
    return _cartService.cartItemsStream(userId);
  }

  // Initialize real-time listener
  void initializeCartListener(String userId) {
    cartStream(userId).listen((cartItems) {
      _cartItems = cartItems;
      _cartItemsCount = cartItems.fold(0, (sum, item) => sum + item.quantity);
      _cartTotal = cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
      notifyListeners();
    });
  }
}
