import 'package:flutter/material.dart';
import 'package:note_todo_app/features/todos/domain/entities/todo.dart';

class TodoFormSheet extends StatefulWidget {
  final Todo? todo;
  final List<String> existingCategories;
  final String initialCategory;
  final bool hideCategory;

  const TodoFormSheet({
    super.key,
    this.todo,
    this.existingCategories = const [],
    this.initialCategory = '',
    this.hideCategory = false,
  });

  @override
  State<TodoFormSheet> createState() => _TodoFormSheetState();
}

class _TodoFormSheetState extends State<TodoFormSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _categoryController = TextEditingController(
      text: widget.todo?.category ?? widget.initialCategory,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.todo != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: const Border(
          top: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: 16,
          left: 20,
          right: 20,
          bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isEditing ? 'Edit Todo' : 'New Todo',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              autofocus: true,
            ),
            if (!widget.hideCategory) ...[
              const SizedBox(height: 20),
              Text(
                'Category',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(
                  hintText: 'e.g. gym, study, work',
                  border: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black, width: 1.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black, width: 1.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  suffixIcon: _categoryController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            setState(() => _categoryController.clear());
                          },
                        )
                      : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
              if (widget.existingCategories.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Existing categories',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.existingCategories.map((cat) {
                    final isSelected = _categoryController.text == cat;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _categoryController.text =
                              isSelected ? '' : cat;
                          _categoryController.selection =
                              TextSelection.fromPosition(
                            TextPosition(
                                offset: _categoryController.text.length),
                          );
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.black,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: isSelected
                              ? const [
                                  BoxShadow(
                                    color: Colors.black,
                                    offset: Offset(2, 2),
                                    blurRadius: 0,
                                    spreadRadius: 0,
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected ? Colors.white : null,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (_titleController.text.trim().isEmpty) return;
                      Navigator.of(context).pop({
                        'title': _titleController.text.trim(),
                        'category': widget.hideCategory
                            ? widget.initialCategory
                            : _categoryController.text.trim(),
                      });
                    },
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: const BorderSide(color: Colors.black, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(isEditing ? 'Save' : 'Create'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
