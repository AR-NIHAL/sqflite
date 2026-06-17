import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_todo_app/features/todos/domain/entities/todo.dart';
import 'package:note_todo_app/features/todos/presentation/pages/category_todos_page.dart';
import 'package:note_todo_app/features/todos/presentation/providers/todos_provider.dart';

class TodosPage extends ConsumerWidget {
  const TodosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todosProvider);

    return todosAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (todos) {
        if (todos.isEmpty) {
          return const Center(child: Text('No todos yet'));
        }

        final grouped = _groupByCategory(todos);

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            _CategoryCard(
              title: 'All Tasks',
              count: todos.length,
              isAll: true,
              onTap: () => _openCategory(context, null),
            ),
            const SizedBox(height: 12),
            ...grouped.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CategoryCard(
                  title: entry.key,
                  count: entry.value.length,
                  onTap: () => _openCategory(context, entry.key),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Map<String, List<Todo>> _groupByCategory(List<Todo> todos) {
    final map = <String, List<Todo>>{};
    for (final t in todos) {
      final cat = t.category.isEmpty ? 'Uncategorized' : t.category;
      map.putIfAbsent(cat, () => []);
      map[cat]!.add(t);
    }
    return map;
  }

  void _openCategory(BuildContext context, String? category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryTodosPage(category: category),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final int count;
  final bool isAll;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.count,
    this.isAll = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isAll
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(4, 4),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isAll ? Colors.white : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$count task${count == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isAll
                          ? Colors.white.withValues(alpha: 0.8)
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isAll ? Colors.white : null,
            ),
          ],
        ),
      ),
    );
  }
}
