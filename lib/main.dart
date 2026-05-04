import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'atl_controller.dart';
import 'providers/account_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureLocalTimeZone();
  final AccountProvider accountProvider = AccountProvider();
  accountProvider.bindApiClientToken();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AccountProvider>.value(value: accountProvider),
      ],
      child: const AtlController(),
    ),
  );
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
}
