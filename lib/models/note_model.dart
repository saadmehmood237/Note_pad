enum NotesViewType { active, archived, trash }

class Note {
  final int? id;
  final String title;
  final String content;
  final int createdAt;
  final int updatedAt;
  final bool isDeleted;
  final bool isArchived;

  const Note({
    this.id,
    this.title = '',
    this.content = '',
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.isArchived = false,
  });

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      createdAt: map['createdAt'] as int,
      updatedAt: map['updatedAt'] as int,
      isDeleted: (map['isDeleted'] as int? ?? 0) == 1,
      isArchived: (map['isArchived'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isDeleted': isDeleted ? 1 : 0,
      'isArchived': isArchived ? 1 : 0,
    };
  }

  Note copyWith({
    int? id,
    String? title,
    String? content,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    bool? isArchived,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
