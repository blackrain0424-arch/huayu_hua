import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'services/storage_service.dart';
import 'services/auth_service.dart';
import 'pages/login_page.dart';
import 'pages/main_tab_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService().init();
  await SupabaseService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return MaterialApp(
      title: '华语花',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: false,
      ),
      home: auth.isLoggedIn ? const MainTabPage() : const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
