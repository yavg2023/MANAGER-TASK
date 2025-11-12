// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import '../services/api.dart';

class TaskFormPage extends StatefulWidget {
  final Map? task;
  const TaskFormPage({Key? key, this.task}) : super(key: key);

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleCtrl.text = widget.task!['title'] ?? '';
      _descCtrl.text = widget.task!['description'] ?? '';
    }
  }

  Future<void> _save() async {
    setState(() {
      _loading = true;
    });
    final body = {'title': _titleCtrl.text.trim(), 'description': _descCtrl.text.trim()};
    bool ok = false;
    if (widget.task == null) {
      final created = await Api.createTask(body);
      ok = created != null;
    } else {
      final id = widget.task!['id'].toString();
      final updated = await Api.updateTask(id, {...body, 'done': widget.task!['done'] == true});
      ok = updated != null;
    }
    setState(() {
      _loading = false;
    });
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error guardando tarea')));
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
            TextField(controller: _titleCtrl, decoration: InputDecoration(labelText: 'Título')),
            SizedBox(height: 12),
            TextField(controller: _descCtrl, decoration: InputDecoration(labelText: 'Descripción')),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading ? CircularProgressIndicator(color: Colors.white) : Text(isEdit ? 'Actualizar' : 'Crear'),
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondary),
              ),
            )
          ],
        ),
      ),
    );
  }
}
