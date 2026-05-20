import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// --- ১. টুডু আইটেমের কাস্টম মডেল ---
class TodoItem {
  final String title;
  final bool isCompleted;

  TodoItem({required this.title, this.isCompleted = false});

  TodoItem copyWith({String? title, bool? isCompleted}) {
    return TodoItem(
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

// --- ২. রিভারপড স্টেটNotifier ---
class TodoListNotifier extends Notifier<List<TodoItem>> {
  @override
  List<TodoItem> build() {
    return [
      TodoItem(title: 'Buy groceries'),
      TodoItem(title: 'Walk the dog', isCompleted: true),
      TodoItem(title: 'Finish Flutter project'),
    ];
  }

  void addTodo(String taskTitle) {
    state = [...state, TodoItem(title: taskTitle)];
  }

  void deleteTodo(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i],
    ];
  }

  void toggleTodo(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          state[i].copyWith(isCompleted: !state[i].isCompleted)
        else
          state[i],
    ];
  }
}

final todoListProvider = NotifierProvider<TodoListNotifier, List<TodoItem>>(() {
  return TodoListNotifier();
});

final navigationProvider = StateProvider<int>((ref) => 0);

// --- মেইন অ্যাপ্লিকেশন ---
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends ConsumerWidget {
  const MainHomeScreen({super.key});

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
                'Add New Task',
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
                    ref
                        .read(todoListProvider.notifier)
                        .addTodo(todoController.text.trim());
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
    final selectedIndex = ref.watch(navigationProvider);
    final List<Widget> screens = [const TodoTab(), const SettingsTab()];

    return Scaffold(
      body: screens[selectedIndex],

      // --- ফ্লোটিং অ্যাকশন বাটন (সাদা ব্যাকগ্রাউন্ড + কালো বর্ডার) ---
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoSection(context, ref),
        backgroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(
          side: BorderSide(color: Colors.black, width: 2.0), // কালো আউটলাইন
        ),
        child: const Icon(
          Icons.add,
          color: Colors.black,
          size: 28,
        ), // প্লাস আইকন কালো
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // --- বটম নেভিগেশন বার (সাদা ব্যাকগ্রাউন্ড + কাস্টম টপ বর্ডার) ---
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.black,
              width: 2.0,
            ), // বারের উপরের কালো আউটলাইন
          ),
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          color: Colors.white, // ব্যাকগ্রাউন্ড সাদা করা হলো
          elevation: 0, // কাস্টম বর্ডারের কারণে ডিফল্ট শ্যাডো ০ করা হলো
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(
                  Icons.list_alt,
                  color: selectedIndex == 0
                      ? Colors.black
                      : Colors.black38, // একটিভ হলে গাঢ় কালো
                  size: 30,
                ),
                onPressed: () =>
                    ref.read(navigationProvider.notifier).state = 0,
              ),
              const SizedBox(
                width: 40,
              ), // মাঝখানের গ্যাপ যেন FAB এর নিচে না পড়ে
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: selectedIndex == 1 ? Colors.black : Colors.black38,
                  size: 30,
                ),
                onPressed: () =>
                    ref.read(navigationProvider.notifier).state = 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- টুডু ট্যাব ---
class TodoTab extends ConsumerWidget {
  const TodoTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoList = ref.watch(todoListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Riverpod Todo')),
      body: todoList.isEmpty
          ? const Center(child: Text('No tasks yet!'))
          : ListView.builder(
              itemCount: todoList.length,
              itemBuilder: (context, index) {
                final item = todoList[index];

                return ListTile(
                  leading: IconButton(
                    icon: Icon(
                      item.isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: item.isCompleted ? Colors.green : Colors.grey,
                    ),
                    onPressed: () {
                      ref.read(todoListProvider.notifier).toggleTodo(index);
                    },
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      decoration: item.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: item.isCompleted ? Colors.grey : Colors.black,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      ref.read(todoListProvider.notifier).deleteTodo(index);
                    },
                  ),
                );
              },
            ),
    );
  }
}

// --- সেটিংস ট্যাব ---
class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(
        child: Text('Settings Screen', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
