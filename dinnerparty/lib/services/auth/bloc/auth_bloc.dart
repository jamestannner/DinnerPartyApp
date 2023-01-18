import 'package:bloc/bloc.dart';
import 'package:dinnerparty/services/auth/auth_provider.dart';
import 'package:dinnerparty/services/auth/bloc/auth_event.dart';
import 'package:dinnerparty/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateUninitialized()) {
    // send email verification
    on<AuthEventSendEmailVerification>((event, emit) async {
      await provider.sendVerificaion();
      emit(state);
    });

    // register new user
    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;
      try {
        await provider.createUser(
          id: email,
          password: password,
        );
        await provider.sendVerificaion();
        emit(const AuthStateNeedsVerification());
      } on Exception catch (e) {
        emit(AuthStateRegistering(e));
      }
    });

    // initialize
    on<AuthEventInitialize>(
      (event, emit) async {
        await provider.initialize();
        final user = provider.currentUser;
        if (user == null) {
          emit(const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ));
        } else if (!user.isUserVerified) {
          emit(const AuthStateNeedsVerification());
        } else {
          emit(AuthStateLoggedIn(user));
        }
      },
    );

    // log in
    on<AuthEventLogIn>(
      (event, emit) async {
        emit(const AuthStateLoggedOut(exception: null, isLoading: true));
        final email = event.email;
        final password = event.password;

        try {
          final user = await provider.logIn(id: email, password: password);

          if (!user.isUserVerified) {
            emit(const AuthStateLoggedOut(exception: null, isLoading: false));
            emit(const AuthStateNeedsVerification());
          } else {
            emit(const AuthStateLoggedOut(exception: null, isLoading: false));
            emit(AuthStateLoggedIn(user));
          }
        } on Exception catch (e) {
          emit(AuthStateLoggedOut(exception: e, isLoading: false));
        }
      },
    );

    // log out
    on<AuthEventLogOut>(
      (event, emit) async {
        try {
          await provider.logOut();
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
        } on Exception catch (e) {
          emit(AuthStateLoggedOut(exception: e, isLoading: false));
        }
      },
    );
  }
}
