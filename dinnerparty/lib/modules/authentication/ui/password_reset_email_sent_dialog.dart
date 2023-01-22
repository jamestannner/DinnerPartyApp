import 'package:dinnerparty/components/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog(
      context: context,
      title: 'Password Reset',
      content: 'Password reset link sent. Please check you email.',
      optionsBuilder: () => {
            'Ok': null,
          });
}
