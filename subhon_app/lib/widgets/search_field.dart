import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_text_field.dart';

/// A search box: [onChanged] on every change (debounce it in the view
/// model), a clear button once something is typed.
class SearchField extends StatefulWidget {
  const SearchField({
    required this.hint,
    required this.onChanged,
    required this.clearTooltip,
    this.initialValue = '',
    super.key,
  });

  final String hint;
  final String initialValue;
  final String clearTooltip;
  final ValueChanged<String> onChanged;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final _text = TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _text,
    builder: (context, _) => AppTextField(
      controller: _text,
      hint: widget.hint,
      prefixIcon: Icons.search_rounded,
      textInputAction: TextInputAction.search,
      // The API accepts at most 100 characters in a search.
      inputFormatters: [LengthLimitingTextInputFormatter(100)],
      onChanged: widget.onChanged,
      onSubmitted: widget.onChanged,
      suffix: _text.text.isEmpty
          ? null
          : IconButton(
              tooltip: widget.clearTooltip,
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                _text.clear();
                widget.onChanged('');
              },
            ),
    ),
  );
}
