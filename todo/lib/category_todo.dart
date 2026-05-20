import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// --- ১. ডাটা মডেল (Data Models) ---

// টুডু আইটেম মডেল
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

// ক্যাটাগরি মডেল (যার ভেতর টুডু লিস্ট থাকবে)
class CategoryItem {
  final String id;
  final String name;
  final List<TodoItem> todos;
  final Color color;

  CategoryItem({
    required this.id,
    required this.name,
    required this.todos,
    required this.color,
  });

  CategoryItem copyWith({String? name, List<TodoItem>? todos, Color? color}) {
    return CategoryItem(
      id: this.id,
      name: name ?? this.name,
      todos: todos ?? this.todos,
      color: color ?? this.color,
    );
  }
}

// --- ২. রিভারপড স্টেট ম্যানেজমেন্ট ---

class CategoryListNotifier extends Notifier<List<CategoryItem>> {
  @override
  List<CategoryItem> build() {
    // শুরুর কিছু ডিফল্ট ক্যাটাগরি ও টুডু
    return [
      CategoryItem(
        id: '1',
        name: 'Work 💼',
        color: Colors.blue.shade100,
        todos: [TodoItem(title: 'Finish Flutter project')],
      ),
      CategoryItem(
        id: '2',
        name: 'Personal 🏠',
        color: Colors.green.shade100,
        todos: [TodoItem(title: 'Walk the dog', isCompleted: true)],
      ),
    ];
  }

  // নতুন ক্যাটাগরি যোগ করার লজিক
  void addCategory(String name, Color color) {
    final newCat = CategoryItem(
      id: DateTime.now().toString(),
      name: name,
      color: color,
      todos: [],
    );
    state = [...state, newCat];
  }

  // নির্দিষ্ট ক্যাটাগরির ভেতর নতুন টুডু যোগ করা
  void addTodoToCategory(String categoryId, String todoTitle) {
    state = [
      for (final cat in state)
        if (cat.id == categoryId)
          cat.copyWith(
            todos: [
              ...cat.todos,
              TodoItem(title: todoTitle),
            ],
          )
        else
          cat,
    ];
  }

  // নির্দিষ্ট ক্যাটাগরির টুডু ডিলিট করা
  void deleteTodoFromCategory(String categoryId, int todoIndex) {
    state = [
      for (final cat in state)
        if (cat.id == categoryId)
          cat.copyWith(
            todos: [
              for (int i = 0; i < cat.todos.length; i++)
                if (i != todoIndex) cat.todos[i],
            ],
          )
        else
          cat,
    ];
  }

  // নির্দিষ্ট ক্যাটাগরির টুডু টগল (চেক/আনচেক) করা
  void toggleTodoInCategory(String categoryId, int todoIndex) {
    state = [
      for (final cat in state)
        if (cat.id == categoryId)
          cat.copyWith(
            todos: [
              for (int i = 0; i < cat.todos.length; i++)
                if (i == todoIndex)
                  cat.todos[i].copyWith(isCompleted: !cat.todos[i].isCompleted)
                else
                  cat.todos[i],
            ],
          )
        else
          cat,
    ];
  }
}

final categoryProvider =
    NotifierProvider<CategoryListNotifier, List<CategoryItem>>(() {
      return CategoryListNotifier();
    });

final navigationProvider = StateProvider<int>((ref) => 0);

// --- ৩. মেইন অ্যাপ্লিকেশন ---
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const MainHomeScreen(),
    );
  }
}

// --- ৪. মেইন হোম স্ক্রিন ---
class MainHomeScreen extends ConsumerWidget {
  const MainHomeScreen({super.key});

  // নতুন ক্যাটাগরি অ্যাড করার বটম শীট
  void _showAddCategorySection(BuildContext context, WidgetRef ref) {
    final TextEditingController catController = TextEditingController();
    // র্যান্ডম কালার সিলেক্ট করার জন্য একটি লিস্ট
    final List<Color> colors = [
      Colors.red.shade100,
      Colors.blue.shade100,
      Colors.green.shade100,
      Colors.orange.shade100,
      Colors.purple.shade100,
      Colors.yellow.shade100,
    ];
    final selectedColor = (colors..shuffle()).first; // র্যান্ডম একটি কালার নেবে

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
                'Create New Category',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: catController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'e.g., Shopping, Fitness',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (catController.text.trim().isNotEmpty) {
                    ref
                        .read(categoryProvider.notifier)
                        .addCategory(catController.text.trim(), selectedColor);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add Category'),
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
    final List<Widget> screens = [
      const CategoriesGridTab(),
      const SettingsTab(),
    ];

    return Scaffold(
      body: screens[selectedIndex],

      // সাদা ব্যাকগ্রাউন্ড + কালো বর্ডার বিশিষ্ট প্লাস বাটন (ক্যাটাগরি অ্যাড করবে)
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategorySection(context, ref),
        backgroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(
          side: BorderSide(color: Colors.black, width: 2.0),
        ),
        child: const Icon(Icons.add, color: Colors.black, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black, width: 2.0)),
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          color: Colors.white,
          elevation: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(
                  Icons.grid_view,
                  color: selectedIndex == 0 ? Colors.black : Colors.black38,
                  size: 30,
                ),
                onPressed: () =>
                    ref.read(navigationProvider.notifier).state = 0,
              ),
              const SizedBox(width: 40),
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

// --- ৫. ক্যাটাগরি গ্রিড ট্যাব (হোম স্ক্রিন ভিউ) ---
class CategoriesGridTab extends ConsumerWidget {
  const CategoriesGridTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Categories',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: categories.isEmpty
          ? const Center(child: Text('No categories yet! Click + to add.'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                itemCount: categories.length,
                // ২ কলাম বিশিষ্ট গ্রিড তৈরি করা
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return InkWell(
                    onTap: () {
                      // ক্যাটাগরিতে ক্লিক করলে তাকে সেই ক্যাটাগরির টুডু স্ক্রিনে নিয়ে যাবে
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TodoListScreen(categoryId: category.id),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: category.color,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            category.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '${category.todos.length} Tasks',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// --- ৬. নির্দিষ্ট ক্যাটাগরির ভেতরের টুডু স্ক্রিন ---
class TodoListScreen extends ConsumerWidget {
  final String categoryId;
  const TodoListScreen({super.key, required this.categoryId});

  // এই ক্যাটাগরির ভেতর টুডু অ্যাড করার আলাদা বটম শীট
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
                    // নির্দিষ্ট ক্যাটাগরি আইডিতে টুডু সেভ হচ্ছে
                    ref
                        .read(categoryProvider.notifier)
                        .addTodoToCategory(
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
    // ক্যাটাগরি লিস্ট থেকে শুধুমাত্র এই নির্দিষ্ট আইডির ক্যাটাগরিটি খুঁজে বের করা
    final categories = ref.watch(categoryProvider);
    final currentCategory = categories.firstWhere(
      (cat) => cat.id == categoryId,
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
      // টুডু স্ক্রিনের ভেতরও একটি সাদা প্লাস বাটন রাখা হয়েছে নতুন টাস্ক যোগ করতে
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

// --- সেটিংস ট্যাব ---
class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Settings Screen', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
