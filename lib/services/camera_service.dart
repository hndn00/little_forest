import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  static final _picker = ImagePicker();

  /// Opens the native camera. Returns an [XFile] or null if
  /// the user cancelled / permission was denied.
  static Future<XFile?> capturePhoto(BuildContext context) async {
    final status = await Permission.camera.request();

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('카메라 권한이 필요합니다. 설정에서 허용해주세요.'),
            action: SnackBarAction(
              label: '설정 열기',
              onPressed: openAppSettings,
            ),
          ),
        );
      }
      return null;
    }

    if (status.isDenied) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카메라 권한이 거부되었습니다.')),
        );
      }
      return null;
    }

    return _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
  }
}
