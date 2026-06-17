import 'package:note_todo_app/features/todos/domain/entities/todo.dart';
import 'package:note_todo_app/features/todos/domain/repositories/todos_repository.dart';

class ToggleTodo {
  final TodosRepository _repository;

  ToggleTodo(this._repository);

  Future<void> call(Todo todo) async {
    final toggled = todo.copyWith(
      isCompleted: !todo.isCompleted,
      updatedAt: DateTime.now(),
    );
    await _repository.updateTodo(toggled);
  }
}
