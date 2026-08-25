import 'package:equatable/equatable.dart';

import '../models/note_model.dart';

class NotesState extends Equatable {
  final List<Note> notes;
  final String searchQuery;
  final NotesViewType viewType;
  final bool isLoading;

  const NotesState({
    this.notes = const [],
    this.searchQuery = '',
    this.viewType = NotesViewType.active,
    this.isLoading = false,
  });

  NotesState copyWith({
    List<Note>? notes,
    String? searchQuery,
    NotesViewType? viewType,
    bool? isLoading,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      searchQuery: searchQuery ?? this.searchQuery,
      viewType: viewType ?? this.viewType,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [notes, searchQuery, viewType, isLoading];
}
