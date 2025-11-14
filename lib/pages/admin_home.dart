import 'package:flutter/material.dart';
import 'package:task_manager_flutter_complete/services/api.dart';
import 'task_form.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  List tasks = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final token = await Api.getStoredToken() ?? "";
    final data = await Api.fetchTasks(token);

    setState(() {
      tasks = data ?? [];
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Usuario Administrativo",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        elevation: 2,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateTask(context),
        label: const Text("Crear Tarea"),
        icon: const Icon(Icons.add),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const SizedBox(height: 20),
          _buildDashboardCards(),
          const SizedBox(height: 25),
          Expanded(child: _buildTaskTable()),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TARJETAS ESTILO DASHBOARD (cards)
  // ---------------------------------------------------------------------------
  Widget _buildDashboardCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _dashboardCard(
            title: "Total tareas",
            value: tasks.length.toString(),
            color: Colors.blue,
          ),
          _dashboardCard(
            title: "Completadas",
            value: tasks.where((t) => t["status"] == "done").length.toString(),
            color: Colors.green,
          ),
          _dashboardCard(
            title: "Pendientes",
            value: tasks.where((t) => t["status"] != "done").length.toString(),
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _dashboardCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TABLA DE TAREAS (DataTable)
  // ---------------------------------------------------------------------------
  Widget _buildTaskTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: const [
              DataColumn(label: Text("Título")),
              DataColumn(label: Text("Estado")),
              DataColumn(label: Text("Prioridad")),
              DataColumn(label: Text("Acciones")),
            ],
            rows: tasks.map((task) {
              return DataRow(cells: [
                DataCell(Text(task["title"] ?? "")),
                DataCell(_statusChip(task["status"] ?? "")),
                DataCell(Text(task["priority"] ?? "")),
                DataCell(_actionButtons(task)),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status) {
      case "done":
        color = Colors.green;
        break;
      case "in_progress":
        color = Colors.orange;
        break;
      default:
        color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BOTONES DE ACCIÓN (editar, eliminar)
  // ---------------------------------------------------------------------------
  Widget _actionButtons(dynamic task) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () => _openEditTask(context, task),
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _confirmDelete(task["id"]),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // ACCIONES DE CRUD
  // ---------------------------------------------------------------------------
  void _openCreateTask(BuildContext context) {
    // Aquí abres tu página de crear tarea
     //Navigator.push(context, MaterialPageRoute(builder: (_) => CrearTareaPage()));
  }

  void _openEditTask(BuildContext context, dynamic task) {
    // Aquí abres tu página de edición
    // Navigator.push(context, MaterialPageRoute(builder: (_) => EditarTareaPage(task: task)));
  }

  void _confirmDelete(String id) async {
    bool ok = await Api.deleteTask(id);
    if (ok) {
      setState(() {
        tasks.removeWhere((t) => t["id"] == id);
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Tarea eliminada")));
    }
  }
}
