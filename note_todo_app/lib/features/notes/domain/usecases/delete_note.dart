import 'package:note_todo_app/features/notes/domain/repositories/notes_repository.dart';

class DeleteNote {
  final NotesRepository _repository;

  DeleteNote(this._repository);

  Future<void> call(String id) => _repository.deleteNote(id);
}
