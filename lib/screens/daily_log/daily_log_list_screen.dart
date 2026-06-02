import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/daily_log_models.dart';
import '../../providers/daily_log_provider.dart';
import '../../services/camera_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';
import 'daily_log_detail_screen.dart';

class DailyLogListScreen extends ConsumerStatefulWidget {
  const DailyLogListScreen({super.key});

  @override
  ConsumerState<DailyLogListScreen> createState() => _DailyLogListScreenState();
}

class _DailyLogListScreenState extends ConsumerState<DailyLogListScreen> {
  int _selectedDay = 2;
  static const int _bottomNavIndex = -1;
  static const String _uid = 'anonymous';

  final List<_WeekDay> _weekDays = [
    _WeekDay('Mon', 5),
    _WeekDay('Tue', 6),
    _WeekDay('Wed', 7),
    _WeekDay('Thu', 8),
    _WeekDay('Fri', 9),
    _WeekDay('Sat', 10),
    _WeekDay('Sun', 11),
  ];

  Future<void> _onCameraFabTapped() async {
    final XFile? xfile = await CameraService.capturePhoto(context);
    if (xfile == null || !mounted) return;

    ref.read(dailyLogProvider.notifier).addPhoto(xfile, _uid).catchError((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('업로드에 실패했습니다.'),
            action: SnackBarAction(
              label: '재시도',
              onPressed: () =>
                  ref.read(dailyLogProvider.notifier).addPhoto(xfile, _uid),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final logState = ref.watch(dailyLogProvider);
    final allEntries = logState.photos;

    return Scaffold(
      backgroundColor: const Color(0xFFEEF3EE),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildWeekBar(),
            const SizedBox(height: 16),
            Expanded(
              child: allEntries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.camera_alt_outlined,
                              size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            '카메라 버튼을 눌러\n오늘의 사진을 기록해보세요',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: allEntries.length,
                      itemBuilder: (context, index) {
                        final entry = allEntries[index];
                        return _LogListItem(
                          entry: entry,
                          onTap: () => _openDetail(entry),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: _bottomNavIndex,
        onItemTapped: (_) => Navigator.pop(context),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onCameraFabTapped,
        backgroundColor: AppColors.forestDeep,
        shape: const CircleBorder(),
        child: const Icon(Icons.camera_alt_outlined, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildWeekBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_weekDays.length, (i) {
          final day = _weekDays[i];
          final isSelected = i == _selectedDay;
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = i),
            child: Column(
              children: [
                Text(
                  day.label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected
                        ? const Color(0xFF1A3A2A)
                        : const Color(0xFFAAAAAA),
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${day.date}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected
                        ? const Color(0xFF1A3A2A)
                        : const Color(0xFFAAAAAA),
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _openDetail(DailyLogEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DailyLogDetailScreen(entry: entry),
      ),
    );
  }
}

class _LogListItem extends StatelessWidget {
  final DailyLogEntry entry;
  final VoidCallback onTap;

  const _LogListItem({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hour = entry.capturedAt.hour;
    final minute = entry.capturedAt.minute;
    final timeLabel =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
                child: _Thumbnail(entry: entry),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Text(
                        timeLabel,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D6A4F),
                        ),
                      ),
                      if (entry.isUploading) ...[
                        const SizedBox(width: 8),
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final DailyLogEntry entry;

  const _Thumbnail({required this.entry});

  @override
  Widget build(BuildContext context) {
    const double w = 120, h = 100;

    Widget? photo;

    // 1) In-memory bytes — most reliable across all platforms
    if (entry.imageBytes != null) {
      photo = Image.memory(
        entry.imageBytes!,
        width: w,
        height: h,
        fit: BoxFit.cover,
      );
    }

    if (photo == null) {
      return _placeholder(w, h, entry.id);
    }

    return Stack(
      children: [
        photo,
        if (entry.isUploading)
          Container(
            width: w,
            height: h,
            color: Colors.black26,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _placeholder(double w, double h, String seed) {
    final colors = [
      const Color(0xFFA8D5B5),
      const Color(0xFF7CB9A0),
      const Color(0xFFD4E8DC),
      const Color(0xFF4A8C62),
    ];
    return Container(
      width: w,
      height: h,
      color: colors[seed.hashCode % colors.length],
      child: const Icon(Icons.image, color: Colors.white54, size: 32),
    );
  }
}

class _WeekDay {
  final String label;
  final int date;
  const _WeekDay(this.label, this.date);
}
