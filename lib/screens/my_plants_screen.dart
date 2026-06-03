import 'dart:async';

import 'package:flutter/material.dart';
import 'package:little_forest/events/app_event.dart';
import 'package:little_forest/screens/daily_log/daily_log_list_screen.dart';
import 'package:little_forest/services/event_bus.dart';
import 'package:little_forest/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyPlantsScreen extends StatefulWidget {
  const MyPlantsScreen({super.key});

  @override
  State<MyPlantsScreen> createState() => _MyPlantsScreenState();
}

class _MyPlantsScreenState extends State<MyPlantsScreen> {
  int _totalPoints = 0;
  late final StreamSubscription _rewardSub;

  static const _treeImages = [
    'assets/images/tree_small.png',
    'assets/images/tree_mid.png',
    'assets/images/tree.png',
  ];

  int get _treeLevel => (_totalPoints ~/ 50).clamp(0, 2);
  String get _treeImage => _treeImages[_treeLevel];

  String get _pointsLabel {
    if (_treeLevel == 2) return '$_totalPoints P (MAX)';
    final nextThreshold = (_treeLevel + 1) * 50;
    return '$_totalPoints / ${nextThreshold}P';
  }

  @override
  void initState() {
    super.initState();
    _loadPoints();
    _rewardSub = AppEventBus().stream.listen((event) {
      if (event is SettLogUploaded) {
        _addPoints(event.points);
      }
    });
  }

  @override
  void dispose() {
    _rewardSub.cancel();
    super.dispose();
  }

  Future<void> _loadPoints() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalPoints = prefs.getInt('totalPoints') ?? 0;
    });
  }

  Future<void> _addPoints(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalPoints += amount;
    });
    await prefs.setInt('totalPoints', _totalPoints);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.skyTop,
                      AppColors.skyBottom,
                      AppColors.grassGreen,
                    ],
                    stops: [0.0, 0.7, 1.0],
                  ),
                ),
              ),
              Positioned(
                top: 30,
                right: 40,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: AppColors.sunYellow,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x66FFC94D),
                        blurRadius: 20,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: Image.asset(
                        _treeImage,
                        key: ValueKey(_treeImage),
                        height: 280,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.eco,
                              color: AppColors.forestLight, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Lv. ${_treeLevel + 1}  $_pointsLabel',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              color: AppColors.forestDeep,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const DailyLogListScreen()),
                      );
                    },
                    icon: const Icon(Icons.alarm, color: Colors.white),
                    label: const Text(
                      'timestamp',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.forestDeep,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.directions_walk,
                        color: AppColors.forestDeep),
                    label: const Text(
                      'walking',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: AppColors.forestDeep,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.forestDeep),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
