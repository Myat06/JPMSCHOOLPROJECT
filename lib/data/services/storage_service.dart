import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Upload image to Firebase Storage
  Future<String?> uploadImage({
    required File imageFile,
    required String folder,
    required String fileName,
  }) async {
    try {
      // Create reference to the file location
      final ref = _storage.ref().child('$folder/$fileName');
      
      // Upload the file
      final uploadTask = await ref.putFile(imageFile);
      
      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  // Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }

  // Delete image from Firebase Storage
  Future<bool> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  // Generate unique filename
  String generateFileName(String originalFileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = path.extension(originalFileName);
    return '${timestamp}_${path.basenameWithoutExtension(originalFileName)}$extension';
  }

  // Upload menu item image
  Future<String?> uploadMenuItemImage({
    required File imageFile,
    required String adminId,
    required String menuItemId,
  }) async {
    final fileName = generateFileName(path.basename(imageFile.path));
    return await uploadImage(
      imageFile: imageFile,
      folder: 'menu_items/$adminId',
      fileName: fileName,
    );
  }
}
