// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pantalla de inicio para administradores.
/// 
/// Estado: **Pendiente de implementación**
/// 
/// Funcionalidades planificadas:
/// - Dashboard con tabla paginada de todas las tareas (10, 25, 50 registros)
/// - Filtrado por ID, título, usuario (email) y fecha de creación
/// - Visualización de detalle completo de tareas en modal (solo lectura)
/// - Ordenamiento por fecha de creación (ascendente por defecto)
/// - Paginación a nivel de base de datos (server-side)
class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Dashboard Administrativo'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');
              Navigator.pushReplacementNamed(context, '/login');
            },
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.admin_panel_settings, size: 64, color: Color(0xFF2563EB)),
              const SizedBox(height: 20),
              const Text(
                'Dashboard Administrativo',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Gestión de todas las tareas del sistema',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.05),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estado: Pendiente de Implementación',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Funcionalidades planificadas:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    BulletPoint(text: 'Tabla paginada de todas las tareas (10, 25, 50 registros)'),
                    BulletPoint(text: 'Filtrado por ID, título, usuario (email) y fecha'),
                    BulletPoint(text: 'Visualización de detalle completo en modal (solo lectura)'),
                    BulletPoint(text: 'Ordenamiento por fecha de creación'),
                    BulletPoint(text: 'Paginación a nivel de base de datos'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('token');
                  Navigator.pushReplacementNamed(context, '/login');
                },
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar Sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget auxiliar para mostrar puntos de lista.
class BulletPoint extends StatelessWidget {
  final String text;

  const BulletPoint({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
