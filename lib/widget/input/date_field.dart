import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:otraku/extension/date_time_extension.dart';
import 'package:otraku/util/theming.dart';

class DateField extends StatefulWidget {
  const DateField({required this.label, required this.value, required this.onChanged});

  final String label;
  final DateTime? value;
  final Function(DateTime?) onChanged;

  @override
  State<DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  late DateTime? _value = widget.value;
  late final _ctrl = TextEditingController(text: _value?.formattedDate ?? '');

  @override
  void didUpdateWidget(covariant DateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _value = widget.value;
    final text = _value?.formattedDate ?? '';
    if (_ctrl.text != text) _ctrl.text = text;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      controller: _ctrl,
      textAlign: TextAlign.center,
      style: TextTheme.of(context).bodyMedium,
      onTap: () => showDatePicker(
        context: context,
        initialDate: _value ?? DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(3000),
        barrierDismissible: true,
        builder: (context, child) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Theme(
            data: (isDark ? ThemeData.dark() : ThemeData.light()).copyWith(
              colorScheme: ColorScheme.of(context),
              dialogTheme: DialogThemeData(backgroundColor: ColorScheme.of(context).surface),
            ),
            child: child!,
          );
        },
      ).then((pickedDate) {
        if (pickedDate == null) return;

        _value = pickedDate;
        _ctrl.text = _value?.formattedDate ?? '';
        widget.onChanged(pickedDate);
      }),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextTheme.of(context).bodyMedium,
        border: const OutlineInputBorder(),
        suffixIcon: Semantics(
          button: true,
          child: Material(
            color: Colors.transparent,
            child: InkResponse(
              radius: Theming.radiusSmall.x,
              child: const Tooltip(message: 'Clear', child: Icon(LucideIcons.x)),
              onTap: () {
                _ctrl.text = '';
                widget.onChanged(null);
              },
            ),
          ),
        ),
      ),
    );
  }
}
