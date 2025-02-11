import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io' show Platform; // Platform için import ekle
import 'controllers/theme_controller.dart';
import 'controllers/task_controller.dart';
import 'models/task.dart';
import 'screens/home_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'controllers/font_controller.dart';
import 'controllers/streak_controller.dart';
import 'controllers/pomodoro_settings_controller.dart';

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
  Get.put(FontController(), permanent: true);
  Get.put(StreakController(), permanent: true);
  Get.put(PomodoroSettingsController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FontController>(
      builder: (fontController) => GetMaterialApp(
        title: 'Todo Pomodoro',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purple,
            primary: const Color.fromARGB(255, 142, 114, 191),
            secondary: const Color.fromARGB(255, 55, 0, 75),
            tertiary: Colors.deepPurple,
          ),
          useMaterial3: true,
          textTheme: TextTheme(
            displayLarge: fontController.getFontStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            bodyLarge: fontController.getFontStyle(),
            bodyMedium: fontController.getFontStyle(),
            titleLarge: fontController.getFontStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.purple.shade50,
            titleTextStyle: fontController.getFontStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.purple.shade900,
            ),
          ),
        ),
        darkTheme: ThemeData.dark().copyWith(
          textTheme: TextTheme(
            displayLarge: fontController.getFontStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            bodyLarge: fontController.getFontStyle(color: Colors.white),
            bodyMedium: fontController.getFontStyle(color: Colors.white),
            titleLarge: fontController.getFontStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          appBarTheme: AppBarTheme(
            titleTextStyle: fontController.getFontStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        themeMode: Get.find<ThemeController>().themeMode,
        home: const HomeScreen(),
      ),
    );
  }
}
