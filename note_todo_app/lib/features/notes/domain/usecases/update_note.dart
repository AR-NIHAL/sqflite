import 'package:note_todo_app/features/notes/domain/entities/note.dart';
import 'package:note_todo_app/features/notes/domain/repositories/notes_repository.dart';

class UpdateNote {
  final NotesRepository _repository;

  UpdateNote(this._repository);

  Future<void> call(Note note) => _repository.updateNote(note);
}
