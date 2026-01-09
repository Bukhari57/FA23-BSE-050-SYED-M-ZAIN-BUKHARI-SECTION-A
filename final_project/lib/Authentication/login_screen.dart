import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool isLogin = true;
  bool isLoading = false;
  bool _obscurePassword = true;

  void handleSubmit() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnack("Please fill in all fields", Colors.orange);
      return;
    }

    setState(() => isLoading = true);

    try {
      if (isLogin) {
        await _authService.login(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        var user = await _authService.signUp(
          _emailController.text,
          _passwordController.text,
        );
        if (user != null) await user.sendEmailVerification();
        _showSnack("Verification email sent!", Colors.green);
      }
    } on FirebaseAuthException catch (e) {
      _showSnack(_getFriendlyError(e.code), Colors.red);
    } catch (e) {
      _showSnack("Error: ${e.toString()}", Colors.red);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  String _getFriendlyError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return "Email already registered.";
      case 'invalid-credential':
        return "Incorrect email or password.";
      case 'user-not-found':
        return "Account does not exist.";
      case 'weak-password':
        return "Password is too weak.";
      default:
        return "Authentication failed ($code)";
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Hero Header
            _buildHeader(context),

            // 2. Form Section
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildTextField(
                    context: context,
                    controller: _emailController,
                    label: "Email Address",
                    icon: Icons.email_outlined,
                    type: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    context: context,
                    controller: _passwordController,
                    label: "Password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),

                  if (isLogin)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {}, // forgetPassword logic
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),

                  // 3. Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              isLogin ? "LOGIN" : "CREATE ACCOUNT",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 4. Toggle Link
                  TextButton(
                    onPressed: () => setState(() => isLogin = !isLogin),
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: isLogin
                                ? "New to the platform? "
                                : "Already have an account? ",
                          ),
                          TextSpan(
                            text: isLogin ? "Sign Up" : "Login",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
            Theme.of(context).colorScheme.primary,
          ],
        ),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(80)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 100,
            left: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.storefront_rounded,
                  color: Colors.white,
                  size: 50,
                ),
                const SizedBox(height: 20),
                Text(
                  isLogin ? "Welcome\nBack" : "Join\nUs",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 36,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType type = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}
