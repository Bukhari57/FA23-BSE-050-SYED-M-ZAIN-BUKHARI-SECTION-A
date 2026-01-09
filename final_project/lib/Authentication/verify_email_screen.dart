import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../home_page.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;
  int secondsRemaining = 30;
  Timer? cooldownTimer;

  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      startCooldown();
      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    if (isEmailVerified) timer?.cancel();
  }

  Future sendVerificationEmail() async {
    try {
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
      setState(() => canResendEmail = false);
      startCooldown();
      _showSnack("Verification link sent!", Colors.green);
    } catch (e) {
      _showSnack(e.toString(), Colors.red);
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

  void startCooldown() {
    secondsRemaining = 30;
    cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsRemaining == 0) {
        setState(() {
          canResendEmail = true;
          t.cancel();
        });
      } else {
        setState(() => secondsRemaining--);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    cooldownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isEmailVerified) return const HomePage();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.logout_rounded, color: theme.colorScheme.primary),
          onPressed: () => FirebaseAuth.instance.signOut(),
        ),
        title: Text(
          "Verify Email",
          style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onBackground),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Visual Illustration
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mark_email_unread_outlined,
                size: 80,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 40),

            // 2. Information Text
            Text(
              "Almost there!",
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              "A verification link has been sent to\n${FirebaseAuth.instance.currentUser?.email}",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),

            // 3. Waiting Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Waiting for verification...",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                     color: Colors.grey[500],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

            // 4. Action Buttons
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: canResendEmail ? sendVerificationEmail : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  disabledBackgroundColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  canResendEmail
                      ? "RESEND EMAIL"
                      : "RESEND IN ${secondsRemaining}S",
                  style: theme.textTheme.labelLarge?.copyWith(
                     color: canResendEmail ? theme.colorScheme.onPrimary : Colors.grey[500],
                  )
                ),
              ),
            ),

            TextButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              child: Text(
                "Cancel and use another email",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
