import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _usersKey = 'registered_users';
  static const String _currentUserKey = 'current_user';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hash password for security
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Generate unique ID
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(1000).toString();
  }

  // Sign up with email and password
  Future<UserModel?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing users
      List<String> usersList = prefs.getStringList(_usersKey) ?? [];
      List<UserModel> users = usersList
          .map((userJson) => UserModel.fromJson(userJson))
          .toList();

      // Check if email already exists
      if (users.any(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
      )) {
        throw Exception('email-already-in-use');
      }

      // Create new user
      final newUser = UserModel(
        uid: _generateId(),
        email: email.toLowerCase(),
        name: name,
        phone: phone,
        role: role,
        createdAt: DateTime.now(),
      );

      // Store user with hashed password
      users.add(newUser);
      usersList = users.map((user) => user.toJson()).toList();
      await prefs.setStringList(_usersKey, usersList);

      // Store passwords separately (in real app, use more secure method)
      await prefs.setString('password_${newUser.uid}', _hashPassword(password));

      // Set as current user
      await prefs.setString(_currentUserKey, newUser.toJson());

      // Also store in Firebase for global access
      try {
        await _firestore
            .collection('users')
            .doc(newUser.uid)
            .set(newUser.toMap());
      } catch (e) {
        print('Error storing user in Firebase: $e');
        // Continue with local storage even if Firebase fails
      }

      return newUser;
    } catch (e) {
      print('Error in signUpWithEmailAndPassword: $e');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing users
      List<String> usersList = prefs.getStringList(_usersKey) ?? [];
      List<UserModel> users = usersList
          .map((userJson) => UserModel.fromJson(userJson))
          .toList();

      // Find user by email
      UserModel? user;
      try {
        user = users.firstWhere(
          (u) => u.email.toLowerCase() == email.toLowerCase(),
        );
      } catch (e) {
        throw Exception('user-not-found');
      }

      // Check password
      String? storedPasswordHash = prefs.getString('password_${user.uid}');
      if (storedPasswordHash == null ||
          storedPasswordHash != _hashPassword(password)) {
        throw Exception('wrong-password');
      }

      // Set as current user
      await prefs.setString(_currentUserKey, user.toJson());

      return user;
    } catch (e) {
      print('Error in signInWithEmailAndPassword: $e');
      rethrow;
    }
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userJson = prefs.getString(_currentUserKey);

      if (userJson != null) {
        return UserModel.fromJson(userJson);
      }
      return null;
    } catch (e) {
      print('Error in getCurrentUser: $e');
      return null;
    }
  }

  // Check if user is signed in
  Future<bool> isSignedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  // Update user data
  Future<void> updateUserData(UserModel userModel) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Update current user
      await prefs.setString(_currentUserKey, userModel.toJson());

      // Update in users list
      List<String> usersList = prefs.getStringList(_usersKey) ?? [];
      List<UserModel> users = usersList
          .map((userJson) => UserModel.fromJson(userJson))
          .toList();

      // Find and update user
      int userIndex = users.indexWhere((user) => user.uid == userModel.uid);
      if (userIndex != -1) {
        users[userIndex] = userModel;
        usersList = users.map((user) => user.toJson()).toList();
        await prefs.setStringList(_usersKey, usersList);
      }
    } catch (e) {
      print('Error in updateUserData: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
    } catch (e) {
      print('Error in signOut: $e');
      rethrow;
    }
  }

  // Reset password (for demo purposes, just show success message)
  Future<void> resetPassword(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing users
      List<String> usersList = prefs.getStringList(_usersKey) ?? [];
      List<UserModel> users = usersList
          .map((userJson) => UserModel.fromJson(userJson))
          .toList();

      // Check if user exists
      bool userExists = users.any(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
      );

      if (!userExists) {
        throw Exception('user-not-found');
      }

      // In a real app, you would send a reset email
      // For demo, we'll just simulate success
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      print('Error in resetPassword: $e');
      rethrow;
    }
  }

  // Check if email exists
  Future<bool> checkEmailExists(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> usersList = prefs.getStringList(_usersKey) ?? [];
      List<UserModel> users = usersList
          .map((userJson) => UserModel.fromJson(userJson))
          .toList();

      return users.any(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (e) {
      print('Error in checkEmailExists: $e');
      return false;
    }
  }

  // Get all users (for admin purposes)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> usersList = prefs.getStringList(_usersKey) ?? [];
      return usersList.map((userJson) => UserModel.fromJson(userJson)).toList();
    } catch (e) {
      print('Error in getAllUsers: $e');
      return [];
    }
  }
}
