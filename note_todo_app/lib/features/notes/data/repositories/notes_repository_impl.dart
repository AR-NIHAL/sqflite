import 'package:note_todo_app/features/notes/data/datasources/notes_local_datasource.dart';
import 'package:note_todo_app/features/notes/data/models/note_model.dart';
import 'package:note_todo_app/features/notes/domain/entities/note.dart';
import 'package:note_todo_app/features/notes/domain/repositories/notes_repository.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDataSource _dataSource;

  NotesRepositoryImpl(this._dataSource);

  @override
  Future<List<Note>> getNotes() async {
    final models = await _dataSource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Note> getNote(String id) async {
    final model = await _dataSource.get(id);
    if (model == null) throw Exception('Note not found');
    return model.toEntity();
  }

  @override
  Future<void> createNote(Note note) async {
    await _dataSource.save(NoteModel.fromEntity(note));
  }

  @override
  Future<void> updateNote(Note note) async {
    await _dataSource.save(NoteModel.fromEntity(note));
  }

  @override
  Future<void> deleteNote(String id) async {
    await _dataSource.delete(id);
  }
}
