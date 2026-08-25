import 'package:flutter_bloc/flutter_bloc.dart';

import '../database/notes_database.dart';
import 'notes_event.dart';
import 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  NotesBloc({required NotesDatabase database})
      : _database = database,
        super(const NotesState()) {
    on<LoadNotes>(_onLoadNotes);
    on<ChangeView>(_onChangeView);
    on<SearchNotes>(_onSearchNotes);
    on<AddNote>(_onAddNote);
    on<UpdateNote>(_onUpdateNote);
    on<SoftDeleteNote>(_onSoftDeleteNote);
    on<RestoreNote>(_onRestoreNote);
    on<PermanentDeleteNote>(_onPermanentDeleteNote);
    on<ArchiveNote>(_onArchiveNote);
    on<UnarchiveNote>(_onUnarchiveNote);
  }

  final NotesDatabase _database;

  Future<void> _onLoadNotes(LoadNotes event, Emitter<NotesState> emit) async {
    emit(state.copyWith(isLoading: true));
    final notes = await _database.getNotes(
      view: state.viewType,
      query: state.searchQuery,
    );
    emit(state.copyWith(notes: notes, isLoading: false));
  }

  Future<void> _onChangeView(ChangeView event, Emitter<NotesState> emit) async {
    emit(state.copyWith(viewType: event.type, isLoading: true));
    final notes = await _database.getNotes(
      view: event.type,
      query: state.searchQuery,
    );
    emit(state.copyWith(notes: notes, isLoading: false));
  }

  Future<void> _onSearchNotes(SearchNotes event, Emitter<NotesState> emit) async {
    emit(state.copyWith(searchQuery: event.query, isLoading: true));
    final notes = await _database.getNotes(
      view: state.viewType,
      query: event.query,
    );
    emit(state.copyWith(notes: notes, isLoading: false));
  }

  Future<void> _onAddNote(AddNote event, Emitter<NotesState> emit) async {
    await _database.addNote(title: event.title, content: event.content);
    await _reloadNotes(emit);
  }

  Future<void> _onUpdateNote(UpdateNote event, Emitter<NotesState> emit) async {
    await _database.updateNote(event.note);
    await _reloadNotes(emit);
  }

  Future<void> _onSoftDeleteNote(
    SoftDeleteNote event,
    Emitter<NotesState> emit,
  ) async {
    await _database.softDeleteNote(event.id);
    await _reloadNotes(emit);
  }

  Future<void> _onRestoreNote(RestoreNote event, Emitter<NotesState> emit) async {
    await _database.restoreNote(event.id);
    await _reloadNotes(emit);
  }

  Future<void> _onPermanentDeleteNote(
    PermanentDeleteNote event,
    Emitter<NotesState> emit,
  ) async {
    await _database.permanentDeleteNote(event.id);
    await _reloadNotes(emit);
  }

  Future<void> _onArchiveNote(ArchiveNote event, Emitter<NotesState> emit) async {
    await _database.archiveNote(event.id);
    await _reloadNotes(emit);
  }

  Future<void> _onUnarchiveNote(
    UnarchiveNote event,
    Emitter<NotesState> emit,
  ) async {
    await _database.unarchiveNote(event.id);
    await _reloadNotes(emit);
  }

  Future<void> _reloadNotes(Emitter<NotesState> emit) async {
    final notes = await _database.getNotes(
      view: state.viewType,
      query: state.searchQuery,
    );
    emit(state.copyWith(notes: notes, isLoading: false));
  }
}
