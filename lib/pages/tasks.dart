import 'package:flutter/material.dart';
import '../services/api.dart';
import '../widgets/kanban_board.dart';
import 'task_form.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  List tasks = [];
  bool loading = true;
  bool offline = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      loading = true;
    });
    final token = await Api.getStoredToken();
    if (token == null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    final data = await Api.fetchTasks(token);
    setState(() {
      tasks = data ?? [];
      loading = false;
      offline = Api.offline;
    });
  }

  // Note: Toggle and delete operations are handled via Kanban actions or
  // through the task form; keep server-side update helper `_moveTaskTo`.

  void _openForm([Map? task]) async {
    final res = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => TaskFormPage(task: task)));
    if (res == true) _loadTasks();
  }

  Future<void> _moveTaskTo(Map t, String column) async {
    final id = t['id'];
    Map<String, dynamic> body = {};
    if (column == 'done') {
      body = {'done': true, 'in_progress': false};
    } else if (column == 'in_progress') {
      body = {'in_progress': true, 'done': false};
    } else if (column == 'todo') {
      body = {'in_progress': false, 'done': false};
    }
    final updated = await Api.updateTask(id.toString(), body);
    if (updated != null) {
      setState(() {
        final idx = tasks.indexWhere((e) => e['id'].toString() == id.toString());
        if (idx != -1) tasks[idx] = updated;
      });
    } else {
      // If server update failed, attempt local update for responsiveness
      setState(() {
        final idx = tasks.indexWhere((e) => e['id'].toString() == id.toString());
        if (idx != -1) {
          tasks[idx] = {...tasks[idx], ...body};
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tareas'),
        actions: [
          if (offline)
            IconButton(
              tooltip: 'Offline - Reintentar',
              icon: const Icon(Icons.cloud_off, color: Colors.orangeAccent),
              onPressed: () => _loadTasks(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (offline)
                  MaterialBanner(
                    content: const Text('Conexión al backend fallida — usando datos en caché'),
                    backgroundColor: Colors.orange.shade100,
                    actions: [
                      TextButton(
                        onPressed: () => _loadTasks(),
                        child: const Text('Reintentar'),
                      ),
                      TextButton(
                        onPressed: () => setState(() => offline = false),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: KanbanBoard(
                      tasks: tasks,
                      onMove: (task, column) async {
                        await _moveTaskTo(task, column);
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
