import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/streak_controller.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';

class DraggableStreakIndicator extends StatefulWidget {
  const DraggableStreakIndicator({super.key});

  @override
  State<DraggableStreakIndicator> createState() =>
      _DraggableStreakIndicatorState();
}

class _DraggableStreakIndicatorState extends State<DraggableStreakIndicator>
    with SingleTickerProviderStateMixin {
  Offset? position;
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  final _settingsBox = Hive.box('settings');

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Kaydedilmiş pozisyonu yükle
    final savedX = _settingsBox.get('streakX', defaultValue: 20.0);
    final savedY = _settingsBox.get('streakY', defaultValue: 0.0);
    position = Offset(savedX, savedY);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streakController = Get.find<StreakController>();
    final screenSize = MediaQuery.of(context).size;

    // İlk pozisyonu ayarla
    position ??= Offset
        .zero; // Başlangıç pozisyonu Align widget'ı tarafından belirleniyor

    return Draggable(
      feedback: Transform.translate(
        offset: const Offset(0, -30),
        child: _buildStreakBadge(streakController, isDragging: true),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildStreakBadge(streakController),
      ),
      onDragStarted: () {
        HapticFeedback.lightImpact();
      },
      onDragEnd: (details) {
        HapticFeedback.mediumImpact();
        setState(() {
          final touchOffset = details.offset;
          final newPosition = Offset(
            touchOffset.dx.clamp(0, screenSize.width - 100),
            touchOffset.dy.clamp(0, screenSize.height - 150),
          );

          _settingsBox.put('streakX', newPosition.dx);
          _settingsBox.put('streakY', newPosition.dy);
          position = newPosition;
        });
      },
      child: _buildStreakBadge(streakController),
    );
  }

  Widget _buildStreakBadge(StreakController controller,
      {bool isDragging = false}) {
    return Material(
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDragging
              ? Colors.purple.withOpacity(0.9)
              : Colors.purple.withOpacity(0.7),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDragging ? 0.3 : 0.2),
              blurRadius: isDragging ? 12 : 8,
              spreadRadius: isDragging ? 2 : 1,
              offset: isDragging ? const Offset(0, 4) : const Offset(0, 2),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => _showStreakInfo(context, controller),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/icons/icons8-fire.gif',
                height: 32,
                width: 32,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              Obx(() => Text(
                    '${controller.currentStreak.value}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
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
