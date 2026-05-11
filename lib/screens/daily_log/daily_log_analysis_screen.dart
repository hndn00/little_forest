// screens/daily_log/daily_log_analysis_screen.dart
//
// 3단계: 라벨 결과 (progress bar) → 4단계: 활동 판별 → 5단계: 리워드 팝업
// PageController로 세 단계 전환

import 'package:flutter/material.dart';
import '../../models/daily_log_models.dart';

// ── 진입점: 분석 시작 화면 ────────────────────────────────
class DailyLogAnalysisScreen extends StatefulWidget {
  final DailyLogEntry entry;

  const DailyLogAnalysisScreen({super.key, required this.entry});

  @override
  State<DailyLogAnalysisScreen> createState() =>
      _DailyLogAnalysisScreenState();
}

class _DailyLogAnalysisScreenState extends State<DailyLogAnalysisScreen> {
  // 0 = 라벨 결과, 1 = 활동 판별, 2 = 리워드
  final PageController _pageController = PageController();
  int _page = 0;

  // Mock: Training으로 고정 (실제는 Vision API 결과)
  final ActivityType _mockActivity = ActivityType.training;

  @override
  void initState() {
    super.initState();
    // 진입 즉시 분석 완료된 것처럼 라벨 화면 보여줌
  }

  void _nextPage() {
    if (_page < 2) {
      setState(() => _page++);
      _pageController.animateToPage(
        _page,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3EE),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // 3단계: 라벨 결과
              _LabelResultPage(
                entry: widget.entry,
                activityType: _mockActivity,
                onNext: _nextPage,
              ),
              // 4단계: 활동 판별
              _ActivityResultPage(
                entry: widget.entry,
                activityType: _mockActivity,
                onNext: _nextPage,
              ),
              // 5단계: 리워드 팝업 (오버레이)
              _RewardPage(
                entry: widget.entry,
                activityType: _mockActivity,
                onDone: () => Navigator.popUntil(
                  context,
                  (route) => route.isFirst,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFEEF3EE),
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            color: Color(0xFF1A3A2A), size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.edit_outlined,
              color: Color(0xFF1A3A2A), size: 18),
          const SizedBox(width: 6),
          const Text(
            '분석 결과',
            style: TextStyle(
              color: Color(0xFF1A3A2A),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      centerTitle: true,
    );
  }
}

// ── 3단계: Vision 라벨 결과 화면 ─────────────────────────
class _LabelResultPage extends StatefulWidget {
  final DailyLogEntry entry;
  final ActivityType activityType;
  final VoidCallback onNext;

  const _LabelResultPage({
    required this.entry,
    required this.activityType,
    required this.onNext,
  });

  @override
  State<_LabelResultPage> createState() => _LabelResultPageState();
}

class _LabelResultPageState extends State<_LabelResultPage>
    with TickerProviderStateMixin {
  late final List<AnimationController> _barControllers;
  late final List<Animation<double>> _barAnimations;
  final labels = MockVisionData.labels[ActivityType.training]!;

  @override
  void initState() {
    super.initState();
    _barControllers = List.generate(
      labels.length,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 600 + i * 80),
      ),
    );
    _barAnimations = _barControllers.map((c) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: c, curve: Curves.easeOut),
      );
    }).toList();

    // 순차 실행
    _startAnimations();
  }

  void _startAnimations() async {
    for (int i = 0; i < _barControllers.length; i++) {
      await Future.delayed(Duration(milliseconds: i * 100));
      if (mounted) _barControllers[i].forward();
    }
  }

  @override
  void dispose() {
    for (final c in _barControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 사진
          _AnalysisPhotoCard(entry: widget.entry),
          const SizedBox(height: 16),
          // 라벨 카드
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ...List.generate(labels.length, (i) {
                  final label = labels[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _LabelBar(
                      label: label.label,
                      confidence: label.confidence,
                      animation: _barAnimations[i],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                // 페이지 인디케이터
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    return Container(
                      width: i == 0 ? 10 : 8,
                      height: i == 0 ? 10 : 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == 0
                            ? const Color(0xFF1A3A2A)
                            : const Color(0xFFCCCCCC),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _PrimaryButton(
            label: '활동 결과 보기',
            onTap: widget.onNext,
          ),
        ],
      ),
    );
  }
}

class _LabelBar extends StatelessWidget {
  final String label;
  final double confidence;
  final Animation<double> animation;

  const _LabelBar({
    required this.label,
    required this.confidence,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (confidence * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF4A8C62),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$pct%',
              style: const TextStyle(
                color: Color(0xFF4A8C62),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        AnimatedBuilder(
          animation: animation,
          builder: (_, __) => ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: confidence * animation.value,
              minHeight: 6,
              backgroundColor: const Color(0xFFEEF3EE),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF4A8C62)),
            ),
          ),
        ),
      ],
    );
  }
}

// ── 4단계: 활동 판별 결과 화면 ───────────────────────────
class _ActivityResultPage extends StatelessWidget {
  final DailyLogEntry entry;
  final ActivityType activityType;
  final VoidCallback onNext;

  const _ActivityResultPage({
    required this.entry,
    required this.activityType,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final result = MockVisionData.results[activityType]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 사진
          _AnalysisPhotoCard(entry: entry),
          const SizedBox(height: 16),
          // 활동 카드
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            child: Column(
              children: [
                _ActivityIcon(type: activityType),
                const SizedBox(height: 20),
                Text(
                  '${result.displayName}!',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A3A2A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _PrimaryButton(
            label: '리워드 받기',
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

// ── 5단계: 리워드 팝업 화면 ──────────────────────────────
class _RewardPage extends StatefulWidget {
  final DailyLogEntry entry;
  final ActivityType activityType;
  final VoidCallback onDone;

  const _RewardPage({
    required this.entry,
    required this.activityType,
    required this.onDone,
  });

  @override
  State<_RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends State<_RewardPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _popupController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _popupController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _popupController, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _popupController, curve: Curves.easeIn),
    );
    _popupController.forward();
  }

  @override
  void dispose() {
    _popupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = MockVisionData.results[widget.activityType]!;

    return Stack(
      children: [
        // 배경 — 활동 판별 결과가 흐릿하게
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _AnalysisPhotoCard(entry: widget.entry, dimmed: true),
              const SizedBox(height: 16),
              Opacity(
                opacity: 0.35,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 36, horizontal: 20),
                  child: Column(
                    children: [
                      _ActivityIcon(type: widget.activityType),
                      const SizedBox(height: 20),
                      Text(
                        '${result.displayName}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A3A2A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 팝업 오버레이
        Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: GestureDetector(
                onTap: widget.onDone,
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.symmetric(
                      vertical: 36, horizontal: 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Reward!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A3A2A),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // 새싹 아이콘
                      _SproutIcon(),
                      const SizedBox(height: 20),
                      Text(
                        '+ ${result.points}P',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A3A2A),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── 공용 위젯들 ──────────────────────────────────────────

class _AnalysisPhotoCard extends StatelessWidget {
  final DailyLogEntry entry;
  final bool dimmed;

  const _AnalysisPhotoCard({required this.entry, this.dimmed = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 220,
            color: const Color(0xFF7CB9A0),
            child: const Icon(Icons.image, color: Colors.white54, size: 64),
          ),
          if (dimmed)
            Container(
              width: double.infinity,
              height: 220,
              color: Colors.black.withOpacity(0.3),
            ),
          // 스캔 코너 장식
          Positioned.fill(
            child: CustomPaint(painter: _ScanCornerPainter()),
          ),
        ],
      ),
    );
  }
}

/// 사진 네 모서리의 스캔 코너 UI (이미지_분석.png 참고)
class _ScanCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A3A2A)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const len = 20.0;
    const pad = 12.0;

    // 좌상
    canvas.drawLine(Offset(pad, pad + len), Offset(pad, pad), paint);
    canvas.drawLine(Offset(pad, pad), Offset(pad + len, pad), paint);
    // 우상
    canvas.drawLine(
        Offset(size.width - pad - len, pad),
        Offset(size.width - pad, pad),
        paint);
    canvas.drawLine(
        Offset(size.width - pad, pad),
        Offset(size.width - pad, pad + len),
        paint);
    // 좌하
    canvas.drawLine(
        Offset(pad, size.height - pad - len),
        Offset(pad, size.height - pad),
        paint);
    canvas.drawLine(
        Offset(pad, size.height - pad),
        Offset(pad + len, size.height - pad),
        paint);
    // 우하
    canvas.drawLine(
        Offset(size.width - pad - len, size.height - pad),
        Offset(size.width - pad, size.height - pad),
        paint);
    canvas.drawLine(
        Offset(size.width - pad, size.height - pad - len),
        Offset(size.width - pad, size.height - pad),
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 활동 타입별 SVG-style 아이콘
class _ActivityIcon extends StatelessWidget {
  final ActivityType type;

  const _ActivityIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      padding: const EdgeInsets.all(18),
      child: CustomPaint(
        painter: _ActivityIconPainter(type: type),
      ),
    );
  }
}

class _ActivityIconPainter extends CustomPainter {
  final ActivityType type;
  const _ActivityIconPainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A3A2A)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (type) {
      case ActivityType.training:
        _drawShoe(canvas, size, paint);
        break;
      case ActivityType.outdoor:
        _drawTree(canvas, size, paint);
        break;
      case ActivityType.cafe:
        _drawCoffee(canvas, size, paint);
        break;
      case ActivityType.walking:
        _drawWalk(canvas, size, paint);
        break;
      default:
        break;
    }
  }

  void _drawShoe(Canvas canvas, Size size, Paint p) {
    final w = size.width;
    final h = size.height;
    // 러닝화 실루엣 (트레드밀 아이콘 스타일)
    final path = Path()
      ..moveTo(w * 0.1, h * 0.75)
      ..lineTo(w * 0.15, h * 0.55)
      ..lineTo(w * 0.3, h * 0.45)
      ..lineTo(w * 0.55, h * 0.4)
      ..lineTo(w * 0.7, h * 0.3)
      ..lineTo(w * 0.85, h * 0.35)
      ..lineTo(w * 0.9, h * 0.5)
      ..lineTo(w * 0.75, h * 0.6)
      ..lineTo(w * 0.9, h * 0.75)
      ..lineTo(w * 0.1, h * 0.75)
      ..close();
    canvas.drawPath(path, p);
    // 밑창
    canvas.drawLine(
      Offset(w * 0.08, h * 0.78),
      Offset(w * 0.92, h * 0.78),
      p,
    );
    // 끈 라인
    canvas.drawLine(
      Offset(w * 0.35, h * 0.42),
      Offset(w * 0.45, h * 0.55),
      p..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(w * 0.5, h * 0.39),
      Offset(w * 0.58, h * 0.53),
      p,
    );
    p.strokeWidth = 3.5;
  }

  void _drawTree(Canvas canvas, Size size, Paint p) {
    final w = size.width;
    final h = size.height;
    // 나무 몸통
    canvas.drawLine(Offset(w * 0.5, h * 0.6), Offset(w * 0.5, h * 0.9), p);
    // 삼각 잎
    final leaf = Path()
      ..moveTo(w * 0.5, h * 0.1)
      ..lineTo(w * 0.15, h * 0.65)
      ..lineTo(w * 0.85, h * 0.65)
      ..close();
    canvas.drawPath(leaf, p);
  }

  void _drawCoffee(Canvas canvas, Size size, Paint p) {
    final w = size.width;
    final h = size.height;
    // 컵
    final cup = Path()
      ..moveTo(w * 0.2, h * 0.3)
      ..lineTo(w * 0.3, h * 0.8)
      ..lineTo(w * 0.7, h * 0.8)
      ..lineTo(w * 0.8, h * 0.3)
      ..close();
    canvas.drawPath(cup, p);
    // 손잡이
    canvas.drawArc(
      Rect.fromLTWH(w * 0.7, h * 0.4, w * 0.2, h * 0.25),
      -1.57,
      3.14,
      false,
      p,
    );
    // 증기
    canvas.drawLine(Offset(w * 0.38, h * 0.18), Offset(w * 0.42, h * 0.06), p);
    canvas.drawLine(Offset(w * 0.5, h * 0.15), Offset(w * 0.5, h * 0.03), p);
    canvas.drawLine(Offset(w * 0.62, h * 0.18), Offset(w * 0.58, h * 0.06), p);
  }

  void _drawWalk(Canvas canvas, Size size, Paint p) {
    final w = size.width;
    final h = size.height;
    // 사람 실루엣
    canvas.drawCircle(Offset(w * 0.5, h * 0.15), w * 0.1, p);
    canvas.drawLine(Offset(w * 0.5, h * 0.25), Offset(w * 0.5, h * 0.6), p);
    canvas.drawLine(Offset(w * 0.5, h * 0.4), Offset(w * 0.3, h * 0.55), p);
    canvas.drawLine(Offset(w * 0.5, h * 0.4), Offset(w * 0.7, h * 0.5), p);
    canvas.drawLine(Offset(w * 0.5, h * 0.6), Offset(w * 0.35, h * 0.85), p);
    canvas.drawLine(Offset(w * 0.5, h * 0.6), Offset(w * 0.65, h * 0.85), p);
  }

  @override
  bool shouldRepaint(covariant _ActivityIconPainter old) =>
      old.type != type;
}

/// 새싹 아이콘 (리워드 팝업용)
class _SproutIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: CustomPaint(painter: _SproutPainter()),
    );
  }
}

class _SproutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stemPaint = Paint()
      ..color = const Color(0xFF8B6914)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final leafPaint = Paint()
      ..color = const Color(0xFF6DBE45)
      ..style = PaintingStyle.fill;

    final darkLeafPaint = Paint()
      ..color = const Color(0xFF4A9E2F)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // 줄기
    final stemPath = Path()
      ..moveTo(w * 0.5, h * 0.95)
      ..quadraticBezierTo(w * 0.5, h * 0.65, w * 0.5, h * 0.45);
    canvas.drawPath(stemPath, stemPaint);

    // 왼쪽 잎
    final leftLeaf = Path()
      ..moveTo(w * 0.5, h * 0.55)
      ..quadraticBezierTo(w * 0.15, h * 0.35, w * 0.2, h * 0.1)
      ..quadraticBezierTo(w * 0.45, h * 0.3, w * 0.5, h * 0.55)
      ..close();
    canvas.drawPath(leftLeaf, leafPaint);

    // 오른쪽 잎
    final rightLeaf = Path()
      ..moveTo(w * 0.5, h * 0.45)
      ..quadraticBezierTo(w * 0.85, h * 0.25, w * 0.82, h * 0.0)
      ..quadraticBezierTo(w * 0.58, h * 0.2, w * 0.5, h * 0.45)
      ..close();
    canvas.drawPath(rightLeaf, darkLeafPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── 공용 기본 버튼 ────────────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A3A2A),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}