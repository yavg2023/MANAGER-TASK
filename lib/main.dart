import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/login.dart';
import 'pages/dashboard.dart';
import 'pages/tasks.dart';
import 'pages/task_form.dart';
import 'services/auth_service.dart';
import 'pages/pageInit.dart';
import 'pages/register.dart';

void main() {
  runApp(TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthService>(
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'Task Manager',
        theme: ThemeData(
          primaryColor: Color(0xFF2563EB),
          colorScheme:
              ColorScheme.fromSwatch().copyWith(secondary: Color(0xFF10B981)),
          scaffoldBackgroundColor: Color(0xFFF9FAFB),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF2563EB),
            foregroundColor: Colors.white,
          ),
        ),
        initialRoute: '/pageInit',
        routes: {
          '/pageInit': (context) => const PageInit(),
          '/login': (context) => const LoginPage(),
          '/dashboard': (context) => DashboardPage(),
          '/tasks': (context) => TasksPage(),
          '/task_form': (context) => TaskFormPage(),
          '/register': (context) => const RegisterPage(),
        },
      ),
    );
  }
}
