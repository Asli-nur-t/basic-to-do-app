import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/streak_controller.dart';

class StreakIndicator extends StatelessWidget {
  const StreakIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final streakController = Get.find<StreakController>();

    return Obx(() {
      final currentStreak = streakController.currentStreak.value;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        constraints: const BoxConstraints(maxWidth: 80), // Maksimum genişlik
        child: GestureDetector(
          onTap: () => _showStreakInfo(context, streakController),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Image.asset(
                  'assets/icons/icons8-fire.gif',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '$currentStreak',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showStreakInfo(BuildContext context, StreakController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Image.asset(
              'assets/icons/icons8-fire.gif',
              height: 24,
              width: 24,
            ),
            const SizedBox(width: 8),
            const Text('Streak Bilgisi'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mevcut Streak: ${controller.currentStreak.value} gün'),
            const SizedBox(height: 8),
            Text('En Uzun Streak: ${controller.longestStreak.value} gün'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
