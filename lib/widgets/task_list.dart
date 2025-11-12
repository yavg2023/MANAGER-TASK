import 'package:flutter/material.dart';

class TaskList extends StatelessWidget {
  final List tasks;
  final Function(Map) onToggle;
  final Function(Map) onDelete;
  final Function([Map?]) onEdit;

  const TaskList({super.key, required this.tasks, required this.onToggle, required this.onDelete, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) return const Center(child: Text('No hay tareas'));
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final t = tasks[index];
        final done = t['done'] == true || t['completed'] == true;
        return Card(
          child: ListTile(
            leading: Checkbox(
              value: done,
              onChanged: (_) => onToggle(t),
            ),
            title: Text(t['title'] ?? 'Sin título'),
            subtitle: Text(t['description'] ?? ''),
            trailing: PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'edit') onEdit(t);
                if (v == 'delete') onDelete(t);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Editar')),
                const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
              ],
            ),
          ),
        );
      },
    );
  }
}
