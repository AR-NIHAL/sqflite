import 'package:flutter/material.dart';

import '../data/note_model.dart';
import '../data/notes_db.dart';
import 'note_form_screen.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  List<NoteModel> notes = [];

  void loadNotes() {
    setState(() {
      notes = NotesDb.getAllNotes();
    });
  }

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete note?'),
          content: const Text('এই note টি delete করলে আর ফেরত আসবে না।'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    return res ?? false;
  }

  Future<void> _deleteNote(NoteModel note) async {
    final ok = await _confirmDelete(context);
    if (!ok) return;

    await NotesDb.deleteNote(note.id);
    loadNotes();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted: ${note.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          IconButton(
            tooltip: 'Reload',
            onPressed: loadNotes,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final changed = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const NoteFormScreen()),
          );

          if (changed == true) loadNotes();
        },
        child: const Icon(Icons.add),
      ),
      body: notes.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No notes yet.\nTap + to add a note.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: notes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final n = notes[index];

                return Card(
                  child: ListTile(
                    title: Text(
                      n.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      n.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () async {
                      final changed = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NoteFormScreen(note: n),
                        ),
                      );

                      if (changed == true) loadNotes();
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteNote(n),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

