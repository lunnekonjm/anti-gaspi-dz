import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:anti_gaspi_dz/l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
// Closes A1-08: dotenv removed — use --dart-define for build-time config

import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/offers_provider.dart';
import 'providers/donations_provider.dart';
import 'providers/reservations_provider.dart';
import 'providers/dev_provider.dart';
import 'pages/auth/login_page.dart';
import 'pages/shared/home_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  await Hive.initFlutter();
  await Hive.openBox('settings_box');
  // Closes A1-08: .env no longer bundled — API_URL set via --dart-define
  runApp(const AntiGaspiApp());
}

class AntiGaspiApp extends StatelessWidget {
  const AntiGaspiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OffersProvider()),
        ChangeNotifierProvider(create: (_) => DonationsProvider()),
        ChangeNotifierProvider(create: (_) => ReservationsProvider()),
        ChangeNotifierProvider(create: (_) => DevProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final locale = Locale(auth.selectedLanguage);
          return MaterialApp(
            title: 'Anti-Gaspi DZ',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(auth.selectedLanguage),
            darkTheme: AppTheme.darkTheme(auth.selectedLanguage),
            themeMode: ThemeMode.system,
            locale: locale,
            supportedLocales: const [
              Locale('fr'),
              Locale('ar'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: auth.isAuthenticated
                ? const HomePage()
                : const LoginPage(),
          );
        },
      ),
    );
  }
}
