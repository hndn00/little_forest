import 'dart:math';
import 'package:flutter/material.dart';
import 'package:little_forest/theme/app_theme.dart';

// ── 데이터 모델 ──────────────────────────────────────────────────────────────

class _UserData {
  final String name;
  final String emoji;
  final Color borderColor;
  final String message;
  final double left;   // 0~1 비율
  final double top;    // 0~1 비율
  final int treeLevel;
  final String treeAsset;

  const _UserData({
    required this.name,
    required this.emoji,
    required this.borderColor,
    required this.message,
    required this.left,
    required this.top,
    required this.treeLevel,
    required this.treeAsset,
  });
}

const _users = [
  _UserData(
    name: 'yeou',
    emoji: '🦊',
    borderColor: Color(0xFF5B8FBF),
    message: '날씨가 너무 좋다!\n같이 걷자~',
    left: 0.12,
    top: 0.30,
    treeLevel: 3,
    treeAsset: 'assets/images/tree_mid.png',
  ),
  _UserData(
    name: 'tokki',
    emoji: '🐰',
    borderColor: Color(0xFF8C7B6B),
    message: '오늘도 화이팅!',
    left: 0.55,
    top: 0.44,
    treeLevel: 5,
    treeAsset: 'assets/images/tree.png',
  ),
  _UserData(
    name: 'bambi',
    emoji: '🦌',
    borderColor: Color(0xFFBF5B5B),
    message: '힘내!!',
    left: 0.62,
    top: 0.62,
    treeLevel: 2,
    treeAsset: 'assets/images/tree_small.png',
  ),
];

// 나를 포함한 친구 목록 (팝업용)
const _friends = [
  ('yeou', '🦊'),
  ('tokki', '🐰'),
  ('bambi', '🦌'),
];

// ── 메인 스크린 ───────────────────────────────────────────────────────────────

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  _UserData? _selectedUser;
  late final AnimationController _floatController;
  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  void _sendGesture(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: AppColors.forestDeep,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildMapArea();
  }

  // ── 지도 영역 ─────────────────────────────────────────────────────────────

  Widget _buildMapArea() {
    return GestureDetector(
      onTap: () {
        if (_selectedUser != null) {
          setState(() => _selectedUser = null);
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // 지도 배경
              Image.asset(
                'assets/images/map_image.png',
                fit: BoxFit.cover,
              ),

              // 지역 활동 알림 말풍선
              _buildAreaNotice(constraints, left: 0.05, top: 0.48,
                  text: '다른 친구들은\n중구에서 현재 활동 중!'),
              _buildAreaNotice(constraints, left: 0.40, top: 0.12,
                  text: '다른 친구들은\n서구에서 현재 활동 중!'),

              // 유저 아이콘들 (애니메이션)
              ..._users.asMap().entries.map((e) {
                final offset = e.key * 1.2; // 각 유저마다 위상 다르게
                return _buildUserPin(e.value, constraints, phaseOffset: offset);
              }),

              // 내 위치 (곰)
              _buildMyPin(constraints),

              // 군집 숫자 뱃지
              _buildClusterBadge(constraints, left: 0.55, top: 0.18, count: 480),
              _buildClusterBadge(constraints, left: 0.10, top: 0.60, count: 200),

              // 나무 현황 팝업
              if (_selectedUser != null)
                _buildTreePopup(_selectedUser!, constraints),

              // 하단 버튼
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: _buildGestureButtons(),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── 지역 알림 말풍선 ──────────────────────────────────────────────────────

  Widget _buildAreaNotice(BoxConstraints c,
      {required double left, required double top, required String text}) {
    return Positioned(
      left: c.maxWidth * left,
      top: c.maxHeight * top,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Color(0x22000000), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            color: Color(0xFF1A3A2A),
            height: 1.4,
          ),
        ),
      ),
    );
  }

  // ── 유저 핀 (동물 아이콘 + 이름 + 말풍선) ─────────────────────────────────

  Widget _buildUserPin(_UserData user, BoxConstraints c,
      {double phaseOffset = 0}) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final phase = (_floatController.value + phaseOffset / 3) % 1.0;
        final dy = sin(phase * 2 * pi) * 5;
        return Positioned(
          left: c.maxWidth * user.left,
          top: c.maxHeight * user.top + dy,
          child: child!,
        );
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedUser = _selectedUser == user ? null : user;
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 말풍선
            _SpeechBubble(text: user.message),
            const SizedBox(height: 4),
            // 아이콘
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: user.borderColor, width: 2.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(user.emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              user.name,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 내 핀 ────────────────────────────────────────────────────────────────

  Widget _buildMyPin(BoxConstraints c) {
    return Positioned(
      left: c.maxWidth * 0.12,
      top: c.maxHeight * 0.72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF6B4226), width: 2.5),
              boxShadow: const [
                BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 3)),
              ],
            ),
            child: const Center(
              child: Text('🐻', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'me',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
            ),
          ),
          const SizedBox(height: 2),
          const Icon(Icons.circle, color: Colors.red, size: 10),
        ],
      ),
    );
  }

  // ── 군집 뱃지 ─────────────────────────────────────────────────────────────

  Widget _buildClusterBadge(BoxConstraints c,
      {required double left, required double top, required int count}) {
    final users = [('🦞', Color(0xFFBF5B5B)), ('🐬', Color(0xFF5B8FBF)),
      ('🦄', Color(0xFFAA5BBF)), ('🦅', Color(0xFF5B8C5B)), ('🐺', Color(0xFF8C8C5B))];
    return Positioned(
      left: c.maxWidth * left,
      top: c.maxHeight * top,
      child: SizedBox(
        width: 90,
        height: 90,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 중앙 숫자 뱃지
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.forestDeep,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  '$count+',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // 주변 작은 아이콘들
            ...List.generate(5, (i) {
              final angle = (i / 5) * 2 * pi - pi / 2;
              final r = 36.0;
              return Positioned(
                left: 45 + r * cos(angle) - 13,
                top: 45 + r * sin(angle) - 13,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: users[i].$2, width: 2),
                  ),
                  child: Center(
                    child: Text(users[i].$1, style: const TextStyle(fontSize: 12)),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── 나무 현황 팝업 ────────────────────────────────────────────────────────

  Widget _buildTreePopup(_UserData user, BoxConstraints c) {
    double popupLeft = c.maxWidth * user.left - 20;
    double popupTop = c.maxHeight * user.top - 230;
    popupLeft = popupLeft.clamp(8, c.maxWidth - 220);
    popupTop = popupTop.clamp(8, c.maxHeight - 320);

    return Positioned(
      left: popupLeft,
      top: popupTop,
      child: GestureDetector(
        onTap: () {}, // 팝업 탭 시 닫히지 않게
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 210,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 제목
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Row(
                    children: [
                      Text(user.emoji, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      const Text(
                        '내 나무 현황',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A3A2A),
                        ),
                      ),
                    ],
                  ),
                ),
                // 나무 이미지 + 레벨
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4EE),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Image.asset(user.treeAsset, height: 90, fit: BoxFit.contain),
                      const SizedBox(height: 8),
                      Text(
                        'Lv. ${user.treeLevel.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A3A2A),
                        ),
                      ),
                    ],
                  ),
                ),
                // 친구한테 자랑하기
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    '친구한테 나무 자랑하기',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: Color(0xFF888888),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _friends.map((f) {
                      return GestureDetector(
                        onTap: () => _sendGesture('${f.$1}에게 나무를 자랑했어요!'),
                        child: Column(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFDDDDDD),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(f.$2,
                                    style: const TextStyle(fontSize: 20)),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              f.$1,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                color: Color(0xFF555555),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── 하단 버튼 ─────────────────────────────────────────────────────────────

  Widget _buildGestureButtons() {
    return Row(
      children: [
        Expanded(
          child: _GestureButton(
            icon: Icons.waving_hand_outlined,
            label: '하이파이브',
            filled: true,
            onTap: () => _sendGesture('하이파이브를 보냈어요!'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GestureButton(
            icon: Icons.person_add_outlined,
            label: '친구 추가',
            filled: false,
            onTap: () => _sendGesture('친구 요청을 보냈어요!'),
          ),
        ),
      ],
    );
  }
}

// ── 말풍선 ────────────────────────────────────────────────────────────────────

class _SpeechBubble extends StatelessWidget {
  final String text;
  const _SpeechBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 120),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10,
          color: Color(0xFF1A3A2A),
          height: 1.4,
        ),
      ),
    );
  }
}

// ── 하단 버튼 위젯 ────────────────────────────────────────────────────────────

class _GestureButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _GestureButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.forestDeep : Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 4,
      shadowColor: const Color(0x441A3A2A),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: filled
              ? null
              : BoxDecoration(
                  border: Border.all(color: AppColors.forestDeep, width: 1.5),
                  borderRadius: BorderRadius.circular(14),
                ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: filled ? Colors.white : AppColors.forestDeep, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: filled ? Colors.white : AppColors.forestDeep,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
