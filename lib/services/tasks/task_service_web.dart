import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/tasks/task.dart';
import '../../exceptions/app_exception.dart';
import '../../exceptions/tasks/task_exceptions.dart';
import '../../utils/validators/task_validator.dart';
import '../../utils/logger.dart';

/// Implementación del servicio de tareas para plataforma web.
///
/// Utiliza SharedPreferences para persistencia de datos.
class TaskService {
  static const _key = 'tasks_v1';

  /// Carga las tareas desde SharedPreferences con opciones de ordenamiento y filtrado.
  ///
  /// [orderBy] - Campo por el cual ordenar: 'title' o 'createdAt' (default: 'createdAt')
  /// [orderDirection] - Dirección de ordenamiento: 'ASC' o 'DESC' (default: 'DESC')
  /// [titleFilter] - Filtro de búsqueda por título (case-insensitive)
  /// [completedFilter] - Filtro por estado completado: null = todas, true = completadas, false = pendientes
  /// [userId] - Filtro por usuario: si se proporciona, solo carga tareas de ese usuario; si es null, carga todas (comportamiento admin)
  Future<List<Task>> loadTasks({
    String orderBy = 'createdAt',
    String orderDirection = 'DESC',
    String? titleFilter,
    bool? completedFilter,
    int? userId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = prefs.getString(_key);
      if (s == null) return [];

      final List decoded = json.decode(s) as List;
      var tasks = decoded
          .map((e) => Task.fromMap(Map<String, dynamic>.from(e)))
          .toList();

      // Aplicar filtros
      // Filtro por título (case-insensitive)
      if (titleFilter != null && titleFilter.trim().isNotEmpty) {
        final filterLower = titleFilter.trim().toLowerCase();
        tasks = tasks.where((task) {
          return task.title.toLowerCase().contains(filterLower);
        }).toList();
      }

      // Filtro por estado completado
      if (completedFilter != null) {
        tasks =
            tasks.where((task) => task.completed == completedFilter).toList();
      }

      // Filtro por userId (si se proporciona)
      if (userId != null) {
        tasks = tasks.where((task) => task.userId == userId).toList();
      }

      // Aplicar ordenamiento
      // Validar orderBy (solo 'title' o 'createdAt' son válidos)
      final validOrderBy = orderBy == 'title' ? 'title' : 'createdAt';
      // Validar orderDirection (solo 'ASC' o 'DESC' son válidos)
      final isAsc = orderDirection.toUpperCase() == 'ASC';

      tasks.sort((a, b) {
        int comparison;
        if (validOrderBy == 'title') {
          // Ordenamiento por título (case-insensitive)
          comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
        } else {
          // Ordenamiento por createdAt
          final aDate = a.createdAt ?? DateTime(1970);
          final bDate = b.createdAt ?? DateTime(1970);
          comparison = aDate.compareTo(bDate);
        }
        return isAsc ? comparison : -comparison;
      });

      AppLogger.info(
          'Cargando tareas: orderBy=$validOrderBy $orderDirection, titleFilter=${titleFilter ?? "null"}, completedFilter=$completedFilter, userId=${userId ?? "null"}, resultado=${tasks.length} tareas');

      return tasks;
    } catch (e) {
      if (e is AppException) rethrow;
      AppLogger.error('Error al cargar tareas desde SharedPreferences', e);
      throw AppException(
          'No se pudieron cargar las tareas. Por favor, intenta nuevamente.');
    }
  }

  Future<Task> createTask(String title, String description, int userId) async {
    // Validar antes de intentar crear
    final errors =
        TaskValidator.validateTask(title: title, description: description);
    if (errors.isNotEmpty) {
      throw TaskValidationException(errors.values.first);
    }

    try {
      final tasks = await loadTasks();
      final id = DateTime.now().millisecondsSinceEpoch;
      // Generar createdAt en UTC antes de crear
      final createdAt = DateTime.now().toUtc();
      final task = Task(
        id: id,
        title: title.trim(),
        description: description.trim(),
        completed: false,
        createdAt: createdAt,
        userId: userId,
      );
      AppLogger.info('Tarea creada con id=$id para usuario userId=$userId');
      final list = tasks.map((t) => t.toMap()).toList();
      list.insert(0, task.toMap());
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(_key, json.encode(list));
      return task;
    } catch (e) {
      if (e is AppException) rethrow;
      AppLogger.error('Error al crear tarea en SharedPreferences', e);
      throw AppException(
          'No se pudo crear la tarea. Por favor, intenta nuevamente.');
    }
  }

  Future<Task?> updateTask(int id, Map<String, dynamic> changes) async {
    // Validar ID
    final idValidation = TaskValidator.validateId(id);
    if (!idValidation.isValid) {
      throw TaskValidationException(
          idValidation.error ?? 'ID de tarea inválido');
    }

    // Validar campos si están presentes
    if (changes.containsKey('title') || changes.containsKey('description')) {
      final errors = TaskValidator.validateTask(
        title: changes['title']?.toString(),
        description: changes['description']?.toString(),
      );
      if (errors.isNotEmpty) {
        throw TaskValidationException(errors.values.first);
      }
    }

    // Asegurar que createdAt NO se modifica (es inmutable después de creación)
    // Eliminar createdAt de changes si está presente (no debe actualizarse)
    changes.remove('createdAt');

    try {
      final tasks = await loadTasks();
      final idx = tasks.indexWhere((t) => t.id == id);
      if (idx == -1) {
        throw TaskNotFoundException(id);
      }
      final current = tasks[idx];

      // Validar que si la tarea está completada, no se permite editar otros campos
      if (current.completed) {
        // Si la tarea está completada:
        // - Si el usuario está desmarcando completed (cambiar de true a false), permitir cualquier cambio
        //   porque está "reabriendo" la tarea para edición
        // - Si el usuario mantiene completed como true, bloquear edición de otros campos
        final isUnmarkingCompleted = changes.containsKey('completed') &&
            changes['completed'] == false &&
            current.completed == true;

        if (!isUnmarkingCompleted) {
          // Si no está desmarcando completed (mantiene true o no lo cambia),
          // verificar que no se modifiquen otros campos
          final otherFieldsChanged =
              changes.keys.any((key) => key != 'completed');

          if (otherFieldsChanged) {
            AppLogger.error('Intento de editar tarea completada',
                'Tarea ID $id está completada y se intentó modificar campos distintos a completed');
            throw TaskValidationException(
                'No se puede editar una tarea completada. Primero debes desmarcarla como completada.');
          }
        }
        // Si está desmarcando completed, permitir cualquier cambio (incluyendo title/description)
      }
      final updated = Task(
        id: current.id,
        title: changes['title']?.toString().trim() ?? current.title,
        description:
            changes['description']?.toString().trim() ?? current.description,
        completed: changes['completed'] ?? current.completed,
        createdAt: current.createdAt, // Preservar createdAt (no se modifica)
        userId: current.userId, // Preservar userId (no se modifica)
      );
      tasks[idx] = updated;
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(_key, json.encode(tasks.map((t) => t.toMap()).toList()));
      return updated;
    } catch (e) {
      if (e is AppException) rethrow;
      AppLogger.error('Error al actualizar tarea en SharedPreferences', e);
      throw AppException(
          'No se pudo actualizar la tarea. Por favor, intenta nuevamente.');
    }
  }

  Future<bool> deleteTask(int id) async {
    // Validar ID
    final idValidation = TaskValidator.validateId(id);
    if (!idValidation.isValid) {
      throw TaskValidationException(
          idValidation.error ?? 'ID de tarea inválido');
    }

    try {
      final tasks = await loadTasks();
      final newTasks = tasks.where((t) => t.id != id).toList();
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(
          _key, json.encode(newTasks.map((t) => t.toMap()).toList()));
      return newTasks.length < tasks.length;
    } catch (e) {
      if (e is AppException) rethrow;
      AppLogger.error('Error al eliminar tarea en SharedPreferences', e);
      throw AppException(
          'No se pudo eliminar la tarea. Por favor, intenta nuevamente.');
    }
  }
}
