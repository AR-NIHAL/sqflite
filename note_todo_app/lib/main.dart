\import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:note_todo_app/app.dart';
import 'package:note_todo_app/features/notes/data/models/note_model.dart';
import 'package:note_todo_app/features/todos/data/models/todo_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(NoteModelAdapter());
  Hive.registerAdapter(TodoModelAdapter());
  await Hive.openBox('settings');
  runApp(const ProviderScope(child: App()));
}
