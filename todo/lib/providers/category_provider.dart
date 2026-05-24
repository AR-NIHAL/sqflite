import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../models/todo_model.dart';

class CategoryListNotifier extends Notifier<List<CategoryItem>> {
  @override
  List<CategoryItem> build() {
    // শুরুর ডিফল্ট ডাটা
    return [
      CategoryItem(
        id: '1',
        name: 'Work 💼',
        color: Colors.blue.shade100,
        todos: [TodoItem(title: 'Finish Flutter project')],
      ),
      CategoryItem(
        id: '2',
        name: 'Personal 🏠',
        color: Colors.green.shade100,
        todos: [TodoItem(title: 'Walk the dog', isCompleted: true)],
      ),
    ];
  }

  // নতুন ক্যাটাগরি যোগ করার লজিক
  void addCategory(String name, Color color) {
    final newCat = CategoryItem(
      id: DateTime.now().toString(),
      name: name,
      color: color,
      todos: [],
    );
    state = [...state, newCat];
  }

  // নির্দিষ্ট ক্যাটাগরির ভেতর নতুন টুডু যোগ করা
  void addTodoToCategory(String categoryId, String todoTitle) {
    state = [
      for (final cat in state)
        if (cat.id == categoryId)
          cat.copyWith(
            todos: [
              ...cat.todos,
              TodoItem(title: todoTitle),
            ],
          )
        else
          cat,
    ];
  }

  // নির্দিষ্ট ক্যাটাগরির টুডু ডিলিট করা
  void deleteTodoFromCategory(String categoryId, int todoIndex) {
    state = [
      for (final cat in state)
        if (cat.id == categoryId)
          cat.copyWith(
            todos: [
              for (int i = 0; i < cat.todos.length; i++)
                if (i != todoIndex) cat.todos[i],
            ],
          )
        else
          cat,
    ];
  }

  // নির্দিষ্ট ক্যাটাগরির টুডু টগল (চেক/আনচেক) করা
  void toggleTodoInCategory(String categoryId, int todoIndex) {
    state = [
      for (final cat in state)
        if (cat.id == categoryId)
          cat.copyWith(
            todos: [
              for (int i = 0; i < cat.todos.length; i++)
                if (i == todoIndex)
                  cat.todos[i].copyWith(isCompleted: !cat.todos[i].isCompleted)
                else
                  cat.todos[i],
            ],
          )
        else
          cat,
    ];
  }
}

// গ্লোবাল প্রোভাইডার
final categoryProvider =
    NotifierProvider<CategoryListNotifier, List<CategoryItem>>(() {
  return CategoryListNotifier();
});