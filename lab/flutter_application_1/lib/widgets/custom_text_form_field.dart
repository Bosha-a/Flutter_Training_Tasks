import 'package:flutter/material.dart';
import '../utils/validation_utils.dart';

class CustomTextFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool isValid;

  const CustomTextFormField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.isValid = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: isValid ? Colors.green : Colors.red,
          ),
        ),
        suffixIcon: isValid ? Icon(Icons.check, color: Colors.green) : null,
      ),
      validator: validator,
      onChanged: (_) => (context as Element).markNeedsBuild(),
    );
  }
}