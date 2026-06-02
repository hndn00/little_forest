import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/daily_log_models.dart';
import '../services/firestore_service.dart';

enum UploadState { idle, uploading, done, error }

class DailyLogState {
  final List<DailyLogEntry> photos;
  final UploadState uploadState;
  final String? errorMessage;

  const DailyLogState({
    this.photos = const [],
    this.uploadState = UploadState.idle,
    this.errorMessage,
  });

  DailyLogState copyWith({
    List<DailyLogEntry>? photos,
    UploadState? uploadState,
    String? errorMessage,
  }) {
    return DailyLogState(
      photos: photos ?? this.photos,
      uploadState: uploadState ?? this.uploadState,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class DailyLogNotifier extends StateNotifier<DailyLogState> {
  final FirestoreService _firestoreService;

  DailyLogNotifier(this._firestoreService) : super(const DailyLogState());

  Future<void> addPhoto(XFile xfile, String uid) async {
    final now = DateTime.now();
    final photoId = now.millisecondsSinceEpoch.toString();
    final dateKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // XFile.readAsBytes() works on all platforms (no dart:io needed)
    final bytes = await xfile.readAsBytes();

    final entry = DailyLogEntry(
      id: photoId,
      capturedAt: now,
      imagePath: xfile.path,
      imageBytes: bytes,
      isUploading: true,
    );

    state = state.copyWith(
      photos: [entry, ...state.photos],
      uploadState: UploadState.uploading,
    );

    try {
      final imageUrl = await _firestoreService.uploadPhoto(
        xfile: xfile,
        uid: uid,
        photoId: photoId,
        dateKey: dateKey,
        capturedAt: now,
      );

      final updated = entry.copyWith(imageUrl: imageUrl, isUploading: false);
      state = state.copyWith(
        photos: state.photos.map((p) => p.id == photoId ? updated : p).toList(),
        uploadState: UploadState.done,
      );
    } catch (e) {
      final updated = entry.copyWith(isUploading: false);
      state = state.copyWith(
        photos: state.photos.map((p) => p.id == photoId ? updated : p).toList(),
        uploadState: UploadState.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(uploadState: UploadState.idle, errorMessage: null);
  }
}

final dailyLogProvider =
    StateNotifierProvider<DailyLogNotifier, DailyLogState>((ref) {
  return DailyLogNotifier(FirestoreService());
});
