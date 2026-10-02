import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordHidden = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  void togglePasswordVisibility() {
    setState(() {
      _isPasswordHidden = !_isPasswordHidden;
    });
  }

  Future<void> loginUser() async {
    bool isValid;

    isValid = _formKey.currentState!.validate();

    if (isValid == false) {
      return;
    }

    AuthProvider authProvider;

    authProvider = context.read<AuthProvider>();

    bool success;

    success = await authProvider.login(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (success == false) {
      showErrorDialog(authProvider.getErrorMessage());
    }
  }

  void showErrorDialog(String? message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      title: 'Login Failed',
      desc: message ?? 'Invalid email or password.',
      btnOkText: 'Try Again',
      btnOkColor: AppColors.brown,
      btnOkOnPress: () {},
    ).show();
  }

  void goToRegisterScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const RegisterScreen();
        },
      ),
    );
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }

    if (!value.contains('@')) {
      return 'Enter a valid email.';
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required.';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider;

    authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 1),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/duck_login.png',
                    height: 450,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 5),

                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'Enter your email',
                    icon: Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: validateEmail,
                  ),

                  const SizedBox(height: 10),

                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Enter your password',
                    icon: Icons.lock_rounded,
                    obscureText: _isPasswordHidden,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordHidden
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: AppColors.brown,
                      ),
                      onPressed: togglePasswordVisibility,
                    ),
                    validator: validatePassword,
                  ),

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    child: CustomButton(
                      text: 'Login',
                      isLoading: authProvider.getIsLoading(),
                      onPressed: loginUser,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Dont have an account?",
                        style: TextStyle(
                          color: AppColors.brown,
                          fontSize: 13,
                          letterSpacing: 2,
                        ),
                      ),
                      TextButton(
                        onPressed: authProvider.getIsLoading()
                            ? null
                            : goToRegisterScreen,
                        child: const Text(
                          'Create account',
                          style: TextStyle(
                            color: AppColors.brown,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}