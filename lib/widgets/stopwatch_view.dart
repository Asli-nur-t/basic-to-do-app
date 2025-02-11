import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../controllers/task_controller.dart';
import '../models/task.dart';
import '../widgets/add_task_dialog.dart';
import '../controllers/stopwatch_controller.dart';
import './full_screen_timer.dart';

class StopwatchView extends StatelessWidget {
  const StopwatchView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StopwatchController>(
      init: StopwatchController(),
      builder: (controller) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Büyük saat göstergesi
              Container(
                width: 300,
                height: 300,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Center(child: _buildTimerContent(context, controller)),
                    // Tam ekran butonu sağ üst köşede
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.fullscreen),
                        onPressed: () {
                          Get.to(
                            () => FullScreenTimer(
                              child: Container(
                                width: Get.width * 0.9,
                                padding: const EdgeInsets.all(40),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                    child: _buildTimerContent(
                                        context, controller,
                                        isFullScreen: true)),
                              ),
                            ),
                            fullscreenDialog: true,
                            transition: Transition.zoom,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Kontrol butonları - merkeze hizalı
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        heroTag: 'reset',
                        onPressed: controller.reset,
                        child: const Icon(Icons.refresh),
                      ),
                      const SizedBox(width: 20),
                      FloatingActionButton.large(
                        heroTag: 'startStop',
                        onPressed: controller.isRunning
                            ? controller.stop
                            : controller.start,
                        child: Icon(
                          controller.isRunning ? Icons.pause : Icons.play_arrow,
                        ),
                      ),
                      const SizedBox(width: 20),
                      FloatingActionButton(
                        heroTag: 'lap',
                        onPressed: controller.isRunning ? controller.lap : null,
                        child: const Icon(Icons.flag),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Tur zamanları listesi
              if (controller.laps.isNotEmpty) ...[
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.laps.length,
                    itemBuilder: (context, index) {
                      final reversedIndex = controller.laps.length - 1 - index;
                      final lap = controller.laps[reversedIndex];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('${reversedIndex + 1}'),
                        ),
                        title: Text(
                          lap,
                          style: const TextStyle(fontSize: 18),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimerContent(
      BuildContext context, StopwatchController controller,
      {bool isFullScreen = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Kullanılabilir alanın boyutuna göre font büyüklüğünü ayarla
        final maxWidth = constraints.maxWidth;
        final digitSize =
            isFullScreen ? maxWidth * 0.4 : maxWidth * 0.25; // Rakamlar için
        final secondsSize =
            isFullScreen ? maxWidth * 0.25 : maxWidth * 0.15; // Saniyeler için

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => Text(
                  '${controller.hours.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: digitSize,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    height: 1.1, // Satır yüksekliğini azalt
                  ),
                )),
            Obx(() => Text(
                  '${controller.minutes.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: digitSize,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    height: 1.1,
                  ),
                )),
            Obx(() => Text(
                  '${controller.seconds.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: secondsSize,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.secondary,
                    height: 1.1,
                  ),
                )),
          ],
        );
      },
    );
  }
}
