// models/daily_log_models.dart

import 'dart:typed_data';

enum ActivityType { training, outdoor, cafe, walking, none }

class VisionLabel {
  final String label;
  final double confidence; // 0.0 ~ 1.0

  const VisionLabel({required this.label, required this.confidence});
}

class ActivityResult {
  final ActivityType type;
  final String displayName;
  final int points;

  const ActivityResult({
    required this.type,
    required this.displayName,
    required this.points,
  });
}

class DailyLogEntry {
  final String id;
  final DateTime capturedAt;
  final String imagePath;
  final String? imageUrl;
  final Uint8List? imageBytes; // in-memory bytes for immediate display
  final ActivityResult? activityResult;
  final bool isUploading;

  const DailyLogEntry({
    required this.id,
    required this.capturedAt,
    required this.imagePath,
    this.imageUrl,
    this.imageBytes,
    this.activityResult,
    this.isUploading = false,
  });

  DailyLogEntry copyWith({
    String? imageUrl,
    bool? isUploading,
    ActivityResult? activityResult,
  }) {
    return DailyLogEntry(
      id: id,
      capturedAt: capturedAt,
      imagePath: imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      imageBytes: imageBytes,
      activityResult: activityResult ?? this.activityResult,
      isUploading: isUploading ?? this.isUploading,
    );
  }
}

// ── Mock Vision API 라벨 ──────────────────────────────────
class MockVisionData {
  static const Map<ActivityType, List<VisionLabel>> labels = {
    ActivityType.training: [
      VisionLabel(label: 'Exercise Machine', confidence: 0.96),
      VisionLabel(label: 'Exercise Equipment', confidence: 0.96),
      VisionLabel(label: 'Gym', confidence: 0.89),
      VisionLabel(label: 'Treadmill', confidence: 0.87),
      VisionLabel(label: 'Physical Fitness', confidence: 0.86),
      VisionLabel(label: 'Exercise', confidence: 0.83),
      VisionLabel(label: 'Machine', confidence: 0.79),
      VisionLabel(label: 'Training', confidence: 0.51),
    ],
    ActivityType.outdoor: [
      VisionLabel(label: 'Park', confidence: 0.94),
      VisionLabel(label: 'Tree', confidence: 0.91),
      VisionLabel(label: 'Nature', confidence: 0.88),
      VisionLabel(label: 'Sky', confidence: 0.85),
      VisionLabel(label: 'Grass', confidence: 0.82),
      VisionLabel(label: 'Outdoor', confidence: 0.78),
      VisionLabel(label: 'Plant', confidence: 0.71),
      VisionLabel(label: 'Green', confidence: 0.63),
    ],
    ActivityType.cafe: [
      VisionLabel(label: 'Cafe', confidence: 0.95),
      VisionLabel(label: 'Coffee', confidence: 0.92),
      VisionLabel(label: 'Cup', confidence: 0.88),
      VisionLabel(label: 'Table', confidence: 0.84),
      VisionLabel(label: 'Beverage', confidence: 0.79),
      VisionLabel(label: 'Restaurant', confidence: 0.74),
      VisionLabel(label: 'Food', confidence: 0.68),
      VisionLabel(label: 'Drink', confidence: 0.61),
    ],
    ActivityType.walking: [
      VisionLabel(label: 'Street', confidence: 0.93),
      VisionLabel(label: 'Road', confidence: 0.90),
      VisionLabel(label: 'Walking', confidence: 0.86),
      VisionLabel(label: 'Sidewalk', confidence: 0.83),
      VisionLabel(label: 'Path', confidence: 0.77),
      VisionLabel(label: 'Urban', confidence: 0.72),
      VisionLabel(label: 'Pedestrian', confidence: 0.65),
      VisionLabel(label: 'City', confidence: 0.58),
    ],
  };

  static const Map<ActivityType, ActivityResult> results = {
    ActivityType.training: ActivityResult(
      type: ActivityType.training,
      displayName: 'Training',
      points: 50,
    ),
    ActivityType.outdoor: ActivityResult(
      type: ActivityType.outdoor,
      displayName: 'Outdoor',
      points: 70,
    ),
    ActivityType.cafe: ActivityResult(
      type: ActivityType.cafe,
      displayName: 'Cafe',
      points: 60,
    ),
    ActivityType.walking: ActivityResult(
      type: ActivityType.walking,
      displayName: 'Walking',
      points: 65,
    ),
  };
}

// ── Mock 로그 목록 (dailylog1 화면용) ─────────────────────
final List<DailyLogEntry> mockDailyLogs = [
  DailyLogEntry(
    id: '1',
    capturedAt: DateTime(2025, 5, 7, 4, 0),
    imagePath: 'assets/mock/log1.jpg',
    activityResult: MockVisionData.results[ActivityType.outdoor],
  ),
  DailyLogEntry(
    id: '2',
    capturedAt: DateTime(2025, 5, 7, 5, 0),
    imagePath: 'assets/mock/log2.jpg',
    activityResult: MockVisionData.results[ActivityType.cafe],
  ),
  DailyLogEntry(
    id: '3',
    capturedAt: DateTime(2025, 5, 7, 6, 0),
    imagePath: 'assets/mock/log3.jpg',
    activityResult: MockVisionData.results[ActivityType.cafe],
  ),
  DailyLogEntry(
    id: '4',
    capturedAt: DateTime(2025, 5, 7, 7, 0),
    imagePath: 'assets/mock/log4.jpg',
    activityResult: MockVisionData.results[ActivityType.training],
  ),
];