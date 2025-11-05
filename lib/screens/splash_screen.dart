import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/security/auth_provider.dart';
import '../utils/database_io.dart';
import '../utils/database_web.dart';
import '../utils/platform_helper.dart';
import '../utils/logger.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Inicializa la aplicación: almacenamiento y sesión.
  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    try {
      await _initializeStorage();
      if (!mounted) return;

      await _checkSession();
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  /// Inicializa el almacenamiento según la plataforma.
  /// En mobile/desktop: inicializa SQLite y ejecuta migraciones.
  /// En web: inicializa SharedPreferences con usuario admin por defecto.
  Future<void> _initializeStorage() async {
    if (PlatformHelper.isWeb) {
      // Web: inicializar SharedPreferences con usuario admin
      final initialized = await DatabaseWeb.initializeDatabase();
      if (!initialized) {
        AppLogger.error('Error al inicializar DatabaseWeb', null);
      }
    } else {
      // Mobile/Desktop: inicializar SQLite y migraciones
      final initialized = await DatabaseIO.initializeDatabase();
      if (!initialized) {
        AppLogger.error('Error al inicializar DatabaseIO', null);
      }
    }
  }

  /// Verifica y carga la sesión del usuario.
  Future<void> _checkSession() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await authProvider.loadCurrentUser();

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      setState(() {
        _loading = false;
      });
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: _loading
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      height: 120,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.task_alt,
                              size: 60, color: Colors.grey),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    const Text('Gestión de tareas',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Aplicación multiplataforma',
                        style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 40),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text('Verificando sesión...',
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      height: 120,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.task_alt,
                              size: 60, color: Colors.grey),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Gestión de tareas',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Aplicación multiplataforma',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: FilledButton.icon(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/login'),
                              icon: const Icon(Icons.login),
                              label: const Text(
                                'Iniciar Sesión',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/register'),
                              icon: const Icon(Icons.person_add),
                              label: const Text(
                                'Registrarse',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
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
