import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/security/auth_provider.dart';
import '../../utils/validators/user_validator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _emailError;
  String? _passwordError;
  bool _emailTouched = false;
  bool _passwordTouched = false;

  @override
  void initState() {
    super.initState();
    // Si el usuario ya está autenticado, redirigir a su dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _validateEmail() {
    if (!_emailTouched) return;
    final validation = UserValidator.validateEmail(_email.text);
    setState(() {
      _emailError = validation.isValid ? null : validation.error;
    });
  }

  void _validatePassword() {
    if (!_passwordTouched) return;
    if (_password.text.isEmpty) {
      setState(() {
        _passwordError = 'La contraseña es requerida';
      });
    } else {
      setState(() {
        _passwordError = null;
      });
    }
  }

  Future<void> _login() async {
    // Marcar campos como tocados para mostrar errores
    setState(() {
      _emailTouched = true;
      _passwordTouched = true;
    });

    // Validar campos
    final emailValidation = UserValidator.validateEmail(_email.text);
    if (!emailValidation.isValid) {
      setState(() {
        _emailError = emailValidation.error;
      });
      return;
    }

    if (_password.text.isEmpty) {
      setState(() {
        _passwordError = 'La contraseña es requerida';
      });
      return;
    }

    // Limpiar errores si validación pasa
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.login(
      _email.text.trim(),
      _password.text,
    );

    if (!mounted) return;

    if (success) {
      // Login exitoso, redirigir a /home
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Mostrar error si existe
      if (authProvider.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Cerrar',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                authProvider.clearError();
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Iniciar sesión'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Image.asset(
                'assets/logo.png',
                height: 100,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.task_alt,
                        size: 50, color: Colors.grey),
                  );
                },
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _email,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  hintText: 'usuario@example.com',
                  prefixIcon: const Icon(Icons.email),
                  errorText: _emailError,
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onChanged: (_) {
                  if (_emailTouched) _validateEmail();
                },
                onTap: () => setState(() => _emailTouched = true),
                onSubmitted: (_) {
                  setState(() => _emailTouched = true);
                  _validateEmail();
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _password,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock),
                  errorText: _passwordError,
                ),
                obscureText: true,
                textInputAction: TextInputAction.done,
                onChanged: (_) {
                  if (_passwordTouched) _validatePassword();
                },
                onTap: () => setState(() => _passwordTouched = true),
                onSubmitted: (_) => _login(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authProvider.loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: authProvider.loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Entrar',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('¿No tienes cuenta? Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
