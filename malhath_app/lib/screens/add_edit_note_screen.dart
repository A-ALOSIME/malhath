import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../providers/auth_provider.dart';
import 'package:uuid/uuid.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _isFavorite = widget.note!.is_favorite;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Note' : 'New Note',
          style: GoogleFonts.cairo(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Title',
                hintStyle: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade400,
                ),
                border: InputBorder.none,
              ),
              style: GoogleFonts.cairo(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
            ),
            const Divider(),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: 'Start typing...',
                  hintStyle: GoogleFonts.cairo(
                    fontSize: 18,
                    color: Colors.grey.shade400,
                  ),
                  border: InputBorder.none,
                ),
                style: GoogleFonts.cairo(fontSize: 18),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveNote,
        backgroundColor: const Color(0xFF4A90E2),
        icon: const Icon(Icons.save, color: Colors.white),
        label: Text(
          'Save',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a title or content')),
      );
      return;
    }

    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (widget.note != null) {
      // Update existing note
      final updatedNote = widget.note!.copyWith(
        title: _titleController.text,
        content: _contentController.text,
        isFavorite: _isFavorite,
      );
      await  noteProvider.updateNote(updatedNote, authProvider.currentUser?.id);
    } else {
      // Create new note
      final newNote = Note(
        id: const Uuid().v4(),
        title: _titleController.text,
        content: _contentController.text,
        is_favorite: _isFavorite,
        userId: authProvider.currentUser?.id,
      );
     await noteProvider.addNote(newNote, authProvider.currentUser?.id);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.note != null ? 'Note updated!' : 'Note saved!'),
      ),
    );
  }
}