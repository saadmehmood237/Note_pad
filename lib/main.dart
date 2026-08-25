import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/notes_bloc.dart';
import 'database/notes_database.dart';
import 'screens/notes_list_screen.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const NotepadApp());
}

class NotepadApp extends StatelessWidget {
  const NotepadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotesBloc(database: NotesDatabase()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Notepad',
        theme: appTheme(),
        home: const NotesListScreen(),
      ),
    );
  }
}
