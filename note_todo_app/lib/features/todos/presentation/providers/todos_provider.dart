import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_todo_app/features/todos/data/datasources/todos_local_datasource.dart';
import 'package:note_todo_app/features/todos/data/repositories/todos_repository_impl.dart';
import 'package:note_todo_app/features/todos/domain/entities/todo.dart';
import 'package:note_todo_app/features/todos/domain/repositories/todos_repository.dart';
import 'package:uuid/uuid.dart';

final todosRepositoryProvider = Provider<TodosRepository>((ref) {
  return TodosRepositoryImpl(TodosLocalDataSource());
});

final todosProvider = StateNotifierProvider<TodosNotifier, AsyncValue<List<Todo>>>((ref) {
  return TodosNotifier(ref.read(todosRepositoryProvider));
});

class TodosNotifier extends StateNotifier<AsyncValue<List<Todo>>> {
  final TodosRepository _repository;
  final _uuid = const Uuid();

  TodosNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    try {
      final todos = await _repository.getTodos();
      state = AsyncValue.data(todos);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createTodo({
    required String title,
    String category = '',
  }) async {
    final now = DateTime.now();
    final todo = Todo(
      id: _uuid.v4(),
      title: title,
      isCompleted: false,
      category: category,
      createdAt: now,
      updatedAt: now,
    );
    try {
      await _repository.createTodo(todo);
      await _loadTodos();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleTodo(Todo todo) async {
    final toggled = todo.copyWith(
      isCompleted: !todo.isCompleted,
      updatedAt: DateTime.now(),
    );
    try {
      await _repository.updateTodo(toggled);
      await _loadTodos();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateTodo(Todo todo) async {
    final updated = todo.copyWith(updatedAt: DateTime.now());
    try {
      await _repository.updateTodo(updated);
      await _loadTodos();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await _repository.deleteTodo(id);
      await _loadTodos();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
