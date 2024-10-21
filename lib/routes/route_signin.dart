import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../applgongbang/util_debug_log.dart';
import '../constants/const_data.dart';

class SignInRoute extends StatelessWidget {
  SignInRoute({super.key});

  // It's handy to then extract the Supabase client in a variable for later uses
  final supabase = Supabase.instance.client;

  Future<AuthResponse> _googleSignIn() async {
    /// Web Client ID that you registered with Google Cloud.
    const webClientId = ConstData.gcpWebClientId;

    /// iOS Client ID that you registered with Google Cloud.
    const iosClientId = ConstData.gcpIosClientId;

    // Google sign in on Android will work without providing the Android
    // Client ID registered on Google Cloud.

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );
    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null) {
      throw 'No Access Token found.';
    }
    if (idToken == null) {
      throw 'No ID Token found.';
    }

    return supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign-in'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  AuthResponse authResponse = await _googleSignIn();
                  if (authResponse.session != null) {
                    Navigator.pushNamed(context, '/home',
                        arguments: authResponse);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('로그인 세션이 없습니다.')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('로그인 중 오류가 발생했습니다: $e')),
                  );
                }
              },
              child: const Text('Google Sign In'),
            ),
            SizedBox(height: 200),
            ElevatedButton(
              onPressed: () async {
                // Attempt to sign out from Google
                try {
                  final GoogleSignIn googleSignIn = GoogleSignIn();
                  await googleSignIn.signOut();
                } catch (e) {
                  applGbDebugLog('Error occurred during Google sign-out: $e');
                  // Proceed with Supabase sign-out regardless of Google sign-out result
                }

                // Supabase Logout
                try {
                  await Supabase.instance.client.auth.signOut();
                } catch (e) {
                  applGbDebugLog('Error occurred during Supabase sign-out: $e');
                  throw Exception('Supabase sign-out failed');
                }

                applGbDebugLog('Logout completed');
              },
              child: const Text('log out'),
            ),
          ],
        ),
      ),
    );
  }
}
