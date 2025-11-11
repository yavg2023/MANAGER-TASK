import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
<<<<<<< HEAD
=======
<<<<<<< HEAD
import 'theme/app_theme.dart';
import 'navigation/app_router.dart';
import 'providers/tasks/task_provider.dart';
import 'providers/security/auth_provider.dart';
import 'utils/database_io.dart'; // ✅ ruta corregida
import 'utils/platform_helper.dart';
import 'utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.info('Iniciando aplicación Task Manager...');

  bool dbReady = false;

  if (!PlatformHelper.isWeb) {
    dbReady = await DatabaseIO.initializeDatabase();
  } else {
    AppLogger.info('Plataforma web detectada — se usará SharedPreferences.');
    dbReady = true;
  }

  if (!dbReady) {
    AppLogger.error('Error crítico: No se pudo inicializar la base de datos.');
    return;
  }

  AppLogger.info('✅ Base de datos inicializada correctamente. Lanzando app...');
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gestión de tareas',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        initialRoute: '/splash',
        onGenerateRoute: AppRouter.generateRoute,
=======
>>>>>>> e8237657f030d0274a4b7f86e29cab350b7790df
import 'pages/login.dart';
import 'pages/dashboard.dart';
import 'pages/tasks.dart';
import 'pages/task_form.dart';
import 'services/auth_service.dart';
import 'pages/pageInit.dart';

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
          '/pageInit': (context) => PagInitPage(),
          '/login': (context) => LoginPage(),
          '/dashboard': (context) => DashboardPage(),
          '/tasks': (context) => TasksPage(),
          '/task_form': (context) => TaskFormPage(),
        },
<<<<<<< HEAD
=======
>>>>>>> cbe15e97e9cfd517c18122b48ef1ad78029d4720
>>>>>>> e8237657f030d0274a4b7f86e29cab350b7790df
      ),
    );
  }
}
<<<<<<< HEAD
=======
<<<<<<< HEAD


=======
>>>>>>> cbe15e97e9cfd517c18122b48ef1ad78029d4720
>>>>>>> e8237657f030d0274a4b7f86e29cab350b7790df
