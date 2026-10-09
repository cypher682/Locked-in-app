import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'features/auth/presentation/screens/welcome_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/email_login_screen.dart';
import 'features/auth/presentation/screens/signup_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/goals/presentation/screens/goals_list_screen.dart';
import 'features/goals/presentation/screens/create_goal_screen.dart';
import 'features/goals/presentation/screens/goal_detail_screen.dart';
import 'features/checkins/presentation/screens/checkins_list_screen.dart';
import 'features/checkins/presentation/screens/create_checkin_screen.dart';
import 'features/checkins/presentation/screens/checkin_detail_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/profile/presentation/screens/edit_profile_screen.dart';
import 'features/profile/presentation/screens/user_profile_screen.dart';
import 'features/friends/presentation/screens/friends_list_screen.dart';
import 'features/friends/presentation/screens/add_friend_screen.dart';
import 'features/feed/presentation/screens/activity_feed_screen.dart';
import 'features/gamification/presentation/screens/leaderboard_screen.dart';
import 'features/gamification/presentation/screens/achievements_screen.dart';
import 'features/settings/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp(
      title: 'LockIn',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/login-email': (context) => const EmailLoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/goals': (context) => const GoalsListScreen(),
        '/goals/create': (context) => const CreateGoalScreen(),
        '/checkins': (context) => const CheckinsListScreen(),
        '/checkins/create': (context) => const CreateCheckinScreen(),
        
        // Profile Routes (Phase 4)
        '/profile': (context) => const ProfileScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        
        // Friend Routes (Phase 4)
        '/friends': (context) => const FriendsListScreen(),
        '/add-friend': (context) => const AddFriendScreen(),
        
        // Feed Route (Phase 4B)
        '/feed': (context) => const ActivityFeedScreen(),
        
        // Gamification Routes (Phase 5)
        '/leaderboard': (context) => const LeaderboardScreen(),
        '/achievements': (context) => const AchievementsScreen(),
        
        // Settings Route (Phase 7)
        '/settings': (context) => const SettingsScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle dynamic routes
        if (settings.name?.startsWith('/goals/detail') == true) {
          final goalId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => GoalDetailScreen(goalId: goalId),
          );
        } else if (settings.name?.startsWith('/checkins/detail') == true) {
          final checkinId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => CheckinDetailScreen(checkinId: checkinId),
          );
        } else if (settings.name == '/user-profile') {
          final userId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => UserProfileScreen(userId: userId),
          );
        }
        return null;
      },
    );
  }
}
