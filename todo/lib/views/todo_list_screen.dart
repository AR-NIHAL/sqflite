import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_provider.dart';

class TodoListScreen extends ConsumerWidget {
  final String categoryId;
  const TodoListScreen({super.key, required this.categoryId});

  void _showAddTodoSection(BuildContext context, WidgetRef ref) {
    final TextEditingController todoController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add Task to Category',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: todoController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'What needs to be done?',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (todoController.text.trim().isNotEmpty) {
                    ref.read(categoryProvider.notifier).addTodoToCategory(
                          categoryId,
                          todoController.text.trim(),
                        );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add Task'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryProvider);
    
    // ক্যাটাগরিটি ডিলিট হয়ে গেলে যেন ক্রাশ না করে সেজন্য safely হ্যান্ডেল করা হয়েছে
    final currentCategory = categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => categories.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(currentCategory.name),
        backgroundColor: currentCategory.color,
      ),
      body: currentCategory.todos.isEmpty
          ? const Center(child: Text('No tasks in this category!'))
          : ListView.builder(
              itemCount: currentCategory.todos.length,
              itemBuilder: (context, index) {
                final todo = currentCategory.todos[index];
                return ListTile(
                  leading: IconButton(
                    icon: Icon(
                      todo.isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: todo.isCompleted ? Colors.green : Colors.grey,
                    ),
                    onPressed: () {
                      ref
                          .read(categoryProvider.notifier)
                          .toggleTodoInCategory(categoryId, index);
                    },
                  ),
                  title: Text(
                    todo.title,
                    style: TextStyle(
                      decoration: todo.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: todo.isCompleted ? Colors.grey : Colors.black,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      ref
                          .read(categoryProvider.notifier)
                          .deleteTodoFromCategory(categoryId, index);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoSection(context, ref),
        backgroundColor: Colors.white,
        shape: const CircleBorder(
          side: BorderSide(color: Colors.black, width: 1.5),
        ),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}