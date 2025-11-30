// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import '../services/tasks_insertUpdate_service.dart';
import '../utils/auth_utils.dart';

class TaskFormPage extends StatefulWidget {
  final Map? task;
  const TaskFormPage({super.key, this.task});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _dueDateCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  
  String _selectedPriority = 'media';
  String _selectedStatus = 'pendiente';
  bool _loading = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleCtrl.text = widget.task!['title'] ?? '';
      _descCtrl.text = widget.task!['description'] ?? '';
      _dueDateCtrl.text = widget.task!['due_date'] ?? '';
      _emailCtrl.text = widget.task!['email'] ?? '';
      _selectedPriority = widget.task!['priority'] ?? 'media';
      _selectedStatus = widget.task!['status'] ?? 'pendiente';
      
      if (widget.task!['due_date'] != null && widget.task!['due_date'].isNotEmpty) {
        try {
          _selectedDate = DateTime.parse(widget.task!['due_date']);
        } catch (e) {
          _selectedDate = null;
        }
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _dueDateCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.blue,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dueDateCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar que el userId esté disponible
    final userId = AuthUtils.userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se pudo obtener el usuario. Por favor inicia sesión nuevamente.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    
    final body = {
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'due_date': _dueDateCtrl.text.trim().isEmpty ? null : _dueDateCtrl.text.trim(),
      'priority': _selectedPriority,
      'status': _selectedStatus,
      'email': _emailCtrl.text.trim(),
      'user_id': userId, // Agregar el user_id obtenido de AuthUtils
    };
    
    bool ok = false;
    
    if (widget.task == null) {
      // Crear nueva tarea
      final created = await Api.createTask(body);
      ok = created != null;
    } else {
      // Actualizar tarea existente
      final id = widget.task!['id'].toString();
      final updated = await Api.updateTask(id, body);
      ok = updated != null;
    }
    
    setState(() => _loading = false);
    
    if (!mounted) return;
    
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.task == null ? 'Tarea creada exitosamente' : 'Tarea actualizada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar la tarea'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.task != null;
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          isEdit ? 'Editar Tarea' : 'Crear Tarea',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card contenedor del formulario
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      const Text(
                        'Información de la tarea',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Campo Título
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: InputDecoration(
                          labelText: 'Título *',
                          hintText: 'Ingresa el título de la tarea',
                          prefixIcon: const Icon(Icons.title),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El título es obligatorio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Campo Descripción
                      TextFormField(
                        controller: _descCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Descripción',
                          hintText: 'Describe los detalles de la tarea',
                          prefixIcon: const Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Campo Fecha de Vencimiento
                      TextFormField(
                        controller: _dueDateCtrl,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Fecha de Vencimiento',
                          hintText: 'Selecciona una fecha',
                          prefixIcon: const Icon(Icons.calendar_today),
                          suffixIcon: _dueDateCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _dueDateCtrl.clear();
                                      _selectedDate = null;
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        onTap: () => _selectDate(context),
                      ),
                      const SizedBox(height: 16),
                      
                      // Fila: Prioridad y Estado
                      Row(
                        children: [
                          // Prioridad
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Prioridad *',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedPriority,
                                      isExpanded: true,
                                      icon: const Icon(Icons.arrow_drop_down),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'alta',
                                          child: Row(
                                            children: [
                                              Icon(Icons.arrow_upward, color: Colors.red, size: 18),
                                              SizedBox(width: 8),
                                              Text('Alta'),
                                            ],
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'media',
                                          child: Row(
                                            children: [
                                              Icon(Icons.remove, color: Colors.orange, size: 18),
                                              SizedBox(width: 8),
                                              Text('Media'),
                                            ],
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'baja',
                                          child: Row(
                                            children: [
                                              Icon(Icons.arrow_downward, color: Colors.blue, size: 18),
                                              SizedBox(width: 8),
                                              Text('Baja'),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedPriority = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Estado
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Estado *',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedStatus,
                                      isExpanded: true,
                                      icon: const Icon(Icons.arrow_drop_down),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'pendiente',
                                          child: Row(
                                            children: [
                                              Icon(Icons.pending, color: Colors.red, size: 18),
                                              SizedBox(width: 8),
                                              Text('Pendiente'),
                                            ],
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'en progreso',
                                          child: Row(
                                            children: [
                                              Icon(Icons.sync, color: Colors.orange, size: 18),
                                              SizedBox(width: 8),
                                              Text('En Progreso'),
                                            ],
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'completada',
                                          child: Row(
                                            children: [
                                              Icon(Icons.check_circle, color: Colors.green, size: 18),
                                              SizedBox(width: 8),
                                              Text('Completada'),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedStatus = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
              
                      // Campo Email
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'ejemplo@correo.com',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(value)) {
                              return 'Ingresa un email válido';
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Botones de acción
                Row(
                  children: [
                    // Botón Cancelar
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _loading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.blue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Botón Guardar
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _loading ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isEdit ? 'Actualizar' : 'Crear Tarea',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}