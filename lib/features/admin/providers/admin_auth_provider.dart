import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminAuthNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void login() {
    state = true;
  }

  void logout() {
    state = false;
  }
}

final adminAuthProvider = NotifierProvider<AdminAuthNotifier, bool>(() {
  return AdminAuthNotifier();
});
