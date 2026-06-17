import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_todo_app/features/notes/data/datasources/notes_local_datasource.dart';
import 'package:note_todo_app/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:note_todo_app/features/notes/domain/entities/note.dart';
import 'package:note_todo_app/features/notes/domain/repositories/notes_repository.dart';
import 'package:uuid/uuid.dart';

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepositoryImpl(NotesLocalDataSource());
});

final notesProvider = StateNotifierProvider<NotesNotifier, AsyncValue<List<Note>>>((ref) {
  return NotesNotifier(ref.read(notesRepositoryProvider));
});

class NotesNotifier extends StateNotifier<AsyncValue<List<Note>>> {
  final NotesRepository _repository;
  final _uuid = const Uuid();

  NotesNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      final notes = await _repository.getNotes();
      state = AsyncValue.data(notes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createNote({
    required String title,
    required String body,
    required int color,
  }) async {
    final now = DateTime.now();
    final note = Note(
      id: _uuid.v4(),
      title: title,
      body: body,
      color: color,
      createdAt: now,
      updatedAt: now,
    );
    try {
      await _repository.createNote(note);
      await _loadNotes();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateNote(Note note) async {
    final updated = note.copyWith(updatedAt: DateTime.now());
    try {
      await _repository.updateNote(updated);
      await _loadNotes();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _repository.deleteNote(id);
      await _loadNotes();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
