import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_todo_app/features/todos/domain/entities/todo.dart';
import 'package:note_todo_app/features/todos/presentation/providers/todos_provider.dart';
import 'package:note_todo_app/features/todos/presentation/widgets/todo_form_dialog.dart';
import 'package:note_todo_app/features/todos/presentation/widgets/todo_tile.dart';

class CategoryTodosPage extends ConsumerWidget {
  final String? category;

  const CategoryTodosPage({super.key, this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todosProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return todosAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (allTodos) {
        final isAll = category == null;
        final title = isAll ? 'All Tasks' : category!;
        final todos = isAll
            ? allTodos
            : allTodos.where((t) => t.category == category).toList();

        final existingCategories = allTodos
            .map((t) => t.category)
            .where((c) => c.isNotEmpty)
            .toSet()
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
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
          body: todos.isEmpty
              ? const Center(child: Text('No tasks in this category'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 100),
                  itemCount: todos.length,
                  itemBuilder: (_, i) => TodoTile(
                    todo: todos[i],
                    onToggle: () => ref
                        .read(todosProvider.notifier)
                        .toggleTodo(todos[i]),
                    onTap: () =>
                        _editTodo(context, ref, todos[i], existingCategories),
                    onDelete: () => ref
                        .read(todosProvider.notifier)
                        .deleteTodo(todos[i].id),
                  ),
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () =>
                _addTodo(context, ref, category ?? '', existingCategories),
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  Future<void> _addTodo(
    BuildContext context,
    WidgetRef ref,
    String category,
    List<String> existingCategories,
  ) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TodoFormSheet(
        existingCategories: existingCategories,
        initialCategory: category,
        hideCategory: category.isNotEmpty,
      ),
    );
    if (result != null) {
      ref.read(todosProvider.notifier).createTodo(
            title: result['title'] as String,
            category: result['category'] as String,
          );
    }
  }

  Future<void> _editTodo(
    BuildContext context,
    WidgetRef ref,
    Todo todo,
    List<String> existingCategories,
  ) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TodoFormSheet(
        todo: todo,
        existingCategories: existingCategories,
      ),
    );
    if (result != null) {
      await ref.read(todosProvider.notifier).updateTodo(
            todo.copyWith(
              title: result['title'] as String,
              category: result['category'] as String,
            ),
          );
    }
  }
}
