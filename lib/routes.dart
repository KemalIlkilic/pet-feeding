import 'package:flutter/material.dart';
import 'package:pet_feeder_app/screens/login_screen.dart';
import 'package:pet_feeder_app/screens/signup_screen.dart';
import 'package:pet_feeder_app/screens/dashboard_screen.dart';
import 'package:pet_feeder_app/screens/profile_screen.dart';
import 'package:pet_feeder_app/screens/pet_profile_screen.dart';
import 'package:pet_feeder_app/screens/schedule_screen.dart';
import 'package:pet_feeder_app/screens/manual_feed_screen.dart';
import 'package:pet_feeder_app/screens/history_screen.dart';
import 'package:pet_feeder_app/screens/settings_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String petProfile = '/pet_profile';
  static const String schedule = '/schedule';
  static const String manualFeed = '/manual_feed';
  static const String history = '/history';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case AppRoutes.petProfile:
        final petName = routeSettings.arguments as String?;
        return MaterialPageRoute(builder: (_) => PetProfileScreen(petName: petName));
      case AppRoutes.schedule:
        return MaterialPageRoute(builder: (_) => const ScheduleScreen());
      case AppRoutes.manualFeed:
        return MaterialPageRoute(builder: (_) => const ManualFeedScreen());
      case AppRoutes.history:
        return MaterialPageRoute(builder: (_) => const HistoryScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Text('No route defined for ${routeSettings.name}'),
            ),
          ),
        );
    }
  }

  // getRoutes can be kept for simpler cases or removed if generateRoute is always used
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // Using generateRoute is generally preferred when arguments might be needed
      // AppRoutes.login: (context) => const LoginScreen(),
      // AppRoutes.signup: (context) => const SignUpScreen(),
      // AppRoutes.dashboard: (context) => const DashboardScreen(),
      // AppRoutes.profile: (context) => const ProfileScreen(),
      // AppRoutes.schedule: (context) => const ScheduleScreen(),
      // AppRoutes.manualFeed: (context) => const ManualFeedScreen(),
      // AppRoutes.history: (context) => const HistoryScreen(),
      // AppRoutes.settings: (context) => const SettingsScreen(),
    };
  }
}
