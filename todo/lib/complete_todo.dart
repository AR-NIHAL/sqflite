import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// --- ১. টুডু আইটেমের কাস্টম মডেল ---
// এখন প্রতিটি টুডু-র একটি নাম (title) এবং সেটি শেষ হয়েছে কি না (isCompleted) তার রেকর্ড থাকবে
class TodoItem {
  final String title;
  final bool isCompleted;

  TodoItem({required this.title, this.isCompleted = false});

  // রিভারপডে স্টেট কপি করার জন্য এই মেথডটি ব্যবহার করা ভালো অভ্যাস
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
      TodoItem(
        title: 'Walk the dog',
        isCompleted: true,
      ), // এটি আগে থেকেই কমপ্লিট
      TodoItem(title: 'Finish Flutter project'),
    ];
  }

  // নতুন টুডু যোগ করার লজিক
  void addTodo(String taskTitle) {
    state = [...state, TodoItem(title: taskTitle)];
  }

  // টুডু ডিলিট করার লজিক
  void deleteTodo(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i],
    ];
  }

  // --- টাস্ক কমপ্লিট বা আন-কমপ্লিট করার আসল লজিক ---
  void toggleTodo(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          // শুধু নির্দিষ্ট ইনডেক্সের আইটেমটির true কে false অথবা false কে true করে দেওয়া
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoSection(context, ref),
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Theme.of(context).colorScheme.inversePrimary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.list_alt,
                color: selectedIndex == 0 ? Colors.deepPurple : Colors.black54,
                size: 30,
              ),
              onPressed: () => ref.read(navigationProvider.notifier).state = 0,
            ),
            const SizedBox(width: 40),
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

// --- টুডু ট্যাব (যেখানে চেক করার লজিক দেওয়া হয়েছে) ---
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
                final item = todoList[index]; // একটি নির্দিষ্ট টুডু আইটেম

                return ListTile(
                  // ১. বাম পাশে চেক বক্স বা গোল বাটন
                  leading: IconButton(
                    icon: Icon(
                      item.isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: item.isCompleted ? Colors.green : Colors.grey,
                    ),
                    onPressed: () {
                      // এখানে ক্লিক করলে টাস্কটি কমপ্লিট বা আন-কমপ্লিট হবে
                      ref.read(todoListProvider.notifier).toggleTodo(index);
                    },
                  ),
                  // ২. টেক্সটের মাঝখানে দাগ দেওয়ার আসল ডিজাইন লজিক
                  title: Text(
                    item.title,
                    style: TextStyle(
                      // যদি কমপ্লিট হয় তবে TextDecoration.lineThrough (মাঝখানে দাগ) হবে, নাহলে কোনো দাগ থাকবে না (none)
                      decoration: item.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      // কমপ্লিট হলে লেখাটি একটু হালকা রঙের (grey) হয়ে যাবে
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
