import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/auth_cubit.dart';
import '../cubits/auth_state.dart';
import '../models/user_model.dart';
import '../services/local_auth_service.dart';
import '../theme/app_colors.dart';
import '../utils/validation_utils.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/date_picker_field.dart';
import '../widgets/password_form_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dobController = TextEditingController();

  bool _termsAccepted = false;
  DateTime? _selectedDob;

  void _submit() {
    if (_formKey.currentState!.validate() && _termsAccepted) {
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        passwordHash: LocalAuthService().hashPassword(
          _passwordController.text,
          DateTime.now().millisecondsSinceEpoch.toString(),
        ),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        dateOfBirth: _selectedDob,
        createdAt: DateTime.now(),
      );

      context.read<AuthCubit>().register(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthRegistered) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Registration successful!")),
            );
            Navigator.pop(context);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    CustomTextFormField(
                      controller: _firstNameController,
                      label: 'First Name',
                      validator: ValidationUtils.validateName,
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      controller: _lastNameController,
                      label: 'Last Name',
                      validator: ValidationUtils.validateName,
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      controller: _emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: ValidationUtils.validateEmail,
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      controller: _phoneController,
                      label: 'Phone (optional)',
                      keyboardType: TextInputType.phone,
                      validator: ValidationUtils.validatePhone,
                    ),
                    const SizedBox(height: 12),
                    DatePickerField(
                      controller: _dobController,
                      label: 'Date of Birth (optional)',
                      onDateSelected: (date) => _selectedDob = date,
                    ),
                    const SizedBox(height: 12),
                    PasswordFormField(
                      controller: _passwordController,
                      label: 'Password',
                      validator: ValidationUtils.validatePassword,
                    ),
                    const SizedBox(height: 12),
                    PasswordFormField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      validator: (value) => value != _passwordController.text
                          ? 'Passwords do not match'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: _termsAccepted,
                          onChanged: (val) =>
                              setState(() => _termsAccepted = val!),
                          activeColor: AppColors.primary,
                        ),
                        const Expanded(
                          child: Text("I agree to the Terms and Conditions"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: (_termsAccepted && state is! AuthLoading)
                          ? _submit
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state is AuthLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Register",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    super.dispose();
  }
}
