class Task {
  final int? id;
  final String title;
  final String description;
  final bool completed;
  final DateTime? createdAt;
  final int? userId;

  Task({
    this.id,
    required this.title,
    required this.description,
    this.completed = false,
    this.createdAt,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'completed': completed ? 1 : 0,
    };
    if (id != null) map['id'] = id;
    if (createdAt != null) {
      map['createdAt'] = createdAt!.toUtc().millisecondsSinceEpoch;
    }
    if (userId != null) map['userId'] = userId;
    return map;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    DateTime? createdAt;
    if (map['createdAt'] != null) {
      final timestamp = map['createdAt'];
      if (timestamp is int) {
        createdAt = DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true);
      }
    }

    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      completed: (map['completed'] == 1) || (map['completed'] == true),
      createdAt: createdAt,
      userId: map['userId'] as int?,
    );
  }
}
