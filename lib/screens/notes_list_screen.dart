import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../bloc/notes_state.dart';
import '../models/note_model.dart';
import '../theme.dart';
import '../widgets/app_drawer.dart';
import 'note_detail_screen.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesBloc>().add(const LoadNotes());
    });
  }

  String _appBarTitle(NotesViewType viewType) {
    switch (viewType) {
      case NotesViewType.active:
        return 'Notepad';
      case NotesViewType.archived:
        return 'Archive';
      case NotesViewType.trash:
        return 'Trash';
    }
  }

  String _emptyMessage(NotesViewType viewType) {
    switch (viewType) {
      case NotesViewType.active:
        return 'No notes yet';
      case NotesViewType.archived:
        return 'No archived notes';
      case NotesViewType.trash:
        return 'Trash is empty';
    }
  }

  void _openNote(BuildContext context, {Note? note}) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<NotesBloc>(),
          child: NoteDetailScreen(note: note),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<NotesBloc, NotesState>(
          buildWhen: (prev, curr) => prev.viewType != curr.viewType,
          builder: (context, state) {
            return Row(
              children: [
                // Image.asset('assets/logo.png', height: 28, width: 28),
                // const SizedBox(width: 8),
                Text(_appBarTitle(state.viewType)),
              ],
            );
          },
        ),
      ),
      drawer: const AppDrawer(),
      floatingActionButton: BlocBuilder<NotesBloc, NotesState>(
        buildWhen: (prev, curr) => prev.viewType != curr.viewType,
        builder: (context, state) {
          if (state.viewType != NotesViewType.active) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton(
            onPressed: () => _openNote(context),
            child: const Icon(Icons.add),
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(appPadding),
        child: Column(
          children: [
            TextField(
              autofocus: false,
              decoration: const InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                context.read<NotesBloc>().add(SearchNotes(query));
              },
            ),
            const SizedBox(height: appPadding),
            Expanded(
              child: BlocBuilder<NotesBloc, NotesState>(
                builder: (context, state) {
                  if (state.isLoading && state.notes.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.notes.isEmpty) {
                    return Center(
                      child: Text(
                        _emptyMessage(state.viewType),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 600) {
                        return ListView.separated(
                          itemCount: state.notes.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: appPadding),
                          itemBuilder: (context, index) {
                            return _NoteCard(
                              note: state.notes[index],
                              onTap: () =>
                                  _openNote(context, note: state.notes[index]),
                              onRestore: state.viewType == NotesViewType.trash
                                  ? () {
                                      context.read<NotesBloc>().add(
                                        RestoreNote(state.notes[index].id!),
                                      );
                                    }
                                  : null,
                            );
                          },
                        );
                      }

                      final columns = (constraints.maxWidth / 300)
                          .floor()
                          .clamp(2, 3);

                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: appPadding,
                          mainAxisSpacing: appPadding,
                          childAspectRatio: 1.4,
                        ),
                        itemCount: state.notes.length,
                        itemBuilder: (context, index) {
                          return _NoteCard(
                            note: state.notes[index],
                            onTap: () =>
                                _openNote(context, note: state.notes[index]),
                            onRestore: state.viewType == NotesViewType.trash
                                ? () {
                                    context.read<NotesBloc>().add(
                                      RestoreNote(state.notes[index].id!),
                                    );
                                  }
                                : null,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback? onRestore;

  const _NoteCard({
    required this.note,
    required this.onTap,
    this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat.yMMMd().add_jm().format(
      DateTime.fromMillisecondsSinceEpoch(note.updatedAt),
    );

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(appPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title.isEmpty ? 'Untitled' : note.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onRestore != null)
                    IconButton(
                      tooltip: 'Restore',
                      icon: const Icon(Icons.restore_outlined),
                      onPressed: onRestore,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                note.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                dateText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.text.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
