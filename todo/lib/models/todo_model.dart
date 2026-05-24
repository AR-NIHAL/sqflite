class TodoItem {
  final String title;
  final bool isCompleted;

  TodoItem({required this.title, this.isCompleted = false});

  TodoItem copyWith({String? title, bool? isCompleted}) {
    return TodoItem(
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}