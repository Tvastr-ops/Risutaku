import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:risutaku/util/theming.dart';
import 'package:risutaku/widget/dialogs.dart';

class NotesLabel extends StatelessWidget {
  const NotesLabel(this.notes);

  final String notes;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) return const SizedBox();

    return SizedBox(
      height: 35,
      child: Tooltip(
        message: 'Comment',
        child: InkResponse(
          radius: Theming.radiusSmall.x,
          child: const Icon(LucideIcons.stickyNote, size: Theming.iconSmall),
          onTap: () => showDialog(
            context: context,
            builder: (context) => TextDialog(title: 'Comment', text: notes),
          ),
        ),
      ),
    );
  }
}
