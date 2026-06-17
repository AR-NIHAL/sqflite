class Todo {
  final String id;
  final String title;
  final bool isCompleted;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.category = '',
    required this.createdAt,
    required this.updatedAt,
  });

  Todo copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
