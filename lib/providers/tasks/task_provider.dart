import 'package:flutter/foundation.dart';
import '../../models/tasks/task.dart';
import '../../services/tasks/task_service.dart';
import '../../exceptions/app_exception.dart';
import '../../exceptions/tasks/task_exceptions.dart';
import '../../utils/logger.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];
  bool _loading = false;
  String? _error;

  // Estado de ordenamiento
  String _orderBy = 'createdAt'; // 'title' o 'createdAt'
  String _orderDirection = 'DESC'; // 'ASC' o 'DESC'

  // Estado de filtros
  String? _titleFilter;
  bool?
      _completedFilter; // null = todas, true = completadas, false = pendientes

  // Estado de usuario
  int? _userId; // ID del usuario actual (puede ser null para admin)

  List<Task> get tasks => _tasks;
  bool get loading => _loading;
  String? get error => _error;
  bool get hasError => _error != null;

  // Getters para ordenamiento
  String get orderBy => _orderBy;
  String get orderDirection => _orderDirection;

  // Getters para filtros
  String? get titleFilter => _titleFilter;
  bool? get completedFilter => _completedFilter;

  // Getter para userId
  int? get userId => _userId;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _handleError(dynamic e) {
    if (e is AppException) {
      // AppException, TaskNotFoundException, TaskValidationException todas extienden de AppException
      _error = e.toString(); // Ya tiene el mensaje en español
    } else {
      _error =
          'Ha ocurrido un error inesperado. Por favor, inténtalo de nuevo.';
    }
    AppLogger.error('Error en TaskProvider', e);
    notifyListeners();
  }

  /// Carga las tareas desde el servicio con los filtros y ordenamiento actuales.
  ///
  /// [userId] - ID del usuario para filtrar tareas. Si se proporciona, se guarda y se usa en recargas.
  /// Si es null, carga todas las tareas (comportamiento admin).
  /// Para usuarios con rol `user`: siempre debe proporcionarse `userId`.
  /// Para usuarios con rol `admin`: `userId` puede ser null (ve todas las tareas en backoffice).
  Future<void> loadTasks({int? userId}) async {
    // Guardar userId si se proporciona
    if (userId != null) {
      _userId = userId;
    }

    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _tasks = await _taskService.loadTasks(
        orderBy: _orderBy,
        orderDirection: _orderDirection,
        titleFilter: _titleFilter,
        completedFilter: _completedFilter,
        userId: _userId,
      );
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _handleError(e);
    }
  }

  /// Establece el ordenamiento y recarga las tareas.
  ///
  /// [orderBy] - Campo por el cual ordenar: 'title' o 'createdAt'
  /// [orderDirection] - Dirección de ordenamiento: 'ASC' o 'DESC'
  void setOrdering(String orderBy, String orderDirection) {
    if (orderBy != 'title' && orderBy != 'createdAt') {
      AppLogger.error('OrderBy inválido', 'Se recibió: $orderBy');
      return;
    }
    if (orderDirection.toUpperCase() != 'ASC' &&
        orderDirection.toUpperCase() != 'DESC') {
      AppLogger.error('OrderDirection inválido', 'Se recibió: $orderDirection');
      return;
    }

    _orderBy = orderBy;
    _orderDirection = orderDirection.toUpperCase();
    notifyListeners();
    // Mantener userId actual para recargar con el mismo filtro
    loadTasks(userId: _userId);
  }

  /// Alterna la dirección de ordenamiento (ASC ↔ DESC) manteniendo el campo actual.
  void toggleOrderDirection() {
    _orderDirection = _orderDirection == 'ASC' ? 'DESC' : 'ASC';
    notifyListeners();
    loadTasks(userId: _userId);
  }

  /// Establece el filtro de título y recarga las tareas.
  ///
  /// [title] - Texto a buscar en el título (null o vacío para limpiar filtro)
  void setTitleFilter(String? title) {
    _titleFilter = title?.trim();
    if (_titleFilter != null && _titleFilter!.isEmpty) {
      _titleFilter = null;
    }
    notifyListeners();
    loadTasks(userId: _userId);
  }

  /// Establece el filtro de estado completado y recarga las tareas.
  ///
  /// [completed] - null = todas, true = completadas, false = pendientes
  void setCompletedFilter(bool? completed) {
    _completedFilter = completed;
    notifyListeners();
    loadTasks(userId: _userId);
  }

  /// Limpia todos los filtros y recarga las tareas.
  void clearFilters() {
    _titleFilter = null;
    _completedFilter = null;
    notifyListeners();
    loadTasks(userId: _userId);
  }

  /// Agrega una nueva tarea para el usuario especificado.
  ///
  /// [title] - Título de la tarea
  /// [description] - Descripción de la tarea
  /// [userId] - ID del usuario propietario (obligatorio para nuevas tareas)
  ///
  /// **Validación**: Verifica que `userId` no sea null antes de crear la tarea.
  Future<bool> addTask(String title, String description, int userId) async {
    _error = null;
    notifyListeners();
    try {
      await _taskService.createTask(title, description, userId);
      await loadTasks(userId: userId);
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  Future<bool> updateTask(int id, Map<String, dynamic> changes) async {
    _error = null;
    notifyListeners();
    try {
      // Validar que si la tarea está completada, no se permite editar otros campos
      final currentTask = _tasks.firstWhere((t) => t.id == id,
          orElse: () => throw Exception('Tarea no encontrada'));

      if (currentTask.completed) {
        // Si la tarea está completada:
        // - Si el usuario está desmarcando completed (cambiar de true a false), permitir cualquier cambio
        //   porque está "reabriendo" la tarea para edición
        // - Si el usuario mantiene completed como true, bloquear edición de otros campos
        final isUnmarkingCompleted = changes.containsKey('completed') &&
            changes['completed'] == false &&
            currentTask.completed == true;

        if (!isUnmarkingCompleted) {
          // Si no está desmarcando completed (mantiene true o no lo cambia),
          // verificar que no se modifiquen otros campos
          final otherFieldsChanged =
              changes.keys.any((key) => key != 'completed');

          if (otherFieldsChanged) {
            throw TaskValidationException(
                'No se puede editar una tarea completada. Primero debes desmarcarla como completada.');
          }
        }
        // Si está desmarcando completed, permitir cualquier cambio (incluyendo title/description)
      }

      await _taskService.updateTask(id, changes);
      await loadTasks(userId: _userId);
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  Future<bool> toggleTask(int id) async {
    _error = null;
    notifyListeners();
    try {
      final t = _tasks.firstWhere((e) => e.id == id);
      await _taskService.updateTask(id, {'completed': !t.completed});
      await loadTasks(userId: _userId);
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  Future<bool> deleteTask(int id) async {
    _error = null;
    notifyListeners();
    try {
      await _taskService.deleteTask(id);
      await loadTasks(userId: _userId);
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }
}
