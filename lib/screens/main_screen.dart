import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_forest/screens/daily_log/daily_log_list_screen.dart';
import 'package:little_forest/screens/my_plants_screen.dart';
import 'package:little_forest/screens/map_screen.dart';
import 'package:little_forest/screens/chatbot_screen.dart';
import 'package:little_forest/theme/app_theme.dart';
import 'package:little_forest/widgets/bottom_nav.dart';
import 'package:image_picker/image_picker.dart';
import 'package:little_forest/services/camera_service.dart';
import 'package:little_forest/providers/daily_log_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedTab = 0;
  int _bottomIndex = 0;

  // Hard-coded UID placeholder — replace with FirebaseAuth.instance.currentUser!.uid
  static const String _uid = 'anonymous';

  Future<void> _onCameraFabTapped() async {
    final XFile? xfile = await CameraService.capturePhoto(context);
    if (xfile == null || !mounted) return;

    ref.read(dailyLogProvider.notifier).addPhoto(xfile, _uid).catchError((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('업로드에 실패했습니다.'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: '재시도',
              onPressed: () =>
                  ref.read(dailyLogProvider.notifier).addPhoto(xfile, _uid),
            ),
          ),
        );
      }
    });

    // Navigate to Daily Log immediately (photo shows with loading indicator)
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DailyLogListScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'LittleForest',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.forestDeep,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        _buildTab('My Plants', 0),
                        _buildTab('map', 1),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _selectedTab == 0
                  ? const MyPlantsScreen()
                  : const MapScreen(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: _bottomIndex,
        onItemTapped: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatbotScreen()),
            );
          } else {
            setState(() => _bottomIndex = index);
          }
        },
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

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.forestDeep : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
