import 'package:note_todo_app/features/todos/domain/entities/todo.dart';
import 'package:note_todo_app/features/todos/domain/repositories/todos_repository.dart';

class CreateTodo {
  final TodosRepository _repository;

  CreateTodo(this._repository);

  Future<void> call(Todo todo) => _repository.createTodo(todo);
}
