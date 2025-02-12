import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import '../widgets/task_list.dart';
import '../widgets/pomodoro_timer.dart';
import '../widgets/add_task_dialog.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../widgets/calendar_view.dart';
import '../widgets/stopwatch_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'account_screen.dart';
import 'settings_screen.dart';
import '../controllers/font_controller.dart';
import '../widgets/streak_indicator.dart';
import '../widgets/draggable_streak_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/images/todo-logom.png'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Todo Pomodoro',
                    style: GoogleFonts.bubblegumSans(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Hesap'),
              onTap: () {
                Get.back();
                Get.to(() => const AccountScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.font_download),
              title: const Text('Yazı Tipi'),
              onTap: () {
                Get.back();
                _showFontSelectionDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Tema'),
              onTap: () {
                Get.back();
                _showThemeSelectionDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ayarlar'),
              onTap: () {
                Get.back();
                Get.to(() => const SettingsScreen());
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Hakkında'),
              onTap: () {
                Get.back();
                _showAboutDialog();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Image.asset(
                'assets/images/todo-logom.png',
                height: 32,
              ),
            ),
            const Flexible(
              child: Text(
                'Todo Pomodoro',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          GetBuilder<ThemeController>(
            builder: (controller) => IconButton(
              icon: Icon(controller.themeIcon),
              tooltip: controller.themeText,
              onPressed: () => controller.toggleTheme(),
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: const [
              TaskList(),
              CalendarView(),
              StopwatchView(),
              PomodoroTimer(),
            ],
          ),
          const Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 20, bottom: 100),
              child: DraggableStreakIndicator(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Görevler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Takvim',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Kronometre',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.av_timer),
            label: 'Pomodoro',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Get.dialog(const AddTaskDialog());
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showFontSelectionDialog() {
    final FontController fontController = Get.find();
    Get.dialog(
      AlertDialog(
        title: const Text('Yazı Tipi Seç'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                'BubblegumSans',
                style: GoogleFonts.bubblegumSans(),
              ),
              trailing: fontController.currentFontName == 'BubblegumSans'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                fontController.setFont(0);
                Get.back();
              },
            ),
            ListTile(
              title: Text(
                'ComicNeue',
                style: GoogleFonts.comicNeue(),
              ),
              trailing: fontController.currentFontName == 'ComicNeue'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                fontController.setFont(1);
                Get.back();
              },
            ),
            ListTile(
              title: Text(
                'Comfortaa',
                style: GoogleFonts.comfortaa(),
              ),
              trailing: fontController.currentFontName == 'Comfortaa'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                fontController.setFont(2);
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeSelectionDialog() {
    final ThemeController themeController = Get.find();
    Get.dialog(
      AlertDialog(
        title: const Text('Tema Seç'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.brightness_auto),
              title: const Text('Sistem'),
              onTap: () {
                themeController.setThemeMode(ThemeMode.system);
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.brightness_7),
              title: const Text('Açık'),
              onTap: () {
                themeController.setThemeMode(ThemeMode.light);
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.brightness_4),
              title: const Text('Koyu'),
              onTap: () {
                themeController.setThemeMode(ThemeMode.dark);
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Hakkında'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Todo Pomodoro'),
            Text('Versiyon 1.0.0'),
            SizedBox(height: 8),
            Text('Görev yönetimi ve pomodoro zamanlayıcısı'),
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
}
