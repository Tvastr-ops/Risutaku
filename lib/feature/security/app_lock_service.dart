import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AppLockService {
  static final _auth = LocalAuthentication();

  static Future<bool> canAuthenticate() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return isSupported || canCheck;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> authenticate({
    String localizedReason = 'Please authenticate to unlock Risutaku',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}
