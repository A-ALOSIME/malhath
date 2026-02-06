import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/note_card.dart';
import '../widgets/shared_widgets.dart';
import 'add_edit_note_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<NoteProvider, AuthProvider>(
      builder: (context, noteProvider, authProvider, child) {
        if (noteProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final notes = noteProvider.notes;

        return Scaffold(
          body: notes.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.note_add_outlined,
                  title: 'No notes yet',
                  subtitle: 'Tap + to create your first note',
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return NoteCard(
                        note: note,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditNoteScreen(note: note),
                            ),
                          );
                        },
                        onFavorite: () {
                          noteProvider.toggleFavorite(
                            note,
                            authProvider.currentUser?.id,
                          );
                        },
                        onDelete: () {
                          showDeleteNoteDialog(
                            context,
                            note,
                            noteProvider,
                            authProvider,
                          );
                        },
                      );
                    },
                  ),
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddEditNoteScreen(),
                ),
              );
            },
            backgroundColor: const Color(0xFF4A90E2),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }
}