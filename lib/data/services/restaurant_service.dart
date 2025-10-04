import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:jpmfood/data/models/restaurant_model.dart';
import '../models/category_model.dart';
import '../models/menu_item_model.dart';
import '../models/restaurant_data_model.dart';
import 'dart:io';

class RestaurantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all restaurants with their categories and menu items
  Future<List<RestaurantData>> getAllRestaurantsWithMenu() async {
    try {
      // Get all users with admin role
      final QuerySnapshot adminQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();

      List<RestaurantData> restaurants = [];

      for (var adminDoc in adminQuery.docs) {
        try {
          final adminData = adminDoc.data() as Map<String, dynamic>;
          final adminId = adminDoc.id;

          // Get categories for this admin's restaurant
          final QuerySnapshot categoriesQuery = await _firestore
              .collection('categories')
              .where('adminId', isEqualTo: adminId)
              .where('isActive', isEqualTo: true)
              .get();

          List<CategoryModel> categories = categoriesQuery.docs
              .map((doc) {
                try {
                  return CategoryModel.fromMap({
                    'id': doc.id,
                    ...doc.data() as Map<String, dynamic>,
                  });
                } catch (e) {
                  print('Error parsing category: $e');
                  return null;
                }
              })
              .where((category) => category != null)
              .cast<CategoryModel>()
              .toList();

          // Get menu items for this admin's restaurant
          final QuerySnapshot menuItemsQuery = await _firestore
              .collection('menuItems')
              .where('adminId', isEqualTo: adminId)
              .where('isAvailable', isEqualTo: true)
              .get();

          List<MenuItemModel> menuItems = menuItemsQuery.docs
              .map((doc) {
                try {
                  return MenuItemModel.fromMap({
                    'id': doc.id,
                    ...doc.data() as Map<String, dynamic>,
                  });
                } catch (e) {
                  print('Error parsing menu item: $e');
                  return null;
                }
              })
              .where((item) => item != null)
              .cast<MenuItemModel>()
              .toList();

          // Create restaurant data
          final restaurantData = RestaurantData(
            adminId: adminId,
            adminName: adminData['name'] ?? 'Admin',
            adminEmail: adminData['email'] ?? '',
            categories: categories,
            menuItems: menuItems,
          );

          restaurants.add(restaurantData);
        } catch (e) {
          print('Error processing admin ${adminDoc.id}: $e');
          // Continue with other admins even if one fails
        }
      }

      return restaurants;
    } catch (e) {
      print('Error getting restaurants with menu: $e');
      return [];
    }
  }

  // Get menu items by category for a specific restaurant
  Future<List<MenuItemModel>> getMenuItemsByCategoryAndAdmin(
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

  // Search menu items across all restaurants
  Future<List<MenuItemModel>> searchMenuItems(String query) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('menuItems')
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

  Future<String> createRestaurant(RestaurantModel restaurant) async {
    try {
      final docRef = _firestore.collection('restaurants').doc();
      final restaurantWithId = restaurant.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await docRef.set(restaurantWithId.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating restaurant: $e');
    }
  }

  Future<String> uploadRestaurantImage(
    File imageFile,
    String restaurantId,
  ) async {
    try {
      // You need to import 'package:firebase_storage/firebase_storage.dart'
      final storageRef = FirebaseStorage.instance.ref();
      final fileName =
          'restaurants/$restaurantId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final uploadTask = await storageRef.child(fileName).putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error uploading restaurant image: $e');
    }
  }

  Future<void> updateRestaurant(RestaurantModel restaurant) async {
    try {
      await _firestore
          .collection('restaurants')
          .doc(restaurant.id)
          .update(restaurant.toMap());
    } catch (e) {
      throw Exception('Error updating restaurant: $e');
    }
  }

  Future<List<RestaurantModel>> getRestaurantsByAdmin(String adminId) async {
    // TODO: Implement logic to fetch restaurants by adminId from your data source
    // For example, fetch from Firestore, REST API, etc.
    // Return a list of RestaurantModel
    return [];
  }

  Future<void> deleteRestaurant(String restaurantId) async {
    // TODO: Implement the logic to delete a restaurant by its ID.
    // For example, make an API call or remove from database.
    // throw UnimplementedError(); // Remove this after implementation.
  }

  Future<String> createMenuItem(MenuItemModel menuItem) async {
    // TODO: Implement the logic to create a menu item and return its ID.
    // For example, you might interact with a database or API here.
    // Replace the following line with your actual implementation.
    throw UnimplementedError('createMenuItem is not implemented yet.');
  }

  Future<String> uploadMenuItemImage(
    File imageFile,
    String restaurantId,
    String menuItemId,
  ) async {
    // TODO: Implement actual upload logic and return the image URL.
    // For now, return a dummy URL.
    return 'https://dummyimage.com/menuitem/$menuItemId.png';
  }

  Future<void> updateMenuItem(MenuItemModel menuItem) async {
    // TODO: Implement the logic to update a menu item in your data source.
    // For example, update the menu item in Firestore or your backend.
    // Example:
    // await FirebaseFirestore.instance
    //     .collection('menuItems')
    //     .doc(menuItem.id)
    //     .update(menuItem.toJson());
  }

  Future<List<MenuItemModel>> getMenuItems(String restaurantId) async {
    // TODO: Implement actual data fetching logic here
    // Example placeholder implementation:
    return [];
  }

  Future<void> toggleMenuItemAvailability(
    String itemId,
    bool isAvailable,
  ) async {
    // TODO: Implement the logic to update menu item availability in your data source.
    // For example, update the database or API with the new availability status.
    // This is a stub implementation.
    // throw UnimplementedError();
  }

  Future<void> deleteMenuItem(String itemId) async {
    // TODO: Implement the logic to delete a menu item by its ID.
    // For example, call your backend API or database here.
    // throw UnimplementedError(); // Remove this after implementation.
  }

  Future<List<String>> getMenuCategories(String restaurantId) async {
    // TODO: Implement logic to fetch menu categories for the given restaurantId
    // For now, return an empty list or mock data
    return [];
  }
}
