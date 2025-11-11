import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/tasks/task_provider.dart';
import '../../providers/security/auth_provider.dart';
import '../../models/tasks/task.dart';

/// Dashboard de tareas para usuarios con rol 'user'.
///
/// Muestra la lista de tareas del usuario con funcionalidades de:
/// - Filtrado por título y estado completado
/// - Ordenamiento por fecha o título (ASC/DESC)
/// - Crear, editar, eliminar y marcar tareas como completadas
class TaskDashboardScreen extends StatefulWidget {
  const TaskDashboardScreen({super.key});

  @override
  State<TaskDashboardScreen> createState() => _TaskDashboardScreenState();
}

class _TaskDashboardScreenState extends State<TaskDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _filtersVisible = true; // Visible por defecto

  @override
  void initState() {
    super.initState();
    // Cargar tareas para el usuario autenticado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      // Obtener userId del usuario autenticado (solo para rol 'user')
      final role = authProvider.role;
      if (role == 'user') {
        final userId = authProvider.currentUser?.id;
        if (userId != null) {
          taskProvider.loadTasks(userId: userId);
        }
      } else {
        // Para admin, no cargar tareas aquí (lo hace backoffice)
        taskProvider.loadTasks();
      }

      // Inicializar campo de búsqueda con valor actual del provider
      _searchController.text = taskProvider.titleFilter ?? '';
    });
  }

  void _showErrorIfAny(BuildContext context, TaskProvider provider) {
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

  /// Muestra un diálogo de confirmación antes de eliminar una tarea.
  ///
  /// Si el usuario confirma, ejecuta la eliminación a través del provider.
  Future<void> _confirmDelete(BuildContext context, Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text(
              '¿Está seguro de que desea eliminar la tarea "${task.title}"? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      final provider = Provider.of<TaskProvider>(context, listen: false);
      final success = await provider.deleteTask(task.id!);
      if (!success && provider.hasError) {
        // El error se mostrará automáticamente en el próximo frame
      }
    }
  }

  /// Maneja el logout del usuario.
  ///
  /// Muestra un diálogo de confirmación y luego ejecuta el logout,
  /// redirigiendo a `/login` después de completar.
  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Está seguro de que desea cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();

      if (context.mounted) {
        // Redirigir a login después de logout (directo, el usuario ya sabe qué hacer)
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.tasks;

    // Detectar errores después del primer frame solo si hay error
    if (taskProvider.hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && taskProvider.hasError) {
          _showErrorIfAny(context, taskProvider);
        }
      });
    }

    return PopScope(
      // Bloquear botón "Regresar" para prevenir navegación accidental al login
      // El usuario debe usar el botón de logout explícitamente
      // En modo debug, permitir pop para evitar problemas con hot restart
      // En producción, bloquear pop para forzar uso del botón de logout
      canPop: kDebugMode,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Mis Tareas'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _handleLogout(context),
              tooltip: 'Cerrar sesión',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/task'),
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            // Botón para mostrar/ocultar filtros
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filtros',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  IconButton(
                    icon: Icon(_filtersVisible
                        ? Icons.expand_less
                        : Icons.expand_more),
                    onPressed: () {
                      setState(() {
                        _filtersVisible = !_filtersVisible;
                      });
                    },
                    tooltip:
                        _filtersVisible ? 'Ocultar filtros' : 'Mostrar filtros',
                  ),
                ],
              ),
            ),
            // Barra de filtros y ordenamiento (colapsable)
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: _filtersVisible
                  ? _buildFiltersAndSorting(context, taskProvider)
                  : const SizedBox.shrink(),
            ),
            // Lista de tareas
            Expanded(
              child: taskProvider.loading
                  ? const Center(child: CircularProgressIndicator())
                  : tasks.isEmpty
                      ? const Center(child: Text('No hay tareas'))
                      : ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final Task t = tasks[index];
                            return Card(
                              child: ListTile(
                                leading: Checkbox(
                                  value: t.completed,
                                  onChanged: (_) async {
                                    final success =
                                        await taskProvider.toggleTask(t.id!);
                                    if (!success && taskProvider.hasError) {
                                      // El error se mostrará automáticamente en el próximo frame
                                    }
                                  },
                                ),
                                title: Text(t.title),
                                subtitle: Text(t.description),
                                onTap: () {
                                  Navigator.pushNamed(context, '/task',
                                      arguments: {'task': t});
                                },
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  onPressed: () => _confirmDelete(context, t),
                                  tooltip: 'Eliminar tarea',
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la barra de filtros y ordenamiento.
  Widget _buildFiltersAndSorting(BuildContext context, TaskProvider provider) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Fila 1: Campo de búsqueda por título
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por título...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: provider.titleFilter != null &&
                      provider.titleFilter!.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        provider.setTitleFilter(null);
                      },
                      tooltip: 'Limpiar búsqueda',
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            onChanged: (value) => provider.setTitleFilter(value),
            controller: _searchController,
          ),
          const SizedBox(height: 12),
          // Fila 2: Filtro por estado completado (SegmentedButton) - expandido
          SegmentedButton<bool?>(
            segments: const [
              ButtonSegment<bool?>(
                value: null,
                label: Text('Todas'),
                icon: Icon(Icons.list, size: 18),
              ),
              ButtonSegment<bool?>(
                value: false,
                label: Text('Pendientes'),
                icon: Icon(Icons.pending, size: 18),
              ),
              ButtonSegment<bool?>(
                value: true,
                label: Text('Completadas'),
                icon: Icon(Icons.check_circle, size: 18),
              ),
            ],
            selected: {provider.completedFilter},
            onSelectionChanged: (Set<bool?> newSelection) {
              provider.setCompletedFilter(
                  newSelection.first); // Selecciona el primero (único valor)
            },
          ),
          const SizedBox(height: 12),
          // Fila 3: Ordenamiento (SegmentedButton) y dirección (ASC/DESC) al lado
          Row(
            children: [
              // Control de campo de ordenamiento
              Expanded(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment<String>(
                      value: 'createdAt',
                      label: Text('Fecha'),
                      icon: Icon(Icons.calendar_today, size: 18),
                    ),
                    ButtonSegment<String>(
                      value: 'title',
                      label: Text('Título'),
                      icon: Icon(Icons.sort_by_alpha, size: 18),
                    ),
                  ],
                  selected: {provider.orderBy},
                  onSelectionChanged: (Set<String> newSelection) {
                    provider.setOrdering(
                        newSelection.first, provider.orderDirection);
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Botón para cambiar dirección de ordenamiento (ASC/DESC)
              IconButton(
                icon: Icon(provider.orderDirection == 'ASC'
                    ? Icons.arrow_upward
                    : Icons.arrow_downward),
                onPressed: () => provider.toggleOrderDirection(),
                tooltip: provider.orderDirection == 'ASC'
                    ? 'Orden ascendente'
                    : 'Orden descendente',
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Fila 4: Botón limpiar filtros
          if (provider.titleFilter != null || provider.completedFilter != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.filter_alt_off, size: 18),
                  label: const Text('Limpiar filtros'),
                  onPressed: () {
                    _searchController.clear();
                    provider.clearFilters();
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
