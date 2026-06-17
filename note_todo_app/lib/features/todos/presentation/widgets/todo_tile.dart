import 'package:flutter/material.dart';
import 'package:note_todo_app/features/todos/domain/entities/todo.dart';

class TodoTile extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TodoTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: isDark ? Colors.white : Colors.black,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: ListTile(
          leading: Checkbox(
            value: todo.isCompleted,
            onChanged: (_) => onToggle(),
            side: BorderSide(
              color: isDark ? Colors.white : Colors.black,
              width: 1.5,
            ),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
              color: todo.isCompleted
                  ? (isDark ? Colors.white54 : Colors.black54)
                  : null,
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            onPressed: onDelete,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
