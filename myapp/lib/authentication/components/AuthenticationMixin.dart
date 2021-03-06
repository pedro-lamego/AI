
import 'package:myapp/aspects/failures/failure.dart';
import 'package:myapp/authentication/authManager.dart';
import 'package:myapp/providers.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

mixin Authentication<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool _isLoading = false;

  Future<void> authenticate(
    Future<void> Function(AuthManager authManager) signIn, {
    GlobalKey<FormState> formKey,
    bool ageAndTermsConfirmation = false,
  }) async {
    if (_isLoading) return;
    _isLoading = true;
    try {
      FocusScope.of(context).unfocus();
      _checkConnection();

      if (formKey != null) {
        final isValid = formKey.currentState.validate();
        if (!isValid) return;
      }

      final authManager = ref.read(authManagerProvider);
      await signIn(authManager);
    } catch (e) {
      //showErrorBar(context, e.message);
    }
    _isLoading = false;
  }

  void _checkConnection() {
    final connectivity = ref.read(connectivityProvider);
    if (connectivity == ConnectivityResult.none)
      throw Failure.noConection(context);
  }
}
