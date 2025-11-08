import 'package:flutter/material.dart';
import 'atl_controller.dart';
import 'database/db_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inizializza il database
  await DB.initialize();
  
  runApp(const AtlController());
}
