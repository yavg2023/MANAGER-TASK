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
  List filteredTasks = [];
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
    // Simula un pequeño delay como si estuviera cargando desde API
    await Future.delayed(const Duration(milliseconds: 500));
    
    // DATOS QUEMADOS - JSON hardcodeado
    setState(() {
      tasks = [
        {
          "id": "1",
          "title": "Otra mas",
          "description": "Tarea 1",
          "due_date": "2024-08-03",
          "status": "done",
          "priority": "high",
          "responsible": "Fernando",
          "email": "",
        },
        {
          "id": "2",
          "title": "Tarea 4",
          "description": "Tarea 4",
          "due_date": "2024-09-05",
          "status": "in_progress",
          "priority": "low",
          "responsible": "Fernando",
          "email": "",
        },
        {
          "id": "3",
          "title": "Hola mundo",
          "description": "",
          "due_date": "2024-09-02",
          "status": "pending",
          "priority": "medium",
          "responsible": "xxxxxxxxxxx",
          "email": "admin@example.co",
        },
        {
          "id": "4",
          "title": "Tarea 6",
          "description": "Criterios de aceptación",
          "due_date": "",
          "status": "pending",
          "priority": "low",
          "responsible": "User 1",
          "email": "",
        },
        {
          "id": "5",
          "title": "Implementar login",
          "description": "Crear pantalla de autenticación",
          "due_date": "2024-11-20",
          "status": "in_progress",
          "priority": "high",
          "responsible": "María García",
          "email": "maria@example.com",
        },
        {
          "id": "6",
          "title": "Revisar documentación",
          "description": "Actualizar README del proyecto",
          "due_date": "2024-11-18",
          "status": "done",
          "priority": "medium",
          "responsible": "Carlos López",
          "email": "carlos@example.com",
        },
      ];
      filteredTasks = tasks;
      loading = false;
    });

    /* 
    // Código original comentado - descomenta cuando quieras usar la API real
    final token = await Api.getStoredToken() ?? "";
    final data = await Api.fetchTasks(token);
    setState(() {
      tasks = data ?? [];
      filteredTasks = tasks;
      loading = false;
    });
    */
  }

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
      filteredTasks = tasks;
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

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const SizedBox(height: 20),
          _buildDashboardCards(),
          const SizedBox(height: 25),
          _buildFilters(),
          const SizedBox(height: 15),
          // Botón de crear tarea
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _openCreateTask(context),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Crear Tarea",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: _buildTaskTable(),
            ),
          ),
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
            icon: Icons.assignment,
          ),
          _dashboardCard(
            title: "Completadas",
            value: tasks.where((t) => t["status"] == "done").length.toString(),
            color: Colors.green,
            icon: Icons.check_circle,
          ),
          _dashboardCard(
            title: "Pendientes",
            value: tasks.where((t) => t["status"] != "done").length.toString(),
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
                  applyFilters();
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
                  applyFilters();
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
          hint: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          value: value,
          isExpanded: true,
          isDense: true,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item["value"],
              child: Text(item["label"]!, style: const TextStyle(fontSize: 12)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TABLA DE TAREAS - Usando ListView en lugar de DataTable
  // ---------------------------------------------------------------------------
  Widget _buildTaskTable() {
    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.grey[50],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                children: [
                  Expanded(flex: 1, child: Text("Título", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  Expanded(flex: 2, child: Text("Descripción", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  Expanded(flex: 1, child: Text("Fecha de Vencimiento", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  Expanded(flex: 1, child: Text("Prioridad", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  Expanded(flex: 1, child: Text("Estado", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  Expanded(flex: 1, child: Text("Responsable", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  Expanded(flex: 2, child: Text("Email", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  SizedBox(width: 100, child: Text("Acciones", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                ],
              ),
            ),
            // Body con scroll
            Expanded(
              child: filteredTasks.isEmpty
                  ? Center(
                      child: Text(
                        "No se encontraron tareas con los filtros seleccionados",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  task["title"] ?? "",
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  task["description"] ?? "",
                                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  task["due_date"] ?? "",
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: _priorityChip(task["priority"] ?? ""),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: _statusChip(task["status"] ?? ""),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  task["responsible"] ?? "",
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  task["email"] ?? "",
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 100, child: _actionButtons(task)),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Status chip - versión más compacta y con ancho fijo
  Widget _statusChip(String status) {
    Color color;
    String label;
    IconData icon;
    
    switch (status) {
      case "done":
        color = Colors.green;
        label = "COMPLETADA";
        icon = Icons.check_circle;
        break;
      case "in_progress":
        color = Colors.orange;
        label = "EN PROGRESO";
        icon = Icons.sync;
        break;
      default:
        color = Colors.red;
        label = "PENDIENTE";
        icon = Icons.pending;
    }

    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  // Priority chip - versión más compacta y con ancho fijo
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
      width: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BOTONES DE ACCIÓN - Icono de editar (azul) y eliminar (rojo)
  // ---------------------------------------------------------------------------
  Widget _actionButtons(dynamic task) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
          onPressed: () => _openEditTask(context, task),
          tooltip: "Editar tarea",
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
          onPressed: () => _confirmDelete(task["id"]),
          tooltip: "Eliminar tarea",
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // ACCIONES DE CRUD
  // ---------------------------------------------------------------------------
  void _openCreateTask(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Crear tarea")),
    );

    Navigator.push(context, MaterialPageRoute(builder: (_) => TaskFormPage()));
  }

  void _openEditTask(BuildContext context, dynamic task) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Editar: ${task['title']}")),
    );
    // Navigator.push(context, MaterialPageRoute(builder: (_) => TaskForm(task: task)));
  }

  void _confirmDelete(String id) async {
    // Muestra diálogo de confirmación
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar eliminación"),
          content: const Text("¿Estás seguro de eliminar esta tarea?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        tasks.removeWhere((t) => t["id"] == id);
        applyFilters();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Tarea eliminada exitosamente"),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
    
    /* 
    // Código original para cuando uses la API real
    bool ok = await Api.deleteTask(id);
    if (ok) {
      setState(() {
        tasks.removeWhere((t) => t["id"] == id);
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Tarea eliminada")));
    }
    */
  }
}