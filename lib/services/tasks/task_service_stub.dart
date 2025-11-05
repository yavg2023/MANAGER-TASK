import '../../models/tasks/task.dart';

/// Implementación stub del servicio de tareas.
///
/// Retorna valores por defecto sin persistencia real.
class TaskService {
  Future<List<Task>> loadTasks({
    String orderBy = 'createdAt',
    String orderDirection = 'DESC',
    String? titleFilter,
    bool? completedFilter,
    int? userId,
  }) async =>
      [];

  Future<Task> createTask(String title, String description, int userId) async =>
      Task(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title,
        description: description,
        userId: userId,
      );
  Future<Task?> updateTask(int id, Map<String, dynamic> changes) async => null;
  Future<bool> deleteTask(int id) async => false;
}
