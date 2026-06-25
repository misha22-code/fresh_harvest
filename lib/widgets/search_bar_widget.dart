import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fresh_harvest/config/app_constants.dart';

/// A premium search bar with 300 ms debounce.
///
/// - Beige fill, rounded corners, subtle shadow.
/// - Prefix search icon; animated clear (✕) button when text is non-empty.
/// - [onChanged] is called after the debounce interval — not on every keystroke.
class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({
    super.key,
    this.hintText,
    this.onChanged,
    this.onClear,
    this.initialValue,
    this.autofocus = false,
  });

  final String? hintText;

  /// Called with the current text value after the 300 ms debounce window.
  final ValueChanged<String>? onChanged;

  /// Called when the user taps the clear button (after the field is cleared).
  final VoidCallback? onClear;

  final String? initialValue;
  final bool autofocus;

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Timer? _debounce;
  bool _isFocused = false;

  static const _debounceDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode()
      ..addListener(() {
        setState(() => _isFocused = _focusNode.hasFocus);
      });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () {
      widget.onChanged?.call(value);
    });
    // Trigger rebuild for clear button visibility.
    setState(() {});
  }

  void _clearText() {
    _debounce?.cancel();
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _isFocused ? kPrimaryColor : Colors.transparent;

    return Container(
      decoration: BoxDecoration(
        color: kBeigeColor,
        borderRadius: BorderRadius.circular(kBorderRadius),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: kShadowColor,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        onChanged: _onTextChanged,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: kTextPrimary,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Search fruits & vegetables…',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: kTextSecondary,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: kTextSecondary,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: kTextSecondary),
                  tooltip: 'Clear',
                  onPressed: _clearText,
                )
              : null,
          // Override theme borders so the container border handles focus state.
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: kPadding,
            vertical: 14,
          ),
          filled: false,
        ),
      ),
    );
  }
}
