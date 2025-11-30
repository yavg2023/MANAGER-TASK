import 'package:flutter/material.dart';

class PageInit extends StatelessWidget {
  const PageInit({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        automaticallyImplyLeading: false,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 8),
            Text(
              'TASK MANAGER',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: const Text(
              'Iniciar sesión',
              style: TextStyle(
                  color: Colors.black87, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/register');
            },
            child: const Text(
              'Registrarse',
              style: TextStyle(
                  color: Colors.black87, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Bienvenido a la Aplicación de Gestión de Tareas',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Esta es tu aplicación sencilla para gestionar tareas diarias.\n'
              'Para comenzar, por favor regístrate en nuestra plataforma o inicia sesión si ya tienes una cuenta, '
              'y empieza a gestionar tus tareas.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            const Text(
              'Qué Hacemos',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'En nuestra plataforma, nos dedicamos a facilitar la vida de nuestros usuarios al proporcionar una '
              'herramienta robusta y visualmente intuitiva para la gestión de tareas. Ya seas un administrador que '
              'necesita organizar múltiples proyectos, o un usuario regular que busca mantenerse al tanto de sus tareas '
              'diarias, nuestra plataforma está diseñada para adaptarse a tus necesidades.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 40),
            const Text(
              'Servicios Destacados',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 20),
            const Wrap(
              alignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 20,
              children: [
                _ServiceCard(
                  icon: Icons.check_circle_outline,
                  title: 'Gestión Eficiente',
                  description:
                      'Administra tus tareas con facilidad y organiza tu trabajo de manera intuitiva con nuestro tablero estilo Kanban.',
                ),
                _ServiceCard(
                  icon: Icons.star_border,
                  title: 'Usabilidad Amigable',
                  description:
                      'Disfruta de una experiencia de usuario fluida y amigable, diseñada para mejorar tu productividad.',
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              'Testimonios',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 20),
            const _TestimonialCard(
              text:
                  '"Esta aplicación ha transformado la forma en que gestiono mis tareas. ¡Es muy fácil de usar y me ayuda a mantenerme organizada!"',
              author: 'Ana G.',
            ),
            const _TestimonialCard(
              text:
                  '"El tablero estilo Kanban es simplemente genial. Me permite visualizar mi flujo de trabajo de una manera muy clara."',
              author: 'Luis P.',
            ),
            const _TestimonialCard(
              text:
                  '"Me encanta la funcionalidad de colaboración. Trabajar en equipo nunca ha sido tan fácil y eficiente."',
              author: 'Marta R.',
            ),
            const SizedBox(height: 40),
            
            // NUEVO: Botón Contáctenos
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.contact_support,
                    size: 48,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '¿Necesitas ayuda?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Estamos aquí para ayudarte. Contáctanos y resolveremos tus dudas.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/contact');
                      },
                      icon: const Icon(Icons.email, color: Colors.white),
                      label: const Text(
                        'Contáctenos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// Widgets auxiliares
class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 6,
              offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: const Color(0xFF2563EB)),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final String text;
  final String author;

  const _TestimonialCard({required this.text, required this.author});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 6,
              offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Text(text,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(
            '- $author',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
