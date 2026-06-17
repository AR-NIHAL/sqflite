import 'package:note_todo_app/features/todos/domain/entities/todo.dart';
import 'package:note_todo_app/features/todos/domain/repositories/todos_repository.dart';

class GetTodos {
  final TodosRepository _repository;

  GetTodos(this._repository);

  Future<List<Todo>> call() => _repository.getTodos();
}
