import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io' show Platform; // Platform için import ekle
import 'controllers/theme_controller.dart';
import 'controllers/task_controller.dart';
import 'models/task.dart';
import 'screens/home_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bildirim ayarlarını başlat
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Android 13 ve üzeri için bildirim izni iste
  if (Platform.isAndroid) {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation
        ?.requestNotificationsPermission(); // requestPermission yerine requestNotificationsPermission kullan
  }

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
