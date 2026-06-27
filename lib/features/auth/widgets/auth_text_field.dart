import 'package:flutter/material.dart';

/// A reusable, Material 3 styled text field for authentication screens.
class AuthTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final bool enabled;
  final bool readOnly;
  final Iterable<String>? autofillHints;
  final bool isPassword;

  const AuthTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
    this.autofillHints,
    this.isPassword = false,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscureText;

  // Theme constants
  static const Color _primaryGreen = Color(0xFF006B33);
  static const Color _textColor = Color(0xFF1A1A1A);
  static const Color _subtitleColor = Color(0xFF666666);
  static const Color _textFieldFillColor = Color(0xFFF2F4F2);

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: _obscureText,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      focusNode: widget.focusNode,
      autofillHints: widget.autofillHints,
      validator: widget.validator,
      style: const TextStyle(
        fontSize: 15.0,
        color: _textColor,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          color: _subtitleColor,
          fontSize: 15.0,
        ),
        filled: true,
        fillColor: _textFieldFillColor,
        prefixIcon: widget.prefixIcon != null
            ? Icon(
                widget.prefixIcon,
                color: _primaryGreen,
                size: 22.0,
              )
            : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: _subtitleColor,
                  size: 22.0,
                ),
                onPressed: _toggleVisibility,
                splashRadius: 24.0,
              )
            : null,
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black12, width: 1.0),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black12, width: 1.0),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: _primaryGreen, width: 1.5),
        ),
        disabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black12, width: 1.0),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1.0),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
      ),
    );
  }
}
