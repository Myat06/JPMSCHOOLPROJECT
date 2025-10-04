import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new category
  Future<String> createCategory(CategoryModel category) async {
    try {
      final docRef = await _firestore
          .collection('categories')
          .add(category.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating category: $e');
      rethrow;
    }
  }

  // Get all active categories (visible to all admins)
  Future<List<CategoryModel>> getAllActiveCategories() async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('categories')
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => CategoryModel.fromMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      print('Error getting active categories: $e');
      return [];
    }
  }

  // Get all categories for an admin
  Future<List<CategoryModel>> getCategoriesByAdmin(String adminId) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('categories')
          .where('adminId', isEqualTo: adminId)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => CategoryModel.fromMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  // Get a single category by ID
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('categories')
          .doc(categoryId)
          .get();

      if (doc.exists) {
        return CategoryModel.fromMap({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }
      return null;
    } catch (e) {
      print('Error getting category: $e');
      return null;
    }
  }

  // Update a category
  Future<void> updateCategory(String categoryId, CategoryModel category) async {
    try {
      await _firestore
          .collection('categories')
          .doc(categoryId)
          .update(category.toMap());
    } catch (e) {
      print('Error updating category: $e');
      rethrow;
    }
  }

  // Delete a category (soft delete by setting isActive to false)
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore.collection('categories').doc(categoryId).update({
        'isActive': false,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error deleting category: $e');
      rethrow;
    }
  }

  // Permanently delete a category
  Future<void> permanentlyDeleteCategory(String categoryId) async {
    try {
      await _firestore.collection('categories').doc(categoryId).delete();
    } catch (e) {
      print('Error permanently deleting category: $e');
      rethrow;
    }
  }

  // Update category sort order
  Future<void> updateCategorySortOrder(String categoryId, int sortOrder) async {
    try {
      await _firestore.collection('categories').doc(categoryId).update({
        'sortOrder': sortOrder,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating category sort order: $e');
      rethrow;
    }
  }

  // Get all categories (including inactive ones) for admin
  Future<List<CategoryModel>> getAllCategoriesForAdmin(String adminId) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('categories')
          .where('adminId', isEqualTo: adminId)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => CategoryModel.fromMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      print('Error getting all categories: $e');
      return [];
    }
  }
}
