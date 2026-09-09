import 'package:flutter/material.dart';
import 'package:risutaku/util/theming.dart';
import 'package:risutaku/util/debounce.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    required this.value,
    required this.hint,
    required this.onChanged,
    this.focusNode,
    this.debounce = false,
  });

  final String value;
  final String hint;
  final void Function(String) onChanged;
  final FocusNode? focusNode;
  final bool debounce;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final _ctrl = TextEditingController(text: widget.value);
  late final _debounce = widget.debounce ? Debounce() : null;

  @override
  void didUpdateWidget(covariant SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_ctrl.text != widget.value) _ctrl.text = widget.value;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Search',
      child: TextField(
        controller: _ctrl,
        focusNode: widget.focusNode,
        style: TextTheme.of(context).bodyMedium,
        onChanged: (val) {
          if (val.isEmpty) {
            _debounce?.cancel();
            widget.onChanged('');
            return;
          }

          if (_debounce != null) {
            _debounce.run(() => widget.onChanged(val));
          } else {
            widget.onChanged(val);
          }
        },
        decoration: InputDecoration(
          isDense: false,
          hintText: widget.hint,
          filled: true,
          fillColor: ColorScheme.of(context).surfaceContainerHighest,
          contentPadding: const .only(left: 15),
          constraints: const BoxConstraints(minHeight: 35, maxHeight: 40),
          suffixIcon: _ctrl.text.isNotEmpty
              ? IconButton(
                  tooltip: 'Clear',
                  iconSize: Theming.iconSmall,
                  icon: const Icon(Icons.close_rounded),
                  color: ColorScheme.of(context).onSurface,
                  padding: const .all(0),
                  onPressed: () {
                    _ctrl.clear();
                    _debounce?.cancel();
                    widget.onChanged('');
                  },
                )
              : null,
        ),
      ),
    );
  }
}
