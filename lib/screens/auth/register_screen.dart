import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() {
    return _RegisterScreenState();
  }
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  void togglePasswordVisibility() {
    setState(() {
      _isPasswordHidden = !_isPasswordHidden;
    });
  }

  void toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
    });
  }

  Future<void> registerUser() async {
    bool isValid;

    isValid = _formKey.currentState!.validate();

    if (isValid == false) {
      return;
    }

    AuthProvider authProvider;

    authProvider = context.read<AuthProvider>();

    bool success;

    success = await authProvider.register(
      _emailController.text,
      _passwordController.text,
      _usernameController.text,
    );

    if (!mounted) {
      return;
    }

    if (success == true) {
      showSuccessDialog();
    } else {
      showErrorDialog(authProvider.getErrorMessage());
    }
  }

  void showSuccessDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: 'Account Created',
      desc: 'Your Roamly account has been created successfully.',
      btnOkText: 'Go to Login',
      btnOkColor: AppColors.brown,
      btnOkOnPress: () {
        Navigator.pop(context);
      },
    ).show();
  }

  void showErrorDialog(String? message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      title: 'Registration Failed',
      desc: message ?? 'Unable to create your account.',
      btnOkText: 'Try Again',
      btnOkColor: AppColors.brown,
      btnOkOnPress: () {},
    ).show();
  }

  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required.';
    }

    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters.';
    }

    return null;
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

  String? validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please confirm your password.';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match.';
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 5),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.brown,
                    ),
                  ),
                ),

                Image.asset(
                  'assets/images/duck_register.png',
                  height: 450,
                  fit: BoxFit.contain,
                ),

                CustomTextField(
                  controller: _usernameController,
                  label: 'Username',
                  hint: 'Enter your username',
                  icon: Icons.person_rounded,
                  validator: validateUsername,
                ),

                const SizedBox(height: 20),

                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter your email',
                  icon: Icons.email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail,
                ),

                const SizedBox(height: 20),

                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Create a password',
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

                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  icon: Icons.verified_user_rounded,
                  obscureText: _isConfirmPasswordHidden,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordHidden
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: AppColors.brown,
                    ),
                    onPressed: toggleConfirmPasswordVisibility,
                  ),
                  validator: validateConfirmPassword,
                ),

                const SizedBox(height: 36),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: CustomButton(
                    text: 'Sign in',
                    isLoading: authProvider.getIsLoading(),
                    onPressed: registerUser,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}