import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive_flutter/hive_flutter.dart';

// গ্লোবাল বক্সের নাম (যেমন আপনার ডায়েরির নাম)
const String todoBoxName = 'my_todo_box';

// --- ১. রিভারপড স্টেটNotifier (উইথ হাইভ) ---
class TodoListNotifier extends Notifier<List<Map<String, dynamic>>> {
  // এই বক্সটি থেকেই আমরা ডাটা রিড এবং রাইট করব
  late Box _myBox;

  @override
  List<Map<String, dynamic>> build() {
    // হাইভ বক্সটি মেমোরি থেকে ধরে আনা
    _myBox = Hive.box(todoBoxName);

    // বক্সে আগে থেকে কোনো ডাটা সেভ করা থাকলে তা নিয়ে আসা, না থাকলে খালি লিস্ট দেখানো
    final dynamic savedTodos = _myBox.get('todos');

    if (savedTodos != null) {
      // হাইভের ডাটাকে কাস্টম লিস্ট ফরম্যাটে রূপান্তর
      return List<Map<String, dynamic>>.from(
        (savedTodos as List).map((item) => Map<String, dynamic>.from(item)),
      );
    }

    // একদম প্রথমবার অ্যাপ ওপেন করলে ডিফল্ট ডাটা
    return [
      {'title': 'Buy groceries', 'isCompleted': false},
      {'title': 'Walk the dog', 'isCompleted': true},
    ];
  }

  // ডাটাবেসে চিরস্থায়ীভাবে সেভ করার প্রাইভেট ফাংশন (The 20% Logic)
  void _saveToHive() {
    _myBox.put(
      'todos',
      state,
    ); // 'todos' চাবির (Key) আন্ডারে পুরো লিস্টটি সেভ হয়ে যাবে
  }

  // নতুন টুডু যোগ করা
  void addTodo(String taskTitle) {
    state = [
      ...state,
      {'title': taskTitle, 'isCompleted': false},
    ];
    _saveToHive(); // সেভ করা হলো
  }

  // টুডু ডিলিট করা
  void deleteTodo(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i],
    ];
    _saveToHive(); // সেভ করা হলো
  }

  // টাস্ক কমপ্লিট বা আন-কমপ্লিট করা
  void toggleTodo(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          {
            'title': state[i]['title'],
            'isCompleted': !(state[i]['isCompleted'] as bool),
          }
        else
          state[i],
    ];
    _saveToHive(); // সেভ করা হলো
  }
}

// প্রোভাইডার ডিক্লেয়ারেশন
final todoListProvider =
    NotifierProvider<TodoListNotifier, List<Map<String, dynamic>>>(() {
      return TodoListNotifier();
    });

final navigationProvider = StateProvider<int>((ref) => 0);

// --- ২. মেইন ফাংশন (এখানে হাইভ ইনিশিয়ালের কাজ করা হয়েছে) ---
void main() async {
  // নিশ্চিত করা যে ফ্ল্যাটার উইজেট ইঞ্জিন পুরোপুরি রেডি
  WidgetsFlutterBinding.ensureInitialized();

  // হাইভ চালু করা (Initialize)
  await Hive.initFlutter();

  // একটি বক্স বা ড্রয়ার খোলা (Open Box)
  await Hive.openBox<Map>(todoBoxName);

  runApp(const ProviderScope(child: MyApp()));
}

// --- ৩. ইউজার ইন্টারফেস (UI Part) ---
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

class TodoTab extends ConsumerWidget {
  const TodoTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoList = ref.watch(todoListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Hive + Riverpod Todo')),
      body: todoList.isEmpty
          ? const Center(child: Text('No tasks yet!'))
          : ListView.builder(
              itemCount: todoList.length,
              itemBuilder: (context, index) {
                final item = todoList[index];
                final bool isCompleted = item['isCompleted'] ?? false;

                return ListTile(
                  leading: IconButton(
                    icon: Icon(
                      isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isCompleted ? Colors.green : Colors.grey,
                    ),
                    onPressed: () {
                      ref.read(todoListProvider.notifier).toggleTodo(index);
                    },
                  ),
                  title: Text(
                    item['title'] ?? '',
                    style: TextStyle(
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: isCompleted ? Colors.grey : Colors.black,
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
