import 'package:flutter/material.dart';
import '../utils/validation_utils.dart';

class DatePickerField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(DateTime?)? validator;

  const DatePickerField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          controller.text = pickedDate.toIso8601String().split('T')[0]; // Format as YYYY-MM-DD
        }
      },
      validator: (_) => validator?.call(controller.text.isEmpty ? null : DateTime.tryParse(controller.text)),
    );
  }
}