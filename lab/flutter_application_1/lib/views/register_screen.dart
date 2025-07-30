import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/auth_cubit.dart';
import '../models/user_model.dart';
import '../utils/validation_utils.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/password_form_field.dart';
import '../widgets/date_picker_field.dart';
import 'package:uuid/uuid.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _securityAnswerController = TextEditingController();
  bool _termsAccepted = false;
  String? _emailError;
  bool _isFormValid = false;
  String? _selectedQuestion;
  final List<String> _securityQuestions = [
    "What's your mother's maiden name?",
    "What was your first pet's name?",
    "What city were you born in?",
  ];

  @override
  void initState() {
    super.initState();
    // Add listeners to all controllers to trigger validation
    _firstNameController.addListener(_updateFormValidity);
    _lastNameController.addListener(_updateFormValidity);
    _emailController.addListener(_validateEmail);
    _phoneController.addListener(_updateFormValidity);
    _dobController.addListener(_updateFormValidity);
    _passwordController.addListener(_updateFormValidity);
    _confirmPasswordController.addListener(_updateFormValidity);
    _securityAnswerController.addListener(_updateFormValidity);
  }

  Future<void> _validateEmail() async {
    final email = _emailController.text;
    if (email.isNotEmpty) {
      context.read<AuthCubit>().checkUserExists(CheckUserExistsEvent(email));
    }
    _updateFormValidity();
  }

  void _updateFormValidity() {
    setState(() {
      _isFormValid =
          _formKey.currentState?.validate() == true &&
          _termsAccepted &&
          _emailError == null &&
          ValidationUtils.validatePassword(_passwordController.text) == null &&
          _passwordController.text == _confirmPasswordController.text &&
          _selectedQuestion != null &&
          _securityAnswerController.text.isNotEmpty;

      // Debug: Log why _isFormValid is false
      if (!_isFormValid) {
        print('Form invalid:');
        print('  Form validates: ${_formKey.currentState?.validate() == true}');
        print('  Terms accepted: $_termsAccepted');
        print('  Email error: $_emailError');
        print('  Password valid: ${ValidationUtils.validatePassword(_passwordController.text) == null}');
        print('  Passwords match: ${_passwordController.text == _confirmPasswordController.text}');
        print('  Security question selected: ${_selectedQuestion != null}');
        print('  Security answer non-empty: ${_securityAnswerController.text.isNotEmpty}');
      }
    });
  }

  void _submitForm() {
    if (_isFormValid) {
      final user = User(
        id: const Uuid().v4(),
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        passwordHash: '', // Will be hashed in LocalAuthService
        phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text,
        dateOfBirth: _dobController.text.isEmpty ? null : DateTime.tryParse(_dobController.text),
        createdAt: DateTime.now(),
        lastLoginAt: null,
        securityQuestion: _selectedQuestion,
        securityAnswer: _securityAnswerController.text,
      );
      context.read<AuthCubit>().register(
        RegisterEvent(
          user,
          _passwordController.text, // Pass raw password
          _selectedQuestion!,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            if (state.message == 'User exists') {
              setState(() {
                _emailError = 'Email is already registered';
              });
            } else if (state.message == 'User does not exist') {
              setState(() {
                _emailError = null;
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
            _updateFormValidity();
          } else if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registration successful!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacementNamed(context, '/home');
          }
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
                  const SizedBox(height: 20),
                  CustomTextFormField(
                    label: 'First Name',
                    controller: _firstNameController,
                    validator: ValidationUtils.validateName,
                    isValid: ValidationUtils.validateName(_firstNameController.text) == null,
                  ),
                  const SizedBox(height: 20),
                  CustomTextFormField(
                    label: 'Last Name',
                    controller: _lastNameController,
                    validator: ValidationUtils.validateName,
                    isValid: ValidationUtils.validateName(_lastNameController.text) == null,
                  ),
                  const SizedBox(height: 20),
                  CustomTextFormField(
                    label: 'Email',
                    controller: _emailController,
                    validator: (value) => _emailError ?? ValidationUtils.validateEmail(value),
                    isValid: ValidationUtils.validateEmail(_emailController.text) == null && _emailError == null,
                  ),
                  const SizedBox(height: 20),
                  CustomTextFormField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    validator: ValidationUtils.validatePhone,
                    isValid: ValidationUtils.validatePhone(_phoneController.text) == null,
                  ),
                  const SizedBox(height: 20),
                  DatePickerField(
                    label: 'Date of Birth',
                    controller: _dobController,
                    validator: ValidationUtils.validateAge,
                  ),
                  const SizedBox(height: 20),
                  PasswordFormField(
                    label: 'Password',
                    controller: _passwordController,
                    validator: ValidationUtils.validatePassword,
                  ),
                  const SizedBox(height: 20),
                  PasswordFormField(
                    label: 'Confirm Password',
                    controller: _confirmPasswordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirm password is required';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Security Question',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedQuestion,
                    items: _securityQuestions
                        .map((question) => DropdownMenuItem(
                              value: question,
                              child: Text(question),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedQuestion = value;
                        _updateFormValidity();
                      });
                    },
                    validator: (value) => value == null ? 'Please select a security question' : null,
                  ),
                  const SizedBox(height: 20),
                  CustomTextFormField(
                    label: 'Security Answer',
                    controller: _securityAnswerController,
                    validator: (value) => value == null || value.isEmpty ? 'Security answer is required' : null,
                    isValid: _securityAnswerController.text.isNotEmpty,
                  ),
                  const SizedBox(height: 20),
                  CheckboxListTile(
                    title: const Text('I accept all the Terms'),
                    value: _termsAccepted,
                    onChanged: (value) {
                      setState(() {
                        _termsAccepted = value ?? false;
                        _updateFormValidity();
                      });
                    },
                  ),
                  if (!_termsAccepted && _formKey.currentState?.validate() == true)
                    const Text(
                      'You must accept the Terms & Conditions',
                      style: TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isFormValid ? _submitForm : null,
                    child: const Text('Register'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text('Already have an account? Login'),
                  ),
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.removeListener(_validateEmail);
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _securityAnswerController.dispose();
    super.dispose();
  }
}