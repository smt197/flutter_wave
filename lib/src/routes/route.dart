import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/HomeScreen.dart';

// Routes pour GetX
final List<GetPage> getPages = [
  GetPage(name: '/login', page: () => const LoginScreen()),
  GetPage(name: '/register', page: () => const RegisterScreen()),
  GetPage(name: '/home', page: () => const HomeScreen()),
];

// Routes pour Provider
final Map<String, WidgetBuilder> routes = {
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),
  '/home': (context) => const HomeScreen(),
};
