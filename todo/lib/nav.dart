import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// --- RIVERPOD STATE MANAGEMENT ---

class TodoListNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    return ['Buy groceries', 'Walk the dog', 'Finish Flutter project'];
  }

  void addTodo(String task) {
    state = [...state, task];
  }

  void deleteTodo(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i],
    ];
  }
}

final todoListProvider = NotifierProvider<TodoListNotifier, List<String>>(() {
  return TodoListNotifier();
});

// A simple provider to keep track of the active tab index (0 for Todo, 1 for Settings)
final navigationProvider = StateProvider<int>((ref) => 0);

// --- MAIN APPLICATION ---

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

// --- MAIN HOME SCREEN (WITH NAVIGATION) ---

class MainHomeScreen extends ConsumerWidget {
  const MainHomeScreen({super.key});

  // Function to show the add todo bottom sheet
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
    // Watch which index is currently selected (0 = Todo, 1 = Settings)
    final selectedIndex = ref.watch(navigationProvider);

    // List of screens to display based on the selected index
    final List<Widget> screens = [const TodoTab(), const SettingsTab()];

    return Scaffold(
      // The body dynamically changes depending on the selected index
      body: screens[selectedIndex],

      // 1. Centered Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoSection(context, ref),
        shape:
            const CircleBorder(), // Makes it perfectly round to look good in the notch
        child: const Icon(Icons.add),
      ),

      // 2. This docks the FAB exactly into the BottomAppBar notch
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 3. Custom Bottom Navigation Bar
      bottomNavigationBar: BottomAppBar(
        shape:
            const CircularNotchedRectangle(), // Creates a beautiful smooth curve around the FAB
        notchMargin: 8.0, // Space between the FAB and the navigation bar
        color: Theme.of(context).colorScheme.inversePrimary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Left Side: Todo List Button
            IconButton(
              icon: Icon(
                Icons.list_alt,
                color: selectedIndex == 0 ? Colors.deepPurple : Colors.black54,
                size: 30,
              ),
              onPressed: () => ref.read(navigationProvider.notifier).state = 0,
            ),

            const SizedBox(
              width: 40,
            ), // Creates spacing so the icons don't go under the FAB
            // Right Side: Settings Button
            IconButton(
              icon: Icon(
                Icons.settings,
                color: selectedIndex == 1 ? Colors.deepPurple : Colors.black54,
                size: 30,
              ),
              onPressed: () => ref.read(navigationProvider.notifier).state = 1,
            ),
          ],
        ),
      ),
    );
  }
}

// --- TAB 1: TODO SCREEN ---
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
                return ListTile(
                  title: Text(todoList[index]),
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

// --- TAB 2: SETTINGS SCREEN ---
class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(
        child: Text(
          'Settings Screen\nConfigure your options here.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
