import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../applgongbang/util_debug_log.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key, required this.authResponse});

  final AuthResponse authResponse;

  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  late String userid;
  late String userName;
  late String email;
  late String accessToken;
  late String refreshToken;

  @override
  void initState() {
    super.initState();
    userid = widget.authResponse.user?.id ?? '';
    userName = widget.authResponse.user?.userMetadata?['name'] ?? '';
    email = widget.authResponse.user?.email ?? '';
    accessToken = widget.authResponse.session?.accessToken ?? '';
    refreshToken = widget.authResponse.session?.refreshToken ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          children: [
            Text('userid: $userid'),
            Text('name: $userName'),
            Text('email: $email'),
            Text(
                'accessToken: ${accessToken.length > 20 ? '${accessToken.substring(0, 20)}...' : accessToken}'),
            Text(
                'refreshToken: ${refreshToken.length > 20 ? '${refreshToken.substring(0, 20)}...' : refreshToken}'),
            const SizedBox(height: 20),
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

                // Navigate to the login screen
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('log out'),
            ),
          ],
        ),
      ),
    );
  }
}
