import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'services/local_auth_service.dart';
import 'cubits/auth_cubit.dart';
import 'views/register_screen.dart';
import 'views/login_screen.dart';
import 'views/forgot_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = LocalAuthService();
  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final LocalAuthService authService;

  const MyApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(authService),
      child: MaterialApp(
        title: 'News App',
        theme: ThemeData(primarySwatch: Colors.blue),
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot_password': (context) => const ForgotPasswordScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('News App')),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Welcome, ${state.user.firstName}!'),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthCubit>().logout(LogoutEvent());
                    },
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Not authenticated'));
        },
      ),
    );
  }
}