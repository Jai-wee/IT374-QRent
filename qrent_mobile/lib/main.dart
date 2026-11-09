import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/app_theme.dart';
import 'models/user_model.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system navigation & status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Check initial login session
  final token = await StorageService.getToken();
  final cachedUser = await StorageService.getCachedUser();

  runApp(QRentApp(
    initialUser: (token != null && cachedUser != null) ? cachedUser : null,
  ));
}

class QRentApp extends StatelessWidget {
  final UserModel? initialUser;

  const QRentApp({super.key, this.initialUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QRent - ระบบยืมคืนอุปกรณ์ด้วย QR Code',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: initialUser != null
          ? MainNavigationScreen(user: initialUser)
          : const LoginScreen(),
    );
  }
}
