import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_provider.dart';
import '../providers/navigation_provider.dart';
import 'categories_grid_tab.dart';
import 'settings_tab.dart';

class MainHomeScreen extends ConsumerWidget {
  const MainHomeScreen({super.key});

  void _showAddCategorySection(BuildContext context, WidgetRef ref) {
    final TextEditingController catController = TextEditingController();
    final List<Color> colors = [
      Colors.red.shade100,
      Colors.blue.shade100,
      Colors.green.shade100,
      Colors.orange.shade100,
      Colors.purple.shade100,
      Colors.yellow.shade100,
    ];
    final selectedColor = (colors..shuffle()).first;

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