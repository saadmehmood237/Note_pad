import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notepad/bloc/notes_bloc.dart';
import 'package:notepad/database/notes_database.dart';
import 'package:notepad/models/note_model.dart';
import 'package:notepad/screens/note_detail_screen.dart';
import 'package:notepad/screens/notes_list_screen.dart';
import 'package:notepad/theme.dart';

class MockNotesDatabase extends Mock implements NotesDatabase {}

void main() {
  late MockNotesDatabase database;

  const timestamp = 1_700_000_000_000;

  setUpAll(() {
    registerFallbackValue(NotesViewType.active);
  });

  setUp(() {
    database = MockNotesDatabase();
    when(
      () => database.getNotes(
        view: any(named: 'view'),
        query: any(named: 'query'),
      ),
    ).thenAnswer((_) async => []);
  });

  Widget buildTestWidget({required NotesBloc bloc}) {
    return MaterialApp(
      theme: appTheme(),
      home: BlocProvider.value(
        value: bloc,
        child: const NotesListScreen(),
      ),
    );
  }

  testWidgets('empty state message when notes is empty', (tester) async {
    final bloc = NotesBloc(database: database);
    addTearDown(bloc.close);

    await tester.pumpWidget(buildTestWidget(bloc: bloc));
    await tester.pumpAndSettle();

    expect(find.text('No notes yet'), findsOneWidget);
  });

  testWidgets('renders note cards with title preview', (tester) async {
    final note = Note(
      id: 1,
      title: 'Shopping list',
      content: 'Milk and eggs',
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    when(
      () => database.getNotes(
        view: any(named: 'view'),
        query: any(named: 'query'),
      ),
    ).thenAnswer((_) async => [note]);

    final bloc = NotesBloc(database: database);
    addTearDown(bloc.close);

    await tester.pumpWidget(buildTestWidget(bloc: bloc));
    await tester.pumpAndSettle();

    expect(find.text('Shopping list'), findsOneWidget);
    expect(find.text('Milk and eggs'), findsOneWidget);
  });

  testWidgets('FAB navigates to detail screen', (tester) async {
    final bloc = NotesBloc(database: database);
    addTearDown(bloc.close);

    await tester.pumpWidget(buildTestWidget(bloc: bloc));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(NoteDetailScreen), findsOneWidget);
  });

  testWidgets('search field dispatches SearchNotes', (tester) async {
    final bloc = NotesBloc(database: database);
    addTearDown(bloc.close);

    await tester.pumpWidget(buildTestWidget(bloc: bloc));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pumpAndSettle();

    expect(bloc.state.searchQuery, 'hello');
    verify(
      () => database.getNotes(
        view: NotesViewType.active,
        query: 'hello',
      ),
    ).called(1);
  });
}
