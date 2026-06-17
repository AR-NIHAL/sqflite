import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_todo_app/core/widgets/add_action_sheet.dart';
import 'package:note_todo_app/core/widgets/category_name_sheet.dart';
import 'package:note_todo_app/core/widgets/custom_bottom_nav.dart';
import 'package:note_todo_app/core/widgets/settings_sheet.dart';
import 'package:note_todo_app/features/notes/presentation/pages/notes_page.dart';
import 'package:note_todo_app/features/notes/presentation/providers/notes_provider.dart';
import 'package:note_todo_app/features/notes/presentation/widgets/note_form_dialog.dart';
import 'package:note_todo_app/features/todos/presentation/pages/category_todos_page.dart';
import 'package:note_todo_app/features/todos/presentation/pages/todos_page.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;

  static const _pages = <Widget>[
    NotesPage(),
    TodosPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'Notes' : 'Todos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: _showSettings,
          ),
        ],
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            border: const Border(
              bottom: BorderSide(color: Colors.black, width: 2),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(0, 3),
                blurRadius: 0,
                spreadRadius: 0,
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 88),
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomBottomNav(
              currentIndex: _currentIndex,
              onTabSelected: (i) => setState(() => _currentIndex = i),
              onAddPressed: _showAddAction,
            ),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (_) => const SettingsSheet(),
    );
  }

  void _showAddAction() {
    showModalBottomSheet<String>(
      context: context,
      builder: (_) => const AddActionSheet(),
    ).then((selection) {
      if (selection == null) return;
      if (selection == 'note') {
        _createNote();
      } else if (selection == 'todo') {
        _createTodo();
      }
    });
  }

  Future<void> _createNote() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const NoteFormSheet(),
    );
    if (result != null) {
      ref.read(notesProvider.notifier).createNote(
            title: result['title'] as String,
            body: result['body'] as String,
            color: result['color'] as int,
          );
    }
  }

  Future<void> _createTodo() async {
    final name = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const CategoryNameSheet(),
    );
    if (name != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CategoryTodosPage(category: name),
        ),
      );
    }
  }
}
