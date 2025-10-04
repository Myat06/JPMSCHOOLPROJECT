// File: lib/services/permission_service.dart
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class PermissionService {
  // Request microphone permission for voice input
  static Future<bool> requestMicrophonePermission(BuildContext context) async {
    final status = await Permission.microphone.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.microphone.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDialog(context);
      return false;
    }

    return false;
  }

  // Request speech recognition permission
  static Future<bool> requestSpeechPermission(BuildContext context) async {
    final status = await Permission.speech.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.speech.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDialog(context);
      return false;
    }

    return false;
  }

  // Check if all required permissions are granted
  static Future<bool> checkAllPermissions() async {
    final micStatus = await Permission.microphone.status;
    final speechStatus = await Permission.speech.status;

    return micStatus.isGranted && speechStatus.isGranted;
  }

  // Show dialog to open app settings
  static void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Microphone permission is required for voice input. '
          'Please enable it in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textLight,
            ),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // Show permission rationale before requesting
  static Future<bool> showPermissionRationale(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Voice Input'),
        content: const Text(
          'This app needs microphone access to use voice input. '
          'Your voice data is only used for speech recognition and is not stored.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No Thanks'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textLight,
            ),
            child: const Text('Allow'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}

// Optional: Add this to message_input.dart for better UX
// Before _toggleListening(), add:
/*
Future<void> _checkPermissions() async {
  final hasPermission = await PermissionService.requestMicrophonePermission(context);
  
  if (!hasPermission) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Microphone permission is required for voice input'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
*/
