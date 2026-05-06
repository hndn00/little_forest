import 'package:flutter/material.dart';
import 'package:little_forest/theme/app_theme.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 64, color: AppColors.forestLight),
          const SizedBox(height: 16),
          Text(
            '지도 화면 준비 중',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.forestDeep,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}