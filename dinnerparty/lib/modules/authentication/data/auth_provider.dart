import 'package:dinnerparty/modules/authentication/data/auth_user.dart';

abstract class AuthProvider {
  AuthUser? get currentUser;

  Future<void> initialize();

  Future<AuthUser> logIn({
    required String id,
    required String password,
  });

  Future<AuthUser> createUser({
    required String id,
    required String password,
  });

  Future<void> logOut();

  Future<void> sendVerificaion();
  
  Future<void> sendPasswordReset({required String toEmail});
}
