import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'atl_controller.dart';
import 'database/db_controller.dart';
import 'providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza il database
  await DB.initialize();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: const AtlController(),
    ),
  );
}
