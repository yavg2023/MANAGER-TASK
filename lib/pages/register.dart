import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Registro de Usuario',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),

                // Nombre completo
                _buildInputLabel('* Nombre completo'),
                _buildTextField(
                  controller: _nameController,
                  hintText: '',
                  validator: (value) => value!.isEmpty
                      ? 'Por favor ingresa tu nombre completo'
                      : null,
                ),

                const SizedBox(height: 16),

                // Correo electrónico
                _buildInputLabel('* Correo electrónico'),
                _buildTextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  hintText: '',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu correo electrónico';
                    }
                    if (!value.contains('@')) {
                      return 'Correo no válido';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Contraseña
                _buildInputLabel('* Contraseña'),
                _buildTextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  validator: (value) => value!.isEmpty
                      ? 'Por favor ingresa una contraseña'
                      : null,
                ),

                const SizedBox(height: 16),

                // Confirmar contraseña
                _buildInputLabel('* Confirmar contraseña'),
                _buildTextField(
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() => _obscureConfirm = !_obscureConfirm);
                    },
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor confirma tu contraseña';
                    }
                    if (value != _passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // Botón de registro
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Mostrar mensaje de registro exitoso
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Registro exitoso')),
                        );

                        // Esperar 2 segundos y redirigir al login
                        Future.delayed(const Duration(seconds: 2), () {
                          Navigator.pushReplacementNamed(context, '/login');
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Registrarse',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Función auxiliar para etiquetas
  Widget _buildInputLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Función auxiliar para campos de texto
  Widget _buildTextField({
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? hintText,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        suffixIcon: suffixIcon,
        fillColor: Colors.white,
        filled: true,
      ),
      validator: validator,
    );
  }
}
