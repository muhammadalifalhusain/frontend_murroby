import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // tambahkan ini
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 

  await initializeDateFormatting('id_ID', null); 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PPATQ RAUDLATUL FALAH',
      home: SplashScreen(),
    );
  }
}
