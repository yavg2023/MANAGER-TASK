import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/security/user_service.dart';
import '../../providers/security/auth_provider.dart';
import '../../utils/validators/user_validator.dart';
import '../../exceptions/app_exception.dart';
import '../../exceptions/security/auth_exceptions.dart';
import '../../utils/logger.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final UserService _userService = UserService();

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _emailTouched = false;
  bool _passwordTouched = false;
  bool _confirmPasswordTouched = false;
  bool _loading = false;

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
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    if (!_emailTouched) return;
    final validation = UserValidator.validateEmail(_emailController.text);
    setState(() {
      _emailError = validation.isValid ? null : validation.error;
    });
  }

  void _validatePassword() {
    if (!_passwordTouched) return;
    final validation = UserValidator.validatePassword(_passwordController.text);
    setState(() {
      _passwordError = validation.isValid ? null : validation.error;
    });
  }

  void _validateConfirmPassword() {
    if (!_confirmPasswordTouched) return;
    final validation = UserValidator.validatePasswordConfirmation(
      _passwordController.text,
      _confirmPasswordController.text,
    );
    setState(() {
      _confirmPasswordError = validation.isValid ? null : validation.error;
    });
  }

  Future<void> _register() async {
    // Marcar campos como tocados para mostrar errores
    setState(() {
      _emailTouched = true;
      _passwordTouched = true;
      _confirmPasswordTouched = true;
    });

    // Validar todos los campos
    final emailValidation = UserValidator.validateEmail(_emailController.text);
    final passwordValidation =
        UserValidator.validatePassword(_passwordController.text);
    final confirmValidation = UserValidator.validatePasswordConfirmation(
      _passwordController.text,
      _confirmPasswordController.text,
    );

    if (!emailValidation.isValid ||
        !passwordValidation.isValid ||
        !confirmValidation.isValid) {
      setState(() {
        _emailError = emailValidation.isValid ? null : emailValidation.error;
        _passwordError =
            passwordValidation.isValid ? null : passwordValidation.error;
        _confirmPasswordError =
            confirmValidation.isValid ? null : confirmValidation.error;
      });
      return;
    }

    // Limpiar errores si validación pasa
    setState(() {
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _loading = true;
    });

    try {
      // Crear usuario (siempre con rol 'user')
      await _userService.createUser(
        _emailController.text.trim(),
        _passwordController.text,
        role: 'user',
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Cuenta creada exitosamente. Inicia sesión para continuar.'),
          backgroundColor: Colors.green,
        ),
      );

      // Redirigir a login
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      String errorMessage =
          'No se pudo crear la cuenta. Por favor, intenta nuevamente.';

      if (e is EmailAlreadyExistsException) {
        errorMessage = e.toString();
        setState(() {
          _emailError = errorMessage;
        });
      } else if (e is InvalidEmailException || e is InvalidPasswordException) {
        errorMessage = e.toString();
      } else if (e is AppException) {
        errorMessage = e.toString();
      } else {
        AppLogger.error('Error al registrar usuario', e);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Registrarse'),
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
                controller: _emailController,
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
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  hintText: 'Mínimo 8 caracteres',
                  prefixIcon: const Icon(Icons.lock),
                  errorText: _passwordError,
                  helperText:
                      'Mínimo 8 caracteres, máximo 32. Solo números, letras y caracteres especiales: !@#\$%^&*()_+-=[]{}|;:,.<>?',
                  helperMaxLines: 2,
                ),
                obscureText: true,
                textInputAction: TextInputAction.next,
                onChanged: (_) {
                  if (_passwordTouched) _validatePassword();
                  if (_confirmPasswordTouched) _validateConfirmPassword();
                },
                onTap: () => setState(() => _passwordTouched = true),
                onSubmitted: (_) {
                  setState(() => _passwordTouched = true);
                  _validatePassword();
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirmar contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  errorText: _confirmPasswordError,
                ),
                obscureText: true,
                textInputAction: TextInputAction.done,
                onChanged: (_) {
                  if (_confirmPasswordTouched) _validateConfirmPassword();
                },
                onTap: () => setState(() => _confirmPasswordTouched = true),
                onSubmitted: (_) => _register(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Crear cuenta',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
                child: const Text('¿Ya tienes cuenta? Iniciar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
