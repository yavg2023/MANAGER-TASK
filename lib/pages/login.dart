// Minimal, clean login page to avoid syntax/parsing issues
// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import '../services/api.dart';
import '../utils/auth_utils.dart';

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
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;
                          final res = await Api.login(_emailController.text, _passwordController.text);
                          if (!mounted) return;
                          if (res != null && res['token'] != null) {
                            // Navegar según el rol del usuario
                            final homeRoute = AuthUtils.getHomeRouteForEmail(_emailController.text);
                            Navigator.pushReplacementNamed(context, homeRoute);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Credenciales incorrectas')));
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14.0),
                          child: Text('Ingresar'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(onPressed: () => Navigator.pushNamed(context, '/register'), child: const Text('Regístrate')),
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

