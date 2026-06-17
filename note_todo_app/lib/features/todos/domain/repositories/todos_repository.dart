import 'package:note_todo_app/features/todos/domain/entities/todo.dart';

abstract class TodosRepository {
  Future<List<Todo>> getTodos();
  Future<Todo> getTodo(String id);
  Future<void> createTodo(Todo todo);
  Future<void> updateTodo(Todo todo);
  Future<void> deleteTodo(String id);
}
