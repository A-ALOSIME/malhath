import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/note_card.dart';
import '../widgets/shared_widgets.dart';
import 'add_edit_note_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<NoteProvider, AuthProvider>(
      builder: (context, noteProvider, authProvider, child) {
        final favoriteNotes = noteProvider.favoriteNotes;

        return Scaffold(
          body: favoriteNotes.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.star_border,
                  title: 'No favorite notes',
                  subtitle: 'Mark notes as favorites to see them here',
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: favoriteNotes.length,
                    itemBuilder: (context, index) {
                      final note = favoriteNotes[index];
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
        );
      },
    );
  }
}