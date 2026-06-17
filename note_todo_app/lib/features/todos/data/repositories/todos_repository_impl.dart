import 'package:note_todo_app/features/todos/data/datasources/todos_local_datasource.dart';
import 'package:note_todo_app/features/todos/data/models/todo_model.dart';
import 'package:note_todo_app/features/todos/domain/entities/todo.dart';
import 'package:note_todo_app/features/todos/domain/repositories/todos_repository.dart';

class TodosRepositoryImpl implements TodosRepository {
  final TodosLocalDataSource _dataSource;

  TodosRepositoryImpl(this._dataSource);

  @override
  Future<List<Todo>> getTodos() async {
    final models = await _dataSource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Todo> getTodo(String id) async {
    final model = await _dataSource.get(id);
    if (model == null) throw Exception('Todo not found');
    return model.toEntity();
  }

  @override
  Future<void> createTodo(Todo todo) async {
    await _dataSource.save(TodoModel.fromEntity(todo));
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    await _dataSource.save(TodoModel.fromEntity(todo));
  }

  @override
  Future<void> deleteTodo(String id) async {
    await _dataSource.delete(id);
  }
}
