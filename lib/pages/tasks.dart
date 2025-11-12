import 'package:flutter/material.dart';
import '../services/api.dart';
import '../widgets/task_list.dart';
import 'task_form.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({Key? key}) : super(key: key);

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  List tasks = [];
  bool loading = true;

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
    });
  }

  Future<void> _toggleTask(Map t) async {
    final id = t['id'];
    final newDone = !(t['done'] == true || t['completed'] == true);
    final updated = await Api.updateTask(id.toString(), {'done': newDone});
    if (updated != null) {
      // update local list
      setState(() {
        final idx =
            tasks.indexWhere((e) => e['id'].toString() == id.toString());
        if (idx != -1) tasks[idx] = updated;
      });
    }
  }

  Future<void> _deleteTask(Map t) async {
    final id = t['id'];
    final ok = await Api.deleteTask(id.toString());
    if (ok) {
      setState(() {
        tasks.removeWhere((e) => e['id'].toString() == id.toString());
      });
    }
  }

  void _openForm([Map? task]) async {
    final res = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => TaskFormPage(task: task)));
    if (res == true) _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mis Tareas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: TaskList(
                  tasks: tasks,
                  onToggle: _toggleTask,
                  onDelete: _deleteTask,
                  onEdit: _openForm),
            ),
    );
  }
}
