import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../models/note_model.dart';
import '../theme.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note? note;

  const NoteDetailScreen({super.key, this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  bool get _isNew => widget.note?.id == null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final bloc = context.read<NotesBloc>();

    if (_isNew) {
      bloc.add(AddNote(title: title, content: content));
    } else {
      bloc.add(
        UpdateNote(
          widget.note!.copyWith(title: title, content: content),
        ),
      );
    }
    Navigator.pop(context);
  }

  void _toggleArchive() {
    final note = widget.note!;
    final bloc = context.read<NotesBloc>();

    if (note.isArchived) {
      bloc.add(UnarchiveNote(note.id!));
    } else {
      bloc.add(ArchiveNote(note.id!));
    }
    Navigator.pop(context);
  }

  void _restore() {
    final note = widget.note!;
    context.read<NotesBloc>().add(RestoreNote(note.id!));
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final note = widget.note!;
    final bloc = context.read<NotesBloc>();
    final navigator = Navigator.of(context);

    if (note.isDeleted) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete permanently?'),
          content: const Text('This note cannot be restored.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        bloc.add(PermanentDeleteNote(note.id!));
        navigator.pop();
      }
    } else {
      bloc.add(SoftDeleteNote(note.id!));
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final note = widget.note;
    final showArchiveActions = note != null && note.id != null && !note.isDeleted;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'New Note' : 'Edit Note'),
        actions: [
          if (note != null && note.id != null && note.isDeleted)
            IconButton(
              tooltip: 'Restore',
              icon: const Icon(Icons.restore_outlined),
              onPressed: _restore,
            ),
          if (showArchiveActions)
            IconButton(
              tooltip: note.isArchived ? 'Unarchive' : 'Archive',
              icon: Icon(
                note.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
              ),
              onPressed: _toggleArchive,
            ),
          if (note?.id != null)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
          IconButton(
            tooltip: 'Save',
            icon: const Icon(Icons.check),
            onPressed: _save,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(appPadding),
        child: Column(
          children: [
            TextField(
              key: const Key('titleField'),
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: appPadding),
            Expanded(
              child: TextField(
                key: const Key('contentField'),
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
