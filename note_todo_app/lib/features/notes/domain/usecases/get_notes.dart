import 'package:note_todo_app/features/notes/domain/entities/note.dart';
import 'package:note_todo_app/features/notes/domain/repositories/notes_repository.dart';

class GetNotes {
  final NotesRepository _repository;

  GetNotes(this._repository);

  Future<List<Note>> call() => _repository.getNotes();
}
