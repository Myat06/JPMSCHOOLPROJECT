import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item_model.dart';
import '../models/menu_item_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user's cart collection reference
  CollectionReference _getUserCartCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('cart');
  }

  // Add item to cart
  Future<String> addToCart({
    required String userId,
    required MenuItemModel menuItem,
    int quantity = 1,
    String? specialInstructions,
  }) async {
    try {
      final cartCollection = _getUserCartCollection(userId);

      // Check if item already exists in cart
      QuerySnapshot existingItems = await cartCollection
          .where('menuItemId', isEqualTo: menuItem.id)
          .get();

      if (existingItems.docs.isNotEmpty) {
        // Update quantity if item exists
        DocumentSnapshot existingDoc = existingItems.docs.first;
        Map<String, dynamic> existingData =
            existingDoc.data() as Map<String, dynamic>;
        int currentQuantity = existingData['quantity'] ?? 1;

        await existingDoc.reference.update({
          'quantity': currentQuantity + quantity,
          'updatedAt': DateTime.now().toIso8601String(),
          if (specialInstructions != null)
            'specialInstructions': specialInstructions,
        });

        return existingDoc.id;
      } else {
        // Add new item to cart
        String cartItemId = cartCollection.doc().id;

        // Store with menu item reference
        await cartCollection.doc(cartItemId).set({
          'id': cartItemId,
          'menuItemId': menuItem.id,
          'adminId': menuItem.adminId, // Use adminId instead of restaurantId
          'quantity': quantity,
          'specialInstructions': specialInstructions,
          'addedAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          // Store essential menu item data for quick access
          'menuItemData': {
            'name': menuItem.name,
            'price': menuItem.price,
            'imageUrl': menuItem.imageUrl,
            'category': menuItem.category,
            'isAvailable': menuItem.isAvailable,
            'description': menuItem.description,
            'adminId': menuItem.adminId,
          },
        });

        return cartItemId;
      }
    } catch (e) {
      throw Exception('Error adding to cart: $e');
    }
  }

  // Get cart items for user
  Future<List<CartItemModel>> getCartItems(String userId) async {
    try {
      final cartCollection = _getUserCartCollection(userId);

      QuerySnapshot snapshot = await cartCollection
          .orderBy('addedAt', descending: true)
          .get();

      List<CartItemModel> cartItems = [];

      for (DocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Get full menu item data
        String menuItemId = data['menuItemId'];
        MenuItemModel? menuItem = await _getMenuItemById(menuItemId);

        if (menuItem != null) {
          CartItemModel cartItem = CartItemModel(
            id: data['id'] ?? doc.id,
            menuItem: menuItem,
            quantity: data['quantity'] ?? 1,
            specialInstructions: data['specialInstructions'],
            addedAt: DateTime.parse(data['addedAt']),
          );
          cartItems.add(cartItem);
        } else {
          // If menu item not found, create from stored data
          Map<String, dynamic> menuItemData = data['menuItemData'] ?? {};
          if (menuItemData.isNotEmpty) {
            MenuItemModel fallbackMenuItem = MenuItemModel(
              id: menuItemId,
              adminId: menuItemData['adminId'] ?? data['adminId'] ?? '',
              name: menuItemData['name'] ?? 'Unknown Item',
              description: menuItemData['description'] ?? '',
              price: (menuItemData['price'] ?? 0.0).toDouble(),
              imageUrl: menuItemData['imageUrl'],
              category: menuItemData['category'] ?? '',
              isAvailable: menuItemData['isAvailable'] ?? false,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

            CartItemModel cartItem = CartItemModel(
              id: data['id'] ?? doc.id,
              menuItem: fallbackMenuItem,
              quantity: data['quantity'] ?? 1,
              specialInstructions: data['specialInstructions'],
              addedAt: DateTime.parse(data['addedAt']),
            );
            cartItems.add(cartItem);
          }
        }
      }

      return cartItems;
    } catch (e) {
      throw Exception('Error getting cart items: $e');
    }
  }

  // Get menu item by ID from Firestore
  Future<MenuItemModel?> _getMenuItemById(String menuItemId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('menu_items')
          .doc(menuItemId)
          .get();

      if (doc.exists) {
        return MenuItemModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting menu item: $e');
      return null;
    }
  }

  // Update cart item quantity
  Future<void> updateCartItemQuantity({
    required String userId,
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      final cartCollection = _getUserCartCollection(userId);

      if (quantity <= 0) {
        // Remove item if quantity is 0 or less
        await cartCollection.doc(cartItemId).delete();
      } else {
        await cartCollection.doc(cartItemId).update({
          'quantity': quantity,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw Exception('Error updating cart item: $e');
    }
  }

  // Remove item from cart
  Future<void> removeFromCart({
    required String userId,
    required String cartItemId,
  }) async {
    try {
      final cartCollection = _getUserCartCollection(userId);
      await cartCollection.doc(cartItemId).delete();
    } catch (e) {
      throw Exception('Error removing from cart: $e');
    }
  }

  // Clear entire cart
  Future<void> clearCart(String userId) async {
    try {
      final cartCollection = _getUserCartCollection(userId);

      QuerySnapshot snapshot = await cartCollection.get();

      WriteBatch batch = _firestore.batch();
      for (DocumentSnapshot doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Error clearing cart: $e');
    }
  }

  // Get cart items count
  Future<int> getCartItemsCount(String userId) async {
    try {
      final cartCollection = _getUserCartCollection(userId);

      QuerySnapshot snapshot = await cartCollection.get();

      int totalItems = 0;
      for (DocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        totalItems += (data['quantity'] ?? 1) as int;
      }

      return totalItems;
    } catch (e) {
      throw Exception('Error getting cart count: $e');
    }
  }

  // Get cart total price
  Future<double> getCartTotal(String userId) async {
    try {
      List<CartItemModel> cartItems = await getCartItems(userId);

      double total = 0.0;
      for (CartItemModel item in cartItems) {
        total += item.totalPrice;
      }

      return total;
    } catch (e) {
      throw Exception('Error calculating cart total: $e');
    }
  }

  // Listen to cart changes (real-time)
  Stream<List<CartItemModel>> cartItemsStream(String userId) {
    final cartCollection = _getUserCartCollection(userId);

    return cartCollection
        .orderBy('addedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          List<CartItemModel> cartItems = [];

          for (DocumentSnapshot doc in snapshot.docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            String menuItemId = data['menuItemId'];
            MenuItemModel? menuItem = await _getMenuItemById(menuItemId);

            if (menuItem != null) {
              CartItemModel cartItem = CartItemModel(
                id: data['id'] ?? doc.id,
                menuItem: menuItem,
                quantity: data['quantity'] ?? 1,
                specialInstructions: data['specialInstructions'],
                addedAt: DateTime.parse(data['addedAt']),
              );
              cartItems.add(cartItem);
            } else {
              // Fallback to stored data if menu item is deleted
              Map<String, dynamic> menuItemData = data['menuItemData'] ?? {};
              if (menuItemData.isNotEmpty) {
                MenuItemModel fallbackMenuItem = MenuItemModel(
                  id: menuItemId,
                  adminId: menuItemData['adminId'] ?? data['adminId'] ?? '',
                  name: menuItemData['name'] ?? 'Unknown Item',
                  description: menuItemData['description'] ?? '',
                  price: (menuItemData['price'] ?? 0.0).toDouble(),
                  imageUrl: menuItemData['imageUrl'],
                  category: menuItemData['category'] ?? '',
                  isAvailable: menuItemData['isAvailable'] ?? false,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                CartItemModel cartItem = CartItemModel(
                  id: data['id'] ?? doc.id,
                  menuItem: fallbackMenuItem,
                  quantity: data['quantity'] ?? 1,
                  specialInstructions: data['specialInstructions'],
                  addedAt: DateTime.parse(data['addedAt']),
                );
                cartItems.add(cartItem);
              }
            }
          }

          return cartItems;
        });
  }

  // Group cart items by admin (restaurant owner)
  Future<Map<String, List<CartItemModel>>> getCartItemsByAdmin(
    String userId,
  ) async {
    try {
      List<CartItemModel> cartItems = await getCartItems(userId);
      Map<String, List<CartItemModel>> grouped = {};

      for (CartItemModel item in cartItems) {
        String adminId = item.menuItem.adminId;
        if (grouped.containsKey(adminId)) {
          grouped[adminId]!.add(item);
        } else {
          grouped[adminId] = [item];
        }
      }

      return grouped;
    } catch (e) {
      throw Exception('Error grouping cart items by admin: $e');
    }
  }
}
