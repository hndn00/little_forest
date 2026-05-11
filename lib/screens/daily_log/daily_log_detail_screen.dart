// screens/daily_log/daily_log_detail_screen.dart

import 'package:flutter/material.dart';
import '../../models/daily_log_models.dart';
import 'daily_log_analysis_screen.dart';

class DailyLogDetailScreen extends StatelessWidget {
  final DailyLogEntry entry;

  const DailyLogDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final hour = entry.capturedAt.hour;
    final timeLabel = '$hour:00';

    return Scaffold(
      backgroundColor: const Color(0xFFEEF3EE),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildWeekBar(),
            const SizedBox(height: 20),
            // 사진 카드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: _MockPhotoLarge(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        timeLabel,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A3A2A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 버튼 2개
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _ActionButton(
                    icon: Icons.photo_library_outlined,
                    label: 'Daily Log 보러 가기',
                    filled: true,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 12),
                  _ActionButton(
                    icon: Icons.edit_outlined,
                    label: '사진 분석하기',
                    filled: false,
                    onTap: () => _goAnalysis(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekBar() {
    final days = [
      ('Mon', 5), ('Tue', 6), ('Wed', 7),
      ('Thu', 8), ('Fri', 9), ('Sat', 10), ('Sun', 11),
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: days.map((d) {
          final isSelected = d.$2 == entry.capturedAt.day;
          return Column(
            children: [
              Text(
                d.$1,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? const Color(0xFF1A3A2A) : const Color(0xFFAAAAAA),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${d.$2}',
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? const Color(0xFF1A3A2A) : const Color(0xFFAAAAAA),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _goAnalysis(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DailyLogAnalysisScreen(entry: entry),
      ),
    );
  }
}

// ── 상세 화면용 큰 사진 Mock ─────────────────────────────
class _MockPhotoLarge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 260,
      color: const Color(0xFF7CB9A0),
      child: const Icon(Icons.image, color: Colors.white54, size: 64),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: filled ? const Color(0xFF1A3A2A) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: filled
              ? null
              : Border.all(color: const Color(0xFF1A3A2A), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: filled ? Colors.white : const Color(0xFF1A3A2A),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: filled ? Colors.white : const Color(0xFF1A3A2A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}