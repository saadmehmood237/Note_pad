import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/note_model.dart';
import 'db_init_stub.dart'
    if (dart.library.io) 'db_init_io.dart'
    if (dart.library.html) 'db_init_web.dart';

class NotesDatabase {
  NotesDatabase({String? dbPath}) : _dbPath = dbPath;

  final String? _dbPath;
  Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;
    initDatabaseFactory();
    final path = _dbPath ?? join(await getDatabasesPath(), 'notes.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL DEFAULT '',
            content TEXT NOT NULL DEFAULT '',
            createdAt INTEGER NOT NULL,
            updatedAt INTEGER NOT NULL,
            isDeleted INTEGER NOT NULL DEFAULT 0,
            isArchived INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
    return _db!;
  }

  Future<Note> addNote({required String title, required String content}) async {
    final db = await _database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = await db.insert('notes', {
      'title': title,
      'content': content,
      'createdAt': now,
      'updatedAt': now,
      'isDeleted': 0,
      'isArchived': 0,
    });
    return Note(
      id: id,
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> updateNote(Note note) async {
    final db = await _database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.update(
      'notes',
      {
        'title': note.title,
        'content': note.content,
        'updatedAt': now,
      },
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<void> softDeleteNote(int id) async {
    final db = await _database;
    await db.update(
      'notes',
      {'isDeleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> restoreNote(int id) async {
    final db = await _database;
    await db.update(
      'notes',
      {'isDeleted': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> permanentDeleteNote(int id) async {
    final db = await _database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> archiveNote(int id) async {
    final db = await _database;
    await db.update(
      'notes',
      {'isArchived': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> unarchiveNote(int id) async {
    final db = await _database;
    await db.update(
      'notes',
      {'isArchived': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Note>> getNotes({
    required NotesViewType view,
    String query = '',
  }) async {
    final db = await _database;
    final whereParts = <String>[];
    final whereArgs = <dynamic>[];

    switch (view) {
      case NotesViewType.active:
        whereParts.add('isDeleted = 0 AND isArchived = 0');
      case NotesViewType.archived:
        whereParts.add('isDeleted = 0 AND isArchived = 1');
      case NotesViewType.trash:
        whereParts.add('isDeleted = 1');
    }

    if (query.isNotEmpty) {
      whereParts.add('(LOWER(title) LIKE ? OR LOWER(content) LIKE ?)');
      final pattern = '%${query.toLowerCase()}%';
      whereArgs.addAll([pattern, pattern]);
    }

    final maps = await db.query(
      'notes',
      where: whereParts.join(' AND '),
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'updatedAt DESC',
    );

    return maps.map(Note.fromMap).toList();
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
