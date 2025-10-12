import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/login_screen.dart';
import 'l10n/app_localizations_delegate.dart';

class AtlController extends StatefulWidget{
  const AtlController({super.key});

  @override
  State<AtlController> createState() => _AtlControllerState();
}

class _AtlControllerState extends State<AtlController>{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ATL App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('it', ''),
      ],
      home: const LoginScreen(),
    );
  }
}