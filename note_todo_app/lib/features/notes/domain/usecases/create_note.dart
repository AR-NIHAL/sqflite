import 'package:note_todo_app/features/notes/domain/entities/note.dart';
import 'package:note_todo_app/features/notes/domain/repositories/notes_repository.dart';

class CreateNote {
  final NotesRepository _repository;

  CreateNote(this._repository);

  Future<void> call(Note note) => _repository.createNote(note);
}
