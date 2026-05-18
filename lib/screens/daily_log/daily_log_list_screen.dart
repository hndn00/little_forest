// screens/daily_log/daily_log_list_screen.dart

import 'package:flutter/material.dart';
import '../../models/daily_log_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';
import 'daily_log_detail_screen.dart';

class DailyLogListScreen extends StatefulWidget {
  const DailyLogListScreen({super.key});

  @override
  State<DailyLogListScreen> createState() => _DailyLogListScreenState();
}

class _DailyLogListScreenState extends State<DailyLogListScreen> {
  // 현재 선택된 날짜 (Wed 7 기준)
  int _selectedDay = 2; // 0=Mon, 1=Tue, 2=Wed ...
  // FAB로 진입한 화면이므로 하단 탭 선택 없음
  static const int _bottomNavIndex = -1;

  final List<_WeekDay> _weekDays = [
    _WeekDay('Mon', 5),
    _WeekDay('Tue', 6),
    _WeekDay('Wed', 7),
    _WeekDay('Thu', 8),
    _WeekDay('Fri', 9),
    _WeekDay('Sat', 10),
    _WeekDay('Sun', 11),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3EE),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildWeekBar(),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: mockDailyLogs.length,
                itemBuilder: (context, index) {
                  final entry = mockDailyLogs[index];
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
        onPressed: () {},
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
    final timeLabel = '$hour:00';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // 썸네일
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: _MockImage(
                width: 120,
                height: 100,
                seed: entry.id,
              ),
            ),
            const SizedBox(width: 20),
            // 시간
            Text(
              timeLabel,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D6A4F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 목업용 색상 플레이스홀더 이미지 ─────────────────────────
class _MockImage extends StatelessWidget {
  final double width;
  final double height;
  final String seed;

  const _MockImage({
    required this.width,
    required this.height,
    required this.seed,
  });

  @override
  Widget build(BuildContext context) {
    // 실제 앱에서는 Image.file() 또는 Image.network()로 교체
    final colors = [
      const Color(0xFFA8D5B5),
      const Color(0xFF7CB9A0),
      const Color(0xFFD4E8DC),
      const Color(0xFF4A8C62),
    ];
    final color = colors[seed.hashCode % colors.length];
    return Container(
      width: width,
      height: height,
      color: color,
      child: const Icon(Icons.image, color: Colors.white54, size: 32),
    );
  }
}

class _WeekDay {
  final String label;
  final int date;
  const _WeekDay(this.label, this.date);
}