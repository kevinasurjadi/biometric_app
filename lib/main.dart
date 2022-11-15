import 'dart:developer';

import 'package:biometricx/biometricx.dart' as biometricX;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart' as localAuth;
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late localAuth.LocalAuthentication _localAuthentication;
  bool _canCheckBiometrics = false;
  List<localAuth.BiometricType> _availableBiometrics = [];
  bool _biometricxEnabled = false;
  biometricX.BiometricType? _biometricXType;

  final GlobalKey<ScaffoldMessengerState> scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    _localAuthentication = localAuth.LocalAuthentication();
    _checkBiometrics();
    super.initState();
  }

  void _checkBiometrics() async {
    _canCheckBiometrics = await _localAuthentication.canCheckBiometrics;
    if (_canCheckBiometrics) {
      _availableBiometrics =
          await _localAuthentication.getAvailableBiometrics();
    }
    _biometricxEnabled = await biometricX.BiometricX.isEnabled;
    _biometricXType = await biometricX.BiometricX.type;
    setState(() {});
  }

  void _authenticate() async {
    try {
      await _localAuthentication.authenticate(
        localizedReason: 'Please authenticate',
        authMessages: [
          const IOSAuthMessages(),
          const AndroidAuthMessages(),
        ],
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
              'Error ${e.code}: ${e.message}, ${e.details}\n${e.stacktrace}'),
        ),
      );
    }
  }

  void _authenticateSticky() async {
    try {
      await _localAuthentication.authenticate(
        localizedReason: 'Please authenticate',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (e) {
      scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
              'Error Sticky ${e.code}: ${e.message}, ${e.details}\n${e.stacktrace}'),
        ),
      );
    }
  }

  void _authenticateBiometricX() async {
    var result = await biometricX.BiometricX.encrypt(
      tag: 'salkuadrat',
      message: 'This is a very secret message',
      returnCipher: true,
    );
    var data = result.data;
    var status = result.status;
    var type = result.type;
    scaffoldKey.currentState!.showSnackBar(SnackBar(
      content: Text('Type: $type\nStatus: $status\nData: $data'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldKey,
      home: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Testing Biometric'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Card(
                  color: Colors.blueAccent,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'LOCAL AUTH:',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          '---',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(text: 'Can Check Biometrics: '),
                              TextSpan(
                                text: '$_canCheckBiometrics'.toUpperCase(),
                                style: TextStyle(
                                  color: _canCheckBiometrics
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(text: 'Available Biometrics: '),
                              TextSpan(
                                text: '$_availableBiometrics',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'BIOMETRICX:',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          '---',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(text: 'Biometric Enabled: '),
                              TextSpan(
                                text: '$_biometricxEnabled'.toUpperCase(),
                                style: TextStyle(
                                  color: _canCheckBiometrics
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(text: 'Biometric Type: '),
                              TextSpan(
                                text: '$_biometricXType',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _authenticate,
                      child: const Text('[LocalAuth] Authenticate'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _authenticateSticky,
                      child: const Text('[LocalAuth] Authenticate with Sticky'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _authenticateBiometricX,
                      child: const Text('[BiometricX] Authenticate'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
