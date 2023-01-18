import 'package:dinnerparty/constants/routes.dart';
import 'package:dinnerparty/helpers/loading/loading_screen.dart';
import 'package:dinnerparty/services/auth/bloc/auth_bloc.dart';
import 'package:dinnerparty/services/auth/bloc/auth_event.dart';
import 'package:dinnerparty/services/auth/bloc/auth_state.dart';
import 'package:dinnerparty/services/auth/firebase_auth_provider.dart';
import 'package:dinnerparty/views/forgot_password_view.dart';
import 'package:dinnerparty/views/posts/create_update_post_view.dart';
import 'package:dinnerparty/views/posts/posts_view.dart';
import 'package:dinnerparty/views/login_view.dart';
import 'package:dinnerparty/views/register_view.dart';
import 'package:dinnerparty/views/verify_email_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'dart:developer' as devtools show log;

Map<int, Color> color = {
  50: const Color.fromRGBO(248, 122, 38, .1),
  100: const Color.fromRGBO(248, 122, 38, .2),
  200: const Color.fromRGBO(248, 122, 38, .3),
  300: const Color.fromRGBO(248, 122, 38, .4),
  400: const Color.fromRGBO(248, 122, 38, .5),
  500: const Color.fromRGBO(248, 122, 38, .6),
  600: const Color.fromRGBO(248, 122, 38, .7),
  700: const Color.fromRGBO(248, 122, 38, .8),
  800: const Color.fromRGBO(248, 122, 38, .9),
  900: const Color.fromRGBO(248, 122, 38, 1),
};

MaterialColor customColor = MaterialColor(0xFFF87A26, color);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: customColor,
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
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen()
              .show(context: context, text: state.loadingText ?? "Loading...");
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        return BlocBuilder<AuthBloc, AuthState>(builder: ((context, state) {
          if (state is AuthStateLoggedIn) {
            return const HomeView();
          } else if (state is AuthStateNeedsVerification) {
            return const VerifyEmailView();
          } else if (state is AuthStateLoggedOut) {
            return const LoginView();
          } else if (state is AuthStateRegistering) {
            return const RegisterView();
          } else if (state is AuthStateForgotPassword) {
            return const ForgotPasswordView();
          } else {
            return const Scaffold(
              body: CircularProgressIndicator(),
            );
          }
        }));
      },
    );
  }
}
