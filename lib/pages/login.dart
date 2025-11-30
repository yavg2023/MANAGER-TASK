// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import '../services/user_auth_service.dart';
import '../utils/auth_utils.dart';
import '../utils/hardcoded_users.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/pageInit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Iniciar sesión', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Correo electrónico'),
                      validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _obscure = !_obscure;
                            });
                          },
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _handleLogin,
                        child: _loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14.0),
                                child: Text('Ingresar'),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      child: const Text('Regístrate'),
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

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 1️⃣ Verificar si el correo existe entre los quemados
    final userExistsInHardcoded = HardcodedUsers.userExists(email);
    if (userExistsInHardcoded) {
      final role = HardcodedUsers.getRole(email, password);

      if (role == "admin") {
        setState(() => _loading = false);
        Navigator.pushReplacementNamed(context, "/admin-dashboard");
        return;
      }

      if (role == "user") {
        setState(() => _loading = false);
        Navigator.pushReplacementNamed(context, "/userDashboard");
        return;
      }

      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña incorrecta')),
      );
      return;
    }

    // 2️⃣ Validar con Supabase (tabla users)
    final res = await UserAuthService.login(email: email, password: password);
    setState(() => _loading = false);

    print("RESPUESTA API ===> $res");

    if (res['success'] == true) {
      final user = res['user'];
      AuthUtils.setUserId(user['id']); // <- guardamos el userId
      final homeRoute = AuthUtils.getHomeRouteForEmail(email);
      Navigator.pushReplacementNamed(context, homeRoute);
    }

    if (res["error"] == "email_not_found") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este correo no existe')),
      );
      return;
    }

    if (res["error"] == "wrong_password") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña incorrecta')),
      );
      return;
    }

    if (res["success"] == true) {
      final user = res["user"];
      final homeRoute = user["role"] == "admin" ? "/admin-dashboard" : "/userDashboard";
      Navigator.pushReplacementNamed(context, homeRoute);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Credenciales incorrectas')),
    );
  }
}
