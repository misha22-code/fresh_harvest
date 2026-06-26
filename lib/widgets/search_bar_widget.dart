// lib/widgets/search_bar_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:fresh_harvest/config/app_constants.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({
    super.key,
    this.hintText,
    this.onChanged,
    this.onClear,
    this.initialValue,
    this.autofocus = false,
    this.onVoiceSearch,  // ✅ Added
  });

  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final String? initialValue;
  final bool autofocus;
  final ValueChanged<String>? onVoiceSearch;  // ✅ Added

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Timer? _debounce;
  bool _isFocused = false;

  // ✅ Voice Search
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  static const _debounceDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode()
      ..addListener(() {
        setState(() => _isFocused = _focusNode.hasFocus);
      });
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (error) {
        if (mounted) setState(() => _isListening = false);
      },
    );
    if (mounted) setState(() => _speechAvailable = available);
  }

  void _toggleListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice search not available on this device.'),
        ),
      );
      return;
    }

    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }

    setState(() => _isListening = true);

    await _speech.listen(
      localeId: 'en_US', // Supports both Urdu and English
      onResult: (result) {
        final text = result.recognizedWords;
        _controller.text = text;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: text.length),
        );
        widget.onChanged?.call(text);
        widget.onVoiceSearch?.call(text);

        if (result.finalResult && mounted) {
          setState(() => _isListening = false);
        }
      },
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _speech.stop();
    super.dispose();
  }

  void _onTextChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () {
      widget.onChanged?.call(value);
    });
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
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(kButtonRadius),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: kShadowColor,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ─── Text Field ──────────────────────────────────────────────────
          Expanded(
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
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✅ Microphone Button
                    if (_speechAvailable)
                      IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                          color: _isListening ? Colors.red : kTextSecondary,
                          size: 22,
                        ),
                        tooltip: 'Voice Search',
                        onPressed: _toggleListening,
                      ),
                    if (_controller.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: kTextSecondary),
                        tooltip: 'Clear',
                        onPressed: _clearText,
                      ),
                  ],
                ),
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
          ),
        ],
      ),
    );
  }
}