import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/security/auth_provider.dart';
import 'backoffice/admin_dashboard_screen.dart';
import 'tasks/task_dashboard_screen.dart';

/// Pantalla home que actúa como router según el rol del usuario.
///
/// Muestra el dashboard correspondiente según el rol del usuario autenticado:
/// - Rol `user`: Dashboard de tareas (lista de tareas del usuario)
/// - Rol `admin`: Dashboard backoffice (gestión de todas las tareas de todos los usuarios)
///
/// Si el usuario no está autenticado, redirige a `/login`.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Verificar autenticación al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Verificar si hay usuario autenticado
      if (!authProvider.isAuthenticated) {
        // Redirigir a login si no está autenticado
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  /// Construye el dashboard según el rol del usuario autenticado.
  Widget _buildDashboardForRole(String? role) {
    if (role == 'user') {
      return _buildTasksDashboard();
    } else if (role == 'admin') {
      return _buildAdminDashboard();
    } else {
      // Rol desconocido o null, redirigir a login
      return const Center(
        child: Text('Rol desconocido. Redirigiendo a login...'),
      );
    }
  }

  /// Construye el dashboard de tareas para usuarios con rol 'user'.
  ///
  /// Delega toda la lógica al TaskDashboardScreen que contiene
  /// la implementación completa del dashboard.
  Widget _buildTasksDashboard() {
    return const TaskDashboardScreen();
  }

  /// Construye el dashboard backoffice para usuarios con rol 'admin'.
  ///
  /// Por ahora usa un widget placeholder. La implementación completa
  /// del dashboard backoffice se realizará en un plan futuro del módulo `backoffice`.
  Widget _buildAdminDashboard() {
    // Usar el widget AdminDashboardScreen como placeholder
    return const AdminDashboardScreen();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Verificar si usuario está autenticado
    if (!authProvider.isAuthenticated) {
      // Redirigir a login si no está autenticado (directo, no a splash)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
      // Retornar widget vacío mientras se redirige
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Obtener rol del usuario autenticado
    final role = authProvider.role;

    // Construir dashboard según rol
    return _buildDashboardForRole(role);
  }
}
