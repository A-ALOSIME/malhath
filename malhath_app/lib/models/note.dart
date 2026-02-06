class Note {
  final String? id;
  final String title;
  final String content;
  final bool is_favorite;
  final DateTime createdAt;
  final String? userId;

  Note({
    this.id,
    required this.title,
    required this.content,
    this.is_favorite = false,
    DateTime? createdAt,
    this.userId,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert Note to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'is_favorite': is_favorite,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
    };
  }

  // Create Note from JSON
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id']?.toString(),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      is_favorite: json['is_favorite'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      userId: json['user_id']?.toString(),
    );
  }

  // Create a copy with modified fields
  Note copyWith({
    String? id,
    String? title,
    String? content,
    bool? isFavorite,
    DateTime? createdAt,
    String? userId,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      is_favorite: isFavorite ?? this.is_favorite,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }
}