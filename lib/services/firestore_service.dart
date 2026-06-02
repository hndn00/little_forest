import 'package:image_picker/image_picker.dart';

class FirestoreService {
  Future<String> uploadPhoto({
    required XFile xfile,
    required String uid,
    required String photoId,
    required String dateKey,
    required DateTime capturedAt,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return xfile.path;
  }
}
