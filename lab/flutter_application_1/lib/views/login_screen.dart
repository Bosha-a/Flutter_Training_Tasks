import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/auth_cubit.dart';
import '../utils/validation_utils.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/password_form_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _updateFormValidity();
  }

  void _updateFormValidity() {
    setState(() {
      _isFormValid =
          _formKey.currentState?.validate() == true &&
          ValidationUtils.validateEmail(_emailController.text) == null &&
          ValidationUtils.validatePassword(_passwordController.text) == null;
    });
  }

  void _submitForm() {
    if (_isFormValid) {
      context.read<AuthCubit>().login(
        LoginEvent(
          _emailController.text,
          _passwordController.text,
          _rememberMe,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login successful!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacementNamed(context, '/home');
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
                  const Text(
                    'News App',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 50),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return state is AuthLoading
                          ? const Center(child: CircularProgressIndicator())
                          : const SizedBox.shrink();
                    },
                  ),
                  CustomTextFormField(
                    label: 'Write Your Email here..',
                    controller: _emailController,
                    validator: ValidationUtils.validateEmail,
                    isValid:
                        ValidationUtils.validateEmail(_emailController.text) ==
                        null,
                  ),
                  const SizedBox(height: 20),
                  PasswordFormField(
                    label: 'Write Your Password here..',
                    controller: _passwordController,
                    validator: ValidationUtils.validatePassword,
                  ),
                  CheckboxListTile(
                    title: const Text('Remember Me'),
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _isFormValid ? _submitForm : null,
                    child: const Text('Login'),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/forgot_password'),
                    child: const Text('Forgot Password?'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: const Text('Don\'t have an account? Register'),
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
