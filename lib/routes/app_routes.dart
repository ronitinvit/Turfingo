import 'package:flutter/material.dart';
import '../views/screens/splash_screen.dart';
import '../views/screens/home_screen.dart';
import '../views/screens/login_screen.dart';
import '../views/screens/signup_screen.dart';
import '../views/screens/turf_details_screen.dart';
import '../views/screens/booking_screen.dart';
import '../views/screens/history_screen.dart';
import '../views/screens/profile_screen.dart';
import '../models/turf.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String turfDetails = '/turf-details';
  static const String booking = '/booking';
  static const String history = '/history';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    home: (context) => const HomeScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) => const SignupScreen(),
    booking: (context) => const BookingScreen(),
    history: (context) => const HistoryScreen(),
    profile: (context) => const ProfileScreen(),
    turfDetails: (context) {
      final turf = ModalRoute.of(context)!.settings.arguments as Turf;
      return TurfDetailsScreen(turf: turf);
    },
  };
}
