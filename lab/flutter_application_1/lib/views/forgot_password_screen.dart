import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/auth_cubit.dart';
import '../utils/validation_utils.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/password_form_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _securityAnswerController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _securityQuestion;
  bool _isEmailValid = false;
  bool _isAnswerValid = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _updateFormValidity();
  }

  void _updateFormValidity() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() == true &&
          _isEmailValid &&
          (_securityQuestion == null || _securityAnswerController.text.isNotEmpty) &&
          (_isAnswerValid || _newPasswordController.text.isNotEmpty);
    });
  }

  void _checkEmail() {
    if (ValidationUtils.validateEmail(_emailController.text) == null) {
      context.read<AuthCubit>().getSecurityQuestion(GetSecurityQuestionEvent(_emailController.text));
    }
  }

  void _verifyAnswer() {
    if (_securityAnswerController.text.isNotEmpty) {
      context.read<AuthCubit>().verifySecurityAnswer(
          VerifySecurityAnswerEvent(_emailController.text, _securityAnswerController.text));
    }
  }

  void _resetPassword() {
    if (_isFormValid) {
      context.read<AuthCubit>().resetPassword(
          ResetPasswordEvent(_emailController.text, _newPasswordController.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
            if (state.message == 'No user found with this email') {
              setState(() {
                _isEmailValid = false;
                _securityQuestion = null;
              });
            }
          } else if (state is AuthSecurityQuestion) {
            setState(() {
              _securityQuestion = state.question.isEmpty ? null : state.question;
              _isEmailValid = state.question.isNotEmpty;
            });
          } else if (state is AuthUnauthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password reset successful!'), backgroundColor: Colors.green),
            );
            Navigator.pushReplacementNamed(context, '/login');
          }
          _updateFormValidity();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            onChanged: _updateFormValidity,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return state is AuthLoading
                          ? const Center(child: CircularProgressIndicator())
                          : const SizedBox.shrink();
                    },
                  ),
                  CustomTextFormField(
                    label: 'Email *',
                    controller: _emailController,
                    validator: ValidationUtils.validateEmail,
                    isValid: _isEmailValid,
                  ),
                  ElevatedButton(
                    onPressed: _emailController.text.isNotEmpty ? _checkEmail : null,
                    child: const Text('Check Email'),
                  ),
                  if (_securityQuestion != null) ...[
                    const SizedBox(height: 20),
                    Text(_securityQuestion!, style: const TextStyle(fontSize: 16)),
                    CustomTextFormField(
                      label: 'Security Answer *',
                      controller: _securityAnswerController,
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Security answer is required' : null,
                      isValid: _securityAnswerController.text.isNotEmpty,
                    ),
                    ElevatedButton(
                      onPressed: _securityAnswerController.text.isNotEmpty ? _verifyAnswer : null,
                      child: const Text('Verify Answer'),
                    ),
                  ],
                  if (_isAnswerValid) ...[
                    const SizedBox(height: 20),
                    PasswordFormField(
                      label: 'New Password *',
                      controller: _newPasswordController,
                      validator: ValidationUtils.validatePassword,
                    ),
                    ElevatedButton(
                      onPressed: _isFormValid ? _resetPassword : null,
                      child: const Text('Reset Password'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _securityAnswerController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }
}