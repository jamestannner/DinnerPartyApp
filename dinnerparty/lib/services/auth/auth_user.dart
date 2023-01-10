import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';

@immutable
class AuthUser {
  final bool isUserVerified;
  const AuthUser({required this.isUserVerified});

  factory AuthUser.fromFirebase(User user) =>
      AuthUser(isUserVerified: user.emailVerified);
}
