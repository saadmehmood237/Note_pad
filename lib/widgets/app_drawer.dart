import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../bloc/notes_state.dart';
import '../models/note_model.dart';
import '../theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotesBloc, NotesState>(
      builder: (context, state) {
        return Drawer(
          child: Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: AppColors.primary),
                padding: const EdgeInsets.all(appPadding),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/logo.png', height: 48, width: 48),
                      const SizedBox(height: 8),
                      const Text(
                        'Notepad',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const Text(
                        'My Notes',
                        style: TextStyle(color: AppColors.text),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _navItem(
                      context: context,
                      label: 'All Notes',
                      icon: Icons.notes,
                      viewType: NotesViewType.active,
                      selected: state.viewType == NotesViewType.active,
                    ),
                    _navItem(
                      context: context,
                      label: 'Archived Notes',
                      icon: Icons.archive_outlined,
                      viewType: NotesViewType.archived,
                      selected: state.viewType == NotesViewType.archived,
                    ),
                    _navItem(
                      context: context,
                      label: 'Trash',
                      icon: Icons.delete_outline,
                      viewType: NotesViewType.trash,
                      selected: state.viewType == NotesViewType.trash,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _navItem({
    required BuildContext context,
    required String label,
    required IconData icon,
    required NotesViewType viewType,
    required bool selected,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: selected
            ? AppColors.text
            : AppColors.text.withValues(alpha: 0.5),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: selected
              ? AppColors.text
              : AppColors.text.withValues(alpha: 0.5),
        ),
      ),
      selected: selected,
      onTap: () {
        Navigator.pop(context);
        context.read<NotesBloc>().add(ChangeView(viewType));
      },
    );
  }
}
