import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notepad/bloc/notes_bloc.dart';
import 'package:notepad/bloc/notes_state.dart';
import 'package:notepad/database/notes_database.dart';
import 'package:notepad/models/note_model.dart';
import 'package:notepad/theme.dart';
import 'package:notepad/widgets/app_drawer.dart';

class MockNotesDatabase extends Mock implements NotesDatabase {}

void main() {
  late MockNotesDatabase database;

  setUp(() {
    database = MockNotesDatabase();
    for (final view in NotesViewType.values) {
      when(
        () => database.getNotes(view: view, query: ''),
      ).thenAnswer((_) async => []);
    }
  });

  Widget buildTestWidget({
    required NotesBloc bloc,
  }) {
    return MaterialApp(
      theme: appTheme(),
      home: BlocProvider.value(
        value: bloc,
        child: Scaffold(
          appBar: AppBar(title: const Text('Test')),
          drawer: const AppDrawer(),
        ),
      ),
    );
  }

  Future<void> openDrawer(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
  }

  testWidgets('renders logo, Notepad, three nav items', (tester) async {
    final bloc = NotesBloc(database: database);
    addTearDown(bloc.close);

    await tester.pumpWidget(buildTestWidget(bloc: bloc));
    await openDrawer(tester);

    expect(find.text('Notepad'), findsOneWidget);
    expect(find.text('My Notes'), findsOneWidget);
    expect(find.text('All Notes'), findsOneWidget);
    expect(find.text('Archived Notes'), findsOneWidget);
    expect(find.text('Trash'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('tapping Archived Notes dispatches ChangeView(archived)', (
    tester,
  ) async {
    final bloc = NotesBloc(database: database);
    addTearDown(bloc.close);

    await tester.pumpWidget(buildTestWidget(bloc: bloc));
    await openDrawer(tester);

    await tester.tap(find.text('Archived Notes'));
    await tester.pumpAndSettle();

    expect(bloc.state.viewType, NotesViewType.archived);
    verify(
      () => database.getNotes(
        view: NotesViewType.archived,
        query: '',
      ),
    ).called(1);
  });

  testWidgets('selected item shows highlighted style when viewType matches', (
    tester,
  ) async {
    final bloc = NotesBloc(database: database)
      ..emit(const NotesState(viewType: NotesViewType.archived));
    addTearDown(bloc.close);

    await tester.pumpWidget(buildTestWidget(bloc: bloc));
    await openDrawer(tester);

    final archivedTile = tester.widget<ListTile>(
      find.ancestor(
        of: find.text('Archived Notes'),
        matching: find.byType(ListTile),
      ),
    );
    expect(archivedTile.selected, isTrue);

    final activeTile = tester.widget<ListTile>(
      find.ancestor(
        of: find.text('All Notes'),
        matching: find.byType(ListTile),
      ),
    );
    expect(activeTile.selected, isFalse);
  });
}
