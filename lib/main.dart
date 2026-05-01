import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'atl_controller.dart';
import 'providers/account_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
