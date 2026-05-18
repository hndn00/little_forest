// screens/daily_log/daily_log_analysis_screen.dart

import 'package:flutter/material.dart';
import '../../models/daily_log_models.dart';
import '../../services/event_bus.dart';
import '../../events/app_event.dart';

const _mockLabels = [
  VisionLabel(label: 'Park', confidence: 0.97),
  VisionLabel(label: 'Tree', confidence: 0.94),
  VisionLabel(label: 'Nature', confidence: 0.91),
  VisionLabel(label: 'Sky', confidence: 0.88),
  VisionLabel(label: 'Outdoor', confidence: 0.85),
];

class DailyLogAnalysisScreen extends StatefulWidget {
  final DailyLogEntry entry;

  const DailyLogAnalysisScreen({super.key, required this.entry});

  @override
  State<DailyLogAnalysisScreen> createState() => _DailyLogAnalysisScreenState();
}

class _DailyLogAnalysisScreenState extends State<DailyLogAnalysisScreen> {
  final PageController _pageController = PageController();
  void _goToStep(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _onRewardConfirmed() {
    final points = widget.entry.activityResult?.points ?? 70;
    AppEventBus().emit(
      SettLogUploaded(capturedAt: widget.entry.capturedAt, points: points),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('나무가 성장했어요! +${points}P'),
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3EE),
      appBar: _buildAppBar(),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _UploadConfirmPage(
            entry: widget.entry,
            onNext: () => _goToStep(1),
          ),
          _AnalyzingPage(
            entry: widget.entry,
            onDone: () => _goToStep(2),
          ),
          _ActivityResultPage(
            entry: widget.entry,
            onNext: () => _goToStep(3),
          ),
          _RewardPage(
            entry: widget.entry,
            onDone: _onRewardConfirmed,
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
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit_outlined, color: Color(0xFF1A3A2A), size: 18),
          SizedBox(width: 6),
          Text(
            '사진 분석',
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

// ── Step 1: 이미지 업로드 확인 ─────────────────────────────
class _UploadConfirmPage extends StatelessWidget {
  final DailyLogEntry entry;
  final VoidCallback onNext;

  const _UploadConfirmPage({required this.entry, required this.onNext});

  String _formatDate(DateTime dt) {
    const months = [
      '1월', '2월', '3월', '4월', '5월', '6월',
      '7월', '8월', '9월', '10월', '11월', '12월',
    ];
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '${dt.year}년 ${months[dt.month - 1]} ${dt.day}일  $hour:$min';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _AnalysisPhotoCard(entry: entry),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time,
                    color: Color(0xFF4A8C62), size: 20),
                const SizedBox(width: 10),
                Text(
                  _formatDate(entry.capturedAt),
                  style: const TextStyle(
                    color: Color(0xFF1A3A2A),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _PrimaryButton(label: '사진 분석하기', onTap: onNext),
        ],
      ),
    );
  }
}

// ── Step 2: 분석 중 (2초 딜레이) ──────────────────────────
class _AnalyzingPage extends StatefulWidget {
  final DailyLogEntry entry;
  final VoidCallback onDone;

  const _AnalyzingPage({required this.entry, required this.onDone});

  @override
  State<_AnalyzingPage> createState() => _AnalyzingPageState();
}

class _AnalyzingPageState extends State<_AnalyzingPage>
    with TickerProviderStateMixin {
  int _visibleCount = 0;
  late final List<AnimationController> _barControllers;
  late final List<Animation<double>> _barAnimations;

  @override
  void initState() {
    super.initState();
    _barControllers = List.generate(
      _mockLabels.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
    _barAnimations = _barControllers
        .map((c) => Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: c, curve: Curves.easeOut),
            ))
        .toList();

    _runAnalysis();
  }

  // Labels appear one by one; total ~2 s before advancing
  void _runAnalysis() async {
    for (int i = 0; i < _mockLabels.length; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      setState(() => _visibleCount = i + 1);
      _barControllers[i].forward();
    }
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) widget.onDone();
  }

  @override
  void dispose() {
    for (final c in _barControllers) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _AnalysisPhotoCard(entry: widget.entry),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor:
                        AlwaysStoppedAnimation(Color(0xFF4A8C62)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  '분석 중...',
                  style: TextStyle(
                    color: Color(0xFF1A3A2A),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                ...List.generate(_mockLabels.length, (i) {
                  if (i >= _visibleCount) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _LabelBar(
                      label: _mockLabels[i].label,
                      confidence: _mockLabels[i].confidence,
                      animation: _barAnimations[i],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 3: 활동 판별 결과 ─────────────────────────────────
class _ActivityResultPage extends StatelessWidget {
  final DailyLogEntry entry;
  final VoidCallback onNext;

  const _ActivityResultPage({required this.entry, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _AnalysisPhotoCard(entry: entry),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              children: [
                _ActivityIcon(type: ActivityType.outdoor),
                SizedBox(height: 20),
                Text(
                  '야외 외출!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A3A2A),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '오늘의 활동이 인식되었어요',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4A8C62),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _PrimaryButton(label: '리워드 받기', onTap: onNext),
        ],
      ),
    );
  }
}

// ── Step 4: 리워드 지급 팝업 ──────────────────────────────
class _RewardPage extends StatefulWidget {
  final DailyLogEntry entry;
  final VoidCallback onDone;

  const _RewardPage({required this.entry, required this.onDone});

  @override
  State<_RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends State<_RewardPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dimmed background showing previous step
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _AnalysisPhotoCard(entry: widget.entry, dimmed: true),
              const SizedBox(height: 16),
              Opacity(
                opacity: 0.3,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 36, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    children: [
                      _ActivityIcon(type: ActivityType.outdoor),
                      SizedBox(height: 20),
                      Text(
                        '야외 외출',
                        style: TextStyle(
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
        // Animated popup card
        Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Container(
                width: 260,
                padding: const EdgeInsets.symmetric(
                    vertical: 36, horizontal: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 28,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.eco,
                        color: Color(0xFF4A8C62), size: 56),
                    const SizedBox(height: 16),
                    const Text(
                      '야외 외출',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A3A2A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '+70P',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4A8C62),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: widget.onDone,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A3A2A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '나무에게 전달하기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Shared widgets ────────────────────────────────────────

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
              color: Colors.black.withValues(alpha: 0.3),
            ),
          Positioned.fill(
            child: CustomPaint(painter: _ScanCornerPainter()),
          ),
        ],
      ),
    );
  }
}

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

    canvas.drawLine(Offset(pad, pad + len), Offset(pad, pad), paint);
    canvas.drawLine(Offset(pad, pad), Offset(pad + len, pad), paint);
    canvas.drawLine(
        Offset(size.width - pad - len, pad), Offset(size.width - pad, pad), paint);
    canvas.drawLine(
        Offset(size.width - pad, pad), Offset(size.width - pad, pad + len), paint);
    canvas.drawLine(
        Offset(pad, size.height - pad - len), Offset(pad, size.height - pad), paint);
    canvas.drawLine(
        Offset(pad, size.height - pad), Offset(pad + len, size.height - pad), paint);
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
          builder: (context, _) => ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: confidence * animation.value,
              minHeight: 6,
              backgroundColor: const Color(0xFFEEF3EE),
              valueColor:
                  const AlwaysStoppedAnimation(Color(0xFF4A8C62)),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityIcon extends StatelessWidget {
  final ActivityType type;

  const _ActivityIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 110,
      child: CustomPaint(painter: _ActivityIconPainter(type: type)),
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
      case ActivityType.outdoor:
        _drawTree(canvas, size, paint);
      case ActivityType.training:
        _drawShoe(canvas, size, paint);
      case ActivityType.cafe:
        _drawCoffee(canvas, size, paint);
      case ActivityType.walking:
        _drawWalk(canvas, size, paint);
      default:
        break;
    }
  }

  void _drawTree(Canvas canvas, Size size, Paint p) {
    final w = size.width;
    final h = size.height;
    canvas.drawLine(Offset(w * 0.5, h * 0.6), Offset(w * 0.5, h * 0.9), p);
    final leaf = Path()
      ..moveTo(w * 0.5, h * 0.1)
      ..lineTo(w * 0.15, h * 0.65)
      ..lineTo(w * 0.85, h * 0.65)
      ..close();
    canvas.drawPath(leaf, p);
  }

  void _drawShoe(Canvas canvas, Size size, Paint p) {
    final w = size.width;
    final h = size.height;
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
    canvas.drawLine(Offset(w * 0.08, h * 0.78), Offset(w * 0.92, h * 0.78), p);
  }

  void _drawCoffee(Canvas canvas, Size size, Paint p) {
    final w = size.width;
    final h = size.height;
    final cup = Path()
      ..moveTo(w * 0.2, h * 0.3)
      ..lineTo(w * 0.3, h * 0.8)
      ..lineTo(w * 0.7, h * 0.8)
      ..lineTo(w * 0.8, h * 0.3)
      ..close();
    canvas.drawPath(cup, p);
    canvas.drawArc(
      Rect.fromLTWH(w * 0.7, h * 0.4, w * 0.2, h * 0.25),
      -1.57, 3.14, false, p,
    );
  }

  void _drawWalk(Canvas canvas, Size size, Paint p) {
    final w = size.width;
    final h = size.height;
    canvas.drawCircle(Offset(w * 0.5, h * 0.15), w * 0.1, p);
    canvas.drawLine(Offset(w * 0.5, h * 0.25), Offset(w * 0.5, h * 0.6), p);
    canvas.drawLine(Offset(w * 0.5, h * 0.4), Offset(w * 0.3, h * 0.55), p);
    canvas.drawLine(Offset(w * 0.5, h * 0.4), Offset(w * 0.7, h * 0.5), p);
    canvas.drawLine(Offset(w * 0.5, h * 0.6), Offset(w * 0.35, h * 0.85), p);
    canvas.drawLine(Offset(w * 0.5, h * 0.6), Offset(w * 0.65, h * 0.85), p);
  }

  @override
  bool shouldRepaint(covariant _ActivityIconPainter old) => old.type != type;
}

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
