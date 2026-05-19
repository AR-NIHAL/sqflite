import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ১. গ্লোবাল স্টেট বা প্রোভাইডার তৈরি করা
// এটি আমাদের টুডু লিস্টের স্টেট এবং লজিক (Add/Delete) হ্যান্ডেল করবে
class TodoListNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    // শুরুর বা ইনিশিয়াল ডাটা
    return ['Buy groceries', 'Walk the dog', 'Finish Flutter project'];
  }

  // টুডু যোগ করার লজিক
  void addTodo(String task) {
    // রিভারপডে স্টেট সরাসরি মিউটেশান (state.add) করা যায় না।
    // নতুন একটি লিস্ট তৈরি করে স্টেট আপডেট করতে হয়।
    state = [...state, task];
  }

  // টুডু ডিলিট করার লজিক
  void deleteTodo(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i],
    ];
  }
}

// প্রোভাইডারটিকে গ্লোবালি ডিক্লেয়ার করা, যাতে যেকোনো স্ক্রিন থেকে একে ডাকা যায়
final todoListProvider = NotifierProvider<TodoListNotifier, List<String>>(() {
  return TodoListNotifier();
});

// ২. মেইন ফাংশনে ProviderScope দেওয়া বাধ্যতামূলক
void main() {
  runApp(
    const ProviderScope(
      // এটি রিভারপডের সব স্টেট ধরে রাখে
      child: MyApp(),
    ),
  );
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
      home: const TodoScreen(),
    );
  }
}

// ৩. ConsumerWidget ব্যবহার করা (StatelessWidget এর পরিবর্তে)
class TodoScreen extends ConsumerWidget {
  const TodoScreen({super.key});

  // রিভারpড স্ক্রিনে 'WidgetRef ref' নামে একটি নতুন প্যারামিটার দেয় ডাটা রিড করার জন্য
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // টুডু লিস্টের ডাটা ওয়াচ (watch) করা। ডাটা চেঞ্জ হলে এই স্ক্রিন নিজে নিজেই রিফ্রেশ হবে।
    final todoList = ref.watch(todoListProvider);
    final TextEditingController todoController = TextEditingController();

    void showAddTodoSection(BuildContext context) {
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
                      // রিভারপডের মাধ্যমে নতুন টুডু যোগ করা
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
                      // রিভারপডের মাধ্যমে নির্দিষ্ট ইনডেক্সের টুডু ডিলিট করা
                      ref.read(todoListProvider.notifier).deleteTodo(index);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddTodoSection(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
