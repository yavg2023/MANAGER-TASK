import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/security/login_screen.dart';
import '../screens/security/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/tasks/task_detail_screen.dart';
import '../pages/task_form.dart'; // 👈 Este import está bien

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/task':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
            builder: (_) => TaskDetailScreen(task: args?['task']));
      case '/task-form':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
            builder: (_) => TaskFormPage(task: args?['task'])); 
      default:
        return MaterialPageRoute(
            builder: (_) => const Scaffold(
                body: Center(child: Text('Ruta no encontrada'))));
    }
  }
}