import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'providers/auth_provider.dart';
import 'auth_success_screen.dart';
import 'animated_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordHidden = true;
  bool _isEmployee = false;
  final Color darkGreen = const Color(0xFF006958);
  final Color lightGreen = const Color(0xFFD4F0DA);
  final Color loginGreen = const Color(0xFFBFE037);
  final Color hintColor = const Color(0xFFB8C7C3);
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  bool _validateInput() {
    if (emailController.text.trim().isEmpty || !emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('invalid_email'.tr())));
      return false;
    }
    if (passwordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('short_password'.tr())));
      return false;
    }
    return true;
  }
  Future<void> _handleSignUp() async {
    if (!_validateInput()) return;
    final authProvider = context.read<AuthProvider>();
    bool success = await authProvider.signUp(emailController.text.trim(), passwordController.text, _isEmployee);
    if (success && mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const AuthSuccessScreen()), (route) => false);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('signup_failed'.tr())));
    }
  }
  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 50),
              Text('get_started'.tr(), textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: darkGreen)),
              const SizedBox(height: 60),
              Text('email'.tr(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkGreen)),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'enter_email'.tr(),
                  hintStyle: TextStyle(color: hintColor, fontWeight: FontWeight.w500),
                  filled: true,
                  fillColor: lightGreen,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 24),
              Text('password'.tr(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkGreen)),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: _isPasswordHidden,
                decoration: InputDecoration(
                  hintText: 'create_password'.tr(),
                  hintStyle: TextStyle(color: hintColor, fontWeight: FontWeight.w500),
                  filled: true,
                  fillColor: lightGreen,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: darkGreen),
                    onPressed: () => setState(() => _isPasswordHidden = !_isPasswordHidden),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: Text("register_employee".tr(), style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold)),
                value: _isEmployee,
                activeColor: darkGreen,
                onChanged: (newValue) => setState(() => _isEmployee = newValue!),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 30),
              isLoading
                  ? Center(child: CircularProgressIndicator(color: darkGreen))
                  : AnimatedButton(
                      onTap: _handleSignUp,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(color: darkGreen, borderRadius: BorderRadius.circular(25)),
                        child: Center(child: Text('signup'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
                      ),
                    ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('already_have_account'.tr(), style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkGreen)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text('login'.tr(), style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: loginGreen)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}