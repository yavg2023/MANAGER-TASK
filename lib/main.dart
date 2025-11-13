import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/login.dart';
import 'pages/dashboard.dart';
import 'pages/tasks.dart';
import 'pages/task_form.dart';
import 'services/auth_service.dart';
import 'pages/page_init.dart';
import 'pages/register.dart';
import 'pages/admin_home.dart';

void main() {
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthService>(
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'Task Manager',
        theme: ThemeData(
          primaryColor: const Color(0xFF2563EB),
          colorScheme:
              ColorScheme.fromSwatch().copyWith(secondary: const Color(0xFF10B981)),
          scaffoldBackgroundColor: const Color(0xFFF9FAFB),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2563EB),
            foregroundColor: Colors.white,
          ),
        ),
        initialRoute: '/pageInit',
        routes: {
          '/pageInit': (context) => const PageInit(),
          '/login': (context) => const LoginPage(),
          '/dashboard': (context) => const DashboardPage(),
          '/tasks': (context) => const TasksPage(),
          '/task_form': (context) => const TaskFormPage(),
          '/register': (context) => const RegisterPage(),
          '/admin-dashboard': (context) => const AdminHome(),
        },
      ),
    );
  }
}
