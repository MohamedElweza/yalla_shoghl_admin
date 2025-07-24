import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:yalla_shogl_admin/screens/home/home.dart';
import 'core/utils/app_colors.dart';
import 'firebase_options.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key,});

  static const title = 'ادارة يلا شغل';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Cairo',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.mainColor),
        textTheme: TextTheme(
          displaySmall: GoogleFonts.cairo(fontSize: 32),
          headlineSmall: GoogleFonts.cairo(fontSize: 20),
          titleLarge: GoogleFonts.cairo(fontSize: 18),
          titleMedium: GoogleFonts.cairo(fontSize: 16),
          titleSmall: GoogleFonts.cairo(fontSize: 14),
          bodyLarge: GoogleFonts.cairo(fontSize: 14),
          bodySmall: GoogleFonts.cairo(fontSize: 12),
        ),
      ),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar', 'AR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeScreen(),
    );
  }
}
