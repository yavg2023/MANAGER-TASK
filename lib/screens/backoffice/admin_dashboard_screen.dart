import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/security/auth_provider.dart';

/// Dashboard backoffice para usuarios con rol 'admin'.
///
/// Este es un placeholder temporal. La implementación completa del dashboard
/// backoffice se realizará en un plan futuro del módulo `backoffice`.
///
/// Funcionalidades futuras:
/// - Tabla paginada de todas las tareas de todos los usuarios
/// - Filtros por usuario, fecha, ID de tarea, título
/// - Visualización de detalle completo de tarea en modal
/// - Ver todas las tareas del sistema sin restricción de usuario
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return PopScope(
      // Bloquear botón "Regresar" para prevenir navegación accidental al login
      // El usuario debe usar el botón de logout explícitamente
      // En modo debug, permitir pop para evitar problemas con hot restart
      // En producción, bloquear pop para forzar uso del botón de logout
      canPop: kDebugMode,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Dashboard Backoffice'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              tooltip: 'Cerrar sesión',
            ),
          ],
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.admin_panel_settings, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Dashboard Backoffice',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'En desarrollo',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 24),
              Text(
                'Este dashboard permitirá gestionar todas las tareas\nde todos los usuarios del sistema.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 32),
              Text(
                'Funcionalidades futuras:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• Tabla paginada de todas las tareas'),
                    Text('• Filtros por usuario, fecha, ID, título'),
                    Text('• Visualización de detalle completo'),
                    Text('• Gestión administrativa completa'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
