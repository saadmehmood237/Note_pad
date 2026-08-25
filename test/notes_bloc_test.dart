import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notepad/bloc/notes_bloc.dart';
import 'package:notepad/bloc/notes_event.dart';
import 'package:notepad/bloc/notes_state.dart';
import 'package:notepad/database/notes_database.dart';
import 'package:notepad/models/note_model.dart';

class MockNotesDatabase extends Mock implements NotesDatabase {}

void main() {
  late MockNotesDatabase database;

  const timestamp = 1_700_000_000_000;

  final activeNote = Note(
    id: 1,
    title: 'Active',
    content: 'Body',
    createdAt: timestamp,
    updatedAt: timestamp,
  );

  final archivedNote = Note(
    id: 2,
    title: 'Archived',
    content: 'Old',
    createdAt: timestamp,
    updatedAt: timestamp,
    isArchived: true,
  );

  final trashNote = Note(
    id: 3,
    title: 'Trash',
    content: 'Deleted',
    createdAt: timestamp,
    updatedAt: timestamp,
    isDeleted: true,
  );

  setUp(() {
    database = MockNotesDatabase();
  });

  group('LoadNotes', () {
    blocTest<NotesBloc, NotesState>(
      'emits loading then list for current viewType',
      build: () {
        when(
          () => database.getNotes(
            view: NotesViewType.active,
            query: '',
          ),
        ).thenAnswer((_) async => [activeNote]);
        return NotesBloc(database: database);
      },
      act: (bloc) => bloc.add(const LoadNotes()),
      expect: () => [
        const NotesState(isLoading: true),
        NotesState(notes: [activeNote], isLoading: false),
      ],
      verify: (_) {
        verify(
          () => database.getNotes(
            view: NotesViewType.active,
            query: '',
          ),
        ).called(1);
      },
    );
  });

  group('ChangeView', () {
    blocTest<NotesBloc, NotesState>(
      'reloads correct subset for archived view',
      build: () {
        when(
          () => database.getNotes(
            view: NotesViewType.archived,
            query: '',
          ),
        ).thenAnswer((_) async => [archivedNote]);
        return NotesBloc(database: database);
      },
      act: (bloc) => bloc.add(const ChangeView(NotesViewType.archived)),
      expect: () => [
        const NotesState(viewType: NotesViewType.archived, isLoading: true),
        NotesState(
          viewType: NotesViewType.archived,
          notes: [archivedNote],
          isLoading: false,
        ),
      ],
      verify: (_) {
        verify(
          () => database.getNotes(
            view: NotesViewType.archived,
            query: '',
          ),
        ).called(1);
      },
    );
  });

  group('SearchNotes', () {
    blocTest<NotesBloc, NotesState>(
      'updates searchQuery and reloads filtered list',
      build: () {
        when(
          () => database.getNotes(
            view: NotesViewType.active,
            query: 'active',
          ),
        ).thenAnswer((_) async => [activeNote]);
        return NotesBloc(database: database);
      },
      act: (bloc) => bloc.add(const SearchNotes('active')),
      expect: () => [
        const NotesState(searchQuery: 'active', isLoading: true),
        NotesState(
          searchQuery: 'active',
          notes: [activeNote],
          isLoading: false,
        ),
      ],
      verify: (_) {
        verify(
          () => database.getNotes(
            view: NotesViewType.active,
            query: 'active',
          ),
        ).called(1);
      },
    );
  });

  group('mutation events', () {
    blocTest<NotesBloc, NotesState>(
      'AddNote calls addNote and re-emits updated list',
      build: () {
        when(
          () => database.addNote(title: 'New', content: 'Note'),
        ).thenAnswer((_) async => activeNote);
        when(
          () => database.getNotes(
            view: NotesViewType.active,
            query: '',
          ),
        ).thenAnswer((_) async => [activeNote]);
        return NotesBloc(database: database);
      },
      act: (bloc) => bloc.add(const AddNote(title: 'New', content: 'Note')),
      expect: () => [NotesState(notes: [activeNote])],
      verify: (_) {
        verify(
          () => database.addNote(title: 'New', content: 'Note'),
        ).called(1);
        verify(
          () => database.getNotes(
            view: NotesViewType.active,
            query: '',
          ),
        ).called(1);
      },
    );

    blocTest<NotesBloc, NotesState>(
      'UpdateNote calls updateNote and re-emits updated list',
      build: () {
        when(() => database.updateNote(activeNote)).thenAnswer((_) async {});
        when(
          () => database.getNotes(
            view: NotesViewType.active,
            query: '',
          ),
        ).thenAnswer((_) async => [activeNote]);
        return NotesBloc(database: database);
      },
      act: (bloc) => bloc.add(UpdateNote(activeNote)),
      expect: () => [NotesState(notes: [activeNote])],
      verify: (_) {
        verify(() => database.updateNote(activeNote)).called(1);
        verify(
          () => database.getNotes(
            view: NotesViewType.active,
            query: '',
          ),
        ).called(1);
      },
    );

    blocTest<NotesBloc, NotesState>(
      'SoftDeleteNote calls softDeleteNote and re-emits updated list',
      build: () {
        when(() => database.softDeleteNote(1)).thenAnswer((_) async {});
        when(
          () => database.getNotes(
            view: NotesViewType.active,
            query: '',
          ),
        ).thenAnswer((_) async => <Note>[]);
        return NotesBloc(database: database);
      },
      act: (bloc) => bloc.add(const SoftDeleteNote(1)),
      expect: () => [const NotesState(notes: [])],
      verify: (_) {
        verify(() => database.softDeleteNote(1)).called(1);
        verify(
          () => database.getNotes(
            view: NotesViewType.active,
            query: '',
          ),
        ).called(1);
      },
    );

    blocTest<NotesBloc, NotesState>(
      'RestoreNote calls restoreNote and re-emits updated list',
      build: () {
        when(() => database.restoreNote(3)).thenAnswer((_) async {});
        when(
          () => database.getNotes(
            view: NotesViewType.active,
            query: '',
          ),
        ).thenAnswer((_) async => [activeNote]);
        return NotesBloc(database: database);
      },
      act: (bloc) => bloc.add(const RestoreNote(3)),
      expect: () => [NotesState(notes: [activeNote])],
      verify: (_) {
        verify(() => database.restoreNote(3)).called(1);
        verify(
          () => database.getNotes(
            view: NotesViewType.active,
            query: '',
          ),
        ).called(1);
      },
    );

    blocTest<NotesBloc, NotesState>(
      'PermanentDeleteNote calls permanentDeleteNote and re-emits updated list',
      build: () {
        when(() => database.permanentDeleteNote(3)).thenAnswer((_) async {});
        when(
          () => database.getNotes(
            view: NotesViewType.trash,
            query: '',
          ),
        ).thenAnswer((_) async => <Note>[]);
        return NotesBloc(database: database);
      },
      seed: () => NotesState(viewType: NotesViewType.trash, notes: [trashNote]),
      act: (bloc) => bloc.add(const PermanentDeleteNote(3)),
      expect: () => [
        const NotesState(viewType: NotesViewType.trash, notes: []),
      ],
      verify: (_) {
        verify(() => database.permanentDeleteNote(3)).called(1);
        verify(
          () => database.getNotes(
            view: NotesViewType.trash,
            query: '',
          ),
        ).called(1);
      },
    );

    blocTest<NotesBloc, NotesState>(
      'ArchiveNote calls archiveNote and re-emits updated list',
      build: () {
        when(() => database.archiveNote(1)).thenAnswer((_) async {});
        when(
          () => database.getNotes(
            view: NotesViewType.active,
            query: '',
          ),
        ).thenAnswer((_) async => <Note>[]);
        return NotesBloc(database: database);
      },
      act: (bloc) => bloc.add(const ArchiveNote(1)),
      expect: () => [const NotesState(notes: [])],
      verify: (_) {
        verify(() => database.archiveNote(1)).called(1);
        verify(
          () => database.getNotes(
            view: NotesViewType.active,
            query: '',
          ),
        ).called(1);
      },
    );

    blocTest<NotesBloc, NotesState>(
      'UnarchiveNote calls unarchiveNote and re-emits updated list',
      build: () {
        when(() => database.unarchiveNote(2)).thenAnswer((_) async {});
        when(
          () => database.getNotes(
            view: NotesViewType.archived,
            query: '',
          ),
        ).thenAnswer((_) async => <Note>[]);
        return NotesBloc(database: database);
      },
      seed: () =>
          NotesState(viewType: NotesViewType.archived, notes: [archivedNote]),
      act: (bloc) => bloc.add(const UnarchiveNote(2)),
      expect: () => [
        const NotesState(viewType: NotesViewType.archived, notes: []),
      ],
      verify: (_) {
        verify(() => database.unarchiveNote(2)).called(1);
        verify(
          () => database.getNotes(
            view: NotesViewType.archived,
            query: '',
          ),
        ).called(1);
      },
    );
  });
}
