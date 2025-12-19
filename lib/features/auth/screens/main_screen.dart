import 'package:flutter/material.dart';
import 'package:prahar/core/theme/theme.dart';
import 'package:prahar/features/calendar/screens/calendar_screen.dart';
import 'package:prahar/features/dashboard/screens/dashboard_screen.dart';
import 'package:prahar/features/fitness/screens/fitness_dashboard.dart';
import 'package:prahar/features/tracking/screens/habit_tracker_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prahar/features/prep/screens/prep_screen.dart';
import 'package:prahar/features/tracking/screens/study_timer_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
    _checkActiveTimerAndNavigate();
  }

  void _checkActiveTimerAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final isTimerActive = prefs.getBool('isTimerActive') ?? false;

    if (isTimerActive && mounted) {
      final startTimeString = prefs.getString('timerStartTime');
      final previouslyElapsedMillis = prefs.getInt('timerPreviouslyElapsed');
      final subject = prefs.getString('timerSubject');

      if (startTimeString != null) {
        final startTime = DateTime.parse(startTimeString);
        final previouslyElapsed = Duration(milliseconds: previouslyElapsedMillis ?? 0);
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => StudyTimerScreen(
                  restoredStartTime: startTime,
                  restoredPreviouslyElapsed: previouslyElapsed,
                  restoredSubject: subject,
                ),
              ),
            );
          }
        });
      }
    }
  }

  void _requestNotificationPermission() async {
    PermissionStatus status = await Permission.notification.request();
    if (status.isDenied) {
      print("Notification permission was denied.");
    }
  }

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    PrepScreen(),
    HabitTrackerScreen(),
    FitnessDashboard(),
    CalendarScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _previousIndex = _selectedIndex;
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final safeIndex = _selectedIndex >= _widgetOptions.length ? 0 : _selectedIndex;
    final isMovingRight = _selectedIndex > _previousIndex;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (Widget child, Animation<double> animation) {
          final offsetAnimation = Tween<Offset>(
            begin: Offset(isMovingRight ? 0.15 : -0.15, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ));
          
          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey<int>(safeIndex),
          child: _widgetOptions[safeIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              activeIcon: Icon(Icons.dashboard),
              label: 'Command',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined),
              activeIcon: Icon(Icons.school),
              label: 'Intel',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.military_tech_outlined),
              activeIcon: Icon(Icons.military_tech),
              label: 'Daily Ops',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_martial_arts_outlined),
              activeIcon: Icon(Icons.sports_martial_arts),
              label: 'Combat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_note_outlined),
              activeIcon: Icon(Icons.event_note),
              label: 'Mission',
            ),
          ],
          currentIndex: safeIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          unselectedItemColor: Colors.grey[600],
          selectedItemColor: kCommandGold,
          backgroundColor: Colors.white,
          elevation: 0,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          selectedFontSize: 11,
          unselectedFontSize: 10,
        ),
      ),
    );
  }
}
