import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';

@immutable
class AuthUser {
  final bool isUserVerified;
  final String? id;
  const AuthUser({required this.id, required this.isUserVerified});

  factory AuthUser.fromFirebase(User user) => AuthUser(
        isUserVerified: user.emailVerified,
        id: user.email,
      );
}
