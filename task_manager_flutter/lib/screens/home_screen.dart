import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../services/theme_service.dart';
import '../services/profile_service.dart';
import '../models/user_profile.dart';
import '../utils/permission_handler.dart';
import 'today_view.dart';
import 'completed_view.dart';
import 'repeated_view.dart';
import 'settings_screen.dart';
import 'new_task_screen.dart';
import 'search_screen.dart';
import 'statistics_screen.dart';
import 'profile_screen.dart';
import 'onboarding_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final GlobalKey<TodayViewState> _todayViewKey = GlobalKey<TodayViewState>();
  final GlobalKey<CompletedViewState> _completedViewKey = GlobalKey<CompletedViewState>();
  final GlobalKey<RepeatedViewState> _repeatedViewKey = GlobalKey<RepeatedViewState>();

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
  }

  Future<void> _checkAndRequestPermissions() async {
    final notificationService = NotificationService.instance;
    final hasPermission = await notificationService.checkPermissions();
    if (!hasPermission && mounted) {
      // Show dialog to request permission
      await PermissionHandler.showPermissionDialog(context);
      // Request permission again
      await notificationService.requestPermissions();
    }
  }

  void _refreshAllViews() {
    _todayViewKey.currentState?.refresh();
    _completedViewKey.currentState?.refresh();
    _repeatedViewKey.currentState?.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TaskFlow',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatisticsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: FutureBuilder(
          future: ProfileService.instance.getProfile(),
          builder: (context, snapshot) {
            final profile = snapshot.data ?? 
              UserProfile(name: 'User', bio: 'Tap to edit your bio');
            
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                // Profile Header
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Profile Avatar
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.2),
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          profile.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            profile.bio,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Menu Items
                ListTile(
                  leading: const Icon(Icons.person_outline, color: Color(0xFF00BCD4)),
                  title: const Text('Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfileScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                
                ListTile(
                  leading: const Icon(Icons.today, color: Color(0xFF00BCD4)),
                  title: const Text('Today'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 0);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.check_circle, color: Color(0xFF00BCD4)),
                  title: const Text('Completed'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 1);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.repeat, color: Color(0xFF00BCD4)),
                  title: const Text('Repeated'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 2);
                  },
                ),
                const Divider(),
                
                // Dark Mode Toggle
                Consumer<ThemeService>(
                  builder: (context, themeService, _) {
                    return ListTile(
                      leading: Icon(
                        themeService.isDarkMode 
                          ? Icons.dark_mode 
                          : Icons.light_mode,
                        color: const Color(0xFF00BCD4),
                      ),
                      title: const Text('Dark Mode'),
                      trailing: Switch(
                        value: themeService.isDarkMode,
                        onChanged: (_) => themeService.toggleTheme(),
                        activeColor: const Color(0xFF00BCD4),
                      ),
                    );
                  },
                ),
                
                ListTile(
                  leading: const Icon(Icons.settings, color: Color(0xFF00BCD4)),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                
                // Logout
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: _showLogoutDialog,
                ),
              ],
            );
          },
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          TodayView(key: _todayViewKey),
          CompletedView(key: _completedViewKey),
          RepeatedView(key: _repeatedViewKey),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          // Refresh the view when switching tabs
          _refreshAllViews();
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Completed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.repeat),
            label: 'Repeated',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewTaskDialog(context),
        backgroundColor: const Color(0xFF00BCD4),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Task',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 6,
      ),
    );
  }

  Future<void> _showNewTaskDialog(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewTaskScreen()),
    );
    // Refresh all views when returning from new task screen
    _refreshAllViews();
  }

  Future<void> _showLogoutDialog() async {
    Navigator.pop(context); // Close drawer first
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout? This will reset the app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // Clear onboarding state to show onboarding screen again
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('hasCompletedOnboarding');
      
      // Navigate to onboarding screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }
}
