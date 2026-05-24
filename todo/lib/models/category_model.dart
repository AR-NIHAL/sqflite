import 'package:flutter/material.dart';
import 'todo_model.dart'; // TodoItem মডেলটি ব্যবহারের জন্য

class CategoryItem {
  final String id;
  final String name;
  final List<TodoItem> todos;
  final Color color;

  CategoryItem({
    required this.id,
    required this.name,
    required this.todos,
    required this.color,
  });

  CategoryItem copyWith({String? name, List<TodoItem>? todos, Color? color}) {
    return CategoryItem(
      id: id,
      name: name ?? this.name,
      todos: todos ?? this.todos,
      color: color ?? this.color,
    );
  }
}