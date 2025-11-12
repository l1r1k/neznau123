import 'package:flutter/material.dart';
import 'package:my_mpt/core/constants/app_constants.dart';
import 'package:my_mpt/presentation/screens/today_schedule_screen.dart';
import 'package:my_mpt/presentation/screens/schedule_screen.dart';
import 'package:my_mpt/presentation/screens/calls_screen.dart';
import 'package:my_mpt/presentation/screens/settings_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.collegeName,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF64B5F6),
          secondary: Color(0xFF81C784),
          tertiary: Color(0xFFF7943C),
          surface: Color(0xFF121212),
          background: Color(0xFF1C1C1C),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onTertiary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF1C1C1C),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF1E1E1E),
          indicatorColor: Colors.transparent,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                color: Colors.white,
                size: 28,
              );
            }
            return const IconThemeData(
              color: Colors.grey,
              size: 28,
              );
          }),
        ),
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TodayScheduleScreen(),
    const ScheduleScreen(),
    const CallsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Apply SafeArea only to specific screens
      body: _currentIndex == 0 || _currentIndex == 1 
        ? _screens[_currentIndex] // Schedule screens without SafeArea
        : SafeArea(child: _screens[_currentIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: const Color(0xFF1E1E1E),
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        elevation: 10,
        height: 60,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, size: 28),
            selectedIcon: Icon(Icons.home, size: 28),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined, size: 28),
            selectedIcon: Icon(Icons.calendar_today, size: 28),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined, size: 28),
            selectedIcon: Icon(Icons.notifications, size: 28),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, size: 28),
            selectedIcon: Icon(Icons.settings, size: 28),
            label: '',
          ),
        ],
      ),
    );
  }
}