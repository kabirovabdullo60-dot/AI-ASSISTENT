import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/l10n.dart';
import '../core/theme/app_dimensions.dart';

/// Text field with a label above it, consistent across all forms.
class AppTextField extends StatefulWidget {
  const AppTextField({
    this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.autofillHints,
    this.prefixIcon,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.maxLength,
    this.autofocus = false,
    this.focusNode,
    this.textAlign = TextAlign.start,
    this.style,
    this.compact = false,
    super.key,
  });

  /// A lower field (about 44 pt instead of 56), e.g. on the login screen.
  final bool compact;

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? initialValue;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final IconData? prefixIcon;

  /// Custom leading widget (e.g. `+992`); takes precedence over [prefixIcon].
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;
  final int? maxLength;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextAlign textAlign;
  final TextStyle? style;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget? suffix = widget.suffix;
    if (widget.obscureText) {
      suffix = IconButton(
        tooltip: _obscured
            ? context.l10n.fieldShowPassword
            : context.l10n.fieldHidePassword,
        icon: Icon(
          _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
        onPressed: () => setState(() => _obscured = !_obscured),
        iconSize: widget.compact ? 20 : null,
        visualDensity: widget.compact ? VisualDensity.compact : null,
      );
    }

    final field = TextFormField(
      controller: widget.controller,
      initialValue: widget.initialValue,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      autofillHints: widget.autofillHints,
      obscureText: _obscured,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      textAlign: widget.textAlign,
      style: widget.style ?? theme.textTheme.bodyLarge,
      autovalidateMode: AutovalidateMode.onUserInteractionIfError,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon:
            widget.prefix ??
            (widget.prefixIcon == null
                ? null
                : Icon(widget.prefixIcon, size: 20)),
        suffixIcon: suffix,
        counterText: '',
        isDense: widget.compact ? true : null,
        contentPadding: widget.compact
            ? const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 12,
              )
            : null,
        suffixIconConstraints: widget.compact
            ? const BoxConstraints(minWidth: 40, minHeight: 40)
            : null,
      ),
    );

    final label = widget.label;
    if (label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        field,
      ],
    );
  }
}
