import 'package:dinnerparty/modules/authentication/data/auth_exceptions.dart';
import 'package:dinnerparty/modules/authentication/data/auth_provider.dart';
import 'package:dinnerparty/modules/authentication/data/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('Should not be initalized to begin with', () {
      expect(provider.isInitialized, false);
    });
    test('Cannot log out if not initialized', () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });
    test('Should be able to be initialied', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });
    test('User should be null after initialization', () {
      expect(provider.currentUser, null);
    });
    test(
      'Should be able to initialize in less than 2 seconds',
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );
    test('Create user should delegate to login function', () async {
      final badEmailUser = provider.createUser(
        id: "foo@bar.com",
        password: '#GoodPassword1',
      );
      expect(
        badEmailUser,
        throwsA(const TypeMatcher<UserNotFoundAuthException>()),
      );
      final badPasswordUser = provider.createUser(
        id: 'foobarbaz@example.com',
        password: 'foobar',
      );
      expect(
        badPasswordUser,
        throwsA(const TypeMatcher<WrongPasswordAuthException>()),
      );
      final user = await provider.createUser(
        id: 'foo',
        password: 'bar',
      );
      expect(provider.currentUser, user);
      expect(user.isUserVerified, false);
    });
    test('Logged in user should be able to get verified', () {
      provider.sendVerificaion();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isUserVerified, true);
    });
    test('Should be able to logout and login again', () async {
      await provider.logOut();
      await provider.logIn(
        id: 'email',
        password: 'password',
      );
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
    test('Cannot send password reset if user does not exist', () async {
      expect(
        provider.sendPasswordReset(toEmail: 'foo@bar.com'),
        throwsA(const TypeMatcher<Exception>()),
      );
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String id,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(
      id: id,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String id,
    required String password,
  }) {
    if (!isInitialized) {
      throw NotInitializedException();
    } else if (id == 'foo@bar.com') {
      throw UserNotFoundAuthException();
    } else if (password == 'foobar') {
      throw WrongPasswordAuthException();
    }
    const user = AuthUser(
      isUserVerified: false,
      email: 'foobarbaz@example.com',
      id: 'myID',
    );
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) {
      throw NotInitializedException();
    } else if (_user == null) {
      throw UserNotFoundAuthException();
    }
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendVerificaion() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(
      isUserVerified: true,
      email: 'foobarbaz@example.com',
      id: 'myID',
    );
    _user = newUser;
  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) async {
    if (toEmail == 'foo@bar.com') {
      throw GenericAuthException();
    }
    return;
  }
}
