import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yalla_shogl_admin/screens/home/home.dart';
import 'package:yalla_shogl_admin/screens/registration/widgets/custom_text_field.dart';
import '../../core/providers/password_visibility_provider.dart';
import '../../core/utils/app_colors.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(child: SignInForm()),
        ),
      ),
    );
  }
}

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  void showSnack(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  /// 🔑 Firebase Sign-In
  Future<void> firebaseSignIn() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showSnack('يرجى إدخال البريد الإلكتروني وكلمة المرور');
      return;
    }

    setState(() => isLoading = true);

    try {
      // Sign in with Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save login status locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      // Navigate to Home
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'حدث خطأ أثناء تسجيل الدخول';

      if (e.code == 'user-not-found') {
        errorMessage = 'المستخدم غير موجود';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'كلمة المرور غير صحيحة';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'البريد الإلكتروني غير صالح';
      }

      showSnack(errorMessage);
    } catch (e) {
      showSnack('فشل تسجيل الدخول: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 120),
        const Text(
          'تسجيل الدخول',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        CustomTextField(
          controller: emailController,
          hintText: 'البريد الإلكتروني',
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 25),
        Consumer<PasswordVisibilityProvider>(
          builder: (context, provider, _) {
            return CustomTextField(
              controller: passwordController,
              hintText: 'كلمة السر',
              icon: Icons.lock_outline,
              isPassword: true,
              textInputAction: TextInputAction.done,
              obscureText: !provider.isPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  provider.isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: provider.togglePasswordVisibility,
              ),
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'كلمة السر يجب أن تكون على الأقل 6 أحرف';
                }
                return null;
              },
            );
          },
        ),
        const SizedBox(height: 50),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: firebaseSignIn,
                child: const Text(
                  'تسجيل الدخول',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
