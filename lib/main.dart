import 'package:firstindex_webapp/login_ui.dart';
import 'package:firstindex_webapp/sharedata.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
        create: (context) => LoginState(), child: FirstIndexApp()),
  );
}

class FirstIndexApp extends StatelessWidget {
  const FirstIndexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginUi(),
      theme: ThemeData(
        textTheme: GoogleFonts.kanitTextTheme(Theme.of(context).textTheme),
      ),
    );
  }
}
