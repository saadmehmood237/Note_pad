import 'package:flutter_test/flutter_test.dart';
import 'package:notepad/database/notes_database.dart';
import 'package:notepad/models/note_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late NotesDatabase database;

  setUp(() {
    database = NotesDatabase(dbPath: inMemoryDatabasePath);
  });

  tearDown(() async {
    await database.close();
  });

  test('addNote returns note with generated id and timestamps', () async {
    final before = DateTime.now().millisecondsSinceEpoch;
    final note = await database.addNote(title: 'Hello', content: 'World');
    final after = DateTime.now().millisecondsSinceEpoch;

    expect(note.id, isNotNull);
    expect(note.title, 'Hello');
    expect(note.content, 'World');
    expect(note.createdAt, inInclusiveRange(before, after));
    expect(note.updatedAt, inInclusiveRange(before, after));
    expect(note.isDeleted, false);
    expect(note.isArchived, false);
  });

  test('updateNote changes title/content and bumps updatedAt', () async {
    final note = await database.addNote(title: 'Old', content: 'Body');
    await Future<void>.delayed(const Duration(milliseconds: 5));

    await database.updateNote(note.copyWith(title: 'New', content: 'Updated'));

    final notes = await database.getNotes(view: NotesViewType.active);
    expect(notes, hasLength(1));
    expect(notes.first.title, 'New');
    expect(notes.first.content, 'Updated');
    expect(notes.first.updatedAt, greaterThan(note.updatedAt));
    expect(notes.first.createdAt, note.createdAt);
  });

  test('softDeleteNote moves note to trash view only', () async {
    final note = await database.addNote(title: 'Delete me', content: 'Soon');

    await database.softDeleteNote(note.id!);

    expect(
      await database.getNotes(view: NotesViewType.active),
      isEmpty,
    );
    expect(
      await database.getNotes(view: NotesViewType.archived),
      isEmpty,
    );
    final trash = await database.getNotes(view: NotesViewType.trash);
    expect(trash, hasLength(1));
    expect(trash.first.id, note.id);
  });

  test('restoreNote returns note to active view', () async {
    final note = await database.addNote(title: 'Temp', content: 'Trash');
    await database.softDeleteNote(note.id!);
    await database.restoreNote(note.id!);

    final active = await database.getNotes(view: NotesViewType.active);
    expect(active, hasLength(1));
    expect(active.first.id, note.id);
    expect(await database.getNotes(view: NotesViewType.trash), isEmpty);
  });

  test('archiveNote and unarchiveNote move between active and archived', () async {
    final note = await database.addNote(title: 'Archive', content: 'Note');
    await database.archiveNote(note.id!);

    expect(await database.getNotes(view: NotesViewType.active), isEmpty);
    final archived = await database.getNotes(view: NotesViewType.archived);
    expect(archived, hasLength(1));
    expect(archived.first.id, note.id);

    await database.unarchiveNote(note.id!);

    expect(await database.getNotes(view: NotesViewType.archived), isEmpty);
    final active = await database.getNotes(view: NotesViewType.active);
    expect(active, hasLength(1));
    expect(active.first.id, note.id);
  });

  test('permanentDeleteNote removes row completely', () async {
    final note = await database.addNote(title: 'Gone', content: 'Forever');
    await database.softDeleteNote(note.id!);
    await database.permanentDeleteNote(note.id!);

    expect(await database.getNotes(view: NotesViewType.trash), isEmpty);
    expect(await database.getNotes(view: NotesViewType.active), isEmpty);
  });

  test('getNotes with query matches title and content case-insensitively', () async {
    await database.addNote(title: 'Shopping List', content: 'Milk and eggs');
    await database.addNote(title: 'Work', content: 'Finish REPORT draft');
    await database.addNote(title: 'Other', content: 'Nothing here');

    final byTitle = await database.getNotes(
      view: NotesViewType.active,
      query: 'shopping',
    );
    expect(byTitle, hasLength(1));
    expect(byTitle.first.title, 'Shopping List');

    final byContent = await database.getNotes(
      view: NotesViewType.active,
      query: 'REPORT',
    );
    expect(byContent, hasLength(1));
    expect(byContent.first.title, 'Work');
  });
}
