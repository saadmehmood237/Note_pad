import 'package:equatable/equatable.dart';

import '../models/note_model.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotes extends NotesEvent {
  const LoadNotes();
}

class ChangeView extends NotesEvent {
  final NotesViewType type;

  const ChangeView(this.type);

  @override
  List<Object?> get props => [type];
}

class SearchNotes extends NotesEvent {
  final String query;

  const SearchNotes(this.query);

  @override
  List<Object?> get props => [query];
}

class AddNote extends NotesEvent {
  final String title;
  final String content;

  const AddNote({required this.title, required this.content});

  @override
  List<Object?> get props => [title, content];
}

class UpdateNote extends NotesEvent {
  final Note note;

  const UpdateNote(this.note);

  @override
  List<Object?> get props => [note];
}

class SoftDeleteNote extends NotesEvent {
  final int id;

  const SoftDeleteNote(this.id);

  @override
  List<Object?> get props => [id];
}

class RestoreNote extends NotesEvent {
  final int id;

  const RestoreNote(this.id);

  @override
  List<Object?> get props => [id];
}

class PermanentDeleteNote extends NotesEvent {
  final int id;

  const PermanentDeleteNote(this.id);

  @override
  List<Object?> get props => [id];
}

class ArchiveNote extends NotesEvent {
  final int id;

  const ArchiveNote(this.id);

  @override
  List<Object?> get props => [id];
}

class UnarchiveNote extends NotesEvent {
  final int id;

  const UnarchiveNote(this.id);

  @override
  List<Object?> get props => [id];
}
