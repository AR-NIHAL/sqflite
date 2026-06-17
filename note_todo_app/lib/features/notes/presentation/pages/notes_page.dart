import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_todo_app/features/notes/domain/entities/note.dart';
import 'package:note_todo_app/features/notes/presentation/providers/notes_provider.dart';
import 'package:note_todo_app/features/notes/presentation/widgets/note_card.dart';
import 'package:note_todo_app/features/notes/presentation/widgets/note_form_dialog.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);

    return notesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (notes) {
        if (notes.isEmpty) {
          return const Center(child: Text('No notes yet'));
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 100),
          itemCount: notes.length,
          itemBuilder: (_, i) => NoteCard(
            note: notes[i],
            onTap: () => _editNote(context, ref, notes[i]),
            onDelete: () =>
                ref.read(notesProvider.notifier).deleteNote(notes[i].id),
          ),
        );
      },
    );
  }

  Future<void> _editNote(BuildContext context, WidgetRef ref, Note note) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => NoteFormSheet(note: note),
    );
    if (result != null) {
      await ref.read(notesProvider.notifier).updateNote(
            note.copyWith(
              title: result['title'] as String,
              body: result['body'] as String,
              color: result['color'] as int,
            ),
          );
    }
  }
}
