import '../../models/tasks/task.dart';
import '../../utils/database_io.dart';
import '../../exceptions/app_exception.dart';
import '../../exceptions/tasks/task_exceptions.dart';
import '../../utils/validators/task_validator.dart';
import '../../utils/logger.dart';

/// Implementación del servicio de tareas para plataformas IO (desktop y móvil).
///
/// Utiliza SQLite a través de DatabaseIO para persistencia de datos.
class TaskService {
  /// Carga las tareas desde la base de datos con opciones de ordenamiento y filtrado.
  ///
  /// [orderBy] - Campo por el cual ordenar: 'title' o 'createdAt' (default: 'createdAt')
  /// [orderDirection] - Dirección de ordenamiento: 'ASC' o 'DESC' (default: 'DESC')
  /// [titleFilter] - Filtro de búsqueda por título (case-insensitive, LIKE)
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
      return await DatabaseIO.withDatabase((db) async {
        // Construir WHERE clause dinámicamente
        final whereClauses = <String>[];
        final whereArgs = <Object?>[];

        // Filtro por título (case-insensitive usando LOWER)
        if (titleFilter != null && titleFilter.trim().isNotEmpty) {
          whereClauses.add('LOWER(title) LIKE LOWER(?)');
          whereArgs.add('%${titleFilter.trim()}%');
        }

        // Filtro por estado completado
        if (completedFilter != null) {
          whereClauses.add('completed = ?');
          whereArgs.add(completedFilter ? 1 : 0);
        }

        // Filtro por userId (si se proporciona)
        if (userId != null) {
          whereClauses.add('userId = ?');
          whereArgs.add(userId);
        }

        final where =
            whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

        // Construir ORDER BY clause
        // Validar orderBy (solo 'title' o 'createdAt' son válidos)
        // Para título, usar LOWER() para ordenamiento case-insensitive
        final validOrderBy = orderBy == 'title' ? 'LOWER(title)' : 'createdAt';
        // Validar orderDirection (solo 'ASC' o 'DESC' son válidos)
        final validOrderDirection =
            orderDirection.toUpperCase() == 'ASC' ? 'ASC' : 'DESC';

        final orderByClause = '$validOrderBy $validOrderDirection';

        AppLogger.info(
            'Cargando tareas: orderBy=$orderByClause, titleFilter=${titleFilter ?? "null"}, completedFilter=$completedFilter, userId=${userId ?? "null"}');

        final res = await db.query(
          'tasks',
          where: where,
          whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
          orderBy: orderByClause,
        );
        return res.map((r) => Task.fromMap(r)).toList();
      });
    } catch (e) {
      if (e is AppException) rethrow;
      AppLogger.error('Error al cargar tareas desde base de datos', e);
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
      return await DatabaseIO.withDatabase((db) async {
        // Generar createdAt en UTC antes de insertar
        final createdAt = DateTime.now().toUtc();
        final createdAtMillis = createdAt.millisecondsSinceEpoch;

        final id = await db.insert(
          'tasks',
          {
            'title': title.trim(),
            'description': description.trim(),
            'completed': 0,
            'createdAt': createdAtMillis,
            'userId': userId,
          },
        );
        AppLogger.info('Tarea creada con id=$id para usuario userId=$userId');
        return Task(
          id: id,
          title: title.trim(),
          description: description.trim(),
          completed: false,
          createdAt: createdAt,
          userId: userId,
        );
      });
    } catch (e) {
      // Si ya es una excepción personalizada, re-lanzarla
      if (e is AppException) rethrow;
      // Loggear error técnico
      AppLogger.error('Error al crear tarea en base de datos', e);
      // Envolver error de BD en AppException con mensaje amigable
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
      return await DatabaseIO.withDatabase((db) async {
        final row = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
        if (row.isEmpty) {
          throw TaskNotFoundException(id);
        }

        final current = Task.fromMap(row.first);

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

        await db.update(
          'tasks',
          updated.toMap(),
          where: 'id = ?',
          whereArgs: [id],
        );
        return updated;
      });
    } catch (e) {
      if (e is AppException) rethrow;
      AppLogger.error('Error al actualizar tarea en base de datos', e);
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
      return await DatabaseIO.withDatabase((db) async {
        final count =
            await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
        return count > 0;
      });
    } catch (e) {
      if (e is AppException) rethrow;
      AppLogger.error('Error al eliminar tarea en base de datos', e);
      throw AppException(
          'No se pudo eliminar la tarea. Por favor, intenta nuevamente.');
    }
  }
}
