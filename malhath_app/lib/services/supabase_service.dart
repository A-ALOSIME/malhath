import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Add a note to Supabase and return the created note with server-generated ID
  Future<Note> addNote(Note note) async {
    final noteData = {
      'title': note.title,
      'content': note.content,
      'is_favorite': note.is_favorite,
      'user_id': note.userId,
    };
    
    final response = await _supabase
        .from('notes')
        .insert(noteData)
        .select()
        .single();
    
    return Note.fromJson(response);
  }

  // Get all notes for a user
  Future<List<Note>> getNotes(String userId) async {
    final response = await _supabase
        .from('notes')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((item) => Note.fromJson(item)).toList();
  }

  // Update a note
  Future<void> updateNote(Note note) async {
    final updateData = {
      'title': note.title,
      'content': note.content,
      'is_favorite': note.is_favorite,
    };
    
    await _supabase
        .from('notes')
        .update(updateData)
        .eq('id', note.id!);
  }

  // Delete a note
  Future<void> deleteNote(String noteId) async {
    await _supabase
        .from('notes')
        .delete()
        .eq('id', noteId);
  }
}