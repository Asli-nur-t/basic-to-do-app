import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../controllers/streak_controller.dart';
import 'package:flutter/services.dart';

class DraggableStreakIndicator extends StatefulWidget {
  const DraggableStreakIndicator({super.key});

  @override
  State<DraggableStreakIndicator> createState() =>
      _DraggableStreakIndicatorState();
}

class _DraggableStreakIndicatorState extends State<DraggableStreakIndicator> {
  // Varsayılan başlangıç pozisyonu
  Offset position = const Offset(20, 80);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return GetBuilder<StreakController>(
      builder: (controller) {
        return Stack(
          children: [
            Positioned(
              left: position.dx,
              top: position.dy,
              child: Draggable(
                feedback: _buildStreakIndicator(controller, context),
                childWhenDragging: Container(),
                onDragEnd: (details) {
                  // Ekran sınırları içinde kalmasını sağla
                  setState(() {
                    position = Offset(
                      details.offset.dx.clamp(0, screenSize.width - 100),
                      details.offset.dy.clamp(0, screenSize.height - 100),
                    );
                  });
                },
                child: _buildStreakIndicator(controller, context),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStreakIndicator(
      StreakController controller, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/icons/icons8-fire.gif',
            height: 24,
            width: 24,
          ),
          const SizedBox(width: 8),
          Text(
            '${controller.currentStreak}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
