import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import '../widgets/task_list.dart';
import '../widgets/pomodoro_timer.dart';
import '../widgets/add_task_dialog.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../widgets/calendar_view.dart';
import '../widgets/stopwatch_view.dart';

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
      appBar: AppBar(
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Image.asset(
                'assets/images/todo-logom.png',
                height: 46,
              ),
            ),
            const Text('Todo Pomodoro'),
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
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          TaskList(),
          CalendarView(),
          StopwatchView(),
          PomodoroTimer(),
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
}
