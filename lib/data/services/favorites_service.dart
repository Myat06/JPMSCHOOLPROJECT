import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item_model.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add item to favorites
  Future<void> addToFavorites(String userId, MenuItemModel menuItem) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(menuItem.id)
          .set({
            'menuItemId': menuItem.id,
            'adminId': menuItem.adminId,
            'addedAt': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      print('Error adding to favorites: $e');
      rethrow;
    }
  }

  // Remove item from favorites
  Future<void> removeFromFavorites(String userId, String menuItemId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(menuItemId)
          .delete();
    } catch (e) {
      print('Error removing from favorites: $e');
      rethrow;
    }
  }

  // Get user's favorite menu items
  Future<List<MenuItemModel>> getFavoriteMenuItems(String userId) async {
    try {
      final QuerySnapshot favoritesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      if (favoritesSnapshot.docs.isEmpty) {
        return [];
      }

      // Get menu item IDs
      final menuItemIds = favoritesSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .map((data) => data['menuItemId'] as String)
          .toList();

      // Fetch menu items
      final List<MenuItemModel> favoriteItems = [];
      for (String menuItemId in menuItemIds) {
        final menuItemDoc = await _firestore
            .collection('menuItems')
            .doc(menuItemId)
            .get();

        if (menuItemDoc.exists) {
          final menuItem = MenuItemModel.fromMap({
            'id': menuItemDoc.id,
            ...menuItemDoc.data() as Map<String, dynamic>,
          });
          favoriteItems.add(menuItem);
        }
      }

      return favoriteItems;
    } catch (e) {
      print('Error getting favorite menu items: $e');
      return [];
    }
  }

  // Check if item is in favorites
  Future<bool> isItemInFavorites(String userId, String menuItemId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(menuItemId)
          .get();

      return doc.exists;
    } catch (e) {
      print('Error checking if item is in favorites: $e');
      return false;
    }
  }

  // Get favorites count
  Future<int> getFavoritesCount(String userId) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      print('Error getting favorites count: $e');
      return 0;
    }
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(String userId, MenuItemModel menuItem) async {
    try {
      final isFavorite = await isItemInFavorites(userId, menuItem.id);

      if (isFavorite) {
        await removeFromFavorites(userId, menuItem.id);
        return false;
      } else {
        await addToFavorites(userId, menuItem);
        return true;
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      rethrow;
    }
  }
}
