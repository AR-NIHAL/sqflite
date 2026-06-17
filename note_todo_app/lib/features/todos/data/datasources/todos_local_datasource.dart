import 'package:hive_flutter/hive_flutter.dart';
import 'package:note_todo_app/core/constants/hive_constants.dart';
import 'package:note_todo_app/features/todos/data/models/todo_model.dart';

class TodosLocalDataSource {
  Future<Box<TodoModel>> get _box async =>
      Hive.openBox<TodoModel>(HiveConstants.todosBox);

  Future<List<TodoModel>> getAll() async {
    final box = await _box;
    return box.values.toList();
  }

  Future<TodoModel?> get(String id) async {
    final box = await _box;
    return box.get(id);
  }

  Future<void> save(TodoModel todo) async {
    final box = await _box;
    await box.put(todo.id, todo);
  }

  Future<void> delete(String id) async {
    final box = await _box;
    await box.delete(id);
  }
}
