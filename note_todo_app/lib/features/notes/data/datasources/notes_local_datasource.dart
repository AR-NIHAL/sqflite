import 'package:hive_flutter/hive_flutter.dart';
import 'package:note_todo_app/core/constants/hive_constants.dart';
import 'package:note_todo_app/features/notes/data/models/note_model.dart';

class NotesLocalDataSource {
  Future<Box<NoteModel>> get _box async =>
      Hive.openBox<NoteModel>(HiveConstants.notesBox);

  Future<List<NoteModel>> getAll() async {
    final box = await _box;
    return box.values.toList();
  }

  Future<NoteModel?> get(String id) async {
    final box = await _box;
    return box.get(id);
  }

  Future<void> save(NoteModel note) async {
    final box = await _box;
    await box.put(note.id, note);
  }

  Future<void> delete(String id) async {
    final box = await _box;
    await box.delete(id);
  }
}
