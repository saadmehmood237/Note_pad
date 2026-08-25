# Notepad

A simple local notepad app built with Flutter. Create, edit, search, archive, and delete notes — all stored on device with sqflite. No login or cloud sync.

## Features

- Add and edit notes with title and plain text content
- Search notes by title or content
- Archive and unarchive notes
- Soft delete to Trash with restore or permanent delete
- Drawer navigation for All Notes, Archived, and Trash
- Responsive list on phones, grid on wider screens

## Setup

```bash
cd notepad
flutter pub get
```

## Run tests

```bash
flutter test
```

## Run the app

```bash
flutter run
```

For web:

```bash
flutter run -d chrome
```

## Dependencies

- `flutter_bloc` — state management
- `sqflite` / `sqflite_common_ffi` / `sqflite_common_ffi_web` — local database
- `intl` — date formatting on note cards
