import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notepad/bloc/notes_bloc.dart';
import 'package:notepad/bloc/notes_event.dart';
import 'package:notepad/bloc/notes_state.dart';
import 'package:notepad/models/note_model.dart';
import 'package:notepad/screens/note_detail_screen.dart';
import 'package:notepad/theme.dart';

class MockNotesBloc extends MockBloc<NotesEvent, NotesState>
    implements NotesBloc {}

void main() {
  late MockNotesBloc bloc;

  const timestamp = 1_700_000_000_000;

  final existingNote = Note(
    id: 1,
    title: 'Meeting notes',
    content: 'Bring the report',
    createdAt: timestamp,
    updatedAt: timestamp,
  );

  setUpAll(() {
    registerFallbackValue(const AddNote(title: '', content: ''));
    registerFallbackValue(
      UpdateNote(
        Note(createdAt: timestamp, updatedAt: timestamp),
      ),
    );
    registerFallbackValue(const SoftDeleteNote(0));
    registerFallbackValue(const PermanentDeleteNote(0));
  });

  setUp(() {
    bloc = MockNotesBloc();
    when(() => bloc.state).thenReturn(const NotesState());
    when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => bloc.add(any())).thenReturn(null);
  });

  Widget buildScreen(Note note) {
    return MaterialApp(
      theme: appTheme(),
      home: BlocProvider<NotesBloc>.value(
        value: bloc,
        child: NoteDetailScreen(note: note),
      ),
    );
  }

  group('edit mode', () {
    testWidgets('shows title and content fields pre-filled', (tester) async {
      await tester.pumpWidget(buildScreen(existingNote));
      await tester.pump();

      expect(find.byKey(const Key('titleField')), findsOneWidget);
      expect(find.byKey(const Key('contentField')), findsOneWidget);
      expect(find.text('Meeting notes'), findsOneWidget);
      expect(find.text('Bring the report'), findsOneWidget);
    });

    testWidgets('save dispatches UpdateNote for existing note', (tester) async {
      await tester.pumpWidget(buildScreen(existingNote));
      await tester.pump();

      await tester.enterText(find.byKey(const Key('titleField')), 'Updated title');
      await tester.enterText(
        find.byKey(const Key('contentField')),
        'Updated content',
      );
      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      verify(
        () => bloc.add(
          any(
            that: isA<UpdateNote>()
                .having((e) => e.note.id, 'id', 1)
                .having((e) => e.note.title, 'title', 'Updated title')
                .having((e) => e.note.content, 'content', 'Updated content'),
          ),
        ),
      ).called(1);
      verifyNever(() => bloc.add(any(that: isA<AddNote>())));
    });
  });

  group('add mode', () {
    testWidgets('save dispatches AddNote for new note', (tester) async {
      final newNote = Note(createdAt: timestamp, updatedAt: timestamp);
      await tester.pumpWidget(buildScreen(newNote));
      await tester.pump();

      await tester.enterText(find.byKey(const Key('titleField')), 'New title');
      await tester.enterText(find.byKey(const Key('contentField')), 'New body');
      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      verify(
        () => bloc.add(
          const AddNote(title: 'New title', content: 'New body'),
        ),
      ).called(1);
      verifyNever(() => bloc.add(any(that: isA<UpdateNote>())));
    });
  });

  group('delete from trash', () {
    final trashNote = Note(
      id: 3,
      title: 'Old draft',
      content: 'Remove me',
      createdAt: timestamp,
      updatedAt: timestamp,
      isDeleted: true,
    );

    testWidgets('shows confirmation dialog before permanent delete',
        (tester) async {
      await tester.pumpWidget(buildScreen(trashNote));
      await tester.pump();

      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete permanently?'), findsOneWidget);
      verifyNever(() => bloc.add(any(that: isA<PermanentDeleteNote>())));

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      verifyNever(() => bloc.add(any(that: isA<PermanentDeleteNote>())));
    });

    testWidgets('confirming dialog dispatches PermanentDeleteNote',
        (tester) async {
      await tester.pumpWidget(buildScreen(trashNote));
      await tester.pump();

      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      verify(() => bloc.add(const PermanentDeleteNote(3))).called(1);
    });
  });
}
