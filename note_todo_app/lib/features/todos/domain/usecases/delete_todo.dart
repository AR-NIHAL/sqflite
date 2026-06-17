import 'package:note_todo_app/features/todos/domain/repositories/todos_repository.dart';

class DeleteTodo {
  final TodosRepository _repository;

  DeleteTodo(this._repository);

  Future<void> call(String id) => _repository.deleteTodo(id);
}
