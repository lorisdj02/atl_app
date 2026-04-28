import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'atl_controller.dart';
import 'providers/account_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AccountProvider())],
      child: const AtlController(),
    ),
  );
}
