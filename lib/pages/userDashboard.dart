import 'package:flutter/material.dart';
import 'package:task_manager_flutter_complete/pages/task_form.dart';
import 'package:task_manager_flutter_complete/services/api.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  List tasks = [];
  List filteredTasks = []; // ← NUEVO: Lista filtrada
  bool loading = true;

  // Filtros
  String? selectedStatus;
  String? selectedPriority;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    setState(() => loading = true);

    try {
      // Intenta cargar desde la API
      final token = await Api.getStoredToken() ?? "";
      final data = await Api.fetchTasks(token);
      
      setState(() {
        tasks = data ?? [];
        filteredTasks = tasks; // ← Inicializar filteredTasks
        loading = false;
      });
    } catch (e) {
      // Si falla la API, usa datos de ejemplo
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        tasks = [
          {
            "id": "1",
            "title": "Diseñar interfaz de usuario",
            "description": "Crear mockups de la nueva interfaz",
            "due_date": "2024-11-20",
            "status": "in_progress",
            "priority": "high",
            "responsible": "Usuario Actual",
            "email": "user@example.com",
          },
          {
            "id": "2",
            "title": "Revisar código del backend",
            "description": "Code review de las últimas funcionalidades",
            "due_date": "2024-11-19",
            "status": "pending",
            "priority": "medium",
            "responsible": "Usuario Actual",
            "email": "user@example.com",
          },
          {
            "id": "3",
            "title": "Documentar API REST",
            "description": "Actualizar documentación Swagger",
            "due_date": "2024-11-15",
            "status": "done",
            "priority": "low",
            "responsible": "Usuario Actual",
            "email": "user@example.com",
          },
          {
            "id": "4",
            "title": "Implementar validaciones",
            "description": "Agregar validaciones en formularios",
            "due_date": "2024-11-22",
            "status": "pending",
            "priority": "high",
            "responsible": "Usuario Actual",
            "email": "user@example.com",
          },
        ];
        filteredTasks = tasks; // ← Inicializar filteredTasks
        loading = false;
      });
    }
  }

  // ← NUEVO: Aplicar filtros correctamente
  void applyFilters() {
    setState(() {
      filteredTasks = tasks.where((task) {
        bool matchesStatus = selectedStatus == null || task["status"] == selectedStatus;
        bool matchesPriority = selectedPriority == null || task["priority"] == selectedPriority;
        
        return matchesStatus && matchesPriority;
      }).toList();
    });
  }

  void clearFilters() {
    setState(() {
      selectedStatus = null;
      selectedPriority = null;
      filteredTasks = tasks; // ← Restaurar todas las tareas
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calcular métricas usando filteredTasks
    final totalTasks = filteredTasks.length;
    final completedTasks = filteredTasks.where((t) => t["status"] == "done").length;
    final pendingTasks = filteredTasks.where((t) => t["status"] != "done").length;

    // Filtrar tareas por columna usando filteredTasks
    final pendingColumnTasks = filteredTasks.where((t) => t["status"] == "pending").toList();
    final inProgressTasks = filteredTasks.where((t) => t["status"] == "in_progress").toList();
    final doneTasks = filteredTasks.where((t) => t["status"] == "done").toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Dashboard de usuario",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadTasks,
            tooltip: "Recargar tareas",
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 20),
                
                // Cards de métricas
                _buildDashboardCards(totalTasks, completedTasks, pendingTasks),
                
                const SizedBox(height: 25),
                
                // Filtros
                _buildFilters(),
                
                const SizedBox(height: 15),
                
                // Botón crear tarea
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => _openCreateTask(context),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "Nueva Tarea",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Tablero Kanban
                Expanded(
                  child: _buildKanbanBoard(
                    pendingColumnTasks,
                    inProgressTasks,
                    doneTasks,
                  ),
                ),
              ],
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // TARJETAS DE MÉTRICAS
  // ---------------------------------------------------------------------------
  Widget _buildDashboardCards(int total, int completed, int pending) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _dashboardCard(
            title: "Total",
            value: total.toString(),
            color: Colors.blue,
            icon: Icons.assignment,
          ),
          _dashboardCard(
            title: "Completadas",
            value: completed.toString(),
            color: Colors.green,
            icon: Icons.check_circle,
          ),
          _dashboardCard(
            title: "Pendientes",
            value: pending.toString(),
            color: Colors.orange,
            icon: Icons.pending,
          ),
        ],
      ),
    );
  }

  Widget _dashboardCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FILTROS
  // ---------------------------------------------------------------------------
  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.filter_list, size: 18),
            const SizedBox(width: 8),
            const Text(
              "Filtros",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(width: 20),
            
            // Filtro por Estado
            _buildFilterDropdown(
              label: "Estado",
              value: selectedStatus,
              items: const [
                {"value": "done", "label": "Completada"},
                {"value": "in_progress", "label": "En Progreso"},
                {"value": "pending", "label": "Pendiente"},
              ],
              onChanged: (value) {
                setState(() {
                  selectedStatus = value;
                  applyFilters(); // ← Aplicar filtros
                });
              },
            ),
            
            const SizedBox(width: 15),
            
            // Filtro por Prioridad
            _buildFilterDropdown(
              label: "Prioridad",
              value: selectedPriority,
              items: const [
                {"value": "high", "label": "Alta"},
                {"value": "medium", "label": "Media"},
                {"value": "low", "label": "Baja"},
              ],
              onChanged: (value) {
                setState(() {
                  selectedPriority = value;
                  applyFilters(); // ← Aplicar filtros
                });
              },
            ),
            
            const Spacer(),
            
            if (selectedStatus != null || selectedPriority != null)
              TextButton(
                onPressed: clearFilters,
                child: const Text("Limpiar", style: TextStyle(fontSize: 13)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required List<Map<String, String>> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      width: 140,
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          value: value,
          isExpanded: true,
          isDense: true,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item["value"],
              child: Text(
                item["label"]!,
                style: const TextStyle(fontSize: 12),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TABLERO KANBAN
  // ---------------------------------------------------------------------------
  Widget _buildKanbanBoard(
    List pending,
    List inProgress,
    List done,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKanbanColumn(
            title: "Por Hacer",
            tasks: pending,
            color: Colors.red,
            icon: Icons.pending,
          ),
          const SizedBox(width: 15),
          _buildKanbanColumn(
            title: "En Progreso",
            tasks: inProgress,
            color: Colors.orange,
            icon: Icons.sync,
          ),
          const SizedBox(width: 15),
          _buildKanbanColumn(
            title: "Completadas",
            tasks: done,
            color: Colors.green,
            icon: Icons.check_circle,
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanColumn({
    required String title,
    required List tasks,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header de la columna
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tasks.length.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Lista de tareas
          Container(
            constraints: const BoxConstraints(maxHeight: 500),
            child: tasks.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inbox,
                            size: 48,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "No hay tareas",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return _buildTaskCard(tasks[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Map task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de la tarea
            Text(
              task["title"] ?? "Sin título",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 8),
            
            // Descripción
            if (task["description"] != null &&
                task["description"].toString().isNotEmpty)
              Text(
                task["description"],
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            
            const SizedBox(height: 12),
            
            // Fecha y prioridad
            Row(
              children: [
                // Fecha de vencimiento
                if (task["due_date"] != null &&
                    task["due_date"].toString().isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task["due_date"],
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(width: 8),
                
                // Prioridad
                _priorityChip(task["priority"] ?? "low"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _priorityChip(String priority) {
    Color color;
    IconData icon;
    String label;

    switch (priority.toLowerCase()) {
      case "high":
        color = Colors.red;
        icon = Icons.arrow_upward;
        label = "ALTA";
        break;
      case "medium":
        color = Colors.orange;
        icon = Icons.remove;
        label = "MEDIA";
        break;
      default:
        color = Colors.blue;
        icon = Icons.arrow_downward;
        label = "BAJA";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ACCIONES
  // ---------------------------------------------------------------------------
  void _openCreateTask(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TaskFormPage()),
    ).then((result) {
      // ← NUEVO: Recargar tareas después de crear/editar
      if (result == true) {
        loadTasks(); // Recarga desde la API o datos de ejemplo
      }
    });
  }
}