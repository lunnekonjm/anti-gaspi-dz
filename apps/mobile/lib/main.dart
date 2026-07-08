import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:anti_gaspi_dz/l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/offers_provider.dart';
import 'providers/donations_provider.dart';
import 'providers/reservations_provider.dart';
import 'providers/dev_provider.dart';
import 'pages/auth/login_page.dart';
import 'pages/shared/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await dotenv.load(fileName: ".env");
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
          return Directionality(
            // Explicit RTL/LTR based on language selection
            textDirection: auth.selectedLanguage == 'ar'
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: MaterialApp(
              title: 'Anti-Gaspi DZ',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme(auth.selectedLanguage),
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
            ),
          );
        },
      ),
    );
  }
}
