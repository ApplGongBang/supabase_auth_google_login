import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'constants/const_data.dart';
import 'routes/route_signin.dart';
import 'routes/route_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: ConstData.supabaseUrl,
    anonKey: ConstData.supabaseAnonKey,
  );

  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/sign_in',
      routes: {
        '/sign_in': (context) => SignInRoute(),
        '/home': (context) => HomeRoute(
              authResponse:
                  ModalRoute.of(context)!.settings.arguments as AuthResponse,
            ),
      },
    );
  }
}
