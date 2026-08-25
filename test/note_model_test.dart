import 'package:flutter_test/flutter_test.dart';
import 'package:notepad/models/note_model.dart';

void main() {
  group('Note', () {
    test('fromMap and toMap round-trip preserves all fields', () {
      const original = Note(
        id: 1,
        title: 'Shopping',
        content: 'Milk and eggs',
        createdAt: 1700000000000,
        updatedAt: 1700001000000,
        isDeleted: true,
        isArchived: false,
      );

      final map = original.toMap();
      final restored = Note.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.content, original.content);
      expect(restored.createdAt, original.createdAt);
      expect(restored.updatedAt, original.updatedAt);
      expect(restored.isDeleted, original.isDeleted);
      expect(restored.isArchived, original.isArchived);
    });

    test('fromMap reads sqflite integer flags', () {
      final note = Note.fromMap({
        'id': 2,
        'title': 'Draft',
        'content': '',
        'createdAt': 1000,
        'updatedAt': 2000,
        'isDeleted': 0,
        'isArchived': 1,
      });

      expect(note.isDeleted, isFalse);
      expect(note.isArchived, isTrue);
    });

    test('copyWith updates only passed fields', () {
      const original = Note(
        id: 3,
        title: 'Old title',
        content: 'Old content',
        createdAt: 100,
        updatedAt: 200,
        isDeleted: false,
        isArchived: false,
      );

      final updated = original.copyWith(
        title: 'New title',
        isArchived: true,
      );

      expect(updated.id, original.id);
      expect(updated.title, 'New title');
      expect(updated.content, original.content);
      expect(updated.createdAt, original.createdAt);
      expect(updated.updatedAt, original.updatedAt);
      expect(updated.isDeleted, original.isDeleted);
      expect(updated.isArchived, isTrue);
    });
  });
}
