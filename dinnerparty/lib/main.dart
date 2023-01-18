import 'package:dinnerparty/constants/routes.dart';
import 'package:dinnerparty/services/auth/bloc/auth_bloc.dart';
import 'package:dinnerparty/services/auth/bloc/auth_event.dart';
import 'package:dinnerparty/services/auth/bloc/auth_state.dart';
import 'package:dinnerparty/services/auth/firebase_auth_provider.dart';
import 'package:dinnerparty/views/posts/create_update_post_view.dart';
import 'package:dinnerparty/views/posts/posts_view.dart';
import 'package:dinnerparty/views/login_view.dart';
import 'package:dinnerparty/views/register_view.dart';
import 'package:dinnerparty/views/verify_email_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'dart:developer' as devtools show log;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        createOrUpdatePostRoute: (context) => const CreateUpdatePostView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocBuilder<AuthBloc, AuthState>(builder: ((context, state) {
      if (state is AuthStateLoggedIn) {
        return const HomeView();
      } else if (state is AuthStateNeedsVerification) {
        return const VerifyEmailView();
      } else if (state is AuthStateLoggedOut) {
        return const LoginView();
      } else if (state is AuthStateRegistering) {
        return const RegisterView();
      } else {
        return const Scaffold(
          body: CircularProgressIndicator(),
        );
      }
    }));
  }
}
