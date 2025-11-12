import 'package:flutter/material.dart';

typedef TaskCallback = Future<void> Function(Map task, String toColumn);

class KanbanBoard extends StatelessWidget {
  final List tasks;
  final TaskCallback onMove;

  const KanbanBoard({super.key, required this.tasks, required this.onMove});

  List<Map> _tasksFor(String column) {
    // Columns: todo, in_progress, done
    return tasks.where((t) {
      final map = Map<String, dynamic>.from(t as Map);
      final done = map['done'] == true || map['completed'] == true;
      final inProgress = map['in_progress'] == true;
      if (column == 'todo') return !done && !inProgress;
      if (column == 'in_progress') return !done && inProgress;
      if (column == 'done') return done;
      return false;
    }).cast<Map>().toList();
  }

  Widget _buildCard(BuildContext context, Map task) {
    final title = task['title'] ?? 'Sin título';
    final desc = task['description'] ?? '';
    return LongPressDraggable<Map>(
      data: task,
      feedback: Material(
        elevation: 6,
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(desc, maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
        ),
      ),
      child: Card(
        child: ListTile(
          title: Text(title),
          subtitle: Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: task['done'] == true || task['completed'] == true
              ? const Icon(Icons.check_circle, color: Colors.green)
              : null,
        ),
      ),
    );
  }

  Widget _buildColumn(BuildContext context, String column, String title, Color color) {
    final columnTasks = _tasksFor(column);
    return SizedBox(
      width: 320,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: DragTarget<Map>(
                // Use the non-deprecated callbacks that provide drag details
                onWillAcceptWithDetails: (details) => true,
                onAcceptWithDetails: (details) async {
                  final data = details.data;
                  await onMove(data, column);
                },
                builder: (context, candidateData, rejectedData) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: columnTasks.length + (candidateData.isNotEmpty ? 1 : 0),
                    itemBuilder: (ctx, idx) {
                      if (idx >= columnTasks.length) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          height: 60,
                          decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent), borderRadius: BorderRadius.circular(6)),
                          child: const Center(child: Text('Suelta para mover aquí')),
                        );
                      }
                      final t = columnTasks[idx];
                      return _buildCard(context, t);
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildColumn(context, 'todo', 'Por hacer', Colors.blueAccent),
            _buildColumn(context, 'in_progress', 'En Proceso', Colors.orangeAccent),
            _buildColumn(context, 'done', 'Hecho', Colors.green),
          ],
        ),
      ),
    );
  }
}
