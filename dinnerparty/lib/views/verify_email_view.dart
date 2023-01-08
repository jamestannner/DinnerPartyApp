import 'package:dinnerparty/constants/routes.dart';
import 'package:dinnerparty/utilities/show_error_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'dart:developer' as devtools show log;

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify email'),
      ),
      body: Column(children: [
        const Text('Please verify your email address:'),
        TextButton(
          onPressed: () async {
            try {
              final user = FirebaseAuth.instance.currentUser;
              await user?.sendEmailVerification();
            } on FirebaseAuthException catch (e) {
              showErrorDialog(
                context,
                'Hmm... Something went wrong\nError: ${e.toString()}',
              );
            }
          },
          child: const Text('Click to resend email verification'),
        ),
        TextButton (
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                (route) => false,
              );
            }
          },
          child: const Text('Reset'),
        ),
      ],
      ),
    );
  }
}
