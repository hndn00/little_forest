import 'package:flutter/material.dart';
import 'package:little_forest/theme/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _avatarDots = [
    _AvatarDot(color: Color(0xFF4A8C62), left: 0.28, top: 0.32),
    _AvatarDot(color: Color(0xFFE07B54), left: 0.60, top: 0.48),
    _AvatarDot(color: Color(0xFF5B8FBF), left: 0.45, top: 0.65),
  ];

  void _sendGesture(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
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
    return Column(
      children: [
        _buildHeader(),
        Expanded(child: _buildMapArea()),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: AppColors.forestDeep,
      child: const Text(
        '탐험 지도',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildMapArea() {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/map_image.png',
            fit: BoxFit.cover,
          ),
        ),
        ..._avatarDots.map((dot) => _buildAvatarDot(dot)),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: _buildGestureButtons(),
        ),
      ],
    );
  }

  Widget _buildAvatarDot(_AvatarDot dot) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Positioned(
          left: constraints.maxWidth * dot.left,
          top: constraints.maxHeight * dot.top,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: dot.color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGestureButtons() {
    return Row(
      children: [
        Expanded(
          child: _GestureButton(
            icon: Icons.waving_hand_outlined,
            label: '하이파이브',
            onTap: () => _sendGesture('하이파이브를 보냈어요!'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GestureButton(
            icon: Icons.local_florist_outlined,
            label: '꽃잎 뿌리기',
            onTap: () => _sendGesture('꽃잎을 뿌렸어요!'),
          ),
        ),
      ],
    );
  }
}

class _AvatarDot {
  final Color color;
  final double left;
  final double top;

  const _AvatarDot({
    required this.color,
    required this.left,
    required this.top,
  });
}

class _GestureButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _GestureButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.forestDeep,
      borderRadius: BorderRadius.circular(14),
      elevation: 4,
      shadowColor: const Color(0x441A3A2A),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
