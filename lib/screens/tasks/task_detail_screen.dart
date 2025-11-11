import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/tasks/task.dart';
import '../../providers/tasks/task_provider.dart';
import '../../providers/security/auth_provider.dart';
import '../../utils/validators/task_validator.dart';
import '../../utils/date_formatter.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task? task;
  const TaskDetailScreen({this.task, super.key});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  bool _loading = false;
  Map<String, String> _errors = {};
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _title.text = widget.task!.title;
      _desc.text = widget.task!.description;
      _isCompleted = widget.task!.completed;
    }
  }

  void _validate() {
    setState(() {
      _errors = TaskValidator.validateTask(
        title: _title.text,
        description: _desc.text,
      );
    });
  }

  bool _isValid() {
    return _errors.isEmpty;
  }

  void _save() async {
    _validate();
    if (!_isValid()) {
      return;
    }

    setState(() {
      _loading = true;
    });
    final provider = Provider.of<TaskProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Validar que el usuario tenga rol 'user' para crear tareas
    if (widget.task == null && authProvider.role != 'user') {
      setState(() {
        _loading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solo usuarios con rol user pueden crear tareas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    bool success = false;
    if (widget.task == null) {
      // Crear nueva tarea (completed por defecto es false)
      // Obtener userId del usuario autenticado (debe existir si rol es 'user')
      final userId = authProvider.currentUser?.id;
      if (userId == null) {
        setState(() {
          _loading = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No se pudo obtener el ID del usuario'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      success =
          await provider.addTask(_title.text.trim(), _desc.text.trim(), userId);
    } else {
      final changes = <String, dynamic>{
        'title': _title.text.trim(),
        'description': _desc.text.trim(),
        'completed': _isCompleted,
      };
      success = await provider.updateTask(widget.task!.id!, changes);
    }
    if (!mounted) return;
    setState(() {
      _loading = false;
    });

    if (success) {
      Navigator.pop(context, true);
    } else {
      // Mostrar error del provider
      if (provider.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Cerrar',
              onPressed: () => provider.clearError(),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.task != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar tarea' : 'Crear tarea')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _title,
              decoration: InputDecoration(
                labelText: 'Título',
                errorText: _errors['title'],
              ),
              onChanged: (_) => _validate(),
              enabled: !_isCompleted, // Deshabilitar si está completada
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _desc,
              decoration: InputDecoration(
                labelText: 'Descripción',
                errorText: _errors['description'],
              ),
              onChanged: (_) => _validate(),
              maxLines: 3,
              enabled: !_isCompleted, // Deshabilitar si está completada
            ),
            const SizedBox(height: 12),
            // Campo completed editable
            Row(
              children: [
                Checkbox(
                  value: _isCompleted,
                  onChanged: (value) {
                    setState(() {
                      _isCompleted = value ?? false;
                    });
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Completada',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            // Mensaje informativo si está completada
            if (_isCompleted) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .errorContainer
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .error
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Esta tarea está completada y no puede ser editada. Desmarca "Completada" para poder editarla.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onErrorContainer,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (widget.task?.createdAt != null) ...[
              const SizedBox(height: 16),
              // Mostrar createdAt como campo de solo lectura
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha de creación',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormatter.formatDateTime(
                                widget.task!.createdAt!),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isEdit ? 'Actualizar' : 'Crear'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
