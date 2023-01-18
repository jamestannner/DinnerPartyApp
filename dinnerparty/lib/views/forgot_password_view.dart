import 'package:dinnerparty/services/auth/bloc/auth_bloc.dart';
import 'package:dinnerparty/services/auth/bloc/auth_event.dart';
import 'package:dinnerparty/services/auth/bloc/auth_state.dart';
import 'package:dinnerparty/utilities/dialogs/error_dialog.dart';
import 'package:dinnerparty/utilities/dialogs/password_reset_email_sent_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.exception != null) {
            await showErrorDialog(context,
                'An error has occured. Please ensure a user exists with that email and try again');
          } else if (state.hasSentEmail) {
            _controller.clear();
            await showPasswordResetSentDialog(context);
            // } else if (state.exception != null) {
            //   await showErrorDialog(
            //       context, 'Could not find a user with that email');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reset password'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text('Enter an email to reset your password'),
              TextField(
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofocus: true,
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Your email adress...',
                ),
              ),
              TextButton(
                onPressed: (() {
                  final email = _controller.text;
                  context
                      .read<AuthBloc>()
                      .add(AuthEventForgotPassword(email: email));
                }),
                child: const Text('Send'),
              ),
              TextButton(
                  onPressed: (() {
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  }),
                  child: const Text('Return to log in')),
            ],
          ),
        ),
      ),
    );
  }
}
