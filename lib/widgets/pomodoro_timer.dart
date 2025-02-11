import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../controllers/pomodoro_settings_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import './full_screen_timer.dart';

class PomodoroTimer extends StatelessWidget {
  const PomodoroTimer({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PomodoroSettingsController>(
      init: PomodoroSettingsController(),
      builder: (controller) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Dairesel ilerleme göstergesi
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.1),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: _buildTimerContent(context, controller),
                        ),
                        // Tam ekran butonu
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.fullscreen),
                            onPressed: () {
                              Get.to(
                                () => FullScreenTimer(
                                  child: Container(
                                    width: Get.width * 0.9,
                                    height: Get.width * 0.9,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer
                                          .withOpacity(0.1),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: _buildTimerContent(
                                          context, controller),
                                    ),
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
                ],
              ),
              const SizedBox(height: 40),
              // Kontrol butonları
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    heroTag: 'resetPomodoro',
                    onPressed: controller.reset,
                    child: const Icon(Icons.refresh),
                  ),
                  const SizedBox(width: 20),
                  FloatingActionButton.large(
                    heroTag: 'startStopPomodoro',
                    onPressed: () {
                      if (controller.isRunning.value) {
                        controller.pause();
                      } else {
                        controller.start();
                      }
                    },
                    child: Obx(() => Icon(
                          controller.isRunning.value
                              ? Icons.pause
                              : Icons.play_arrow,
                        )),
                  ),
                  const SizedBox(width: 20),
                  FloatingActionButton(
                    heroTag: 'skipPomodoro',
                    onPressed: controller.skip,
                    child: const Icon(Icons.skip_next),
                  ),
                  const SizedBox(width: 20),
                  FloatingActionButton(
                    heroTag: 'settingsPomodoro',
                    onPressed: () => _showSettingsDialog(context, controller),
                    child: const Icon(Icons.settings),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimerContent(
      BuildContext context, PomodoroSettingsController controller) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Dairesel ilerleme göstergesi
        SizedBox(
          width: 280,
          height: 280,
          child: Obx(() => CircularProgressIndicator(
                value: controller.progress,
                strokeWidth: 12,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  controller.isBreak.value
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.primary,
                ),
              )),
        ),
        // Zaman göstergesi
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => Text(
                  '${(controller.remainingSeconds.value ~/ 60).toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )),
            Obx(() => Text(
                  '${(controller.remainingSeconds.value % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                )),
            const SizedBox(height: 8),
            Obx(() => Text(
                  controller.isBreak.value ? 'Mola' : 'Çalışma',
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                )),
          ],
        ),
      ],
    );
  }

  void _showSettingsDialog(
      BuildContext context, PomodoroSettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Pomodoro Ayarları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Çalışma Süresi (dk)'),
              trailing: Obx(() => Text('${controller.workDuration.value}')),
              onTap: () => _showDurationPicker(
                context,
                controller.workDuration.value,
                (value) => controller.updateSettings(work: value),
                'Çalışma Süresi',
              ),
            ),
            ListTile(
              title: const Text('Kısa Mola (dk)'),
              trailing:
                  Obx(() => Text('${controller.shortBreakDuration.value}')),
              onTap: () => _showDurationPicker(
                context,
                controller.shortBreakDuration.value,
                (value) => controller.updateSettings(shortBreak: value),
                'Kısa Mola Süresi',
              ),
            ),
            ListTile(
              title: const Text('Uzun Mola (dk)'),
              trailing:
                  Obx(() => Text('${controller.longBreakDuration.value}')),
              onTap: () => _showDurationPicker(
                context,
                controller.longBreakDuration.value,
                (value) => controller.updateSettings(longBreak: value),
                'Uzun Mola Süresi',
              ),
            ),
            SwitchListTile(
              title: const Text('Otomatik Mola Başlat'),
              value: controller.autoStartBreaks.value,
              onChanged: (value) =>
                  controller.updateSettings(autoStartBreak: value),
            ),
            SwitchListTile(
              title: const Text('Otomatik Çalışma Başlat'),
              value: controller.autoStartPomodoros.value,
              onChanged: (value) => controller.updateSettings(autoStart: value),
            ),
            SwitchListTile(
              title: const Text('Ses'),
              value: controller.soundEnabled.value,
              onChanged: (value) => controller.updateSettings(sound: value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showDurationPicker(
    BuildContext context,
    int currentValue,
    Function(int) onChanged,
    String title,
  ) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: SizedBox(
          height: 200,
          child: ListView.builder(
            itemCount: 60,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('${index + 1} dk'),
                selected: currentValue == index + 1,
                onTap: () {
                  onChanged(index + 1);
                  Get.back();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
