import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/main_shell.dart';
import 'services/saved_store.dart';

const Color pinlyRed = Color(0xFFE60023);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await savedStore.load(); // load saved pins from local storage
  runApp(const PinlyApp());
}

class PinlyApp extends StatelessWidget {
  const PinlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: pinlyRed,
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Pinly',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.poppins(
            color: pinlyRed,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: pinlyRed,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ),
      home: const MainShell(),
    );
  }
}
