import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/note.dart';
import '../services/supabase_service.dart';

class NoteProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  List<Note> _notes = [];
  bool _isLoading = false;

  List<Note> get notes => _notes;
  List<Note> get favoriteNotes =>
      _notes.where((note) => note.is_favorite).toList();
  bool get isLoading => _isLoading;

  NoteProvider() {
    loadNotes();
  }

  // Load notes from local storage
  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getString('local_notes');

    if (notesJson != null) {
      final List<dynamic> decoded = json.decode(notesJson);
      _notes = decoded.map((item) => Note.fromJson(item)).toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Save notes to local storage
  Future<void> _saveToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = json.encode(_notes.map((note) => note.toJson()).toList());
    await prefs.setString('local_notes', notesJson);
  }

  // Add a new note
  Future<void> addNote(Note note, String? userId) async {
    try {
      if (userId != null) {
        // If user is logged in, add to Supabase and get the server note
        final serverNote = await _supabaseService.addNote(note.copyWith(userId: userId));
        _notes.insert(0, serverNote);
      } else {
        // If not logged in, just add locally
        _notes.insert(0, note);
      }
      
      await _saveToLocal();
      notifyListeners();
    } catch (e) {
      // If Supabase fails, still save locally
      debugPrint('Failed to sync note to Supabase: $e');
      _notes.insert(0, note);
      await _saveToLocal();
      notifyListeners();
    }
  }

  // Update a note
  Future<void> updateNote(Note updatedNote, String? userId) async {
    final index = _notes.indexWhere((note) => note.id == updatedNote.id);
    if (index == -1) return;

    // Update locally first
    _notes[index] = updatedNote;
    await _saveToLocal();
    notifyListeners();

    // Sync with Supabase if user is logged in and note has a userId
    if (userId != null && updatedNote.userId != null) {
      try {
        await _supabaseService.updateNote(updatedNote);
      } catch (e) {
        debugPrint('Failed to sync update to Supabase: $e');
      }
    }
  }

  // Delete a note
  Future<void> deleteNote(String noteId, String? userId) async {
    // Find the note first
    final noteIndex = _notes.indexWhere((note) => note.id == noteId);
    if (noteIndex == -1) return;

    final note = _notes[noteIndex];

    // Delete locally first
    _notes.removeAt(noteIndex);
    await _saveToLocal();
    notifyListeners();

    // Delete from Supabase if user is logged in and note has a userId
    if (userId != null && note.userId != null) {
      try {
        await _supabaseService.deleteNote(noteId);
      } catch (e) {
        debugPrint('Failed to sync delete to Supabase: $e');
      }
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite(Note note, String? userId) async {
    final updatedNote = note.copyWith(isFavorite: !note.is_favorite);
    await updateNote(updatedNote, userId);
  }

  // Sync with Supabase when user logs in
  Future<void> syncWithSupabase(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Upload local notes that don't have a userId (offline created notes)
      final localNotesToUpload = _notes.where((note) => note.userId == null).toList();
      
      for (var localNote in localNotesToUpload) {
        try {
          await _supabaseService.addNote(localNote.copyWith(userId: userId));
        } catch (e) {
          debugPrint('Failed to upload local note: $e');
        }
      }

      // Fetch all notes from Supabase (includes newly uploaded ones)
      final supabaseNotes = await _supabaseService.getNotes(userId);
      
      // Update local notes with Supabase data
      _notes = supabaseNotes;
      await _saveToLocal();
      
      debugPrint('Sync completed successfully');
    } catch (e) {
      debugPrint('Sync failed: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Refresh notes from Supabase (useful for pulling latest changes)
  Future<void> refreshFromSupabase(String userId) async {
    try {
      final supabaseNotes = await _supabaseService.getNotes(userId);
      _notes = supabaseNotes;
      await _saveToLocal();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to refresh from Supabase: $e');
    }
  }
}