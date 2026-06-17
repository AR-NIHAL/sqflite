import 'package:note_todo_app/features/todos/domain/entities/todo.dart';
import 'package:note_todo_app/features/todos/domain/repositories/todos_repository.dart';

class UpdateTodo {
  final TodosRepository _repository;

  UpdateTodo(this._repository);

  Future<void> call(Todo todo) => _repository.updateTodo(todo);
}
