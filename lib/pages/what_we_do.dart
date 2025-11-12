import 'package:flutter/material.dart';

class WhatWeDoPage extends StatelessWidget {
  const WhatWeDoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qué Hacemos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/pageInit'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Qué Hacemos',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'En nuestra plataforma, nos dedicamos a facilitar la vida de ' 
                  'nuestros usuarios al proporcionar una herramienta robusta y ' 
                  'visualmente intuitiva para la gestión de tareas. Ya seas un ' 
                  'administrador que necesita organizar múltiples proyectos, o ' 
                  'un usuario regular que busca mantenerse al tanto de sus ' 
                  'tareas diarias, nuestra plataforma está diseñada para ' 
                  'adaptarse a tus necesidades.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 20),

            const Text(
              'Servicios Destacados',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Servicios en forma de tarjetas
            const Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ServiceCard(
                  icon: Icons.check_circle_outline,
                  title: 'Gestión Eficiente',
                  description:
                      'Administra tus tareas con facilidad y organiza tu trabajo de manera intuitiva.',
                ),
                _ServiceCard(
                  icon: Icons.view_kanban,
                  title: 'Tablero Kanban',
                  description:
                      'Visualiza el flujo de trabajo con nuestro tablero estilo Kanban y arrastra tareas entre columnas.',
                ),
                _ServiceCard(
                  icon: Icons.group,
                  title: 'Roles Diferenciadores',
                  description:
                      'Controla permisos y responsabilidades con roles personalizados para tu equipo.',
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text(
              'Imágenes y ejemplos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            // Placeholder de imágenes en fila
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    height: 100,
                    margin: const EdgeInsets.all(4),
                    color: Colors.grey.shade200,
                    child: const Center(child: Text('Imagen 1')),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 100,
                    margin: const EdgeInsets.all(4),
                    color: Colors.grey.shade200,
                    child: const Center(child: Text('Imagen 2')),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 100,
                    margin: const EdgeInsets.all(4),
                    color: Colors.grey.shade200,
                    child: const Center(child: Text('Imagen 3')),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
            const Text(
              'Testimonios',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const _TestimonialCard(
              text:
                  '“Esta aplicación ha transformado la forma en que gestiono mis tareas. ¡Es muy fácil de usar y me ayuda a mantenerme organizada!”',
              author: 'Ana G.',
            ),
            const SizedBox(height: 8),
            const _TestimonialCard(
              text:
                  '“El tablero estilo Kanban es simplemente genial. Me permite visualizar mi flujo de trabajo de una manera muy clara.”',
              author: 'Luis P.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ServiceCard({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 36, color: Theme.of(context).primaryColor),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Text(description, style: const TextStyle(color: Colors.black54)),
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
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: const TextStyle(color: Colors.black87)),
          const SizedBox(height: 8),
          Text('- $author', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
        ],
      ),
    );
  }
}
