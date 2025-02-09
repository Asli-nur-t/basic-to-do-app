import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'controllers/theme_controller.dart';
import 'controllers/task_controller.dart';
import 'models/task.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Adaptörleri kaydet
  Hive.registerAdapter(TaskTypeAdapter());
  Hive.registerAdapter(TaskAdapter());

  // Box'ları aç
  await Hive.openBox('settings');
  await Hive.openBox<Task>('tasks');

  // Controller'ları başlat
  Get.put(ThemeController(), permanent: true);
  Get.put(TaskController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Todo Pomodoro',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: Get.find<ThemeController>().themeMode,
      home: const HomeScreen(),
    );
  }
}
