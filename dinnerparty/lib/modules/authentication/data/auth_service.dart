import 'package:dinnerparty/modules/authentication/data/auth_provider.dart';
import 'package:dinnerparty/modules/authentication/data/auth_user.dart';
import 'package:dinnerparty/modules/authentication/data/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
  const AuthService(this.provider);

  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  @override
  Future<AuthUser> createUser({
    required String id,
    required String password,
  }) =>
      provider.createUser(id: id, password: password);

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> logIn({
    required String id,
    required String password,
  }) =>
      provider.logIn(id: id, password: password);

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<void> sendVerificaion() => provider.sendVerificaion();

  @override
  Future<void> initialize() => provider.initialize();

  @override
  Future<void> sendPasswordReset({required String toEmail}) =>
      provider.sendPasswordReset(toEmail: toEmail);
}
