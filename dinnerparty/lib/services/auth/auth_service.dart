import 'package:dinnerparty/services/auth/auth_provider.dart';
import 'package:dinnerparty/services/auth/auth_user.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
  const AuthService(this.provider);

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
}
