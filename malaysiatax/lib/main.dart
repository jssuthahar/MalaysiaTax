import 'package:flutter/material.dart';
import 'home_page.dart';
import 'tax_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TaxConfig.loadConfig(); // load tax slabs from JSON
  runApp(const MalaysiaTaxApp());
}

class MalaysiaTaxApp extends StatelessWidget {
  const MalaysiaTaxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Malaysia Tax Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}
