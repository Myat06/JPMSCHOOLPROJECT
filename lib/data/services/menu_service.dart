import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item_model.dart';

class MenuService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new menu item
  Future<String> createMenuItem(MenuItemModel menuItem) async {
    try {
      final docRef = await _firestore
          .collection('menuItems')
          .add(menuItem.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating menu item: $e');
      rethrow;
    }
  }

  // Get all menu items for an admin
  Future<List<MenuItemModel>> getMenuItemsByAdmin(String adminId) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('menuItems')
          .where('adminId', isEqualTo: adminId)
          .where('isAvailable', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => MenuItemModel.fromMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      print('Error getting menu items: $e');
      return [];
    }
  }

  // Get menu items by category
  Future<List<MenuItemModel>> getMenuItemsByCategory(
    String adminId,
    String category,
  ) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('menuItems')
          .where('adminId', isEqualTo: adminId)
          .where('category', isEqualTo: category)
          .where('isAvailable', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => MenuItemModel.fromMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      print('Error getting menu items by category: $e');
      return [];
    }
  }

  // Get a single menu item by ID
  Future<MenuItemModel?> getMenuItemById(String menuItemId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('menuItems')
          .doc(menuItemId)
          .get();

      if (doc.exists) {
        return MenuItemModel.fromMap({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }
      return null;
    } catch (e) {
      print('Error getting menu item: $e');
      return null;
    }
  }

  // Update a menu item
  Future<void> updateMenuItem(String menuItemId, MenuItemModel menuItem) async {
    try {
      await _firestore
          .collection('menuItems')
          .doc(menuItemId)
          .update(menuItem.toMap());
    } catch (e) {
      print('Error updating menu item: $e');
      rethrow;
    }
  }

  // Delete a menu item (soft delete by setting isAvailable to false)
  Future<void> deleteMenuItem(String menuItemId) async {
    try {
      await _firestore.collection('menuItems').doc(menuItemId).update({
        'isAvailable': false,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error deleting menu item: $e');
      rethrow;
    }
  }

  // Permanently delete a menu item
  Future<void> permanentlyDeleteMenuItem(String menuItemId) async {
    try {
      await _firestore.collection('menuItems').doc(menuItemId).delete();
    } catch (e) {
      print('Error permanently deleting menu item: $e');
      rethrow;
    }
  }

  // Toggle menu item availability
  Future<void> toggleMenuItemAvailability(
    String menuItemId,
    bool isAvailable,
  ) async {
    try {
      await _firestore.collection('menuItems').doc(menuItemId).update({
        'isAvailable': isAvailable,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error toggling menu item availability: $e');
      rethrow;
    }
  }

  // Get all menu items (including unavailable ones) for admin
  Future<List<MenuItemModel>> getAllMenuItemsForAdmin(String adminId) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('menuItems')
          .where('adminId', isEqualTo: adminId)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => MenuItemModel.fromMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      print('Error getting all menu items: $e');
      return [];
    }
  }

  // Search menu items for a specific admin
  Future<List<MenuItemModel>> searchMenuItems(
    String adminId,
    String query,
  ) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('menuItems')
          .where('adminId', isEqualTo: adminId)
          .where('isAvailable', isEqualTo: true)
          .get();

      final List<MenuItemModel> allItems = querySnapshot.docs
          .map(
            (doc) => MenuItemModel.fromMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();

      // Filter by name or description containing the query
      return allItems
          .where(
            (item) =>
                item.name.toLowerCase().contains(query.toLowerCase()) ||
                item.description.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } catch (e) {
      print('Error searching menu items: $e');
      return [];
    }
  }

  // Update menu item rating
  Future<void> updateMenuItemRating(
    String menuItemId,
    double rating,
    int reviewCount,
  ) async {
    try {
      await _firestore.collection('menuItems').doc(menuItemId).update({
        'rating': rating,
        'reviewCount': reviewCount,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating menu item rating: $e');
      rethrow;
    }
  }
}
