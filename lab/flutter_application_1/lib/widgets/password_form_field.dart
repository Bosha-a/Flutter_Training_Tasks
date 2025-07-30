import 'package:flutter/material.dart';
import '../utils/validation_utils.dart';

class PasswordFormField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const PasswordFormField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
  });

  @override
  _PasswordFormFieldState createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _obscureText = true;
  bool _isValid = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.label,
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: _isValid ? Colors.green : Colors.red,
          ),
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isValid) Icon(Icons.check, color: Colors.green),
            IconButton(
              icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ],
        ),
      ),
      obscureText: _obscureText,
      validator: widget.validator,
      onChanged: (value) {
        setState(() {
          _isValid = ValidationUtils.validatePassword(value) == null;
        });
      },
    );
  }
}