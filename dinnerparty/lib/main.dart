import 'package:dinnerparty/constants/routes.dart';
import 'package:dinnerparty/services/auth/auth_service.dart';
import 'package:dinnerparty/views/posts/create_update_post_view.dart';
import 'package:dinnerparty/views/posts/posts_view.dart';
import 'package:dinnerparty/views/login_view.dart';
import 'package:dinnerparty/views/register_view.dart';
import 'package:dinnerparty/views/verify_email_view.dart';
import 'package:flutter/material.dart';
// import 'dart:developer' as devtools show log;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        homeRoute: (context) => const HomeView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        createOrUpdatePostRoute: (context) => const CreateUpdatePostView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isUserVerified) {
                return const HomeView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
